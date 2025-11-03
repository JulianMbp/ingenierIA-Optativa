1) Resumen rápido de roles

Admin General — acceso total (super-admin).

Admin Obra — administra recursos de las obras que tiene asignadas. CRUD completo en materiales/bitácoras/presupuestos/documentos/asistencias de sus obras. Puede crear obras y asignar usuarios.

Supervisor — nivel operativo/gestión: ver materiales, crear/editar bitácoras (pero no eliminar globalmente), ver presupuestos, ver asistencias.

RRHH — gestión de asistencias y usuarios; puede crear/editar asistencias y ver usuarios.

Operario — perfil más limitado: ver materiales y bitácoras, crear su propia bitácora y registrar su asistencia; no administra obras ni presupuestos.

2) Mapa de permisos (endpoints → roles)

Leyenda: C = Create, R = Read, U = Update, D = Delete, — = no access, (own) = solamente sobre sus propios recursos.

Autenticación / user info

POST /auth/login
Todos (C) — para autenticarse.

GET /auth/me
Todos (R) — devuelve info del usuario logueado.

GET /auth/my-obras
Todos (R) — lista obras a las que pertenece el usuario.

POST /auth/switch-obra
Todos con >1 obra (C) — produce nuevo token con obra seleccionada.

Obras

GET /obras?page=&limit= (list all)
Admin General: R; Admin Obra: R (solo sus obras vía my-obras); Supervisor/RRHH/Operario: R (solo sus obras via my-obras).

POST /obras (create)
Admin General: C; Admin Obra: — (si quieres permitir Admin Obra crear obras, cambiar a C).

POST /obras/asignar-usuario
Admin General: C; Admin Obra: C (si lo has permitido en backend para su propia obra). Otros: —.

Materiales (obra scoped: /obras/:obraId/materiales)

GET /obras/:obraId/materiales
Admin General: R; Admin Obra: R; Supervisor: R; RRHH: R (si necesitas); Operario: R

GET /obras/:obraId/materiales?filters...
Igual que GET list.

GET /obras/:obraId/materiales/:id
Igual que GET list (R).

POST /obras/:obraId/materiales
Admin General: C; Admin Obra: C; Supervisor: — or C (si Supervisor puede proponer compras — decide). Operario/RRHH: —.

PATCH /obras/:obraId/materiales/:id
Admin General: U; Admin Obra: U; Supervisor: — (puede depender); Operario: —.

DELETE /obras/:obraId/materiales/:id
Admin General: D; Admin Obra: D (si lo permites); Otros: —.

Bitácoras ( /obras/:obraId/bitacoras )

GET /obras/:obraId/bitacoras
Admin General: R; Admin Obra: R; Supervisor: R; RRHH: R; Operario: R

GET /obras/:obraId/bitacoras/:id
Igual que GET list.

POST /obras/:obraId/bitacoras
Admin General: C; Admin Obra: C; Supervisor: C; Operario: C (puede crear sus propias entradas)

PATCH /obras/:obraId/bitacoras/:id
Admin General: U; Admin Obra: U; Supervisor: U (si es autor o si el sistema lo permite); Operario: U (solo own)

Regla: si author != user entonces solo Admin General / Admin Obra / Supervisor pueden editar.

DELETE /obras/:obraId/bitacoras/:id
Admin General: D; Admin Obra: D; Supervisor: — (o D solo own?); Operario: — (normalmente no).

Asistencias (/obras/:obraId/asistencias)

GET /obras/:obraId/asistencias
Admin General: R; Admin Obra: R; Supervisor: R; RRHH: R; Operario: R (ver sus propias)

GET /obras/:obraId/asistencias/:id
Igual.

POST /obras/:obraId/asistencias
Admin General: C; Admin Obra: C; RRHH: C; Supervisor: C?; Operario: C (si la app permite automarcar asistencia)

PATCH /obras/:obraId/asistencias/:id
Admin General: U; Admin Obra: U; RRHH: U; Operario: U (own only)

DELETE /obras/:obraId/asistencias/:id
Admin General: D; Admin Obra: D; RRHH: D (si la política lo permite); Operario: —.

Activity Logs (/logs)

GET /logs
Admin General: R only. (posible paginado)
Otros: —.

Usuarios & Roles (/users, /roles)

GET /users
Admin General: R; Admin Obra: R (solo sus usuarios?); RRHH: R (si lo permites) ; Otros: —.

