-- Agrega el tipo de espacio al perfil de organizadores.
-- Correrlo una vez en el SQL editor de Supabase.

alter table profiles
  add column if not exists venue_type text;
