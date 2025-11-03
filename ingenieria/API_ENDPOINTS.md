# API Endpoints - IngenierIA

Documentación completa de endpoints para consumir desde el frontend.

**Base URL:** `http://localhost:3000/api/v1`

---

## 🔐 Autenticación

### Login para IngenierIA
Autenticación con soporte de obra opcional.

```http
POST /auth/ingenieria/login
```

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "email": "admin.general@ingenieria.com",
  "password": "AdminIngenieria2024!",
  "obraId": "uuid-de-la-obra" // Opcional
}
```

**Response 200:**
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
    },
    "status": {
      "id": 1,
      "name": "Active"
    }
  }
}
```

**Errores:**
- `422` - Credenciales inválidas
- `401` - No tiene acceso a la obra especificada

---

### Login Estándar
Login original del boilerplate.

```http
POST /auth/email/login
```

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "email": "admin@example.com",
  "password": "secret"
}
```

**Response 200:** (Igual que el endpoint de IngenierIA)

---

### Obtener Usuario Actual

```http
GET /auth/me
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "id": 1,
  "email": "admin.general@ingenieria.com",
  "firstName": "Admin",
  "lastName": "General",
  "role": {
    "id": 3,
    "name": "Admin General",
    "descripcion": "Administrador general del sistema IngenierIA"
  },
  "status": {
    "id": 1,
    "name": "Active"
  },
  "createdAt": "2024-11-02T10:00:00.000Z",
  "updatedAt": "2024-11-02T10:00:00.000Z"
}
```

---

### Refresh Token

```http
POST /auth/refresh
```

**Headers:**
```
Authorization: Bearer {refreshToken}
```

**Response 200:**
```json
{
  "token": "nuevo_token_jwt",
  "refreshToken": "nuevo_refresh_token",
  "tokenExpires": 1730678400000
}
```

---

### Logout

```http
POST /auth/logout
```

**Headers:**
```
Authorization: Bearer {token}
```

**Response 204:** No Content

---

## 🏗️ Obras

### Listar Todas las Obras

```http
GET /obras?page=1&limit=10
```

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (opcional): Número de página (default: 1)
- `limit` (opcional): Items por página (default: 10, max: 50)

**Response 200:**
```json
{
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "nombre": "Edificio Central Plaza",
      "direccion": "Calle 123 #45-67, Bogotá",
      "administrador": {
        "id": 1,
        "email": "admin@obra.com",
        "firstName": "Juan",
        "lastName": "Pérez"
      },
      "createdAt": "2024-11-02T10:00:00.000Z",
      "updatedAt": "2024-11-02T10:00:00.000Z"
    }
  ],
  "hasNextPage": true
}
```

---

### Obtener Obra por ID

```http
GET /obras/{id}
```

**Headers:**
```
Authorization: Bearer {token}
```

**Path Parameters:**
- `id`: UUID de la obra

**Response 200:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "nombre": "Edificio Central Plaza",
  "direccion": "Calle 123 #45-67, Bogotá",
  "administrador": {
    "id": 1,
    "email": "admin@obra.com",
    "firstName": "Juan",
    "lastName": "Pérez",
    "role": {
      "id": 4,
      "name": "Admin Obra"
    }
  },
  "createdAt": "2024-11-02T10:00:00.000Z",
  "updatedAt": "2024-11-02T10:00:00.000Z"
}
```

**Errores:**
- `404` - Obra no encontrada

---

### Crear Nueva Obra

```http
POST /obras
```

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Roles permitidos:** `admin_general`, `admin_obra`

**Body:**
```json
{
  "nombre": "Torre Empresarial Norte",
  "direccion": "Av. Principal #100-20, Medellín",
  "administradorId": 1
}
```

**Response 201:**
```json
{
  "id": "987e6543-e21b-12d3-a456-426614174999",
  "nombre": "Torre Empresarial Norte",
  "direccion": "Av. Principal #100-20, Medellín",
  "createdAt": "2024-11-02T15:30:00.000Z",
  "updatedAt": "2024-11-02T15:30:00.000Z"
}
```