GET /roles
Admin General: R; Admin Obra: R; Supervisor/RRHH/Operario: R (si quieres que puedan ver lista de roles).

POST /users (create user)
Admin General: C; RRHH: C (si RRHH maneja onboarding) ; Admin Obra: — (o C solo para su obra, según política).

PATCH /users/:id
Admin General: U; RRHH: U (perfil / password resets); Admin Obra: U (si es de su obra).

DELETE /users/:id
Admin General: D; RRHH: — (opcional).

3) Reglas y excepciones importantes (resumen operacional)

Tenant validation: cada ruta obras/:obraId/... debe validar que obraId coincide con el contexto del JWT o con las obras listadas en auth/my-obras. Si no, 403 Forbidden.

Own-only rules:

Bitácoras: usuarios pueden editar/eliminar solo sus propias bitácoras (a menos que role permita lo contrario).

Asistencias: un usuario sólo puede crear/editar su propia asistencia para una fecha; RRHH/Admin pueden manipular registros de otros.

Activity logs: registrar user_id, obra_id (si aplica), action, metadata en cada operación de escritura.

Switch-obra: si lo mantienes, POST /auth/switch-obra debe devolver token con obra_id claim; solo usuarios con >1 obra pueden usarlo.

Paginación y filtros: endpoints listables usan page, limit y filters[...] (como en Postman). Respetar permisos en queries filtradas.

Validaciones de negocio:

avance_porcentaje en bitácoras → 0..100.

cantidad en materiales → >= 0.

Unicidad: (obra_id, usuario_id, fecha) en asistencias.

4) Snippet JSON para frontend (visibilidad UI por rol)

Pega esto en tu Flutter app y úsalo para decidir qué módulos mostrar en el Dashboard.

{
  "Admin General": {
    "modules": ["materials","bitacoras","asistencias","presupuestos","documentos","logs","users","obras"]
  },
  "Admin Obra": {
    "modules": ["materials","bitacoras","asistencias","presupuestos","documentos","users"]
  },
  "Supervisor": {
    "modules": ["materials","bitacoras","asistencias"]
  },
  "RRHH": {
    "modules": ["asistencias","users"]
  },
  "Operario": {
    "modules": ["materials","bitacoras","asistencias"]
  }
}


Regla en Flutter: tras login decodifica role.name del JWT y usa ese objeto para construir el menú.

5) Recomendaciones técnicas rápidas para implementación


Frontend (Flutter):

Después de login: decodifica JWT (ej. jwt_decoder) → guarda accessToken seguro y role.name.

Mostrar/ocultar módulos en dashboard según JSON de permisos.

Para cada petición a /obras/:obraId/... enviar Authorization: Bearer <token>.

Manejar 401/403: si 403 mostrar mensaje "No tienes permisos para realizar esta acción" y deshabilitar UI.


1) Ejemplo concreto — permisos por endpoint (compacto)
Endpoint	Admin General	Admin Obra	Supervisor	RRHH	Operario
POST /auth/login	C	C	C	C	C
GET /auth/me	R	R	R	R	R
GET /auth/my-obras	R	R	R	R	R
POST /auth/switch-obra	C (if multi)	C (if multi)	—	—	—
GET /obras	R	R	—	—	—
POST /obras	C	—	—	—	—
POST /obras/asignar-usuario	C	C (own)	—	—	—
GET /obras/:id/materiales	R	R	R	R	R
POST /obras/:id/materiales	C	C	—	—	—
PATCH /obras/:id/materiales/:m	U	U	—	—	—
DELETE /obras/:id/materiales/:m	D	D (policy)	—	—	—
GET /obras/:id/bitacoras	R	R	R	R	R
POST /obras/:id/bitacoras	C	C	C	—	C
PATCH /obras/:id/bitacoras/:b	U	U	U (own or team)	—	U (own only)
DELETE /obras/:id/bitacoras/:b	D	D	—	—	—
GET /obras/:id/asistencias	R	R	R	R	R
POST /obras/:id/asistencias	C	C	—	C	C (own)
PATCH /obras/:id/asistencias/:a	U	U	—	U	U (own)
GET /logs	R	—	—	—	—
GET /users	R	R (own obra)	—	R	—
GET /roles	R	R	R	R	R

(ajusta según tus políticas internas — esto es la propuesta coherente con la colección Postman)