# 🔍 Análisis de Problemas - Login y Obras

## ❌ Problemas Encontrados

### 1. **Roles no alineados con el backend**

**Síntoma:**
```
role: {id: 3, name: "Admin General"}
role: {id: 4, name: "Admin Obra"}  
role: {id: 5, name: "Encargado de Área"}
```

**Problema:**
El backend devuelve nombres de roles con espacios y acentos (ej: "Admin General", "Encargado de Área"), pero el frontend esperaba formato underscore (ej: "admin_general", "encargado_area").

**Solución Aplicada:**
- ✅ Mejorado el normalizador en `UserRole.fromString()` para:
  - Convertir espacios a underscores
  - Remover acentos (á→a, é→e)
  - Manejar "de" en nombres compuestos
  - Agregar logging detallado para debugging

### 2. **Error 500 en `/obras` - CRÍTICO** ⚠️

**Síntoma:**
```
ERROR[500] => PATH: /obras
Error data: {statusCode: 500, message: Internal server error}
```

**Problema:**
El endpoint `/obras` del backend NestJS está fallando con error 500 (Internal Server Error).

**Causas Posibles:**

#### A) Usuario sin obras asignadas
El usuario no tiene registros en la tabla de relación `usuario_obras`:

```sql
-- Verificar en Supabase:
SELECT * FROM usuario_obras WHERE user_id = 3; -- admin.general@ingenieria.com
SELECT * FROM usuario_obras WHERE user_id = 4; -- admin.obra1@ingenieria.com
SELECT * FROM usuario_obras WHERE user_id = 6; -- encargado.area1@ingenieria.com
```

Si no hay resultados, debes insertar las relaciones:

```sql
-- Asignar obras a usuarios
INSERT INTO usuario_obras (user_id, obra_id, created_at)
VALUES 
  (3, 'uuid-obra-1', NOW()),  -- Admin General → Obra 1
  (3, 'uuid-obra-2', NOW()),  -- Admin General → Obra 2
  (4, 'uuid-obra-1', NOW()),  -- Admin Obra → Obra 1
  (6, 'uuid-obra-1', NOW());  -- Encargado → Obra 1
```

#### B) Políticas RLS mal configuradas
Las Row Level Security (RLS) policies en Supabase pueden estar bloqueando el acceso:

```sql
-- Verificar políticas en tabla 'obras'
SELECT * FROM pg_policies WHERE tablename = 'obras';

-- Política requerida para SELECT en tabla obras:
CREATE POLICY "Users can view their assigned obras"
ON obras FOR SELECT
USING (
  id IN (
    SELECT obra_id 
    FROM usuario_obras 
    WHERE user_id = (current_setting('request.jwt.claims')::json->>'id')::integer
  )
  OR
  -- Admin General puede ver todas las obras
  EXISTS (
    SELECT 1 FROM users
    WHERE id = (current_setting('request.jwt.claims')::json->>'id')::integer
    AND role_id = 3  -- ID del rol "Admin General"
  )
);
```

#### C) Error en el backend NestJS
El controlador o servicio de obras tiene un error. Revisar logs del backend:

```bash
# En el terminal del backend NestJS
npm run start:dev

# Buscar stack trace del error
```

## ✅ Soluciones Aplicadas en Frontend

### 1. Normalización de Roles
```dart
// Antes:
final normalizedValue = value.toLowerCase().replaceAll(' ', '_');

// Ahora:
final normalizedValue = value
    .toLowerCase()
    .replaceAll(' de ', '_')  // "Encargado de Área"
    .replaceAll(' ', '_')     // "Admin General"
    .replaceAll('á', 'a')     // Remover acentos
    // ... más normalizaciones
```

### 2. Mensajes de Error Mejorados
```dart
// Ahora muestra detalles específicos del error:
if (e.toString().contains('500')) {
  errorMsg = 'Error del servidor (500). Verifique:\n'
            '1. El usuario tiene obras asignadas en la BD\n'
            '2. Las políticas RLS de Supabase están configuradas\n'
            '3. Los logs del backend NestJS para más detalles';
}
```

## 🔧 Acciones Requeridas (BACKEND)

### 1. Verificar Datos en Supabase

```sql
-- 1. Verificar que existen obras
SELECT id, nombre, direccion FROM obras LIMIT 5;

-- 2. Verificar usuarios
SELECT id, email, first_name, last_name, role_id FROM users WHERE id IN (3, 4, 6);

-- 3. Verificar relaciones usuario-obra
SELECT uo.*, u.email, o.nombre as obra_nombre
FROM usuario_obras uo
JOIN users u ON u.id = uo.user_id
JOIN obras o ON o.id = uo.obra_id;
```

### 2. Verificar Backend NestJS

```typescript
// En obras.controller.ts o similar
@Get()
async findAll(@Req() request: Request) {
  const userId = request.user.id;  // Verificar que existe
  const role = request.user.role;   // Verificar rol
  
  try {
    return await this.obrasService.findByUser(userId, role);
  } catch (error) {
    // AGREGAR LOGGING AQUÍ
    console.error('Error in GET /obras:', error);
    throw error;
  }
}
```

### 3. Verificar Políticas RLS

```sql
-- Deshabilitar temporalmente RLS para debugging
ALTER TABLE obras DISABLE ROW LEVEL SECURITY;

-- Hacer request de /obras
-- Si funciona, el problema es RLS

-- Re-habilitar RLS
ALTER TABLE obras ENABLE ROW LEVEL SECURITY;

-- Crear política correcta
CREATE POLICY "obra_select_policy" 
ON obras FOR SELECT
USING (
  -- Ver query de política arriba
);
```

## 📊 Estado Actual

| Componente | Estado | Acción |
|------------|--------|--------|
| Normalización de roles | ✅ Arreglado | Ninguna |
| Login básico | ✅ Funciona | Ninguna |
| Extracción de JWT | ✅ Funciona | Ninguna |
| GET /obras | ❌ Error 500 | **REVISAR BACKEND** |
| Relaciones user-obra | ❓ Desconocido | **VERIFICAR BD** |
| Políticas RLS | ❓ Desconocido | **VERIFICAR SUPABASE** |

## 🎯 Próximos Pasos

1. **INMEDIATO**: Revisar logs del backend NestJS para ver el error exacto
2. **VERIFICAR**: Ejecutar queries SQL en Supabase para confirmar:
   - ✓ Existen obras en la tabla
   - ✓ Usuarios están relacionados con obras
   - ✓ Políticas RLS permiten acceso
3. **CORREGIR**: Según los resultados:
   - Insertar relaciones faltantes
   - Arreglar políticas RLS
   - Corregir código del backend

## 📝 Usuarios de Prueba

Según los logs:

| Email | Role | User ID | ¿Tiene obras? |
|-------|------|---------|---------------|
| admin.general@ingenieria.com | Admin General (id: 3) | 3 | ❓ (500 error) |
| admin.obra1@ingenieria.com | Admin Obra (id: 4) | 4 | ❓ (500 error) |
| encargado.area1@ingenieria.com | Encargado de Área (id: 5) | 6 | ❓ (500 error) |

Todos fallan con el mismo error 500, lo que sugiere un problema sistémico en el backend, no específico de un usuario.

---

**Conclusión**: El frontend está funcionando correctamente. El problema es en el **BACKEND** (NestJS + Supabase). Necesitas revisar los logs del servidor y la configuración de la base de datos.
