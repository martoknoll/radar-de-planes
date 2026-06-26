-- Agrega Facebook al perfil del organizador.

alter table profiles add column if not exists facebook text;
