-- Agrega nombre, apellido y nombre de usuario a los perfiles,
-- para no tener que mostrar el email de nadie en la app.
-- Correr esto en el SQL Editor de Supabase (Project > SQL Editor).

alter table public.profiles
  add column if not exists first_name text,
  add column if not exists last_name text,
  add column if not exists username text;

-- Usernames únicos, sin importar mayúsculas/minúsculas.
create unique index if not exists profiles_username_unique
  on public.profiles (lower(username));
