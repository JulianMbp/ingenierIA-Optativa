-- Script SQL para Supabase - Sistema de Gestión de Obra
-- Basado en las ideas clave de la entrevista

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabla de roles de especialidades
CREATE TABLE IF NOT EXISTS roles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar roles por defecto basados en las especialidades mencionadas
INSERT INTO roles (name, description) VALUES
('estructura', 'Encargado de estructura'),
('plomeria', 'Encargado de plomería'),
('electricidad', 'Encargado de electricidad'),
('mamposteria', 'Encargado de mampostería'),
('acabados', 'Encargado de acabados'),
('supervisor', 'Supervisor general de obra'),
('administrador', 'Administrador del sistema')
ON CONFLICT (name) DO NOTHING;

-- Tabla de usuarios extendida (se conecta con auth.users de Supabase)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    role_id UUID REFERENCES roles(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de proyectos/obras
CREATE TABLE IF NOT EXISTS projects (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(15,2),
    status VARCHAR(50) DEFAULT 'activo',
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de trabajadores
CREATE TABLE IF NOT EXISTS workers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    full_name VARCHAR(255) NOT NULL,
    document_number VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    role_id UUID REFERENCES roles(id),
    project_id UUID REFERENCES projects(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de control de asistencia
CREATE TABLE IF NOT EXISTS attendance (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    worker_id UUID REFERENCES workers(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id),
    date DATE NOT NULL,
    check_in TIME,
    check_out TIME,
    hours_worked DECIMAL(4,2),
    is_present BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(worker_id, date)
);

-- Tabla de materiales
CREATE TABLE IF NOT EXISTS materials (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    unit VARCHAR(50) NOT NULL, -- unidad de medida (kg, m, pza, etc.)
    unit_price DECIMAL(10,2),
    current_stock DECIMAL(10,2) DEFAULT 0,
    min_stock DECIMAL(10,2) DEFAULT 0,
    supplier VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de presupuestos por especialidad
CREATE TABLE IF NOT EXISTS budgets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    role_id UUID REFERENCES roles(id),
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(15,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    completed_quantity DECIMAL(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de reportes diarios
CREATE TABLE IF NOT EXISTS daily_reports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    role_id UUID REFERENCES roles(id),
    reported_by UUID REFERENCES auth.users(id),
    date DATE NOT NULL,
    work_description TEXT NOT NULL,
    progress_percentage DECIMAL(5,2),
    materials_used JSONB, -- JSON con materiales utilizados
    issues TEXT,
    next_day_plan TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de exámenes médicos y de altura
CREATE TABLE IF NOT EXISTS medical_exams (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    worker_id UUID REFERENCES workers(id) ON DELETE CASCADE,
    exam_type VARCHAR(50) NOT NULL, -- 'medico', 'altura'
    exam_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    is_valid BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de formatos ATS (Análisis de Trabajo Seguro)
CREATE TABLE IF NOT EXISTS ats_forms (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    date DATE NOT NULL,
    filled_by UUID REFERENCES auth.users(id),
    safety_conditions TEXT,
    equipment_check JSONB, -- JSON con verificación de equipos
    incidents TEXT,
    recommendations TEXT,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de reportes de accidentes/incidentes
CREATE TABLE IF NOT EXISTS incident_reports (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    project_id UUID REFERENCES projects(id),
    worker_id UUID REFERENCES workers(id),
    incident_type VARCHAR(50) NOT NULL, -- 'accidente', 'incidente'
    date DATE NOT NULL,
    time TIME,
    description TEXT NOT NULL,
    severity VARCHAR(50), -- 'leve', 'moderado', 'grave'
    actions_taken TEXT,
    reported_to_arl BOOLEAN DEFAULT false,
    created_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para actualizar updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workers_updated_at BEFORE UPDATE ON workers FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_materials_updated_at BEFORE UPDATE ON materials FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_budgets_updated_at BEFORE UPDATE ON budgets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_daily_reports_updated_at BEFORE UPDATE ON daily_reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_medical_exams_updated_at BEFORE UPDATE ON medical_exams FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_ats_forms_updated_at BEFORE UPDATE ON ats_forms FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_incident_reports_updated_at BEFORE UPDATE ON incident_reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Políticas de seguridad RLS (Row Level Security)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE workers ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE medical_exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE ats_forms ENABLE ROW LEVEL SECURITY;
ALTER TABLE incident_reports ENABLE ROW LEVEL SECURITY;

-- Políticas básicas (se pueden ajustar según necesidades específicas)
CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Authenticated users can view projects" ON projects FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can insert projects" ON projects FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Función para crear perfil automáticamente al registrarse
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (NEW.id, NEW.email, NEW.raw_user_meta_data->>'full_name');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear perfil automáticamente
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
