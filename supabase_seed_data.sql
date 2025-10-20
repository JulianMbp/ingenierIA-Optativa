-- Script SQL para datos de prueba - Sistema de Gestión de Obra
-- Ejecutar después de supabase_tables.sql

-- Insertar roles adicionales si no existen
INSERT INTO roles (name, description) VALUES
('estructura', 'Encargado de estructura'),
('plomeria', 'Encargado de plomería'),
('electricidad', 'Encargado de electricidad'),
('mamposteria', 'Encargado de mampostería'),
('acabados', 'Encargado de acabados'),
('supervisor', 'Supervisor general de obra'),
('administrador', 'Administrador del sistema')
ON CONFLICT (name) DO NOTHING;

-- Crear un proyecto de prueba
INSERT INTO projects (name, description, location, start_date, end_date, budget, status) VALUES
('Edificio Residencial Los Pinos', 
 'Construcción de edificio residencial de 5 pisos con 20 apartamentos', 
 'Calle 123 #45-67, Bogotá', 
 '2024-01-15', 
 '2024-12-15', 
 2500000000.00, 
 'activo')
ON CONFLICT DO NOTHING;

-- Insertar algunos materiales de prueba
INSERT INTO materials (name, description, unit, unit_price, current_stock, min_stock, supplier) VALUES
('Cemento Portland', 'Cemento gris para construcción', 'kg', 850.00, 5000, 1000, 'Cementos Argos'),
('Ladrillo común', 'Ladrillo de arcilla cocida 6x12x24 cm', 'unidad', 120.00, 10000, 2000, 'Ladrillera San José'),
('Varilla #3', 'Acero de refuerzo diámetro 3/8"', 'kg', 3200.00, 2000, 500, 'Acerías Paz del Río'),
('Arena gruesa', 'Arena para concreto y mortero', 'm3', 45000.00, 50, 10, 'Arenas del Norte'),
('Grava 3/4"', 'Grava triturada para concreto', 'm3', 55000.00, 30, 8, 'Graveras del Sur'),
('Tubo PVC 2"', 'Tubo de PVC para instalaciones hidráulicas', 'm', 8500.00, 200, 50, 'Tubos y Conexiones Ltda'),
('Cable THW #12', 'Cable eléctrico calibre 12 AWG', 'm', 1200.00, 1000, 200, 'Cables Eléctricos del Caribe'),
('Pintura vinílica', 'Pintura para interiores color blanco', 'galón', 45000.00, 50, 10, 'Pinturas y Químicos S.A.')
ON CONFLICT DO NOTHING;

