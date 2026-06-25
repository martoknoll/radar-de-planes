-- Tabla de "seguir" organizadores/admins + RLS.
-- Ejecutar en el SQL editor de Supabase, después de supabase-roles-events.sql.

create table if not exists follows (
  follower_id uuid not null references profiles(id) on delete cascade,
  followed_id uuid not null references profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (follower_id, followed_id),
  constraint follows_no_self check (follower_id <> followed_id)
);

alter table follows enable row level security;

drop policy if exists follows_select_own on follows;
create policy follows_select_own on follows for select
  using (follower_id = auth.uid() or followed_id = auth.uid());

drop policy if exists follows_insert_own on follows;
create policy follows_insert_own on follows for insert
  with check (
    follower_id = auth.uid()
    and exists(select 1 from profiles where id = followed_id and role in ('organizer','admin'))
  );

drop policy if exists follows_delete_own on follows;
create policy follows_delete_own on follows for delete
  using (follower_id = auth.uid());
