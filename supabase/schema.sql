-- Radar de Planes: esquema inicial de usuarios y preferencias de categorías.
-- Corré esto una vez en el SQL Editor de tu proyecto de Supabase
-- (Project > SQL Editor > New query > pegar > Run).

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.category_preferences (
  user_id uuid not null references public.profiles(id) on delete cascade,
  category_id text not null,
  primary key (user_id, category_id)
);

alter table public.profiles enable row level security;
alter table public.category_preferences enable row level security;

create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);

create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);

create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);

create policy "prefs_select_own" on public.category_preferences
  for select using (auth.uid() = user_id);

create policy "prefs_insert_own" on public.category_preferences
  for insert with check (auth.uid() = user_id);

create policy "prefs_delete_own" on public.category_preferences
  for delete using (auth.uid() = user_id);
