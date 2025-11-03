-- =========================================================
-- 🚧 INGENIERIA - BASE DE DATOS OPERACIONAL (SUPABASE)
-- =========================================================
-- Fecha: 2025-11-02
-- Autor: Julian Bastidas
-- Descripción:
-- Estructura base para la gestión de obras, materiales,
-- bitácoras, presupuestos, documentos, asistencias, etc.
-- =========================================================

-- =========================================================
-- 1️⃣ CONFIGURACIONES INICIALES
-- =========================================================
create extension if not exists "uuid-ossp";

-- =========================================================
-- 2️⃣ TABLA: OBRAS
-- =========================================================
create table public.obras (
  id uuid primary key default uuid_generate_v4(),
  nombre text not null,
  direccion text,
  estado text default 'activa',
  fecha_inicio date,
  fecha_fin date,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

comment on table public.obras is 'Tabla principal de obras o proyectos gestionados por IngenierIA.';

-- =========================================================
-- 3️⃣ TABLA: MATERIALES
-- =========================================================
create table public.materiales (
  id uuid primary key default uuid_generate_v4(),
  obra_id uuid references public.obras(id) on delete cascade,
  nombre text not null,
  categoria text,
  cantidad numeric,
  unidad text,
  proveedor text,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

comment on table public.materiales is 'Materiales asociados a cada obra.';

-- =========================================================
-- 4️⃣ TABLA: BITACORAS
-- =========================================================
create table public.bitacoras (
  id uuid primary key default uuid_generate_v4(),
  obra_id uuid references public.obras(id) on delete cascade,
  usuario_id uuid not null, -- ID del microservicio de auth
  descripcion text,
  avance_porcentaje numeric,
  archivos text[],
  fecha date default now(),
  created_at timestamp with time zone default now()
);

comment on table public.bitacoras is 'Bitácoras de avance técnico y operativo de las obras.';

-- =========================================================
-- 5️⃣ TABLA: ASISTENCIAS
-- =========================================================
create table public.asistencias (
  id uuid primary key default uuid_generate_v4(),
  obra_id uuid references public.obras(id) on delete cascade,
  usuario_id uuid not null,
  fecha date default now(),
  estado text check (estado in ('presente', 'ausente', 'justificado')),
  observaciones text,
  created_at timestamp with time zone default now()
);

comment on table public.asistencias is 'Control diario de asistencia de los trabajadores de una obra.';

-- =========================================================
-- 6️⃣ TABLA: PRESUPUESTOS
-- =========================================================
create table public.presupuestos (
  id uuid primary key default uuid_generate_v4(),
  obra_id uuid references public.obras(id) on delete cascade,
  partida text not null,
  unidad text,
  cantidad numeric,
  valor_unitario numeric,
  valor_ejecutado numeric default 0,
  created_at timestamp with time zone default now()
);

comment on table public.presupuestos is 'Presupuesto por partidas técnicas de cada obra.';

-- =========================================================
-- 7️⃣ TABLA: DOCUMENTOS
-- =========================================================
create table public.documentos (
  id uuid primary key default uuid_generate_v4(),
  obra_id uuid references public.obras(id) on delete cascade,
  tipo text,
  nombre text,
  url text,
  version text,
  usuario_id uuid not null,
  created_at timestamp with time zone default now()
);

comment on table public.documentos is 'Documentos técnicos y administrativos asociados a las obras.';

-- =========================================================
-- 8️⃣ VISTAS Y FUNCIONES AUXILIARES
-- =========================================================
create or replace view public.v_materiales_por_obra as
select
  o.id as obra_id,
  o.nombre as obra_nombre,
  m.id as material_id,
  m.nombre as material_nombre,
  m.cantidad,
  m.unidad,
  m.categoria,
  m.proveedor
from public.obras o
join public.materiales m on m.obra_id = o.id;

comment on view public.v_materiales_por_obra is 'Vista que consolida materiales por obra.';

-- =========================================================
-- 9️⃣ FUNCIONES RPC (para uso desde Flutter)
-- =========================================================
create or replace function public.get_materiales_by_obra(obra uuid)
returns setof public.materiales
language sql
security definer
as $$
  select * from public.materiales where obra_id = obra;
$$;

create or replace function public.get_bitacoras_by_obra(obra uuid)
returns setof public.bitacoras
language sql
security definer
as $$
  select * from public.bitacoras where obra_id = obra order by fecha desc;
$$;

create or replace function public.get_asistencias_by_obra(obra uuid)
returns setof public.asistencias
language sql
security definer
as $$
  select * from public.asistencias where obra_id = obra;
$$;

-- =========================================================
-- 🔟 HABILITACIÓN DE RLS
-- =========================================================
alter table public.obras enable row level security;
alter table public.materiales enable row level security;
alter table public.bitacoras enable row level security;
alter table public.asistencias enable row level security;
alter table public.presupuestos enable row level security;
alter table public.documentos enable row level security;

-- Nota: Las políticas específicas de RLS se agregan
-- en el script 02_rls_multitenant.sql


-- =========================================================
-- 🔒 INGENIERIA - RLS MULTI-TENANT POR OBRA (JWT)
-- =========================================================
-- Fecha: 2025-11-02
-- Autor: Julian Bastidas
-- Descripción:
-- Políticas de Row Level Security basadas en el claim 'obra_id'
-- del JWT emitido por el microservicio de autenticación NestJS.
-- =========================================================

-- Elimina políticas genéricas anteriores
drop policy if exists "Lectura permitida para todos los usuarios autenticados" on public.obras;
drop policy if exists "Lectura permitida en materiales" on public.materiales;
drop policy if exists "Lectura permitida en bitacoras" on public.bitacoras;

-- =========================================================
-- 1️⃣ POLÍTICAS DE LECTURA (SELECT)
-- =========================================================
create policy "Solo ver obras asignadas"
on public.obras
for select
using (
  id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

create policy "Solo ver materiales de su obra"
on public.materiales
for select
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

create policy "Solo ver bitácoras de su obra"
on public.bitacoras
for select
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

create policy "Solo ver asistencias de su obra"
on public.asistencias
for select
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

create policy "Solo ver presupuestos de su obra"
on public.presupuestos
for select
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

create policy "Solo ver documentos de su obra"
on public.documentos
for select
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

-- =========================================================
-- 2️⃣ POLÍTICAS DE INSERCIÓN (INSERT)
-- =========================================================
create policy "Insertar solo en su obra"
on public.materiales
for insert
with check (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

create policy "Insertar bitácoras solo en su obra"
on public.bitacoras
for insert
with check (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

create policy "Insertar asistencias solo en su obra"
on public.asistencias
for insert
with check (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

-- =========================================================
-- 3️⃣ POLÍTICAS DE ACTUALIZACIÓN Y ELIMINACIÓN (opcional)
-- =========================================================
create policy "Actualizar solo registros de su obra"
on public.materiales
for update
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
)
with check (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);

create policy "Eliminar solo registros de su obra"
on public.materiales
for delete
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);
