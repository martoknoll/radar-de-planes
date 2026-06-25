-- Roles de usuario + tabla de eventos compartida, con RLS.
-- Ejecutar este script completo en el SQL editor de Supabase.

-- 1) Roles y verificación en profiles
alter table profiles add column if not exists role text not null default 'user';
alter table profiles add column if not exists verified boolean not null default false;

alter table profiles drop constraint if exists profiles_role_check;
alter table profiles add constraint profiles_role_check check (role in ('user','organizer','admin'));

-- 2) Tabla de eventos (reemplaza el localStorage del MVP)
create table if not exists events (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  category text not null,
  lat double precision not null,
  lng double precision not null,
  date date not null,
  time text not null,
  price text not null,
  address text not null,
  organizer text not null,
  description text not null,
  img text,
  created_by uuid references profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

-- 3) Funciones de soporte para las policies
create or replace function is_admin() returns boolean
language sql security definer stable as $$
  select exists(select 1 from profiles where id = auth.uid() and role = 'admin');
$$;

create or replace function can_create_events() returns boolean
language sql security definer stable as $$
  select exists(select 1 from profiles where id = auth.uid() and role in ('organizer','admin'));
$$;

-- 4) Evitar que un usuario se auto-asigne un rol o verificación
create or replace function prevent_role_escalation() returns trigger
language plpgsql as $$
begin
  if auth.uid() is not null and not is_admin() then
    new.role := old.role;
    new.verified := old.verified;
  end if;
  return new;
end;
$$;

drop trigger if exists trg_prevent_role_escalation on profiles;
create trigger trg_prevent_role_escalation
  before update on profiles
  for each row execute function prevent_role_escalation();

-- 5) RLS en profiles
alter table profiles enable row level security;

drop policy if exists profiles_select_all on profiles;
create policy profiles_select_all on profiles for select using (true);

drop policy if exists profiles_insert_own on profiles;
create policy profiles_insert_own on profiles for insert with check (auth.uid() = id);

drop policy if exists profiles_update_own_or_admin on profiles;
create policy profiles_update_own_or_admin on profiles for update
  using (auth.uid() = id or is_admin());

-- 6) RLS en events
alter table events enable row level security;

drop policy if exists events_select_all on events;
create policy events_select_all on events for select using (true);

drop policy if exists events_insert_organizer on events;
create policy events_insert_organizer on events for insert
  with check (can_create_events() and created_by = auth.uid());

drop policy if exists events_update_owner_or_admin on events;
create policy events_update_owner_or_admin on events for update
  using (is_admin() or created_by = auth.uid());

drop policy if exists events_delete_owner_or_admin on events;
create policy events_delete_owner_or_admin on events for delete
  using (is_admin() or created_by = auth.uid());

-- 7) Para promover el primer admin a mano (reemplazar el email):
-- update profiles set role = 'admin' where id = (select id from auth.users where email = 'tu-email@ejemplo.com');
