# 📝 Resumen de Cambios - Autenticación Dos Pasos

## 🎯 Objetivo
Implementar flujo de autenticación de dos pasos:
1. Login inicial → obtener token
2. Listar obras disponibles
3. Re-login con obra seleccionada → obtener JWT con `obra_id`

---

## ✅ Archivos Modificados

### 1. `/lib/core/config/api_config.dart`
**Cambios:**
- ✅ Agregado endpoint `emailLoginEndpoint = '/auth/email/login'` (paso 1)
- ✅ Renombrado `loginEndpoint` a `ingenieriaLoginEndpoint = '/auth/ingenieria/login'` (paso 3)

**Razón:** Separar los dos endpoints de login según el flujo.

---

### 2. `/lib/services/nestjs_api_client.dart`
**Cambios:**
- ✅ **Nuevo método** `loginWithEmail()` - Login inicial sin obra
- ✅ **Nuevo método** `loginWithObra()` - Login con obra seleccionada
- ✅ **Deprecated** método `login()` antiguo (mantiene compatibilidad)
- ✅ **Corregido** interceptor de refresh token:
  - Antes: Enviaba `refreshToken` en body ❌
  - Ahora: Envía en header `Authorization: Bearer <refreshToken>` ✅
  - Antes: Esperaba `access_token` ❌
  - Ahora: Lee `token` y `refreshToken` del response ✅
  - Ahora: Guarda **ambos tokens** actualizados ✅

**Código actualizado:**
```dart
/// Login inicial con email y password (sin obra)
Future<Response> loginWithEmail({
  required String email,
  required String password,
}) async {
  return await _dio.post(
    ApiConfig.emailLoginEndpoint,
    data: {
      'email': email,
      'password': password,
    },
  );
}

/// Login con obra seleccionada (segundo paso)
Future<Response> loginWithObra({
  required String email,
  required String password,
  required String obraId,
}) async {
  return await _dio.post(
    ApiConfig.ingenieriaLoginEndpoint,
    data: {
      'email': email,
      'password': password,
      'obraId': obraId,
    },
  );
}
```

**Interceptor corregido:**
```dart
@override
void onError(DioException err, ErrorInterceptorHandler handler) async {
  if (err.response?.statusCode == 401) {
    try {
      final refreshToken = await _secureStorage.read(
        key: AppConstants.refreshTokenKey,
      );

      if (refreshToken != null) {
        final dio = Dio(BaseOptions(baseUrl: ApiConfig.nestJsBaseUrl));
        final response = await dio.post(
          ApiConfig.refreshTokenEndpoint,
          options: Options(
            headers: {
              'Authorization': 'Bearer $refreshToken',  // ✅ Corregido
            },
          ),
        );

        if (response.statusCode == 200) {
          final newToken = response.data['token'];              // ✅ Corregido
          final newRefreshToken = response.data['refreshToken'];// ✅ Nuevo
          
          // Guardar ambos tokens ✅
          await _secureStorage.write(
            key: AppConstants.tokenKey,
            value: newToken,
          );
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: newRefreshToken,
          );

          // Reintentar petición original ✅
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(err.requestOptions);
          return handler.resolve(retryResponse);
        }
      }
    } catch (e) {
      AppLogger.error('Token refresh failed', e);
    }
  }
  handler.next(err);
}
```

---

### 3. `/lib/presentation/providers/auth_provider.dart`
**Cambios:**
- ✅ Método `login()` ahora usa `loginWithEmail()` o `loginWithObra()` según parámetros
- ✅ Agregado log: `AppLogger.info('Login successful. User: $userEmail, Role: $roleName, ObraId in JWT: $jwtObraId')`
- ✅ Mejorado comentario en `loginWithObra()` explicando el flujo

**Código actualizado:**
```dart
/// Login user - Paso 1: Login inicial sin obra (usa /auth/email/login)
/// Para el paso 2 con obra seleccionada, usar loginWithObra()
Future<void> login(String email, String password, {String? obraId}) async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    // Determinar qué endpoint usar basado en si hay obraId
    final response = obraId != null && obraId.isNotEmpty
        ? await _apiClient.loginWithObra(
            email: email,
            password: password,
            obraId: obraId,
          )
        : await _apiClient.loginWithEmail(
            email: email,
            password: password,
          );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ... procesamiento de respuesta ...
      
      AppLogger.info('Login successful. User: $userEmail, Role: $roleName, ObraId in JWT: $jwtObraId');
      
      // ... resto del código ...
    }
  } catch (e) {
    // ... manejo de errores ...
  }
}
```

---

### 4. `/lib/core/constants/user_roles.dart` (cambios previos)
**Cambios anteriores:**
- ✅ Normalización de roles con espacios y acentos
- ✅ Manejo de "de" en "Encargado de Área"
- ✅ Logs detallados cuando falla el parsing

