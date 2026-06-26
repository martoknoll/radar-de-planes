-- Tabla de interacciones (me interesa / voy) sincronizada con Supabase,
-- para que los organizadores puedan ver cuánta gente está interesada o va
-- a sus propios eventos. Ejecutar después de supabase-roles-events.sql.

create table if not exists interactions (
  user_id uuid not null references profiles(id) on delete cascade,
  event_id uuid not null references events(id) on delete cascade,
  interested boolean not null default false,
  going boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key (user_id, event_id)
);

alter table interactions enable row level security;

drop policy if exists interactions_select_own_or_organizer on interactions;
create policy interactions_select_own_or_organizer on interactions for select
  using (
    user_id = auth.uid()
    or exists(select 1 from events where events.id = interactions.event_id and events.created_by = auth.uid())
  );

drop policy if exists interactions_insert_own on interactions;
create policy interactions_insert_own on interactions for insert
  with check (user_id = auth.uid());

drop policy if exists interactions_update_own on interactions;
create policy interactions_update_own on interactions for update
  using (user_id = auth.uid());

drop policy if exists interactions_delete_own on interactions;
create policy interactions_delete_own on interactions for delete
  using (user_id = auth.uid());
