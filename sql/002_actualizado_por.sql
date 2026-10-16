-- Análisis de Cabida · registra quién hizo la última edición o baja de cada lote.
-- Correr una vez en el SQL Editor (se puede repetir sin problema).
alter table public.lotes add column if not exists actualizado_por text check (char_length(actualizado_por) <= 120);
