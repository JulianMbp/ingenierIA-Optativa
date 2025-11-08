# Implementación de Modo Offline

## 📋 Resumen

Se ha implementado funcionalidad offline completa para la aplicación IngenierIA, permitiendo que los usuarios trabajen sin conexión a internet y sincronicen automáticamente cuando se recupere la conexión.

## ✅ Características Implementadas

### 1. Base de Datos SQLite Local
- **Archivo**: `lib/core/services/database_service.dart`
- Base de datos local para almacenar datos cuando no hay conexión
- Tablas creadas:
  - `users`: Usuarios autenticados
  - `obras`: Obras/proyectos
  - `user_obras`: Relación usuario-obra
  - `tareas`: Tareas del proyecto
  - `materiales`: Materiales
  - `bitacoras`: Bitácoras
  - `asistencias`: Asistencias
  - `pending_requests`: Cola de peticiones pendientes

### 2. Detección de Conexión
- **Archivo**: `lib/core/services/connectivity_service.dart`
- Detecta el estado de conexión a internet en tiempo real
- Verifica conexión WiFi y móvil
- Provider reactivo para cambios en la conectividad

### 3. Servicio Offline
- **Archivo**: `lib/core/services/offline_service.dart`
- Gestiona la cola de peticiones pendientes
- Marca entidades como "dirty" cuando necesitan sincronización
- Procesa peticiones pendientes cuando hay conexión

### 4. Servicio de Sincronización
- **Archivo**: `lib/core/services/sync_service.dart`
- Sincronización automática cuando se detecta conexión
- Sincronización periódica cada 30 segundos
- Se inicia automáticamente al abrir la aplicación

### 5. Repositorios con Soporte Offline

#### Tareas
- **Archivo**: `lib/core/repositories/tarea_repository.dart`
- ✅ Listar tareas (usa cache si no hay conexión)
- ✅ Crear tarea (guarda en cola si no hay conexión)
- ✅ Actualizar tarea (guarda en cola si no hay conexión)
- ✅ Eliminar tarea (guarda en cola si no hay conexión)

#### Autenticación
- **Archivo**: `lib/core/repositories/auth_repository.dart`
- ✅ Guardar usuario autenticado en SQLite
- ✅ Obtener usuario desde cache offline
- ✅ Limpiar datos al hacer logout

### 6. Notificaciones Visuales
- **Archivo**: `lib/core/widgets/offline_banner.dart`
- Banner que muestra el estado de conexión
- Indica número de peticiones pendientes
- Se muestra en Dashboard y pantalla de Tareas

### 7. Integración en Servicios
- **TareaService**: Actualizado para usar repositorio con soporte offline
- **AuthService**: Actualizado para guardar credenciales en SQLite

## 🔄 Flujo de Funcionamiento

### Modo Online
1. Usuario realiza una acción (crear/editar/eliminar)
2. Se intenta hacer la petición al servidor
3. Si es exitosa, se guarda en cache local
4. La UI se actualiza inmediatamente

### Modo Offline
1. Usuario realiza una acción
2. Se detecta que no hay conexión
3. Los datos se guardan en SQLite como "dirty"
4. La petición se agrega a la cola de peticiones pendientes
5. La UI se actualiza con los datos locales
6. Se muestra banner indicando modo offline

### Sincronización Automática
1. Se detecta que hay conexión a internet
2. El servicio de sincronización procesa la cola de peticiones
3. Se envían las peticiones pendientes al servidor
4. Si son exitosas, se marcan como sincronizadas
5. Si fallan, se incrementa el contador de reintentos
6. El banner se oculta cuando no hay peticiones pendientes

## 📦 Dependencias Agregadas

```yaml
sqflite: ^2.3.3+2
path: ^1.9.0
connectivity_plus: ^6.1.1
uuid: ^4.5.1
```

## 🚧 Pendiente por Implementar

### Repositorios Offline
- [ ] Repositorio para Materiales
- [ ] Repositorio para Bitácoras
- [ ] Repositorio para Asistencias

### Mejoras Futuras
- [ ] Sincronización incremental (solo cambios desde última sync)
- [ ] Resolución de conflictos cuando hay cambios simultáneos
- [ ] Compresión de datos para reducir tamaño de la base de datos
- [ ] Limpieza automática de datos antiguos
- [ ] Indicador de progreso de sincronización
- [ ] Sincronización manual desde UI

## 🎯 Cómo Usar

### Para Desarrolladores

1. **Usar repositorios en lugar de servicios directos**:
```dart
// ❌ Antes
final tareas = await tareaService.listTasks(obraId);

// ✅ Ahora (automático, el servicio ya usa el repositorio)
final tareas = await tareaService.listTasks(obraId);
```

2. **El banner offline se muestra automáticamente**:
```dart
// Se agrega en las pantallas principales
const OfflineBanner(),
```

3. **La sincronización es automática**:
```dart
// Se inicia automáticamente en main.dart
// No requiere acción manual
```

### Para Usuarios

1. **Trabajar normalmente**: La aplicación funciona igual con o sin conexión
2. **Ver estado**: El banner naranja indica cuando estás offline
3. **Sincronización automática**: Cuando vuelvas a tener internet, los datos se suben automáticamente
4. **Notificaciones**: El banner muestra cuántas peticiones están pendientes

## 🔍 Archivos Modificados/Creados

### Nuevos Archivos
- `lib/core/services/database_service.dart`
- `lib/core/services/connectivity_service.dart`
- `lib/core/services/offline_service.dart`
- `lib/core/services/sync_service.dart`
- `lib/core/repositories/tarea_repository.dart`
- `lib/core/repositories/auth_repository.dart`
- `lib/core/widgets/offline_banner.dart`

### Archivos Modificados
- `pubspec.yaml` - Agregadas dependencias
- `lib/main.dart` - Inicialización de sincronización
- `lib/core/services/tarea_service.dart` - Usa repositorio
- `lib/core/services/auth_service.dart` - Guarda en SQLite
- `lib/features/dashboard/dashboard_screen.dart` - Banner offline
- `lib/features/dashboard/modules/tareas_screen.dart` - Banner offline

## 📝 Notas Importantes

1. **Autenticación Offline**: El usuario puede iniciar sesión si ya había iniciado sesión antes (usa cache)
2. **Datos Locales**: Todos los datos se guardan en SQLite para acceso rápido
3. **Sincronización**: Se sincroniza automáticamente cuando hay conexión
4. **Reintentos**: Las peticiones fallidas se reintentan hasta 3 veces
5. **Limpieza**: Las peticiones antiguas (más de 7 días) se eliminan automáticamente

