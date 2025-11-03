# Backend JWT Requirements - UPDATED STATUS

## ⚠️ CURRENT STATUS (Nov 3, 2025)

**TEMPORARY WORKAROUND IMPLEMENTED**: The Flutter app now queries Supabase directly to get the `user_uuid` when it's missing from the JWT. This is a **temporary solution** to unblock development.

**STILL REQUIRED**: Backend should be updated to include `user_uuid` and `obra_id` in the JWT payload to avoid additional database queries and improve performance.

---

## Problem Statement

## Problema Actual
El backend de NestJS está devolviendo JWTs con el `id` numérico del usuario, pero Supabase necesita el `user_uuid` (UUID) para las operaciones de base de datos.

## ✅ Solución Requerida

### 1. Actualizar el payload del JWT

El JWT que firma NestJS debe incluir el `user_uuid` de Supabase:

```typescript
// ANTES (incorrecto)
{
  "id": 3,  // ❌ ID numérico
  "role": {...},
  "sessionId": 31,
  "email": "admin.general@ingenieria.com",
  "obra_id": "c13e4b9e-41f1-4273-a18e-c26699edab61",
  "iat": 1762155104,
  "exp": 1762156004
}

// DESPUÉS (correcto)
{
  "id": 3,  // Mantener para compatibilidad
  "user_uuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",  // ✅ UUID de Supabase
  "role": {...},
  "sessionId": 31,
  "email": "admin.general@ingenieria.com",
  "obra_id": "c13e4b9e-41f1-4273-a18e-c26699edab61",
  "iat": 1762155104,
  "exp": 1762156004
}
```

### 2. Mapeo Usuario → Supabase UUID

**Opción A: Tabla de mapeo en NestJS** (Recomendada si no tienes acceso directo a Supabase)
```sql
CREATE TABLE user_supabase_mapping (
  user_id INTEGER PRIMARY KEY,
  supabase_uuid UUID NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Opción B: Consultar directamente a Supabase** (Más simple)
```typescript
// En el servicio de autenticación de NestJS
async getUserSupabaseUuid(email: string): Promise<string> {
  const { data, error } = await this.supabaseClient
    .from('usuarios')  // o la tabla que manejes para usuarios
    .select('id')
    .eq('email', email)
    .single();
    
  if (error || !data) {
    throw new Error('Usuario no encontrado en Supabase');
  }
  
  return data.id; // Este es el UUID
}
```

**Opción C: Generar UUID determinístico** (Solo si no puedes modificar Supabase)
```typescript
import { v5 as uuidv5 } from 'uuid';

const NAMESPACE_UUID = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';

function generateUserUuid(userId: number): string {
  return uuidv5(`ingenieria-user-${userId}`, NAMESPACE_UUID);
}
```

### 3. Actualizar el endpoint `/auth/email/login`

```typescript
// auth.service.ts
async login(email: string, password: string) {
  // 1. Validar credenciales
  const user = await this.validateUser(email, password);
  
  // 2. Obtener UUID de Supabase
  const userUuid = await this.getUserSupabaseUuid(user.email);
  
  // 3. Generar JWT con user_uuid
  const payload = {
    id: user.id,
    user_uuid: userUuid,  // ✅ Campo crítico
    role: user.role,
    sessionId: session.id,
    email: user.email,
  };
  
  const token = this.jwtService.sign(payload);
  
  return {
    token,
    refreshToken,
    tokenExpires,
    user,
  };
}
```

### 4. Actualizar el endpoint `/auth/ingenieria/login`

```typescript
// auth.service.ts
async loginWithObra(email: string, password: string, obraId: string) {
  // 1. Validar credenciales
  const user = await this.validateUser(email, password);
  
  // 2. Obtener UUID de Supabase
  const userUuid = await this.getUserSupabaseUuid(user.email);
  
  // 3. Validar que el usuario tenga acceso a la obra
  await this.validateUserObraAccess(userUuid, obraId);
  
  // 4. Generar JWT con user_uuid Y obra_id
  const payload = {
    id: user.id,
    user_uuid: userUuid,  // ✅ UUID del usuario
    obra_id: obraId,      // ✅ UUID de la obra
    role: user.role,
    sessionId: session.id,
    email: user.email,
  };
  
  const token = this.jwtService.sign(payload);
  
  return {
    token,
    refreshToken,
    tokenExpires,
    user,
  };
}
```

## 🧪 Testing

### Probar el JWT decodificado:

```bash
# Decodificar JWT en https://jwt.io/
# O usar:
echo "YOUR_JWT_HERE" | cut -d '.' -f 2 | base64 -d | jq
```

Debe mostrar:
```json
{
  "id": 3,
  "user_uuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "obra_id": "c13e4b9e-41f1-4273-a18e-c26699edab61",
  "role": {...}
}
```

### Probar inserciones en Supabase:

```bash
curl -X POST https://ksjrwpabpfcltazmrnbh.supabase.co/rest/v1/bitacoras \
  -H "Authorization: Bearer YOUR_JWT" \
  -H "apikey: YOUR_SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "obra_id": "c13e4b9e-41f1-4273-a18e-c26699edab61",
    "usuario_id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "descripcion": "Test",
    "avance_porcentaje": 50
  }'
```

## 📋 Checklist de Implementación

- [ ] Agregar campo `user_uuid` al payload del JWT
- [ ] Implementar método para obtener UUID de Supabase
- [ ] Actualizar `/auth/email/login` para incluir `user_uuid`
- [ ] Actualizar `/auth/ingenieria/login` para incluir `user_uuid` y `obra_id`
- [ ] Validar que RLS de Supabase use `user_uuid` del JWT
- [ ] Probar creación de bitácoras desde Flutter
- [ ] Probar creación de materiales desde Flutter
- [ ] Validar que cada obra solo vea sus datos

## ⚠️ Importante

1. **Nunca usar IDs numéricos en Supabase**: Todas las foreign keys son UUIDs
2. **El JWT debe tener `user_uuid` desde el primer login**: Flutter lo necesita inmediatamente
3. **RLS de Supabase debe validar**: 
   - `obra_id` del registro = `obra_id` del JWT
   - `usuario_id` del registro = `user_uuid` del JWT

## 🔗 Referencias

- Arquitectura: `/BACKEND_JWT_REQUIREMENTS.md`
- Schema Supabase: `/ingenieria/base-supabase.md`
- Auth Provider Flutter: `/ingenieria/lib/presentation/providers/auth_provider.dart`
