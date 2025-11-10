# IngenierIA - Sistema de Gestión de Obras

Sistema completo de gestión de obras de ingeniería desarrollado en Flutter, diseñado con Clean Architecture para mantener un código escalable, mantenible y testeable.

## 📋 Descripción

IngenierIA es una aplicación móvil multiplataforma que permite gestionar obras de ingeniería de manera eficiente. Incluye módulos para gestión de materiales, tareas, bitácoras de trabajo, asistencias, documentos, logs y un chat con IA para asistencia inteligente.

## 🚀 Características Principales

### Módulos Disponibles
- **Autenticación y Seguridad**: Sistema de login con JWT y almacenamiento seguro de credenciales
- **Gestión de Proyectos**: Selección y gestión de múltiples proyectos de obra
- **Materiales**: Control y gestión de materiales de construcción
- **Tareas**: Gestión de tareas y asignaciones del proyecto
- **Bitácoras de Trabajo**: Registro detallado de actividades diarias
- **Asistencias**: Control de asistencia del personal
- **Documentos**: Gestión y visualización de documentos del proyecto
- **Logs**: Registro de eventos y actividades del sistema
- **Chat IA**: Asistente inteligente con IA para consultas y generación de informes

### Funcionalidades Técnicas
- **Modo Offline**: Funcionalidad completa sin conexión a internet
- **Sincronización Automática**: Sincronización automática cuando se detecta conexión
- **Almacenamiento Local**: Almacenamiento seguro de datos locales
- **Gestión de Estado**: Riverpod para gestión de estado reactiva
- **Navegación**: GoRouter para navegación declarativa
- **Generación de PDFs**: Generación de informes y documentos en PDF
- **Diseño Moderno**: UI/UX moderna con Glassmorphism y Google Fonts

## 🏗️ Arquitectura

El proyecto sigue los principios de **Clean Architecture**, organizando el código en capas bien definidas:

```
lib/
├── config/              # Configuración de la aplicación
│   ├── api_config.dart  # Configuración de API y endpoints
│   ├── router.dart      # Configuración de rutas
│   └── theme.dart       # Tema de la aplicación
│
├── core/                # Capa core - Lógica de negocio
│   ├── models/          # Modelos de datos
│   ├── repositories/    # Repositorios (interfaz de datos)
│   ├── services/        # Servicios de negocio
│   └── widgets/         # Widgets reutilizables
│
└── features/            # Capa de presentación - Features
    ├── auth/            # Módulo de autenticación
    ├── dashboard/       # Dashboard principal
    ├── projects/        # Gestión de proyectos
    ├── profile/         # Perfil de usuario
    └── obras/           # Gestión de obras
```

### Capas de la Arquitectura

1. **Capa de Presentación (Features)**: Widgets y pantallas de la UI
2. **Capa de Dominio (Core/Repositories)**: Lógica de negocio y reglas de dominio
3. **Capa de Datos (Core/Services)**: Acceso a datos, APIs y almacenamiento local

### Servicios Principales

- **ApiService**: Comunicación con el backend
- **AuthService**: Autenticación y autorización
- **StorageService**: Almacenamiento seguro local
- **OfflineService**: Gestión de modo offline
- **SyncService**: Sincronización automática de datos
- **ConnectivityService**: Detección de conectividad
- **MaterialService**: Gestión de materiales
- **TaskService**: Gestión de tareas
- **WorkLogService**: Gestión de bitácoras
- **AttendanceService**: Gestión de asistencias
- **ProjectService**: Gestión de proyectos
- **WorkLogAIService**: Servicio de IA para bitácoras
- **PdfService**: Generación de documentos PDF

## 📦 Requisitos

### Desarrollo
- **Flutter SDK**: ^3.9.0
- **Dart SDK**: ^3.9.0
- **Android Studio / VS Code**: IDE para desarrollo
- **Git**: Control de versiones

### Plataformas Soportadas
- Android (minSdk: 21)
- iOS
- Web
- Windows
- Linux
- macOS

## 🛠️ Instalación

### 1. Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd clean-architecture
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Configurar el Ambiente

Edita el archivo `lib/config/api_config.dart` para configurar el ambiente:

```dart
static const Environment _environment = Environment.development; // o Environment.production
```

### 4. Generar Iconos de la Aplicación (Opcional)

```bash
flutter pub run flutter_launcher_icons
```

## 🚀 Cómo Ejecutar

### Modo Desarrollo

1. **Conectar un dispositivo o iniciar un emulador**:
   - Android: `flutter devices`
   - iOS: Requiere Mac y Xcode

2. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

3. **Ejecutar en un dispositivo específico**:
   ```bash
   flutter run -d <device-id>
   ```

### Modo Desarrollo con Hot Reload

```bash
flutter run
# Presiona 'r' para hot reload
# Presiona 'R' para hot restart
# Presiona 'q' para salir
```

### Ejecutar Tests

```bash
flutter test
```

## 📱 Lanzamiento en Producción

### 1. Configurar Ambiente de Producción

Edita `lib/config/api_config.dart`:

```dart
static const Environment _environment = Environment.production;
```

