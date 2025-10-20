-- Script completo para solucionar problemas de autenticación
-- Ejecutar paso a paso en SQL Editor de Supabase

-- ============================================
-- PASO 1: CONFIRMAR USUARIOS EXISTENTES
-- ============================================

-- Confirmar todos los usuarios existentes
UPDATE auth.users 
SET email_confirmed_at = NOW(), 
    confirmed_at = DEFAULT
WHERE email_confirmed_at IS NULL;

-- ============================================
-- PASO 2: LIMPIAR TRIGGERS PROBLEMÁTICOS
-- ============================================

-- Eliminar triggers existentes que pueden estar causando problemas
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- ============================================
-- PASO 3: VERIFICAR Y CREAR ROLES
-- ============================================

-- Asegurar que los roles existen
INSERT INTO roles (name, description) VALUES
('estructura', 'Encargado de estructura'),
('plomeria', 'Encargado de plomería'),
('electricidad', 'Encargado de electricidad'),
('mamposteria', 'Encargado de mampostería'),
('acabados', 'Encargado de acabados'),
('supervisor', 'Supervisor general de obra'),
('administrador', 'Administrador del sistema')
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- PASO 4: CREAR TRIGGER SIMPLIFICADO (OPCIONAL)
-- ============================================

-- Función simplificada para crear perfil (solo si quieres usar trigger)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    admin_role_id UUID;
BEGIN
    -- Obtener el ID del rol administrador
    SELECT id INTO admin_role_id FROM roles WHERE name = 'administrador' LIMIT 1;
    
    -- Crear perfil básico
    INSERT INTO public.profiles (
        id, 
        email, 
        full_name, 
        role_id,
        is_active
    )
    VALUES (
        NEW.id, 
        NEW.email, 
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'Usuario Nuevo'),
        admin_role_id,
        true
    )
    ON CONFLICT (id) DO NOTHING; -- Evitar duplicados
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Si hay error, no bloquear la creación del usuario
        RAISE LOG 'Error creando perfil para usuario %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger (opcional - puedes omitir esto y usar solo creación manual)
-- CREATE TRIGGER on_auth_user_created
--     AFTER INSERT ON auth.users
--     FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- PASO 5: LIMPIAR PERFILES HUÉRFANOS
-- ============================================

-- Eliminar perfiles sin usuario correspondiente
DELETE FROM profiles 
WHERE id NOT IN (SELECT id FROM auth.users);

-- ============================================
-- PASO 6: CREAR PERFILES PARA USUARIOS SIN PERFIL
-- ============================================

-- Crear perfiles para usuarios que no los tienen
DO $$
DECLARE
    user_record RECORD;
    admin_role_id UUID;
BEGIN
    -- Obtener el ID del rol administrador
    SELECT id INTO admin_role_id FROM roles WHERE name = 'administrador' LIMIT 1;
    
    -- Iterar sobre usuarios sin perfil
    FOR user_record IN 
        SELECT u.id, u.email, u.raw_user_meta_data
        FROM auth.users u
        LEFT JOIN profiles p ON u.id = p.id
        WHERE p.id IS NULL
    LOOP
        INSERT INTO profiles (
            id, 
            email, 
            full_name, 
            role_id, 
            is_active
        ) VALUES (
            user_record.id,
            user_record.email,
            COALESCE(user_record.raw_user_meta_data->>'full_name', 'Usuario'),
            admin_role_id,
            true
        );
    END LOOP;
END $$;

-- ============================================
-- PASO 7: VERIFICACIÓN
-- ============================================

-- Mostrar usuarios y sus perfiles
SELECT 
    u.id,
    u.email,
    u.email_confirmed_at,
    u.confirmed_at,
    p.full_name,
    r.name as role_name
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
LEFT JOIN roles r ON p.role_id = r.id
ORDER BY u.created_at DESC;

-- Mostrar estadísticas
SELECT 
    'Usuarios totales' as tipo, 
    COUNT(*) as cantidad 
FROM auth.users
UNION ALL
SELECT 
    'Usuarios confirmados' as tipo, 
    COUNT(*) as cantidad 
FROM auth.users 
WHERE email_confirmed_at IS NOT NULL
UNION ALL
SELECT 
    'Perfiles totales' as tipo, 
    COUNT(*) as cantidad 
FROM profiles;

-- ============================================
-- PASO 8: CONFIGURAR RLS (Row Level Security)
-- ============================================

-- Habilitar RLS en tablas sensibles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Política para que los usuarios puedan ver su propio perfil
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

-- Política para que los usuarios puedan actualizar su propio perfil
CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

-- Política para permitir inserción de perfiles (necesario para registro)
CREATE POLICY "Enable insert for all users" ON profiles
    FOR INSERT WITH CHECK (true);

-- Política para que administradores puedan ver todos los perfiles
CREATE POLICY "Admins can view all profiles" ON profiles
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM profiles p 
            JOIN roles r ON p.role_id = r.id 
            WHERE p.id = auth.uid() AND r.name = 'administrador'
        )
    );

SELECT 'Configuración completada exitosamente' as resultado;