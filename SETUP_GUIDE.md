# 🚀 Guía de Configuración - IngenierIA App

## 📋 Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- ✅ Flutter SDK 3.5.0+
- ✅ Dart 3.5.0+
- ✅ Android Studio / Xcode (para emuladores)
- ✅ VS Code con extensión Flutter (recomendado)

## 🔧 Configuración del Backend

### Paso 1: Actualizar la URL del API

Edita el archivo `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // 🔴 CAMBIAR ESTA URL por la de tu backend
  static const String baseUrl = 'https://tu-backend.com/api/v1';
  
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/auth/me';
  
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

### Opciones de URL según ambiente:

**Desarrollo local:**
```dart
static const String baseUrl = 'http://localhost:3000/api/v1';
// o si usas Android Emulator:
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

**Producción:**
```dart
static const String baseUrl = 'https://api.ingenieria-auth.com/api/v1';
```

## 📱 Instalación

### 1. Instalar dependencias

```bash
cd ingenieria_app
flutter pub get
```

### 2. Verificar dispositivos disponibles

```bash
flutter devices
```

### 3. Ejecutar la aplicación

**En iOS (requiere Mac):**
```bash
flutter run -d iPhone
```

**En Android:**
```bash
flutter run -d android
```

**En Chrome (para desarrollo web):**
```bash
flutter run -d chrome
```

## 🧪 Testing

### Ejecutar tests

```bash
flutter test
```

### Análisis de código

```bash
flutter analyze
```

### Formatear código

```bash
flutter format lib/
```

## 🔐 Credenciales de Prueba

Para probar la aplicación, necesitarás usuarios creados en el backend. Ejemplo:

```
Email: admin@test.com
Password: password123

Email: obrero@test.com  
Password: password123
```

## 📊 Estructura de Respuesta del Backend

La app espera estas estructuras de datos del backend:

### Login Response
```json
{
  "status": "success",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid-here",
      "email": "user@example.com",
      "name": "Usuario Test",
      "role": {
        "id": "role-id",
        "name": "Admin General",
        "permissions": ["create:materials", "read:materials", ...]
      }
    }
  }
}
```

### Profile Response
```json
{
  "status": "success",
  "data": {
    "id": "uuid-here",
    "email": "user@example.com",
    "name": "Usuario Test",
    "role": {
      "id": "role-id",
      "name": "Admin General",
      "permissions": [...]
    }
  }
}
```

## 🎨 Personalización del Tema

Para cambiar los colores de la app, edita `lib/config/theme.dart`:

```dart
// iOS Colors
static const Color iosBlue = Color(0xFF007AFF);     // Color principal
static const Color iosGreen = Color(0xFF34C759);    // Éxito
static const Color iosRed = Color(0xFFFF3B30);      // Error
// ... más colores
```

## 🛠️ Solución de Problemas

### Error: "No se puede conectar al backend"

1. Verifica que el backend esté corriendo
2. Revisa la URL en `api_config.dart`
3. Si usas Android Emulator, usa `10.0.2.2` en lugar de `localhost`
4. Verifica que no haya firewall bloqueando la conexión

### Error: "Token expirado"

El token JWT tiene un tiempo de vida. Si expira:
1. La app automáticamente cierra sesión
2. Vuelve a iniciar sesión

### Error de compilación

```bash
# Limpiar caché de Flutter
flutter clean

# Reinstalar dependencias
flutter pub get

# Intentar de nuevo
flutter run
```

### Error en iOS: "Signing for requires a development team"

1. Abre el proyecto en Xcode
2. Selecciona un equipo de desarrollo en "Signing & Capabilities"
3. O ejecuta sin firma de código para simulador

## 📱 Compilar para Producción

### Android (APK)

```bash
flutter build apk --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

### Android (App Bundle)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

Luego abre en Xcode para firmar y distribuir.

## 🔄 Hot Reload

Durante el desarrollo, usa:

- `r` - Hot reload (recarga cambios sin perder estado)
- `R` - Hot restart (reinicia la app)
- `q` - Salir

## 📝 Próximos Pasos

1. ✅ Configurar URL del backend
2. ✅ Probar login con credenciales reales
3. ✅ Verificar que el dashboard muestre los módulos correctos según rol
4. ✅ Implementar la funcionalidad de cada módulo

## 🆘 Soporte

Si encuentras problemas:

1. Revisa la consola de Flutter para errores
2. Verifica los logs del backend
3. Usa `flutter doctor` para verificar tu instalación
4. Consulta la documentación de Flutter: https://flutter.dev

---

¡Listo para desarrollar! 🚀