-- Insertar algunos trabajadores de prueba
INSERT INTO workers (full_name, document_number, phone, email, role_id, project_id, is_active) VALUES
('Carlos Mendoza', '12345678', '3001234567', 'carlos.mendoza@email.com', 
 (SELECT id FROM roles WHERE name = 'estructura'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 true),
('Ana García', '87654321', '3007654321', 'ana.garcia@email.com', 
 (SELECT id FROM roles WHERE name = 'plomeria'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 true),
('Luis Rodríguez', '11223344', '3001122334', 'luis.rodriguez@email.com', 
 (SELECT id FROM roles WHERE name = 'electricidad'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 true),
('María López', '44332211', '3004433221', 'maria.lopez@email.com', 
 (SELECT id FROM roles WHERE name = 'mamposteria'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 true),
('Pedro Silva', '55667788', '3005566778', 'pedro.silva@email.com', 
 (SELECT id FROM roles WHERE name = 'acabados'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 true)
ON CONFLICT (document_number) DO NOTHING;

-- Insertar algunos registros de asistencia de prueba (últimos 7 días)
INSERT INTO attendance (worker_id, project_id, date, check_in, check_out, hours_worked, is_present, notes) VALUES
-- Carlos Mendoza (Estructura) - Últimos 7 días
((SELECT id FROM workers WHERE document_number = '12345678'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '6 days', '07:00:00', '17:00:00', 8.0, true, 'Trabajo en cimentación'),
((SELECT id FROM workers WHERE document_number = '12345678'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '5 days', '07:00:00', '17:00:00', 8.0, true, 'Armado de acero'),
((SELECT id FROM workers WHERE document_number = '12345678'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '4 days', '07:00:00', '17:00:00', 8.0, true, 'Vaciado de concreto'),
((SELECT id FROM workers WHERE document_number = '12345678'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '3 days', '07:00:00', '17:00:00', 8.0, true, 'Desencofrado'),
((SELECT id FROM workers WHERE document_number = '12345678'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '2 days', '07:00:00', '17:00:00', 8.0, true, 'Preparación para segundo piso'),
((SELECT id FROM workers WHERE document_number = '12345678'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '1 day', '07:00:00', '17:00:00', 8.0, true, 'Inicio de segundo piso'),
((SELECT id FROM workers WHERE document_number = '12345678'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE, '07:00:00', '17:00:00', 8.0, true, 'Continuación segundo piso'),

-- Ana García (Plomería) - Últimos 7 días
((SELECT id FROM workers WHERE document_number = '87654321'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '6 days', '08:00:00', '16:00:00', 8.0, true, 'Instalación de tuberías principales'),
((SELECT id FROM workers WHERE document_number = '87654321'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '5 days', '08:00:00', '16:00:00', 8.0, true, 'Conexiones hidráulicas'),
((SELECT id FROM workers WHERE document_number = '87654321'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '4 days', '08:00:00', '16:00:00', 8.0, true, 'Instalación de medidores'),
((SELECT id FROM workers WHERE document_number = '87654321'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '3 days', '08:00:00', '16:00:00', 8.0, true, 'Pruebas de presión'),
((SELECT id FROM workers WHERE document_number = '87654321'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '2 days', '08:00:00', '16:00:00', 8.0, true, 'Instalación de grifos'),
((SELECT id FROM workers WHERE document_number = '87654321'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE - INTERVAL '1 day', '08:00:00', '16:00:00', 8.0, true, 'Instalación de sanitarios'),
((SELECT id FROM workers WHERE document_number = '87654321'), 
 (SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'), 
 CURRENT_DATE, '08:00:00', '16:00:00', 8.0, true, 'Finalización instalaciones primer piso')
ON CONFLICT (worker_id, date) DO NOTHING;

-- Insertar algunos presupuestos de prueba
INSERT INTO budgets (project_id, role_id, item_name, description, quantity, unit_price, completed_quantity) VALUES
-- Presupuesto para Estructura
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'estructura'),
 'Cimentación', 'Excavación y cimentación del edificio', 1.0, 50000000.00, 1.0),
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'estructura'),
 'Estructura primer piso', 'Columnas, vigas y losa del primer piso', 1.0, 80000000.00, 1.0),
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'estructura'),
 'Estructura segundo piso', 'Columnas, vigas y losa del segundo piso', 1.0, 80000000.00, 0.3),

-- Presupuesto para Plomería
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'plomeria'),
 'Instalación hidráulica', 'Tuberías principales y conexiones', 1.0, 30000000.00, 0.8),
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'plomeria'),
 'Instalación sanitaria', 'Sanitarios, grifos y accesorios', 1.0, 25000000.00, 0.6),

-- Presupuesto para Electricidad
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'electricidad'),
 'Instalación eléctrica', 'Cableado y tableros principales', 1.0, 40000000.00, 0.2),
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'electricidad'),
 'Iluminación', 'Instalación de luminarias', 1.0, 15000000.00, 0.0)
ON CONFLICT DO NOTHING;

-- Insertar algunos reportes diarios de prueba
INSERT INTO daily_reports (project_id, role_id, date, work_description, progress_percentage, materials_used, issues, next_day_plan) VALUES
-- Reporte de Estructura
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'estructura'),
 CURRENT_DATE - INTERVAL '1 day',
 'Se completó el armado de acero para el segundo piso. Se realizó el vaciado de concreto en las columnas principales.',
 25.0,
 '{"cemento": "500 kg", "varilla": "200 kg", "arena": "2 m3", "grava": "3 m3"}',
 'Ningún inconveniente reportado.',
 'Continuar con el armado de vigas del segundo piso.'),

-- Reporte de Plomería
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'plomeria'),
 CURRENT_DATE - INTERVAL '1 day',
 'Se instalaron las tuberías principales del primer piso. Se realizaron las conexiones hidráulicas básicas.',
 40.0,
 '{"tubo_pvc": "50 m", "conexiones": "25 unidades"}',
 'Falta material para conexiones especiales.',
 'Instalar medidores y realizar pruebas de presión.'),

-- Reporte de Electricidad
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM roles WHERE name = 'electricidad'),
 CURRENT_DATE - INTERVAL '1 day',
 'Se inició la instalación del cableado principal. Se instalaron los tableros de distribución.',
 15.0,
 '{"cable_thw": "100 m", "tableros": "2 unidades"}',
 'Retraso en la entrega de materiales eléctricos.',
 'Continuar con la instalación de cableado en el primer piso.')
