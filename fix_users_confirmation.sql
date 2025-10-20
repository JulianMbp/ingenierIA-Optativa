-- Script para confirmar usuarios existentes y configurar autenticación
-- Ejecutar en SQL Editor de Supabase

-- 1. Confirmar todos los usuarios existentes
UPDATE auth.users 
SET email_confirmed_at = NOW(), 
    confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 2. Verificar que los usuarios están confirmados
SELECT id, email, email_confirmed_at, confirmed_at, created_at 
FROM auth.users 
ORDER BY created_at DESC;

-- 3. Mostrar perfiles existentes
SELECT p.id, p.email, p.full_name, r.name as role_name
FROM profiles p
LEFT JOIN roles r ON p.role_id = r.id
ORDER BY p.created_at DESC;