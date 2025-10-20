# 🚀 Configuración de Supabase - Guía Paso a Paso

## 📋 Pasos para Configurar Supabase

### 1. Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. Inicia sesión o crea una cuenta
3. Haz clic en "New Project"
4. Completa la información:
   - **Name**: `gestión-obra` (o el nombre que prefieras)
   - **Database Password**: Crea una contraseña segura
   - **Region**: Selecciona la más cercana a tu ubicación
5. Haz clic en "Create new project"

### 2. Obtener Credenciales

Una vez creado el proyecto:

1. Ve a **Settings** → **API**
2. Copia los siguientes valores:
   - **Project URL** (ejemplo: `https://rcpiimlkeeazxpqpnytz.supabase.co`)
   - **anon public** key (la clave larga que empieza con `eyJ...`)

### 3. Configurar Variables de Entorno

Actualiza tu archivo `.env` con las credenciales:

```env
SUPABASE_URL=https://tu-proyecto-id.supabase.co
SUPABASE_ANON_KEY=tu_clave_anonima_aqui
SUPABASE_SERVICE_ROLE_KEY=tu_clave_de_servicio_aqui
```

### 4. Ejecutar Scripts SQL

#### Paso 4.1: Crear Tablas
1. Ve a **SQL Editor** en tu proyecto de Supabase
2. Copia y pega el contenido completo de `supabase_tables.sql`
3. Haz clic en **Run** para ejecutar el script

#### Paso 4.2: Insertar Datos de Prueba
1. En el **SQL Editor**, copia y pega el contenido de `supabase_seed_data.sql`
2. Haz clic en **Run** para ejecutar el script

### 5. Configurar Autenticación

#### Paso 5.1: Configurar Email
1. Ve a **Authentication** → **Settings**
2. En **Auth Providers**, asegúrate de que **Email** esté habilitado
3. **IMPORTANTE**: En **Email Confirmation**, DESHABILITA la confirmación por email:
   - Busca "Enable email confirmations" y ponlo en **OFF/DISABLED**
   - Esto permite que los usuarios se registren sin necesidad de confirmar su email
4. Guarda los cambios

#### Paso 5.2: Configurar RLS (Row Level Security)
Las políticas ya están configuradas en el script SQL, pero puedes verificar en:
- **Authentication** → **Policies**

### 6. Verificar Configuración

#### Verificar Tablas Creadas
1. Ve a **Table Editor**
2. Deberías ver las siguientes tablas:
   - `roles`
   - `profiles`
   - `projects`
   - `workers`
   - `attendance`
   - `materials`
   - `budgets`
   - `daily_reports`
   - `medical_exams`
   - `ats_forms`
   - `incident_reports`

#### Verificar Datos de Prueba
1. En **Table Editor**, selecciona la tabla `roles`
2. Deberías ver 7 roles creados
3. Selecciona la tabla `projects`
4. Deberías ver 1 proyecto de prueba

### 7. Probar la Aplicación

1. Ejecuta la aplicación:
   ```bash
   flutter run
   ```

2. Intenta crear una cuenta nueva
3. Revisa los logs en la consola para ver si hay errores

## 🔧 Solución de Problemas

### Error: "Error al crear la cuenta"

**Posibles causas:**
1. **Tablas no creadas**: Ejecuta el script `supabase_tables.sql`
2. **Trigger no funciona**: El trigger para crear perfiles automáticamente podría fallar
3. **RLS muy restrictivo**: Las políticas de seguridad podrían estar bloqueando la inserción

**Solución:**
1. Verifica que todas las tablas estén creadas
2. Revisa los logs en la consola de Flutter
3. Ve a **Authentication** → **Users** en Supabase para ver si el usuario se creó

### Error: "Error al obtener perfil de usuario"

**Posibles causas:**
1. **Perfil no creado**: El trigger no funcionó
2. **RLS bloqueando**: Las políticas no permiten leer el perfil

**Solución:**
1. Ve a **Table Editor** → `profiles` y verifica si existe el perfil
2. Si no existe, créalo manualmente o ejecuta el script de nuevo

### Error de Conexión

**Posibles causas:**
1. **URL incorrecta**: Verifica que la URL en `.env` sea correcta
2. **Clave incorrecta**: Verifica que la clave anónima sea correcta
3. **Proyecto no activo**: El proyecto podría estar pausado

**Solución:**
1. Verifica las credenciales en `.env`
2. Ve a tu proyecto en Supabase y verifica que esté activo

## 📱 Logs de Debug

La aplicación ahora incluye logs detallados. Cuando ejecutes la app, verás en la consola:

```
🔐 Intentando crear cuenta para: usuario@email.com
📧 Respuesta de Supabase: [user-id]
📧 Email confirmado: [timestamp o null]
👤 Creando perfil manualmente para: [user-id]
✅ Perfil creado exitosamente
✅ Usuario creado exitosamente: Nombre Usuario
```

Si ves errores, compártelos para poder ayudarte mejor.

## 🎯 Próximos Pasos

Una vez que la autenticación funcione:

1. **Probar login** con una cuenta creada
2. **Verificar roles** en la pantalla de inicio
3. **Desarrollar módulos** específicos de gestión de obra

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs en la consola
2. Verifica la configuración en Supabase
3. Asegúrate de que todos los scripts SQL se ejecutaron correctamente
