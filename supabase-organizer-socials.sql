-- Agrega redes sociales al perfil del organizador.
-- Ejecutar después de supabase-organizer-bio.sql.

alter table profiles add column if not exists instagram text;
alter table profiles add column if not exists twitter text;
alter table profiles add column if not exists website text;