Asegúrate de que la URL de producción esté configurada:
```dart
static const String _productionUrl = 'https://ingeniera.julian-mnp.pro/api/v1';
```

### 2. Build para Android (APK)

```bash
flutter build apk --release
```

El APK se generará en: `build/app/outputs/flutter-apk/app-release.apk`

**O usar el script proporcionado**:
```bash
chmod +x build_android_apk.sh
./build_android_apk.sh
```

### 3. Build para Android (App Bundle)

```bash
flutter build appbundle --release
```

El archivo AAB se generará en: `build/app/outputs/bundle/release/app-release.aab`

### 4. Build para iOS

```bash
flutter build ios --release
```

Luego abre el proyecto en Xcode y archiva para App Store Connect.

### 5. Build para Web

```bash
flutter build web --release
```

Los archivos se generarán en: `build/web/`

### 6. Build para Windows

```bash
flutter build windows --release
```

### 7. Build para macOS

```bash
flutter build macos --release
```

### 8. Build para Linux

```bash
flutter build linux --release
```

## 🌐 Servidor en Producción

**URL del Servidor**: https://ingeniera.julian-mnp.pro

**Endpoint Base de API**: https://ingeniera.julian-mnp.pro/api/v1

### Endpoints Principales

- **Autenticación**: `/auth/login`
- **Perfil de Usuario**: `/auth/me`
- **Proyectos**: `/projects`
- **Materiales**: `/materials`
- **Tareas**: `/tasks`
- **Bitácoras**: `/work-logs`
- **Asistencias**: `/attendance`
- **Documentos**: `/documents`

## 📚 Dependencias Principales

- **flutter_riverpod**: ^3.0.3 - Gestión de estado
- **dio**: ^5.9.0 - Cliente HTTP
- **go_router**: ^16.3.0 - Navegación
- **flutter_secure_storage**: ^9.2.4 - Almacenamiento seguro
- **jwt_decoder**: ^2.0.1 - Decodificación de JWT
- **google_fonts**: ^6.3.2 - Fuentes de Google
- **connectivity_plus**: ^6.1.1 - Detección de conectividad
- **printing**: ^5.13.3 - Impresión y PDFs
- **pdf**: ^3.11.1 - Generación de PDFs
- **glassmorphism**: ^3.0.0 - Efectos de diseño

Ver `pubspec.yaml` para la lista completa de dependencias.

## 🔒 Seguridad

- Autenticación basada en JWT
- Almacenamiento seguro de tokens con `flutter_secure_storage`
- Validación de credenciales en el backend
- Timeouts configurados para peticiones HTTP
- Manejo seguro de errores y excepciones

## 📱 Funcionalidad Offline

La aplicación incluye soporte completo para modo offline:

- **Almacenamiento Local**: Los datos se guardan localmente cuando no hay conexión
- **Sincronización Automática**: Cuando se detecta conexión, los datos se sincronizan automáticamente
- **Cola de Peticiones**: Las peticiones fallidas se almacenan y se reintentan automáticamente
- **Detección de Conectividad**: Monitoreo constante del estado de la conexión

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage
```

## 📖 Documentación Adicional

Para más información sobre Flutter, consulta:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## 🤝 Contribuciones

Este es un proyecto privado. Para contribuciones, por favor contacta al desarrollador.

## 📝 Changelog

### Versión 1.0.0
- Versión inicial
- Implementación de todos los módulos principales
- Soporte offline
- Sincronización automática
- Integración con IA

## 🐛 Reporte de Bugs

Para reportar bugs, por favor abre un issue en el repositorio o contacta al desarrollador.

## 📞 Soporte

Para soporte técnico, contacta a: Julian Bastidas

## 👤 Autor

**Julian Bastidas**

Desarrollado con ❤️ por Julian Bastidas

---

## 📄 Licencia

Copyright (c) 2024 Julian Bastidas. Todos los derechos reservados.

### Licencia de Código Abierto con Restricciones Comerciales

Este software y su código fuente están disponibles bajo los siguientes términos:

#### Uso Personal y Educativo
- ✅ Puedes usar este código para propósitos personales y educativos
- ✅ Puedes estudiar el código y aprender de él
- ✅ Puedes modificar el código para tu uso personal

#### Uso Comercial
- ❌ **NO** puedes usar este código para propósitos comerciales sin autorización
- ❌ **NO** puedes distribuir versiones modificadas comercialmente
- ❌ **NO** puedes usar este código en productos comerciales sin una licencia

#### Requisitos para Uso Comercial
Si deseas usar este código para propósitos comerciales, debes:

1. Contactar a **Julian Bastidas** para obtener una licencia comercial
2. Pagar la tarifa de licencia acordada
3. Obtener autorización escrita antes de usar el código comercialmente

#### Restricciones
- No puedes eliminar los avisos de copyright
- No puedes usar el nombre del autor para promocionar productos derivados sin permiso
- No puedes sublicenciar este código

#### Exención de Responsabilidad
Este software se proporciona "tal cual", sin garantías de ningún tipo, expresas o implícitas.

Para obtener una licencia comercial, contacta a: **Julian Bastidas**

---

**Todos los derechos reservados © 2024 Julian Bastidas**