**Código:**
```dart
static UserRole fromString(String value) {
  final normalizedValue = value
      .toLowerCase()
      .replaceAll(' de ', '_')   // "Encargado de Área" → "encargado_área"
      .replaceAll(' ', '_')      // "Admin General" → "admin_general"
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .trim();

  try {
    return UserRole.values.firstWhere(
      (role) => role.value == normalizedValue,
      orElse: () {
        AppLogger.warning('Unknown role: $value (normalized: $normalizedValue)');
        AppLogger.info('Available roles: ${UserRole.values.map((r) => r.value).join(', ')}');
        throw ArgumentError('Unknown role: $value');
      },
    );
  } catch (e) {
    AppLogger.error('Error parsing role', e);
    rethrow;
  }
}
```

---

## 📄 Documentos Creados

### 1. `FLUJO_AUTENTICACION.md`
Documentación completa del flujo de autenticación:
- Diagramas del flujo
- Ejemplos de requests/responses
- Código Flutter de implementación
- Comandos cURL para pruebas
- Troubleshooting

---

## 🔍 Validación del Backend

### Respuesta del Login (`/auth/email/login`):
```json
{
  "token": "eyJ...",
  "refreshToken": "eyJ...",
  "tokenExpires": 1762153032694,
  "user": {
    "id": 3,
    "email": "admin.general@ingenieria.com",
    "role": {
      "id": 3,
      "name": "Admin General"  // ← Espacios y mayúsculas
    }
  }
}
```

### Respuesta de Obras (`/obras`):
```json
{
  "data": [
    {
      "id": "c13e4b9e-41f1-4273-a18e-c26699edab61",
      "nombre": "Edificio Central Plaza",
      "direccion": "Calle 100 #15-20, Bogotá D.C.",
      ...
    }
  ],
  "hasNextPage": true
}
```

---

## 🧪 Pruebas Necesarias

### Checklist:
- [ ] Login inicial funciona (endpoint `/auth/email/login`)
- [ ] Se reciben y guardan `token` + `refreshToken`
- [ ] Se puede decodificar el JWT y extraer role
- [ ] Role "Admin General" se normaliza correctamente a `admin_general`
- [ ] GET `/obras` retorna 200 con lista de obras
- [ ] Usuario puede seleccionar una obra
- [ ] Re-login con obra funciona (endpoint `/auth/ingenieria/login`)
- [ ] Nuevo JWT incluye `obra_id` en el payload
- [ ] Token refresh automático funciona cuando expira access token
- [ ] Dashboard se carga con contexto de obra

---

## 🚀 Siguientes Pasos

1. **Probar login en Flutter:**
   ```bash
   flutter run
   ```

2. **Verificar logs:**
   - Login exitoso debe mostrar: `Login successful. User: ..., Role: ..., ObraId in JWT: ...`
   - Primera vez: `ObraId in JWT: null`
   - Segunda vez (con obra): `ObraId in JWT: c13e4b9e-41f1-4273-a18e-c26699edab61`

3. **Decodificar JWT para verificar:**
   - Usar https://jwt.io
   - O usar `jwt_decoder` en Flutter
   - Verificar que después del re-login, el JWT incluye `"obra_id": "uuid..."`

4. **Probar refresh automático:**
   - Esperar 15 minutos (expiración del token)
   - Hacer una petición (ej: GET obras)
   - Verificar que se renueva automáticamente sin error

---

## 📚 Referencias

- **Swagger API:** http://localhost:3000/api/docs
- **Endpoints:**
  - Login inicial: `POST /api/v1/auth/email/login`
  - Login con obra: `POST /api/v1/auth/ingenieria/login`
  - Refresh: `POST /api/v1/auth/refresh`
  - Obras: `GET /api/v1/obras`

---

## 🐛 Problemas Resueltos

1. ✅ **Error 401 al obtener obras**
   - Causa: Token expirado
   - Solución: Interceptor ahora renueva automáticamente

2. ✅ **Refresh token fallaba**
   - Causa: Se enviaba en body en vez de header
   - Solución: Ahora se envía en `Authorization: Bearer <refreshToken>`

3. ✅ **No se guardaba nuevo refreshToken**
   - Causa: Solo se guardaba el access token
   - Solución: Ahora se guardan ambos tokens

4. ✅ **Roles no se parseaban correctamente**
   - Causa: Backend envía "Admin General" (con espacios)
   - Solución: Normalización en `UserRole.fromString()`

5. ✅ **No había dos endpoints de login**
   - Causa: Solo se usaba `/auth/ingenieria/login`
   - Solución: Ahora se usa `/auth/email/login` para paso 1 y `/auth/ingenieria/login` para paso 3
