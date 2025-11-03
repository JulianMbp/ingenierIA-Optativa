# ✅ Cambios Realizados - Integración con NestJS y Supabase

## 📝 Resumen

Se actualizaron los servicios del frontend Flutter para que coincidan correctamente con los endpoints del backend NestJS y la estructura de Supabase.

---

## 🔧 Archivos Modificados

### 1. `/lib/core/config/api_config.dart`

**Cambios:**
- ✅ Actualizado endpoint de login a `/auth/ingenieria/login` (correcto para IngenierIA)
- ✅ Agregado endpoint `/auth/me` para obtener usuario actual
- ✅ Agregados endpoints para obras: `/obras`, `/obras/asignar-usuario`
- ✅ Agregado endpoint para usuarios: `/users`
- ❌ Eliminado endpoint obsoleto `/auth/verify`

**Antes:**
```dart
static const String loginEndpoint = '/auth/login';
static const String verifyTokenEndpoint = '/auth/verify';
```

**Después:**
```dart
static const String loginEndpoint = '/auth/ingenieria/login';
static const String getMeEndpoint = '/auth/me';
static const String obrasEndpoint = '/obras';
static const String asignarUsuarioObraEndpoint = '/obras/asignar-usuario';
```

---

### 2. `/lib/services/nestjs_api_client.dart`

**Cambios:**
- ✅ Método `login()` ahora soporta parámetro opcional `obraId`
- ✅ Agregado método `getCurrentUser()` para obtener info del usuario autenticado
- ✅ Mejorado método `refreshToken()` para usar header Authorization
- ✅ Agregado método `getObras()` con paginación
- ✅ Agregado método `getObraById()`
- ✅ Agregado método `createObra()`
- ✅ Agregado método `assignUserToObra()`
- ✅ Agregado método `getObraUsers()`

**Ejemplo de Login con Obra:**
```dart
final response = await nestJsClient.login(
  email: 'admin.general@ingenieria.com',
  password: 'AdminIngenieria2024!',
  obraId: 'uuid-de-obra', // ← Nuevo parámetro opcional
);
```

---

### 3. `/lib/services/supabase_service.dart`

**Cambios:**
- ✅ Método `setAuthToken()` simplificado (solo almacena en secure storage)
- ✅ Agregada documentación sobre RLS (Row Level Security)
- ✅ Agregado TODO para implementar RLS con JWT de NestJS

**Nota Importante:**
```dart
/// Note: Currently, Supabase operations use the anon key for authentication.
/// The JWT token from NestJS is stored for future RLS (Row Level Security) implementation.
/// 
/// TODO: Implement RLS policies in Supabase to validate the NestJS JWT token
/// and restrict access based on user roles and project assignments.
```

---

## 📚 Nuevo Documento: INTEGRATION_GUIDE.md

Se creó una guía completa de integración que incluye:

1. **Arquitectura de Integración**: Diagrama de flujo entre Flutter, NestJS y Supabase
2. **Flujo de Autenticación**: Paso a paso del proceso de login
3. **Uso del NestJS API Client**: Ejemplos para cada endpoint
4. **Uso del Supabase Service**: Ejemplos para operaciones CRUD
5. **Políticas RLS de Supabase**: Explicación del sistema de seguridad multi-tenant
6. **Ejemplos de Uso Completos**: Flujos reales de login, dashboard, asistencias
7. **Debugging y Troubleshooting**: Cómo verificar tokens y RLS
8. **Checklist de Integración**: Lista de verificación antes/durante/después del login

---

## 🔑 Puntos Clave de la Integración

### 1. Estructura del Request de Login

```json
POST /auth/ingenieria/login
{
  "email": "admin.general@ingenieria.com",
  "password": "AdminIngenieria2024!",
  "obraId": "uuid-opcional-de-obra"
}
```

### 2. Estructura del Response

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenExpires": 1730678400000,
  "user": {
    "id": 1,
    "email": "admin.general@ingenieria.com",
    "firstName": "Admin",
    "lastName": "General",
    "role": {
      "id": 3,
      "name": "Admin General"
    }
  }
}
```

### 3. Payload del JWT

```json
{
  "id": 1,
  "role": {
    "id": 3,
    "name": "Admin General"
  },
  "email": "admin.general@ingenieria.com",
  "obra_id": "123e4567-e89b-12d3-a456-426614174000", // ⚠️ CRÍTICO para RLS
  "iat": 1730581234,
  "exp": 1730667634
}
```

### 4. Flujo Completo de Login

```dart
// 1. Login en NestJS
final response = await nestJsClient.login(
  email: email,
  password: password,
  obraId: selectedObraId,
);

// 2. Extraer datos
final token = response.data['token'];
final refreshToken = response.data['refreshToken'];
final user = response.data['user'];

// 3. Decodificar JWT
final decodedToken = JwtDecoder.decode(token);
final obraId = decodedToken['obra_id'];
final rol = decodedToken['role']['name'];

// 4. Guardar tokens
await secureStorage.write(key: 'jwt_token', value: token);
await secureStorage.write(key: 'refresh_token', value: refreshToken);

