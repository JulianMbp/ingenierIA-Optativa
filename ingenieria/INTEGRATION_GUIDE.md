# 🔗 Guía de Integración - IngenierIA

Esta guía explica cómo integrar el frontend Flutter con el backend NestJS y Supabase.

## 📋 Índice

1. [Arquitectura de Integración](#arquitectura-de-integración)
2. [Flujo de Autenticación](#flujo-de-autenticación)
3. [Uso del NestJS API Client](#uso-del-nestjs-api-client)
4. [Uso del Supabase Service](#uso-del-supabase-service)
5. [Políticas RLS de Supabase](#políticas-rls-de-supabase)
6. [Ejemplos de Uso](#ejemplos-de-uso)

---

## 🏗️ Arquitectura de Integración

```
┌─────────────────┐
│  Flutter App    │
└────────┬────────┘
         │
         ├──────────────┐
         │              │
         ▼              ▼
┌──────────────┐  ┌──────────────┐
│  NestJS API  │  │   Supabase   │
│  (Auth)      │  │  (Datos)     │
└──────────────┘  └──────────────┘
```

### Responsabilidades:

- **NestJS**: Autenticación, gestión de usuarios, roles y obras
- **Supabase**: Almacenamiento de datos operacionales (materiales, bitácoras, asistencias, etc.)
- **Flutter**: UI y lógica de negocio del cliente

---

## 🔐 Flujo de Autenticación

### 1. Login (NestJS)

```dart
// En auth_provider.dart
final response = await nestJsApiClient.login(
  email: email,
  password: password,
  obraId: selectedObraId, // Opcional
);
```

**Endpoint**: `POST /auth/ingenieria/login`

**Request Body**:
```json
{
  "email": "admin.general@ingenieria.com",
  "password": "AdminIngenieria2024!",
  "obraId": "uuid-opcional-de-obra"
}
```

**Response**:
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

### 2. Decodificar JWT

```dart
// El JWT contiene:
{
  "id": 1,
  "role": {
    "id": 3,
    "name": "Admin General"
  },
  "sessionId": 123,
  "email": "admin.general@ingenieria.com",
  "obra_id": "123e4567-e89b-12d3-a456-426614174000", // ⚠️ IMPORTANTE para RLS
  "iat": 1730581234,
  "exp": 1730667634
}
```

### 3. Guardar Token

```dart
// En auth_provider.dart
await secureStorage.write(key: 'jwt_token', value: token);
await secureStorage.write(key: 'refresh_token', value: refreshToken);

// CRÍTICO: También pasar el token a Supabase
await supabaseService.setAuthToken(token);
```

---

## 🔧 Uso del NestJS API Client

### Login con Obra

```dart
final nestJsClient = ref.read(nestJsApiClientProvider);

try {
  final response = await nestJsClient.login(
    email: 'admin.general@ingenieria.com',
    password: 'AdminIngenieria2024!',
    obraId: 'uuid-de-obra', // Si el usuario selecciona una obra
  );
  
  final data = response.data;
  final token = data['token'];
  final user = data['user'];
  
  // Guardar token
  await secureStorage.write(key: 'jwt_token', value: token);
  
  // Pasar token a Supabase para RLS
  await supabaseService.setAuthToken(token);
} catch (e) {
  // Manejar error
}
```

### Obtener Usuario Actual

```dart
final response = await nestJsClient.getCurrentUser();
final user = response.data;

print('Usuario: ${user['firstName']} ${user['lastName']}');
print('Rol: ${user['role']['name']}');
```

### Listar Obras

```dart
final response = await nestJsClient.getObras(page: 1, limit: 10);
final obrasData = response.data;

final obras = obrasData['data'] as List;
final hasNextPage = obrasData['hasNextPage'];

for (var obra in obras) {
  print('Obra: ${obra['nombre']} - ${obra['direccion']}');
}
```

### Crear Obra

```dart
final response = await nestJsClient.createObra(
  nombre: 'Torre Empresarial Norte',
  direccion: 'Av. Principal #100-20, Medellín',
  administradorId: 1, // Opcional
);

final nuevaObra = response.data;
print('Obra creada con ID: ${nuevaObra['id']}');
```

### Asignar Usuario a Obra

```dart
final response = await nestJsClient.assignUserToObra(
  userId: 2,
  obraId: 'uuid-de-obra',
  roleId: 6, // 6 = Obrero
);

final asignacion = response.data;
print('Usuario asignado exitosamente');
```

---

## 📊 Uso del Supabase Service

⚠️ **IMPORTANTE**: Supabase usa Row Level Security (RLS) basado en el `obra_id` del JWT.

### Configurar Token de Supabase

```dart
// SIEMPRE después de login
final token = await secureStorage.read(key: 'jwt_token');
await supabaseService.setAuthToken(token);
```

### Obtener Materiales de la Obra

```dart
final supabaseService = ref.read(supabaseServiceProvider);

// El obra_id se extrae automáticamente del JWT
final materiales = await supabaseService.getMaterials(obraId);

for (var material in materiales) {
  print('Material: ${material['nombre']} - ${material['cantidad']} ${material['unidad']}');
}
```

### Agregar Material

```dart
final nuevoMaterial = await supabaseService.addMaterial({
  'obra_id': obraId,
  'nombre': 'Cemento',
  'categoria': 'Construcción',
  'cantidad': 100,
  'unidad': 'bultos',
  'proveedor': 'Cementos Argos',
});

print('Material agregado: ${nuevoMaterial['id']}');
```

### Registrar Asistencia

```dart
await supabaseService.addAttendance({
  'obra_id': obraId,
  'usuario_id': usuarioId,
  'fecha': DateTime.now().toIso8601String(),
  'estado': 'presente',
  'observaciones': 'Trabajó en área de estructura',
});
```

### Agregar Bitácora

```dart
await supabaseService.addLog({
  'obra_id': obraId,
  'usuario_id': usuarioId,
  'descripcion': 'Avance en columnas del segundo piso',
  'avance_porcentaje': 45.5,
  'archivos': ['https://storage.url/foto1.jpg', 'https://storage.url/foto2.jpg'],
  'fecha': DateTime.now().toIso8601String(),
});
```

---

## 🔒 Políticas RLS de Supabase

Supabase usa el `obra_id` del JWT para filtrar automáticamente los datos.

### Cómo Funciona RLS

1. El JWT de NestJS incluye `obra_id` en su payload
2. Supabase lee el claim `obra_id` del JWT
3. Las políticas RLS filtran automáticamente los datos

**Política de Lectura** (ejemplo para `materiales`):
```sql
create policy "Solo ver materiales de su obra"
on public.materiales
for select
using (
  obra_id = (current_setting('request.jwt.claims'::text, true)::json ->> 'obra_id')::uuid
);
```

### ⚠️ Implicaciones Importantes

1. **El usuario solo verá datos de su obra asignada**
2. **No puede insertar datos en otra obra diferente**
3. **Si el JWT no tiene `obra_id`, NO verá ningún dato**

### Ejemplo de Flujo Completo

```dart
// 1. Login en NestJS
final loginResponse = await nestJsClient.login(
  email: 'obrero@example.com',
  password: 'password123',
  obraId: 'obra-uuid-123', // ← Se incluye en el JWT
);

final token = loginResponse.data['token'];

// 2. Configurar token en Supabase
await supabaseService.setAuthToken(token);

// 3. Consultar materiales
// RLS filtra automáticamente por obra_id = 'obra-uuid-123'
final materiales = await supabaseService.getMaterials('obra-uuid-123');
// Solo retorna materiales de la obra-uuid-123
```

---

## 💡 Ejemplos de Uso Completos

### Ejemplo 1: Login y Selección de Obra

```dart
class LoginFlow {
  final NestJsApiClient nestJsClient;
  final SupabaseService supabaseService;
  final FlutterSecureStorage secureStorage;

  Future<void> loginWithObra(String email, String password) async {
    // Paso 1: Login sin obra para obtener lista de obras disponibles
    final loginResponse = await nestJsClient.login(
      email: email,
      password: password,
    );

    final tempToken = loginResponse.data['token'];
    final user = loginResponse.data['user'];

    // Paso 2: Obtener obras disponibles
    await secureStorage.write(key: 'jwt_token', value: tempToken);
    final obrasResponse = await nestJsClient.getObras();
    final obras = obrasResponse.data['data'] as List;

    // Paso 3: Usuario selecciona una obra
    final selectedObraId = await showObraSelectionDialog(obras);

    // Paso 4: Login con obra seleccionada
    final finalLoginResponse = await nestJsClient.login(
      email: email,
      password: password,
      obraId: selectedObraId,
    );

    final finalToken = finalLoginResponse.data['token'];
    
    // Paso 5: Guardar token final
    await secureStorage.write(key: 'jwt_token', value: finalToken);
    await supabaseService.setAuthToken(finalToken);
  }
}
```

### Ejemplo 2: Dashboard del Encargado de Área

```dart
class AreaManagerDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final obraId = authState.user?.obraId;

    return FutureBuilder(
      future: Future.wait([
        ref.read(supabaseServiceProvider).getMaterials(obraId!),
        ref.read(supabaseServiceProvider).getAttendance(obraId),
        ref.read(supabaseServiceProvider).getLogs(obraId),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final materiales = snapshot.data![0];
        final asistencias = snapshot.data![1];
        final bitacoras = snapshot.data![2];

        return Column(
          children: [
            MaterialesWidget(materiales: materiales),
            AsistenciasWidget(asistencias: asistencias),
            BitacorasWidget(bitacoras: bitacoras),
          ],
        );
      },
    );
  }
}
```

### Ejemplo 3: Registro de Asistencia Diaria

```dart
class AsistenciaService {
  final SupabaseService supabaseService;
  
  Future<void> registrarAsistenciaDiaria(
    String obraId,
    List<String> usuariosPresentes,
  ) async {
    final hoy = DateTime.now().toIso8601String().split('T')[0];

    for (final usuarioId in usuariosPresentes) {
      await supabaseService.addAttendance({
        'obra_id': obraId,
        'usuario_id': usuarioId,
        'fecha': hoy,
        'estado': 'presente',
        'observaciones': null,
      });
    }
  }
}
```

---

## 🐛 Debugging y Troubleshooting

### Verificar Token JWT

```dart
import 'package:jwt_decoder/jwt_decoder.dart';

final token = await secureStorage.read(key: 'jwt_token');
final decodedToken = JwtDecoder.decode(token!);

print('User ID: ${decodedToken['id']}');
print('Email: ${decodedToken['email']}');
print('Rol: ${decodedToken['role']['name']}');
print('Obra ID: ${decodedToken['obra_id']}'); // ← Crítico para RLS
print('Expira: ${DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000)}');
```

### Verificar RLS en Supabase

Si no ves datos en Supabase:

1. Verifica que el JWT tiene `obra_id`
2. Verifica que el `obra_id` coincide con los datos en la tabla
3. Verifica que el token se configuró en Supabase: `await supabaseService.setAuthToken(token)`

### Logs de Red

El `NestJsApiClient` ya incluye un `_LoggingInterceptor` que registra todas las peticiones:

```
[REQUEST] POST /auth/ingenieria/login
[REQUEST DATA] {email: admin@..., password: ***}
[RESPONSE] 200 {token: eyJ..., user: {...}}
```

---

## 📝 Checklist de Integración

Antes de hacer login:
- [ ] Variables de entorno configuradas en `.env`
- [ ] `ApiConfig.load()` ejecutado en `main.dart`
- [ ] Supabase inicializado con URL y anon key
- [ ] Servicios registrados en providers

Durante el login:
- [ ] Endpoint correcto: `/auth/ingenieria/login`
- [ ] Email y password válidos
- [ ] Opcional: `obraId` si se requiere acceso a obra específica

Después del login:
- [ ] Token guardado en `FlutterSecureStorage`
- [ ] Refresh token guardado
- [ ] Token configurado en Supabase: `setAuthToken(token)`
- [ ] JWT decodificado para extraer `obra_id`
- [ ] Usuario navegado a dashboard correcto según rol

---

## 🔄 Flujo de Refresh Token

```dart
class TokenRefreshInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        // Obtener refresh token
        final refreshToken = await secureStorage.read(key: 'refresh_token');
        
        // Solicitar nuevo token
        final response = await nestJsClient.refreshToken(refreshToken!);
        
        final newToken = response.data['token'];
        final newRefreshToken = response.data['refreshToken'];
        
        // Guardar nuevos tokens
        await secureStorage.write(key: 'jwt_token', value: newToken);
        await secureStorage.write(key: 'refresh_token', value: newRefreshToken);
        
        // Actualizar Supabase
        await supabaseService.setAuthToken(newToken);
        
        // Reintentar request original
        return handler.resolve(await _retry(err.requestOptions));
      } catch (e) {
        // Refresh falló, cerrar sesión
        await logout();
      }
    }
    
    return handler.next(err);
  }
}
```

---

## 🎯 Próximos Pasos

1. **Implementar data layer**: Crear modelos y repository implementations
2. **Agregar manejo de errores**: Crear excepciones específicas
3. **Implementar Drift**: Para caché local y offline-first
4. **Agregar tests**: Unit tests para servicios y providers
5. **Implementar navegación**: Con go_router según roles

---

**Última actualización**: 3 de noviembre de 2025
