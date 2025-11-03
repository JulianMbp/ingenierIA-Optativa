# 🔐 Flujo de Autenticación - IngenierIA

## 📋 Resumen del Flujo de Dos Pasos

El sistema de autenticación de IngenierIA utiliza un flujo de **dos pasos** para permitir que los usuarios seleccionen la obra en la que trabajarán:

```
┌─────────────────────────────────────────────────────────────┐
│  PASO 1: Login Inicial (sin obra)                          │
│  POST /api/v1/auth/email/login                             │
│  Body: { email, password }                                 │
│  ↓                                                          │
│  Respuesta: token + refreshToken + user (sin obra_id)      │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  PASO 2: Obtener Obras Disponibles                         │
│  GET /api/v1/obras?page=1&limit=100                        │
│  Header: Authorization Bearer <token_paso_1>               │
│  ↓                                                          │
│  Respuesta: { data: [...obras], hasNextPage: bool }        │
└─────────────────────────────────────────────────────────────┘
                          ↓
                   Usuario selecciona obra
                          ↓
┌─────────────────────────────────────────────────────────────┐
│  PASO 3: Re-Login con Obra                                 │
│  POST /api/v1/auth/ingenieria/login                        │
│  Body: { email, password, obraId }                         │
│  ↓                                                          │
│  Respuesta: nuevo token + refreshToken                     │
│  JWT ahora incluye: { obra_id: "uuid..." }                 │
└─────────────────────────────────────────────────────────────┘
                          ↓
               Dashboard con contexto de obra
```

---

## 🎯 Endpoints Utilizados

### 1. Login Inicial (Email/Password)
```bash
POST http://localhost:3000/api/v1/auth/email/login
Content-Type: application/json

{
  "email": "admin.obra1@ingenieria.com",
  "password": "secret"
}
```

**Respuesta:**
```json
{
  "token": "eyJhbGci...",
  "refreshToken": "eyJhbGci...",
  "tokenExpires": 1762153032694,
  "user": {
    "id": 4,
    "email": "admin.obra1@ingenieria.com",
    "firstName": "Admin",
    "lastName": "Obra 1",
    "role": {
      "id": 4,
      "name": "Admin Obra"
    }
  }
}
```

**JWT decodificado (sin obra_id):**
```json
{
  "id": 4,
  "role": {
    "id": 4,
    "name": "Admin Obra"
  },
  "sessionId": 18,
  "iat": 1762152201,
  "exp": 1762153101
}
```

---

### 2. Obtener Obras Disponibles
```bash
GET http://localhost:3000/api/v1/obras?page=1&limit=100
Authorization: Bearer eyJhbGci...
```

**Respuesta:**
```json
{
  "data": [
    {
      "id": "c13e4b9e-41f1-4273-a18e-c26699edab61",
      "nombre": "Edificio Central Plaza",
      "direccion": "Calle 100 #15-20, Bogotá D.C.",
      "createdAt": "2025-11-03T11:30:26.426Z",
      "updatedAt": "2025-11-03T11:30:26.426Z"
    }
  ],
  "hasNextPage": true
}
```

---

### 3. Re-Login con Obra Seleccionada
```bash
POST http://localhost:3000/api/v1/auth/ingenieria/login
Content-Type: application/json

{
  "email": "admin.obra1@ingenieria.com",
  "password": "secret",
  "obraId": "c13e4b9e-41f1-4273-a18e-c26699edab61"
}
```

**Respuesta:**
```json
{
  "token": "eyJhbGci...",  // Nuevo token con obra_id
  "refreshToken": "eyJhbGci...",
  "tokenExpires": 1762153500000,
  "user": { ... }
}
```

**JWT decodificado (CON obra_id):**
```json
{
  "id": 4,
  "role": {
    "id": 4,
    "name": "Admin Obra"
  },
  "obra_id": "c13e4b9e-41f1-4273-a18e-c26699edab61",  // ← Ahora incluye obra_id
  "sessionId": 19,
  "iat": 1762153400,
  "exp": 1762154300
}
```

---

## 💻 Implementación en Flutter

### Paso 1: Login Inicial

```dart
// En LoginScreen
final authNotifier = ref.read(authProvider.notifier);

// Login sin obra (usa /auth/email/login)
await authNotifier.login(email, password);

// Verificar si el login fue exitoso
if (authState.isAuthenticated) {
  // Navegar a la pantalla de selección de obras
  Navigator.pushReplacementNamed(context, '/select-obra');
}
```

### Paso 2: Obtener Obras

