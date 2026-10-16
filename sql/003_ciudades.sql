-- Análisis de Cabida · cartera por ciudad. Correr una vez en el SQL Editor (se puede repetir).
-- Los lotes que ya existen quedan en 'cordoba'.
alter table public.lotes add column if not exists ciudad text not null default 'cordoba' check (ciudad ~ '^[a-z0-9-]{2,40}$');
create index if not exists lotes_ciudad_idx on public.lotes (ciudad);
drop index if exists public.lotes_nomenclatura_activos_uq;
create unique index if not exists lotes_nomenclatura_ciudad_uq on public.lotes (empresa, ciudad, nomenclatura) where nomenclatura is not null and not eliminado;
