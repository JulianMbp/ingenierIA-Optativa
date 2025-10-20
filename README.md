# 🏗️ Gestión de Obra - Aplicación Flutter

Una aplicación de gestión de obra construida con Flutter y Clean Architecture, integrada con Supabase para autenticación y base de datos.

## 📋 Características

- **Autenticación completa** con Supabase
- **Roles por especialidad**: Estructura, Plomería, Electricidad, Mampostería, Acabados, Supervisor, Administrador
- **Clean Architecture** con separación clara de capas
- **Gestión de usuarios** con perfiles extendidos
- **Interfaz moderna** con Material Design 3

## 🚀 Configuración Inicial

### 1. Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com)
2. Ejecuta el script SQL en tu base de datos de Supabase:
   ```bash
   # Copia y ejecuta el contenido de supabase_tables.sql en el SQL Editor de Supabase
   ```

### 2. Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```env
# Supabase Configuration
SUPABASE_URL=tu_url_de_supabase_aqui
SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase_aqui
SUPABASE_SERVICE_ROLE_KEY=tu_clave_de_servicio_de_supabase_aqui

# App Configuration
APP_NAME=Gestión de Obra
APP_VERSION=1.0.0

# Database Configuration
DATABASE_URL=tu_url_de_base_de_datos_aqui
```

### 3. Instalar Dependencias

```bash
flutter pub get
```

### 4. Ejecutar la Aplicación

```bash
flutter run
```

## 🏗️ Arquitectura

La aplicación sigue los principios de Clean Architecture:

```
lib/
├── data/                    # Capa de Datos
│   └── repositories/        # Implementaciones de repositorios
├── domain/                  # Capa de Dominio
│   ├── entities/           # Entidades del negocio
│   ├── repositories/       # Interfaces de repositorios
│   └── usecases/          # Casos de uso
├── presentation/           # Capa de Presentación
│   ├── bloc/              # Gestión de estado con BLoC
│   ├── pages/             # Pantallas de la aplicación
│   └── widgets/           # Widgets reutilizables
└── di/                    # Inyección de Dependencias
```

## 📊 Base de Datos

### Tablas Principales

- **`roles`** - Especialidades de la obra
- **`profiles`** - Perfiles de usuarios (conectado con auth.users)
- **`projects`** - Proyectos/obras
- **`workers`** - Trabajadores
- **`attendance`** - Control de asistencia
- **`materials`** - Base de datos de materiales
- **`budgets`** - Presupuestos por especialidad
- **`daily_reports`** - Reportes diarios
- **`medical_exams`** - Exámenes médicos y de altura
- **`ats_forms`** - Formatos ATS (Análisis de Trabajo Seguro)
- **`incident_reports`** - Reportes de accidentes e incidentes

## 🔐 Autenticación

La aplicación incluye:

- **Registro de usuarios** con validación
- **Inicio de sesión** con email y contraseña
- **Recuperación de contraseña**
- **Gestión de sesiones** automática
- **Roles y permisos** por especialidad

## 🎨 Interfaz de Usuario

### Pantallas Implementadas

- **Login** - Inicio de sesión con validación
- **Registro** - Creación de cuenta con selección de rol
- **Home** - Dashboard principal con módulos de gestión

### Módulos Planificados

- 📋 **Proyectos** - Gestión de obras
- 👥 **Trabajadores** - Control de personal
- ⏰ **Asistencia** - Control diario
- 📦 **Materiales** - Stock y pedidos
- 💰 **Presupuestos** - Control de costos
- 🛡️ **Seguridad** - ATS y reportes

## 🛠️ Tecnologías Utilizadas

- **Flutter** - Framework de desarrollo
- **Supabase** - Backend como servicio
- **BLoC** - Gestión de estado
- **GetIt** - Inyección de dependencias
- **Dartz** - Programación funcional
- **Equatable** - Comparación de objetos

## 📱 Funcionalidades Actuales

✅ **Completadas:**
- Autenticación completa (login/registro)
- Gestión de usuarios con roles
- Interfaz moderna y responsive
- Navegación entre pantallas
- Validación de formularios
- Manejo de errores

🚧 **En Desarrollo:**
- Módulos de gestión específicos
- Reportes y dashboards
- Notificaciones push
- Sincronización offline

## 🔧 Desarrollo

### Estructura de Commits

```
feat: nueva funcionalidad
fix: corrección de bug
docs: documentación
style: formato de código
refactor: refactorización
test: pruebas
chore: tareas de mantenimiento
```

### Ejecutar Tests

```bash
flutter test
```

### Análisis de Código

```bash
flutter analyze
```

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Soporte

Para soporte o preguntas, contacta al equipo de desarrollo.

---

**Desarrollado con ❤️ para la gestión eficiente de obras de construcción**