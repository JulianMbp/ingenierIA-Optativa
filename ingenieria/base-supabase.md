-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.asistencias (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  obra_id uuid,
  usuario_id uuid NOT NULL,
  fecha date DEFAULT now(),
  estado text CHECK (estado = ANY (ARRAY['presente'::text, 'ausente'::text, 'justificado'::text])),
  observaciones text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT asistencias_pkey PRIMARY KEY (id),
  CONSTRAINT asistencias_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id)
);
CREATE TABLE public.bitacoras (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  obra_id uuid,
  usuario_id uuid NOT NULL,
  descripcion text,
  avance_porcentaje numeric,
  archivos ARRAY,
  fecha date DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT bitacoras_pkey PRIMARY KEY (id),
  CONSTRAINT bitacoras_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id)
);
CREATE TABLE public.documentos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  obra_id uuid,
  tipo text,
  nombre text,
  url text,
  version text,
  usuario_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT documentos_pkey PRIMARY KEY (id),
  CONSTRAINT documentos_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id)
);
CREATE TABLE public.materiales (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  obra_id uuid,
  nombre text NOT NULL,
  categoria text,
  cantidad numeric,
  unidad text,
  proveedor text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT materiales_pkey PRIMARY KEY (id),
  CONSTRAINT materiales_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id)
);
CREATE TABLE public.obras (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  nombre text NOT NULL,
  direccion text,
  estado text DEFAULT 'activa'::text,
  fecha_inicio date,
  fecha_fin date,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT obras_pkey PRIMARY KEY (id)
);
CREATE TABLE public.presupuestos (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  obra_id uuid,
  partida text NOT NULL,
  unidad text,
  cantidad numeric,
  valor_unitario numeric,
  valor_ejecutado numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT presupuestos_pkey PRIMARY KEY (id),
  CONSTRAINT presupuestos_obra_id_fkey FOREIGN KEY (obra_id) REFERENCES public.obras(id)
);

-- 1. Crear tabla users
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Insertar usuarios de prueba (con emails que coincidan con PostgreSQL)
INSERT INTO public.users (email) VALUES
  ('admin.general@ingenieria.com'),
  ('admin.obra1@ingenieria.com'),
  ('admin.obra2@ingenieria.com'),
  ('encargado.area1@ingenieria.com'),
  ('encargado.area2@ingenieria.com'),
  ('obrero.1@ingenieria.com'),
  ('obrero.2@ingenieria.com'),
  ('sst.1@ingenieria.com'),
  ('compras.1@ingenieria.com'),
  ('rrhh.1@ingenieria.com'),
  ('consultor.1@ingenieria.com')
ON CONFLICT (email) DO NOTHING;

-- 3. Verificar que se insertaron correctamente
SELECT id, email FROM public.users ORDER BY email;

-- ============================================================================
-- SCRIPT DE CONFIGURACIÓN SUPABASE - MULTI-TENANCY INGENIERIA
-- ============================================================================
-- Este script configura las tablas necesarias para multi-tenancy en Supabase
-- Incluye usuarios REALES de Supabase Auth, obras y relaciones obra_usuario
-- ============================================================================

-- Sección 1-3: Crear las tablas principales
-- ----------------------------------------------------------------------------

-- 1. Tabla de usuarios (sincronizada con Supabase Auth)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Tabla de obras (proyectos de construcción)
CREATE TABLE IF NOT EXISTS public.obras (
  id UUID PRIMARY KEY,
  nombre VARCHAR(255) NOT NULL,
  direccion TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Tabla de relación usuario-obra (multi-tenancy)
CREATE TABLE IF NOT EXISTS public.obra_usuario (
  id SERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  obra_id UUID NOT NULL REFERENCES public.obras(id) ON DELETE CASCADE,
  role_name VARCHAR(100),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, obra_id)
);