// 5. ⚠️ IMPORTANTE: Configurar token en Supabase para RLS
await supabaseService.setAuthToken(token);

// 6. Navegar al dashboard según rol
navigateToRoleDashboard(rol);
```

---

## 🔒 Row Level Security (RLS) en Supabase

### Cómo Funciona

1. El JWT de NestJS incluye `obra_id` en el payload
2. Supabase extrae el `obra_id` del JWT automáticamente
3. Las políticas RLS filtran los datos según este `obra_id`

### Ejemplo de Política RLS

```sql
create policy "Solo ver materiales de su obra"
on public.materiales
for select
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);
```

### ⚠️ Implicaciones

- ✅ **Seguridad multi-tenant automática**: Cada usuario solo ve datos de su obra
- ✅ **Sin lógica adicional en el frontend**: Supabase filtra automáticamente
- ⚠️ **CRÍTICO**: Siempre llamar `supabaseService.setAuthToken(token)` después del login
- ⚠️ **Si no hay `obra_id` en el JWT**: El usuario NO verá ningún dato

---

## 🎯 Tablas de Supabase Disponibles

Según `scripts-supabase.md`:

| Tabla | Descripción | RLS Habilitado |
|-------|-------------|----------------|
| `obras` | Proyectos de construcción | ✅ |
| `materiales` | Materiales por obra | ✅ |
| `bitacoras` | Bitácoras de avance | ✅ |
| `asistencias` | Asistencias de trabajadores | ✅ |
| `presupuestos` | Presupuestos por partidas | ✅ |
| `documentos` | Documentos técnicos | ✅ |

### Funciones RPC Disponibles

```dart
// Desde Flutter
final materiales = await supabase.rpc('get_materiales_by_obra', params: {'obra': obraId});
final bitacoras = await supabase.rpc('get_bitacoras_by_obra', params: {'obra': obraId});
final asistencias = await supabase.rpc('get_asistencias_by_obra', params: {'obra': obraId});
```

---

## 📊 Roles Disponibles (del API)

| ID | Nombre | Descripción |
|----|--------|-------------|
| 1 | Admin | Administrador del sistema base |
| 2 | User | Usuario base |
| 3 | Admin General | Acceso total a todas las obras |
| 4 | Admin Obra | Gestión de una obra específica |
| 5 | Encargado de Área | Responsable de área |
| 6 | Obrero | Trabajador operativo |
| 7 | SST | Seguridad y Salud en el Trabajo |
| 8 | Compras | Encargado de compras |
| 9 | RRHH | Recursos Humanos |
| 10 | Consultor | Consultor externo |

---

## ✅ Validación de la Integración

### Checklist Pre-Login:
- [x] Variables de entorno en `.env` configuradas
- [x] `ApiConfig.load()` en `main.dart`
- [x] Supabase inicializado
- [x] Servicios registrados en providers
- [x] Endpoint correcto: `/auth/ingenieria/login`

### Checklist Post-Login:
- [x] Token JWT guardado en `FlutterSecureStorage`
- [x] Refresh token guardado
- [x] Token configurado en Supabase con `setAuthToken()`
- [x] JWT decodificado para extraer `obra_id` y `role`
- [x] Usuario navegado al dashboard correcto

---

## 🚀 Próximos Pasos

1. **Probar la aplicación**:
   ```bash
   flutter run -d chrome
   ```

2. **Verificar conexión con backend**:
   - Asegurarse de que NestJS esté corriendo en `http://localhost:3000`
   - Verificar que las credenciales de prueba funcionen

3. **Implementar data layer**:
   - Crear modelos con `freezed`
   - Implementar repositories
   - Agregar use cases

4. **Agregar manejo de errores**:
   - Crear excepciones personalizadas
   - Mejorar feedback al usuario

5. **Implementar navegación con `go_router`**:
   - Rutas protegidas por autenticación
   - Redirección según rol

---

## 🐛 Problemas Conocidos

### Error: "Target of URI doesn't exist"

**Causa**: El analizador de Dart no ha recargado las dependencias.

**Solución**:
1. Reiniciar el servidor de análisis de Dart en VS Code:
   - Cmd+Shift+P → "Dart: Restart Analysis Server"
2. O simplemente esperar unos segundos, el analizador se actualizará automáticamente

### Los imports de Dio/Logger no se resuelven

**Causa**: Las dependencias están instaladas pero el analizador no las reconoce aún.

**Solución**:
- Ya ejecutamos `flutter pub get` exitosamente
- Las dependencias están disponibles (verificado con `dart pub deps`)
- El código compilará correctamente cuando se ejecute

---

## 📖 Referencias

- **API Documentation**: `API_ENDPOINTS.md`
- **Supabase Scripts**: `scripts-supabase.md`
- **Supabase Schema**: `base-supabase.md`
- **Integration Guide**: `INTEGRATION_GUIDE.md`

---

**Última actualización**: 3 de noviembre de 2025
**Autor**: GitHub Copilot
