-- Script para arreglar el trigger de creación de perfiles
-- Ejecutar en el SQL Editor de Supabase

-- Primero, asegurémonos de que los roles existen
INSERT INTO roles (name, description) VALUES
('estructura', 'Encargado de estructura'),
('plomeria', 'Encargado de plomería'),
('electricidad', 'Encargado de electricidad'),
('mamposteria', 'Encargado de mampostería'),
('acabados', 'Encargado de acabados'),
('supervisor', 'Supervisor general de obra'),
('administrador', 'Administrador del sistema')
ON CONFLICT (name) DO NOTHING;

-- Eliminar el trigger y función existentes
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Crear la función corregida para crear perfil automáticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    role_uuid UUID;
    user_role_name TEXT;
BEGIN
    -- Obtener el rol del usuario desde los metadatos
    user_role_name := NEW.raw_user_meta_data->>'role_id';
    
    -- Si no se especifica rol, usar 'administrador' por defecto
    IF user_role_name IS NULL OR user_role_name = '' THEN
        user_role_name := 'administrador';
    END IF;
    
    -- Obtener el UUID del rol
    SELECT id INTO role_uuid FROM roles WHERE name = user_role_name;
    
    -- Si no se encuentra el rol, usar 'administrador' como fallback
    IF role_uuid IS NULL THEN
        SELECT id INTO role_uuid FROM roles WHERE name = 'administrador';
    END IF;
    
    -- Crear el perfil con el rol asignado
    INSERT INTO public.profiles (
        id, 
        email, 
        full_name, 
        phone,
        role_id,
        is_active
    )
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuario'),
        NEW.raw_user_meta_data->>'phone',
        role_uuid,
        true
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear el trigger corregido
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Verificar que todo está correcto
SELECT 'Trigger corregido exitosamente' as mensaje;
SELECT 'Roles disponibles:' as info;
SELECT * FROM roles ORDER BY name;