-- Sección 4: Crear índices para optimización de consultas
-- ----------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_obra_usuario_user_id ON public.obra_usuario(user_id);
CREATE INDEX IF NOT EXISTS idx_obra_usuario_obra_id ON public.obra_usuario(obra_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- Sección 5: Habilitar Row Level Security (RLS)
-- ----------------------------------------------------------------------------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.obras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.obra_usuario ENABLE ROW LEVEL SECURITY;

-- Sección 6-8: Crear políticas de RLS
-- ----------------------------------------------------------------------------

-- 6. Política para usuarios: ver solo su propio perfil
DROP POLICY IF EXISTS "Users can view own profile" ON public.users;
CREATE POLICY "Users can view own profile" 
  ON public.users 
  FOR SELECT 
  USING (auth.uid() = id);

-- 7. Política para obras: ver solo obras asignadas
DROP POLICY IF EXISTS "Users can view assigned obras" ON public.obras;
CREATE POLICY "Users can view assigned obras" 
  ON public.obras 
  FOR SELECT 
  USING (
    id IN (
      SELECT obra_id 
      FROM public.obra_usuario 
      WHERE user_id = auth.uid()
    )
  );

-- 8. Política para obra_usuario: ver solo asignaciones propias
DROP POLICY IF EXISTS "Users can view own obra assignments" ON public.obra_usuario;
CREATE POLICY "Users can view own obra assignments" 
  ON public.obra_usuario 
  FOR SELECT 
  USING (user_id = auth.uid());

-- Sección 9: Insertar usuarios (UUIDs REALES de Supabase Auth)
-- ----------------------------------------------------------------------------
INSERT INTO public.users (id, email) VALUES
  ('9aa0276b-9779-4202-a71c-4fd48440b309', 'admin.general@ingenieria.com'),
  ('44122da5-6a3b-4200-826f-17479c824756', 'admin.obra1@ingenieria.com'),
  ('7eed50f3-9c04-44f4-9126-2f0f0ff4b841', 'admin.obra2@ingenieria.com'),
  ('5662d520-2e79-4ac3-9704-5d130777da51', 'compras.1@ingenieria.com'),
  ('4bfb9996-4c1f-421f-a8d6-8c05bde8e3f0', 'consultor.1@ingenieria.com'),
  ('96a89fb4-bcec-4658-92e7-595b524a59a0', 'encargado.area1@ingenieria.com'),
  ('06c6e9ba-6243-4848-b596-ec9224d1c1da', 'encargado.area2@ingenieria.com'),
  ('bbb62ea2-ffc6-4aeb-ba21-a310187b5d2e', 'obrero.1@ingenieria.com'),
  ('3b77715b-6bc3-48b5-859d-029be9a0744c', 'obrero.2@ingenieria.com'),
  ('3f0aac8b-f27b-46e5-8504-c11b153ec6e9', 'rrhh.1@ingenieria.com'),
  ('7f4eabaa-b2a8-42ae-bbb2-aa05f82364ca', 'sst.1@ingenieria.com')
ON CONFLICT (id) DO NOTHING;

-- Sección 10: Insertar las 4 obras de prueba
-- ----------------------------------------------------------------------------
INSERT INTO public.obras (id, nombre, direccion) VALUES
  ('c13e4b9e-41f1-4273-a18e-c26699edab61', 'Edificio Central Plaza', 'Calle 100 #15-20, Bogotá D.C.'),
  ('b46ecadd-3277-4fc9-a62e-d48e2fbf491e', 'Torre Empresarial Norte', 'Av. El Poblado #43-50, Medellín'),
  ('887f3d9d-fc67-455e-9e17-824275f8c763', 'Conjunto Residencial Alameda', 'Calle 170 #54-32, Bogotá D.C.'),
  ('759199e3-7d40-44d4-9083-928ff05c219e', 'Centro Comercial Portal del Sur', 'Autopista Sur Km 5, Bogotá D.C.')
ON CONFLICT (id) DO NOTHING;

-- Sección 11: Asignar usuarios a obras (multi-tenancy con UUIDs REALES)
-- ----------------------------------------------------------------------------
INSERT INTO public.obra_usuario (user_id, obra_id, role_name) VALUES
  -- Admin General tiene acceso a TODAS las obras
  ('9aa0276b-9779-4202-a71c-4fd48440b309', 'c13e4b9e-41f1-4273-a18e-c26699edab61', 'Admin General'),
  ('9aa0276b-9779-4202-a71c-4fd48440b309', 'b46ecadd-3277-4fc9-a62e-d48e2fbf491e', 'Admin General'),
  ('9aa0276b-9779-4202-a71c-4fd48440b309', '887f3d9d-fc67-455e-9e17-824275f8c763', 'Admin General'),
  ('9aa0276b-9779-4202-a71c-4fd48440b309', '759199e3-7d40-44d4-9083-928ff05c219e', 'Admin General'),
  
  -- Obra 1: Edificio Central Plaza (admin.obra1, compras.1, consultor.1)
  ('44122da5-6a3b-4200-826f-17479c824756', 'c13e4b9e-41f1-4273-a18e-c26699edab61', 'Admin Obra'),
  ('5662d520-2e79-4ac3-9704-5d130777da51', 'c13e4b9e-41f1-4273-a18e-c26699edab61', 'Compras'),
  ('4bfb9996-4c1f-421f-a8d6-8c05bde8e3f0', 'c13e4b9e-41f1-4273-a18e-c26699edab61', 'Consultor'),
  
  -- Obra 2: Torre Empresarial Norte (admin.obra2, encargado.area1, obrero.1)
  ('7eed50f3-9c04-44f4-9126-2f0f0ff4b841', 'b46ecadd-3277-4fc9-a62e-d48e2fbf491e', 'Admin Obra'),
  ('96a89fb4-bcec-4658-92e7-595b524a59a0', 'b46ecadd-3277-4fc9-a62e-d48e2fbf491e', 'Encargado Área'),
  ('bbb62ea2-ffc6-4aeb-ba21-a310187b5d2e', 'b46ecadd-3277-4fc9-a62e-d48e2fbf491e', 'Obrero'),
  
  -- Obra 3: Conjunto Residencial Alameda (encargado.area2, obrero.2, rrhh.1)
  ('06c6e9ba-6243-4848-b596-ec9224d1c1da', '887f3d9d-fc67-455e-9e17-824275f8c763', 'Encargado Área'),
  ('3b77715b-6bc3-48b5-859d-029be9a0744c', '887f3d9d-fc67-455e-9e17-824275f8c763', 'Obrero'),
  ('3f0aac8b-f27b-46e5-8504-c11b153ec6e9', '887f3d9d-fc67-455e-9e17-824275f8c763', 'RRHH'),
  
  -- Obra 4: Centro Comercial Portal del Sur (sst.1)
  ('7f4eabaa-b2a8-42ae-bbb2-aa05f82364ca', '759199e3-7d40-44d4-9083-928ff05c219e', 'SST')
ON CONFLICT (user_id, obra_id) DO NOTHING;

-- Sección 12: Verificación final
-- ----------------------------------------------------------------------------
-- Esta consulta muestra todos los usuarios y sus obras asignadas
SELECT 
  u.email,
  o.nombre AS obra,
  ou.role_name AS rol
FROM public.users u
LEFT JOIN public.obra_usuario ou ON u.id = ou.user_id
LEFT JOIN public.obras o ON ou.obra_id = o.id
ORDER BY u.email, o.nombre;