```dart
// En ObraSelectionScreen
final authNotifier = ref.read(authProvider.notifier);

try {
  // Obtiene obras usando el token del paso 1
  final obras = await authNotifier.getAvailableObras();
  
  // Mostrar lista de obras al usuario
  setState(() {
    _obras = obras;
  });
} catch (e) {
  // Manejar error (401, 500, etc.)
  print('Error al obtener obras: $e');
}
```

### Paso 3: Re-Login con Obra

```dart
// En ObraSelectionScreen - cuando usuario selecciona una obra
final selectedObraId = obras[index]['id'];
final email = authState.user!.email;
final password = _cachedPassword; // Guardar password del login inicial

// Re-login con obra (usa /auth/ingenieria/login)
final success = await authNotifier.loginWithObra(
  email,
  password,
  selectedObraId,
);

if (success) {
  // Navegar al dashboard
  Navigator.pushReplacementNamed(context, '/dashboard');
}
```

---

## 🔄 Refresh de Tokens

El sistema maneja automáticamente la renovación de tokens cuando expiran:

1. **Interceptor detecta 401** (token expirado)
2. **Envía refresh token**:
   ```bash
   POST /api/v1/auth/refresh
   Authorization: Bearer <refreshToken>
   ```
3. **Recibe nuevo par de tokens**:
   ```json
   {
     "token": "nuevo_access_token",
     "refreshToken": "nuevo_refresh_token"
   }
   ```
4. **Guarda tokens** y **reintenta** la petición original

**Código en `nestjs_api_client.dart`:**
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
              'Authorization': 'Bearer $refreshToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          final newToken = response.data['token'];
          final newRefreshToken = response.data['refreshToken'];
          
          // Guardar ambos tokens
          await _secureStorage.write(
            key: AppConstants.tokenKey,
            value: newToken,
          );
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: newRefreshToken,
          );

          // Reintentar petición con nuevo token
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

## 🧪 Pruebas con cURL

### 1. Login inicial
```bash
curl -X 'POST' \
  'http://localhost:3000/api/v1/auth/email/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "admin.obra1@ingenieria.com",
    "password": "secret"
  }'
```

### 2. Obtener obras
```bash
TOKEN="<token_del_paso_1>"

curl -X 'GET' \
  'http://localhost:3000/api/v1/obras?page=1&limit=100' \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Re-login con obra
```bash
OBRA_ID="c13e4b9e-41f1-4273-a18e-c26699edab61"

curl -X 'POST' \
  'http://localhost:3000/api/v1/auth/ingenieria/login' \
  -H 'Content-Type: application/json' \
  -d '{
    "email": "admin.obra1@ingenieria.com",
    "password": "secret",
    "obraId": "'$OBRA_ID'"
  }'
```

---

## ✅ Verificación del Flujo

### Checklist:

- [ ] **Login inicial funciona** (200 OK, recibe token sin obra_id)
- [ ] **GET /obras funciona** (200 OK, devuelve lista de obras)
- [ ] **Re-login con obra funciona** (200 OK, recibe token con obra_id)
- [ ] **JWT incluye obra_id** después del paso 3
- [ ] **Supabase RLS funciona** con obra_id del JWT
- [ ] **Refresh token automático** funciona cuando token expira

### Decodificar JWT:
```bash
# Copiar token y pegar en https://jwt.io
# O usar jwt_decoder en Flutter:

final decodedToken = JwtDecoder.decode(token);
print('obra_id: ${decodedToken['obra_id']}');
```

---

## 🚨 Solución de Problemas

### Error 401 al obtener obras
**Causa:** Token expirado  
**Solución:** El interceptor debe renovar automáticamente

### Error 500 al obtener obras
**Causa:** Backend no puede filtrar obras por usuario  
**Solución:** Verificar tabla `usuario_obras` y políticas RLS

### obra_id no aparece en JWT (paso 3)
**Causa:** Endpoint incorrecto o backend no procesa obraId  
**Solución:** Verificar que se usa `/auth/ingenieria/login` y no `/auth/email/login`

### Lista de obras vacía
**Causa:** Usuario no tiene obras asignadas  
**Solución:** Ejecutar SQL para asignar obras al usuario en Supabase

---

## 📝 Notas Importantes

1. **Dos endpoints de login diferentes:**
   - `/auth/email/login` → Login inicial (sin obra)
   - `/auth/ingenieria/login` → Login con obra (incluye obraId en JWT)

2. **El password NO se guarda** en el dispositivo:
   - Solo se guarda temporalmente en memoria durante el flujo
   - Después del paso 3, se descarta

3. **Tokens tienen tiempo de expiración:**
   - Access token: 15 minutos
   - Refresh token: ~365 días
   - El interceptor renueva automáticamente

4. **obra_id en JWT es crucial:**
   - Supabase RLS usa este valor para filtrar datos
   - Sin obra_id, las queries fallarán o no filtrarán correctamente
