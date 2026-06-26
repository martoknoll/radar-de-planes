-- Agrega columna de descripción/bio al perfil del organizador.
-- Ejecutar después de supabase-interactions.sql.

alter table profiles add column if not exists bio text;
