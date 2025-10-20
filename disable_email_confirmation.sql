-- Configuración para deshabilitar confirmación de email en Supabase
-- Ejecutar en SQL Editor de Supabase

-- Deshabilitar confirmación de email
UPDATE auth.config 
SET value = 'false' 
WHERE parameter = 'MAILER_SECURE_EMAIL_CHANGE_ENABLED';

UPDATE auth.config 
SET value = 'false' 
WHERE parameter = 'SMTP_ADMIN_EMAIL';

-- Configurar para permitir registro sin confirmación
INSERT INTO auth.config (parameter, value) 
VALUES ('ENABLE_SIGNUP', 'true')
ON CONFLICT (parameter) DO UPDATE SET value = 'true';

INSERT INTO auth.config (parameter, value) 
VALUES ('DISABLE_SIGNUP', 'false')
ON CONFLICT (parameter) DO UPDATE SET value = 'false';