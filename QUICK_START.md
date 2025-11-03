# ⚡ Quick Start - IngenierIA App

## 🚀 Inicio Rápido en 3 Pasos

### 1️⃣ Configurar Backend
Edita `lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://localhost:3000/api/v1';  // Tu backend
```

### 2️⃣ Instalar y Ejecutar
```bash
cd ingenieria_app
flutter pub get
flutter run
```

### 3️⃣ Probar Login
Usa credenciales de tu backend, por ejemplo:
```
Email: admin@test.com
Password: password123
```

---

## 📁 Archivos Importantes

- `lib/main.dart` - Punto de entrada
- `lib/config/api_config.dart` - Configuración del API
- `lib/features/auth/login_screen.dart` - Pantalla de login
- `lib/features/dashboard/dashboard_screen.dart` - Dashboard principal

---

## 🎯 Estructura Rápida

```
lib/
├── config/          → Configuración (API, tema, rutas)
├── core/
│   ├── models/      → User, Role, JwtPayload
│   ├── services/    → API, Auth, Storage
│   └── widgets/     → Componentes reutilizables
└── features/
    ├── auth/        → Login
    ├── dashboard/   → Dashboard + Módulos
    └── profile/     → Perfil
```

---

## 🔧 Comandos Útiles

```bash
# Ejecutar app
flutter run

# Ver dispositivos
flutter devices

# Limpiar build
flutter clean && flutter pub get

# Análisis de código
flutter analyze

# Tests
flutter test

# Hot reload durante desarrollo
Presiona 'r' en la consola
```

---

## 📚 Documentación Completa

- `README_APP.md` - Documentación principal
- `SETUP_GUIDE.md` - Guía detallada de configuración
- `PROJECT_SUMMARY.md` - Resumen completo del proyecto

---

## ✅ Checklist Inicial

- [ ] Backend corriendo en `localhost:3000`
- [ ] URL actualizada en `api_config.dart`
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Dispositivo/emulador disponible
- [ ] Credenciales de prueba listas
- [ ] App ejecutándose (`flutter run`)

---

**¡Listo para comenzar! 🎉**
