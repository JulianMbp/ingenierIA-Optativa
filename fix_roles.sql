-- Script para crear roles si no existen
-- Ejecutar en el SQL Editor de Supabase

-- Crear tabla de roles si no existe
CREATE TABLE IF NOT EXISTS roles (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar roles si no existen
INSERT INTO roles (name, description) VALUES
('estructura', 'Encargado de estructura'),
('plomeria', 'Encargado de plomería'),
('electricidad', 'Encargado de electricidad'),
('mamposteria', 'Encargado de mampostería'),
('acabados', 'Encargado de acabados'),
('supervisor', 'Supervisor general de obra'),
('administrador', 'Administrador del sistema')
ON CONFLICT (name) DO NOTHING;

-- Verificar que los roles se crearon
SELECT * FROM roles ORDER BY name;
