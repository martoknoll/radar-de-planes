-- Conecta las Edge Functions notify-new-event y weekly-digest con la base.
-- Correr DESPUÉS de desplegar ambas funciones (ver instrucciones-emails.md).
--
-- IMPORTANTE: reemplazá los placeholders <PROJECT_REF> y <SERVICE_ROLE_KEY> antes de
-- ejecutar, y NO subas este archivo con los valores reales a ningún repositorio público.

create extension if not exists pg_net;
create extension if not exists pg_cron;

-- 1) Trigger: al insertar un evento, llama a notify-new-event con su id.
create or replace function trigger_notify_new_event() returns trigger
language plpgsql as $$
begin
  perform net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/notify-new-event',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <SERVICE_ROLE_KEY>'
    ),
    body := jsonb_build_object('event_id', new.id)
  );
  return new;
end;
$$;

drop trigger if exists trg_notify_new_event on events;
create trigger trg_notify_new_event
  after insert on events
  for each row execute function trigger_notify_new_event();

-- 2) Cron: todos los lunes a las 09:00 (Argentina, UTC-3 = 12:00 UTC) llama a weekly-digest.
select cron.schedule(
  'weekly-digest-monday',
  '0 12 * * 1',
  $$
  select net.http_post(
    url := 'https://<PROJECT_REF>.supabase.co/functions/v1/weekly-digest',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer <SERVICE_ROLE_KEY>'
    ),
    body := '{}'::jsonb
  );
  $$
);

-- Para desprogramar el cron si hace falta:
-- select cron.unschedule('weekly-digest-monday');