**Errores:**
- `401` - No autorizado (falta token o rol inadecuado)
- `422` - Datos de validación incorrectos

---

### Actualizar Obra

```http
PATCH /obras/{id}
```

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Roles permitidos:** `admin_general`, `admin_obra`

**Path Parameters:**
- `id`: UUID de la obra

**Body (todos los campos opcionales):**
```json
{
  "nombre": "Edificio Central Plaza - Actualizado",
  "direccion": "Nueva Dirección #123-45",
  "administradorId": 2
}
```

**Response 200:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "nombre": "Edificio Central Plaza - Actualizado",
  "direccion": "Nueva Dirección #123-45",
  "createdAt": "2024-11-02T10:00:00.000Z",
  "updatedAt": "2024-11-02T16:45:00.000Z"
}
```

**Errores:**
- `404` - Obra no encontrada
- `401` - No autorizado

---

### Eliminar Obra

```http
DELETE /obras/{id}
```

**Headers:**
```
Authorization: Bearer {token}
```

**Roles permitidos:** `admin_general`

**Path Parameters:**
- `id`: UUID de la obra

**Response 204:** No Content

**Errores:**
- `404` - Obra no encontrada
- `401` - No autorizado (solo admin_general)

---

## 👥 Gestión de Usuarios en Obras

### Asignar Usuario a Obra

```http
POST /obras/asignar-usuario
```

**Headers:**
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Roles permitidos:** `admin_general`, `admin_obra`

**Body:**
```json
{
  "userId": 2,
  "obraId": "123e4567-e89b-12d3-a456-426614174000",
  "roleId": 6
}
```

**Roles disponibles (roleId):**
- `3` - Admin General
- `4` - Admin Obra
- `5` - Encargado de Área
- `6` - Obrero
- `7` - SST (Seguridad y Salud en el Trabajo)
- `8` - Compras
- `9` - RRHH
- `10` - Consultor

**Response 201:**
```json
{
  "id": "abc12345-e89b-12d3-a456-426614174000",
  "user": {
    "id": 2,
    "email": "obrero@example.com",
    "firstName": "Carlos",
    "lastName": "González"
  },
  "obra": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "nombre": "Edificio Central Plaza"
  },
  "role": {
    "id": 6,
    "name": "Obrero",
    "descripcion": "Trabajador operativo de la obra"
  },
  "fechaAsignacion": "2024-11-02T17:00:00.000Z",
  "createdAt": "2024-11-02T17:00:00.000Z",
  "updatedAt": "2024-11-02T17:00:00.000Z"
}
```

**Errores:**
- `404` - Usuario, obra o rol no encontrado
- `401` - No autorizado

---

### Listar Usuarios de una Obra

```http
GET /obras/{id}/usuarios
```

**Headers:**
```
Authorization: Bearer {token}
```

**Path Parameters:**
- `id`: UUID de la obra

**Response 200:**
```json
[
  {
    "id": "abc12345-e89b-12d3-a456-426614174000",
    "user": {
      "id": 2,
      "email": "obrero@example.com",
      "firstName": "Carlos",
      "lastName": "González"
    },
    "role": {
      "id": 6,
      "name": "Obrero",
      "descripcion": "Trabajador operativo de la obra"
    },
    "fechaAsignacion": "2024-11-02T17:00:00.000Z"
  },
  {
    "id": "def67890-e89b-12d3-a456-426614174001",
    "user": {
      "id": 3,
      "email": "sst@example.com",
      "firstName": "María",
      "lastName": "Rodríguez"
    },
    "role": {
      "id": 7,
      "name": "SST",
      "descripcion": "Responsable de Seguridad y Salud en el Trabajo"
    },
    "fechaAsignacion": "2024-11-02T18:30:00.000Z"
  }
]
```

---

## 📋 Usuarios (Endpoints del Boilerplate)

### Listar Usuarios

```http
GET /users?page=1&limit=10
```

**Headers:**
```
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (opcional): Número de página
- `limit` (opcional): Items por página