ON CONFLICT DO NOTHING;

-- Insertar algunos exámenes médicos de prueba
INSERT INTO medical_exams (worker_id, exam_type, exam_date, expiry_date, is_valid, notes) VALUES
((SELECT id FROM workers WHERE document_number = '12345678'), 'medico', '2024-01-01', '2024-12-31', true, 'Examen médico anual - Apto para trabajo'),
((SELECT id FROM workers WHERE document_number = '12345678'), 'altura', '2024-01-01', '2024-12-31', true, 'Examen de trabajo en alturas - Certificado vigente'),
((SELECT id FROM workers WHERE document_number = '87654321'), 'medico', '2024-01-15', '2024-12-31', true, 'Examen médico anual - Apto para trabajo'),
((SELECT id FROM workers WHERE document_number = '87654321'), 'altura', '2024-01-15', '2024-12-31', true, 'Examen de trabajo en alturas - Certificado vigente'),
((SELECT id FROM workers WHERE document_number = '11223344'), 'medico', '2024-02-01', '2024-12-31', true, 'Examen médico anual - Apto para trabajo'),
((SELECT id FROM workers WHERE document_number = '11223344'), 'altura', '2024-02-01', '2024-12-31', true, 'Examen de trabajo en alturas - Certificado vigente')
ON CONFLICT DO NOTHING;

-- Insertar algunos formatos ATS de prueba
INSERT INTO ats_forms (project_id, date, safety_conditions, equipment_check, incidents, recommendations, is_completed) VALUES
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 CURRENT_DATE - INTERVAL '1 day',
 'Condiciones climáticas favorables. Área de trabajo limpia y organizada.',
 '{"cascos": "Todos en buen estado", "arneses": "Verificados", "escaleras": "Estables", "herramientas": "En buen estado"}',
 'Ningún incidente reportado.',
 'Mantener el área de trabajo limpia. Verificar equipos de seguridad diariamente.',
 true),

((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 CURRENT_DATE,
 'Lluvia ligera en la mañana. Área de trabajo húmeda.',
 '{"cascos": "Todos en buen estado", "arneses": "Verificados", "escaleras": "Revisar estabilidad", "herramientas": "En buen estado"}',
 'Ningún incidente reportado.',
 'Tener precaución con superficies húmedas. Usar calzado antideslizante.',
 false)
ON CONFLICT DO NOTHING;

-- Insertar un reporte de incidente de prueba
INSERT INTO incident_reports (project_id, worker_id, incident_type, date, time, description, severity, actions_taken, reported_to_arl, created_by) VALUES
((SELECT id FROM projects WHERE name = 'Edificio Residencial Los Pinos'),
 (SELECT id FROM workers WHERE document_number = '11223344'),
 'incidente',
 CURRENT_DATE - INTERVAL '3 days',
 '14:30:00',
 'Trabajador tropezó con una herramienta en el suelo. No hubo lesiones, solo un susto.',
 'leve',
 'Se removió la herramienta del área de trabajo. Se reforzó la capacitación sobre orden y limpieza.',
 false,
 (SELECT id FROM auth.users LIMIT 1))
ON CONFLICT DO NOTHING;

-- Mensaje de confirmación
SELECT 'Datos de prueba insertados exitosamente' as mensaje;
