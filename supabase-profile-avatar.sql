-- Agrega foto de perfil y nombre editable a los usuarios.
-- Correr esto en el SQL Editor de Supabase (Project > SQL Editor).

alter table public.profiles
  add column if not exists avatar_url text;

-- Bucket público para fotos de perfil.
insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do nothing;

-- Cualquiera puede ver las fotos (son públicas, como un avatar normal).
create policy if not exists "Avatares: lectura pública"
on storage.objects for select
using (bucket_id = 'avatars');

-- Cada usuario solo puede subir/actualizar/borrar su propia foto,
-- guardada en la carpeta `<user_id>/...` dentro del bucket.
create policy if not exists "Avatares: subir la propia"
on storage.objects for insert
with check (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

create policy if not exists "Avatares: actualizar la propia"
on storage.objects for update
using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);

create policy if not exists "Avatares: borrar la propia"
on storage.objects for delete
using (bucket_id = 'avatars' and auth.uid()::text = (storage.foldername(name))[1]);
