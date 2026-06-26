-- Agrega link de entradas/formulario al evento.

alter table events add column if not exists ticket_url text;