**Response 200:**
```json
{
  "data": [
    {
      "id": 1,
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "role": {
        "id": 2,
        "name": "User"
      },
      "status": {
        "id": 1,
        "name": "Active"
      }
    }
  ],
  "hasNextPage": false
}
```

---

### Obtener Usuario por ID

```http
GET /users/{id}
```

**Headers:**
```
Authorization: Bearer {token}
```

**Path Parameters:**
- `id`: ID numérico del usuario

**Response 200:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": {
    "id": 2,
    "name": "User",
    "descripcion": "Usuario regular del sistema"
  },
  "status": {
    "id": 1,
    "name": "Active"
  },
  "createdAt": "2024-11-01T10:00:00.000Z",
  "updatedAt": "2024-11-02T12:00:00.000Z"
}
```

---

## 🎭 Roles

Los roles están predefinidos en el sistema. No hay endpoints CRUD para roles, pero puedes consultar los roles disponibles:

**Roles del Sistema:**

| ID | Nombre | Descripción | Uso |
|----|--------|-------------|-----|
| 1 | Admin | Administrador del sistema base | Gestión completa del sistema |
| 2 | User | Usuario base | Usuario estándar |
| 3 | Admin General | Administrador general IngenierIA | Acceso total a todas las obras |
| 4 | Admin Obra | Administrador de obra | Gestión de una obra específica |
| 5 | Encargado de Área | Responsable de área | Gestión de áreas dentro de obra |
| 6 | Obrero | Trabajador operativo | Operaciones en obra |
| 7 | SST | Seguridad y Salud en el Trabajo | Control de seguridad |
| 8 | Compras | Encargado de compras | Gestión de compras y suministros |
| 9 | RRHH | Recursos Humanos | Gestión de personal |
| 10 | Consultor | Consultor externo | Asesoría externa |

---

## 🔒 Códigos de Error Comunes

### Autenticación
- `401 Unauthorized` - Token inválido, expirado o no proporcionado
- `403 Forbidden` - El usuario no tiene permisos para realizar la acción

### Validación
- `422 Unprocessable Entity` - Datos de entrada inválidos
  ```json
  {
    "status": 422,
    "errors": {
      "email": "Email inválido",
      "password": "La contraseña es requerida"
    }
  }
  ```

### Recursos
- `404 Not Found` - Recurso no encontrado
  ```json
  {
    "statusCode": 404,
    "message": "Obra con ID xyz no encontrada"
  }
  ```

### Servidor
- `500 Internal Server Error` - Error interno del servidor

---

## 🔐 Autenticación con JWT

Todos los endpoints protegidos requieren el header de autorización:

```
Authorization: Bearer {token}
```

El token se obtiene del endpoint de login y tiene una duración de **24 horas**.

**Estructura del JWT Payload:**
```json
{
  "id": 1,
  "role": {
    "id": 3,
    "name": "Admin General"
  },
  "sessionId": 123,
  "email": "admin.general@ingenieria.com",
  "obra_id": "123e4567-e89b-12d3-a456-426614174000",
  "iat": 1730581234,
  "exp": 1730667634
}
```

---

## 💡 Ejemplos de Uso con JavaScript/TypeScript

### Login

```typescript
async function login(email: string, password: string, obraId?: string) {
  const response = await fetch('http://localhost:3000/api/v1/auth/ingenieria/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password, obraId }),
  });

  if (!response.ok) {
    throw new Error('Login fallido');
  }

  const data = await response.json();
  // Guardar token en localStorage o contexto
  localStorage.setItem('token', data.token);
  localStorage.setItem('refreshToken', data.refreshToken);
  
  return data;
}
```

### Crear Obra

```typescript
async function crearObra(nombre: string, direccion: string, administradorId?: number) {
  const token = localStorage.getItem('token');
  
  const response = await fetch('http://localhost:3000/api/v1/obras', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    },
    body: JSON.stringify({ nombre, direccion, administradorId }),
  });

  if (!response.ok) {
    throw new Error('Error al crear obra');
  }

  return await response.json();
}
```

### Listar Obras con Paginación

```typescript
async function listarObras(page: number = 1, limit: number = 10) {
  const token = localStorage.getItem('token');
  
  const response = await fetch(
    `http://localhost:3000/api/v1/obras?page=${page}&limit=${limit}`,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    }
  );

  if (!response.ok) {
    throw new Error('Error al listar obras');
  }

  return await response.json();
}
```

### Asignar Usuario a Obra

```typescript
async function asignarUsuarioObra(userId: number, obraId: string, roleId: number) {
  const token = localStorage.getItem('token');
  
  const response = await fetch('http://localhost:3000/api/v1/obras/asignar-usuario', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
    },
    body: JSON.stringify({ userId, obraId, roleId }),
  });

  if (!response.ok) {
    throw new Error('Error al asignar usuario');
  }

  return await response.json();
}
```

### Interceptor de Refresh Token (Ejemplo con Axios)

```typescript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:3000/api/v1',
});

