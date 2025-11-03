# 📱 IngenierIA Flutter App

Aplicación móvil para gestión de obras de construcción, conectada al backend NestJS de IngenierIA.

## ✨ Características

- 🎨 **Diseño iOS 18 Glassmorphism**: Interfaz moderna con efectos de vidrio
- 🏗️ **Clean Architecture**: Estructura modular y escalable
- 🔐 **Autenticación JWT**: Login seguro con tokens
- 👥 **Dashboard basado en roles**: Diferentes vistas según permisos
- �� **State Management con Riverpod**: Gestión de estado reactiva
- 🚀 **Navegación con GoRouter**: Rutas declarativas

## 🧩 Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada
├── config/                        # Configuración global
│   ├── api_config.dart           # URLs y endpoints
│   ├── theme.dart                # Tema iOS 18
│   └── router.dart               # Rutas de navegación
├── core/                         # Lógica compartida
│   ├── services/                 # Servicios
│   │   ├── api_service.dart     # Cliente HTTP (Dio)
│   │   ├── auth_service.dart    # Autenticación
│   │   └── storage_service.dart # Almacenamiento seguro
│   ├── models/                   # Modelos de datos
│   │   ├── user.dart
│   │   ├── role.dart
│   │   └── jwt_payload.dart
│   └── widgets/                  # Widgets reutilizables
│       ├── glass_container.dart # Efecto glassmorphism
│       ├── primary_button.dart  # Botón principal
│       └── input_field.dart     # Campo de entrada
└── features/                     # Características
    ├── auth/                     # Autenticación
    │   ├── login_screen.dart
    │   └── auth_provider.dart
    ├── dashboard/                # Panel principal
    │   ├── dashboard_screen.dart
    │   └── modules/             # Módulos de la app
    │       ├── materiales_screen.dart
    │       ├── bitacoras_screen.dart
    │       ├── asistencias_screen.dart
    │       ├── presupuestos_screen.dart
    │       ├── documentos_screen.dart
    │       └── logs_screen.dart
    └── profile/                  # Perfil de usuario
        └── profile_screen.dart
```

## 🚀 Instalación

### Prerrequisitos

- Flutter SDK 3.5.0 o superior
- Dart 3.5.0 o superior
- iOS 12.0+ / Android 6.0+

### Pasos

1. **Instalar dependencias**:
   ```bash
   flutter pub get
   ```

2. **Configurar el backend**:
   - Edita `lib/config/api_config.dart` y actualiza la URL del backend:
   ```dart
   static const String baseUrl = 'https://tu-backend.com/api/v1';
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## 📦 Dependencias Principales

| Paquete | Versión | Propósito |
|---------|---------|-----------|
| `flutter_riverpod` | ^3.0.3 | State management |
| `dio` | ^5.9.0 | Cliente HTTP |
| `go_router` | ^16.3.0 | Navegación |
| `flutter_secure_storage` | ^9.2.4 | Almacenamiento seguro |
| `jwt_decoder` | ^2.0.1 | Decodificación JWT |
| `google_fonts` | ^6.3.2 | Fuentes personalizadas |
| `glassmorphism` | ^3.0.0 | Efectos de vidrio |

## 🎯 Roles y Módulos

### Admin General
- ✅ Materiales
- ✅ Bitácoras
- ✅ Asistencias
- ✅ Presupuestos
- ✅ Documentos
- ✅ Logs

### Admin Obra
- ✅ Materiales
- ✅ Bitácoras
- ✅ Presupuestos

### Obrero
- ✅ Asistencias
- ✅ Bitácoras

### RRHH
- ✅ Asistencias

### SST
- ✅ Documentos
- ✅ Bitácoras

## 🔐 Autenticación

La app utiliza JWT tokens para autenticación:

1. Usuario ingresa email y password
2. Backend valida credenciales
3. Backend retorna token JWT + datos de usuario
4. Token se almacena de forma segura
5. Token se envía en cada request (header Authorization)

## 🎨 Tema y Diseño

- **Colores iOS 18**: Blue, Green, Red, Orange, Purple, Pink, Teal, Yellow
- **Glassmorphism**: Efectos de blur y transparencia
- **Fuentes**: Google Fonts (Inter como alternativa a SF Pro)
- **Componentes**: Diseño consistente con iOS

## 🧪 Testing

```bash
# Ejecutar tests
flutter test

# Análisis de código
flutter analyze

# Formatear código
flutter format lib/
```

## 📝 Próximos Pasos

- [ ] Implementar funcionalidad de cada módulo
- [ ] Agregar paginación en listados
- [ ] Implementar refresh token
- [ ] Agregar modo offline
- [ ] Implementar notificaciones push
- [ ] Agregar soporte para múltiples idiomas
- [ ] Agregar tests unitarios y de integración

## 👨‍💻 Desarrollo

### Agregar un nuevo módulo

1. Crear pantalla en `lib/features/dashboard/modules/`
2. Agregar ruta en `lib/config/router.dart`
3. Actualizar permisos en `dashboard_screen.dart`

### Agregar un nuevo servicio

1. Crear archivo en `lib/core/services/`
2. Crear provider en el archivo correspondiente
3. Inyectar dependencias via Riverpod

---

**Desarrollado con ❤️ usando Flutter**
