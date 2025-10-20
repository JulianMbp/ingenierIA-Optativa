-- Script simplificado para solucionar problemas de autenticación
-- Ejecutar en SQL Editor de Supabase

-- ============================================
-- PASO 1: CONFIRMAR USUARIOS EXISTENTES
-- ============================================

-- Confirmar usuarios existentes (la columna confirmed_at se actualizará automáticamente)
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- ============================================
-- PASO 2: ELIMINAR TRIGGER PROBLEMÁTICO
-- ============================================

-- Eliminar el trigger que está causando problemas en el registro
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- ============================================
-- PASO 3: VERIFICAR ROLES
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
-- PASO 4: CREAR PERFILES PARA USUARIOS SIN PERFIL
-- ============================================

-- Obtener el ID del rol administrador
DO $$
DECLARE
    admin_role_id UUID;
    user_record RECORD;
BEGIN
    -- Obtener el ID del rol administrador
    SELECT id INTO admin_role_id FROM roles WHERE name = 'administrador' LIMIT 1;
    
    -- Crear perfiles para usuarios que no los tienen
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
        
        RAISE NOTICE 'Perfil creado para usuario: %', user_record.email;
    END LOOP;
END $$;

-- ============================================
-- PASO 5: VERIFICACIÓN
-- ============================================

-- Mostrar usuarios y sus perfiles
SELECT 
    u.id,
    u.email,
    CASE 
        WHEN u.email_confirmed_at IS NOT NULL THEN 'Confirmado'
        ELSE 'No confirmado'
    END as estado_email,
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

SELECT 'Script ejecutado exitosamente' as resultado;