// Interceptor para agregar token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Interceptor para refresh token
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = localStorage.getItem('refreshToken');
        const response = await axios.post(
          'http://localhost:3000/api/v1/auth/refresh',
          {},
          {
            headers: { Authorization: `Bearer ${refreshToken}` },
          }
        );

        const { token, refreshToken: newRefreshToken } = response.data;
        localStorage.setItem('token', token);
        localStorage.setItem('refreshToken', newRefreshToken);

        originalRequest.headers.Authorization = `Bearer ${token}`;
        return api(originalRequest);
      } catch (refreshError) {
        // Redirigir a login
        window.location.href = '/login';
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

export default api;
```

---

## 🧪 Testing con cURL

### Login
```bash
curl -X POST http://localhost:3000/api/v1/auth/ingenieria/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin.general@ingenieria.com",
    "password": "AdminIngenieria2024!"
  }'
```

### Crear Obra
```bash
curl -X POST http://localhost:3000/api/v1/obras \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "nombre": "Torre Norte",
    "direccion": "Calle 100 #20-30"
  }'
```

### Listar Obras
```bash
curl -X GET "http://localhost:3000/api/v1/obras?page=1&limit=10" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Asignar Usuario
```bash
curl -X POST http://localhost:3000/api/v1/obras/asignar-usuario \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "userId": 2,
    "obraId": "123e4567-e89b-12d3-a456-426614174000",
    "roleId": 6
  }'
```

---

## 📚 Documentación Swagger

Para una documentación interactiva y poder probar los endpoints directamente, accede a:

```
http://localhost:3000/docs
```

En Swagger podrás:
- ✅ Ver todos los endpoints disponibles
- ✅ Probar las peticiones directamente
- ✅ Ver los esquemas de datos
- ✅ Autenticarte y usar el token

---

## ⚙️ Variables de Entorno Necesarias

Asegúrate de tener configuradas estas variables en tu `.env`:

```env
# API
APP_PORT=3000
API_PREFIX=api
APP_FALLBACK_LANGUAGE=es

# Database
DATABASE_TYPE=postgres
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=ingenieria_db

# JWT
AUTH_JWT_SECRET=your-secret-key-here
AUTH_JWT_TOKEN_EXPIRES_IN=24h
AUTH_JWT_REFRESH_SECRET=your-refresh-secret-here
AUTH_JWT_REFRESH_TOKEN_EXPIRES_IN=7d
```

---

## 🚀 Usuario de Prueba

Después de ejecutar los seeders, tendrás disponible:

**Admin General:**
- Email: `admin.general@ingenieria.com`
- Password: `AdminIngenieria2024!`
- Rol: Admin General (ID: 3)

---

**Última actualización:** 2 de noviembre de 2025
