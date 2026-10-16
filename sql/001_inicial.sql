-- Análisis de Cabida · esquema del Supabase de Grupo ECIPSA
-- SIN LOGIN: la página usa la clave anon y puede leer, agregar y editar la cartera.
-- Protecciones: no se puede borrar (los lotes se dan de baja con eliminado = true y se recuperan desde acá),
-- las notas son solo de alta, y todo queda en una única empresa 'ecipsa'.
-- Se puede correr dos veces sin romper nada.

-- ───────────── Empresas ─────────────
create table if not exists public.empresas (
  id text primary key check (id ~ '^[a-z0-9_-]{2,40}$'),
  nombre text not null check (char_length(nombre) <= 120),
  created_at timestamptz not null default now()
);
alter table public.empresas enable row level security;
revoke all on public.empresas from anon, authenticated;
grant select on public.empresas to anon, authenticated;
drop policy if exists empresas_select on public.empresas;
create policy empresas_select on public.empresas for select to anon, authenticated using (true);

insert into public.empresas (id, nombre) values ('ecipsa', 'Grupo ECIPSA') on conflict (id) do nothing;

-- ───────────── Cartera de lotes ─────────────
create table if not exists public.lotes (
  id uuid primary key default gen_random_uuid(),
  empresa text not null default 'ecipsa' references public.empresas(id),
  creado_por uuid default auth.uid(),
  creado_por_email text check (char_length(creado_por_email) <= 120),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  nombre text check (char_length(nombre) <= 200),
  nomenclatura text check (char_length(nomenclatura) <= 40),
  nom_muni text check (char_length(nom_muni) <= 40),
  cuenta text check (char_length(cuenta) <= 40),
  lat double precision not null check (lat between -90 and 90),
  lon double precision not null check (lon between -180 and 180),
  direccion text check (char_length(direccion) <= 300),
  superficie numeric,
  zona text check (char_length(zona) <= 200),
  norma text check (char_length(norma) <= 300),
  estado text not null default 'nuevo'
    check (estado in ('nuevo', 'en_analisis', 'oferta', 'reservado', 'comprado', 'descartado')),
  precio numeric check (precio is null or precio >= 0),
  moneda text not null default 'USD' check (moneda in ('USD', 'ARS')),
  tipo_cambio numeric check (tipo_cambio is null or tipo_cambio > 0),
  eficiencia numeric not null default 0.8 check (eficiencia > 0 and eficiencia <= 1),
  cabida_m2 numeric,
  unidades integer,
  etiquetas text[] not null default '{}',
  analisis jsonb,
  escenarios jsonb not null default '[]'::jsonb,
  eliminado boolean not null default false,
  actualizado_por text check (char_length(actualizado_por) <= 120)
);
alter table public.lotes add column if not exists actualizado_por text check (char_length(actualizado_por) <= 120);
alter table public.lotes add column if not exists ciudad text not null default 'cordoba' check (ciudad ~ '^[a-z0-9-]{2,40}$');
create index if not exists lotes_ciudad_idx on public.lotes (ciudad);

create table if not exists public.lote_notas (
  id uuid primary key default gen_random_uuid(),
  lote_id uuid not null references public.lotes(id) on delete cascade,
  empresa text not null default 'ecipsa' references public.empresas(id),
  autor uuid default auth.uid(),
  autor_email text check (char_length(autor_email) <= 120),
  created_at timestamptz not null default now(),
  tipo text not null default 'nota' check (tipo in ('nota', 'estado', 'precio', 'sistema')),
  texto text not null check (char_length(texto) between 1 and 4000)
);

create index if not exists lotes_empresa_idx on public.lotes (empresa);
drop index if exists public.lotes_empresa_nomenclatura_uq;
drop index if exists public.lotes_nomenclatura_activos_uq;
create unique index if not exists lotes_nomenclatura_ciudad_uq on public.lotes (empresa, ciudad, nomenclatura) where nomenclatura is not null and not eliminado;
create index if not exists lote_notas_lote_idx on public.lote_notas (lote_id, created_at desc);
create index if not exists lote_notas_empresa_idx on public.lote_notas (empresa);

create or replace function public.lotes_touch()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;
revoke all on function public.lotes_touch() from public, anon, authenticated;
drop trigger if exists lotes_touch on public.lotes;
create trigger lotes_touch before update on public.lotes for each row execute function public.lotes_touch();

alter table public.lotes enable row level security;
alter table public.lote_notas enable row level security;
revoke all on public.lotes from anon, authenticated;
revoke all on public.lote_notas from anon, authenticated;
grant select, insert, update on public.lotes to anon, authenticated;   -- sin delete
grant select, insert on public.lote_notas to anon, authenticated;      -- sin update ni delete

drop policy if exists lotes_select on public.lotes;
drop policy if exists lotes_insert on public.lotes;
drop policy if exists lotes_update on public.lotes;
drop policy if exists lotes_delete on public.lotes;
create policy lotes_select on public.lotes for select to anon, authenticated using (empresa = 'ecipsa');
create policy lotes_insert on public.lotes for insert to anon, authenticated with check (empresa = 'ecipsa' and not eliminado);
create policy lotes_update on public.lotes for update to anon, authenticated using (empresa = 'ecipsa') with check (empresa = 'ecipsa');

drop policy if exists notas_select on public.lote_notas;
drop policy if exists notas_insert on public.lote_notas;
drop policy if exists notas_delete on public.lote_notas;
create policy notas_select on public.lote_notas for select to anon, authenticated using (empresa = 'ecipsa');
create policy notas_insert on public.lote_notas for insert to anon, authenticated
  with check (empresa = 'ecipsa' and exists (select 1 from public.lotes l where l.id = lote_id and l.empresa = 'ecipsa'));

-- Recuperar un lote dado de baja:
--   select id, nombre, updated_at from public.lotes where eliminado order by updated_at desc;
--   update public.lotes set eliminado = false where id = '...';
