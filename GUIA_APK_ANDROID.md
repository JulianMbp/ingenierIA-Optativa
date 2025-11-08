# 🤖 Guía para Crear e Instalar APK en Android

Esta guía te explica cómo crear un archivo APK y instalarlo directamente en tu dispositivo Android.

## 🚀 Construir el APK

### Método Rápido (Script Automático):
```bash
./build_android_apk.sh
```

### Método Manual:
```bash
# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Construir APK Release
flutter build apk --release
```

El archivo APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Instalar el APK en tu Dispositivo Android

### OPCIÓN 1: Transferencia Directa (⭐ RECOMENDADO)

**Pasos:**

1. **Transferir el APK a tu dispositivo:**
   - **USB**: Conecta tu teléfono, copia el archivo APK
   - **Google Drive/Dropbox**: Sube el APK y descárgalo en tu teléfono
   - **Email**: Envíatelo a ti mismo y descárgalo
   - **AirDroid**: Usa apps como AirDroid para transferencia inalámbrica
   - **WhatsApp/Telegram**: Envía el archivo a ti mismo

2. **Habilitar instalación desde fuentes desconocidas:**
   - Ve a **Configuración → Seguridad**
   - Activa **"Instalar aplicaciones desconocidas"** o **"Fuentes desconocidas"**
   - O cuando intentes instalar, Android te pedirá permiso para esa app específica

3. **Instalar el APK:**
   - Abre el administrador de archivos en tu dispositivo
   - Navega hasta donde guardaste el APK
   - Toca el archivo APK
   - Toca **"Instalar"**
   - Espera a que se complete la instalación
   - Toca **"Abrir"** o busca la app en el menú

### OPCIÓN 2: ADB (Android Debug Bridge)

Si tienes tu dispositivo conectado por USB:

```bash
# Conectar dispositivo
adb devices

# Instalar APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Requisitos:**
- USB Debugging activado en tu dispositivo
- ADB instalado en tu computadora
- Drivers USB instalados

### OPCIÓN 3: Google Play Internal Testing

Para distribución más profesional:

1. Crea una cuenta de desarrollador en Google Play Console
2. Sube el APK a Google Play Console
3. Crea un grupo de prueba interna
4. Comparte el enlace con los testers
5. Los testers pueden instalar desde Google Play

## 📋 Requisitos Previos

Antes de construir el APK, asegúrate de tener:

1. **Flutter instalado:**
   ```bash
   flutter --version
   ```

2. **Android SDK instalado:**
   - Descarga Android Studio
   - Instala el Android SDK
   - Configura las variables de entorno

3. **Java JDK instalado:**
   - Flutter requiere Java JDK 11 o superior

4. **Verificar configuración:**
   ```bash
   flutter doctor
   ```

## 🔍 Verificar que el APK se Construyó Correctamente

Después de construir, verifica:

```bash
# Ver información del APK
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Ver el tamaño (debería ser varios MB)
du -h build/app/outputs/flutter-apk/app-release.apk
```

## 📦 Variantes del APK

### APK Único (Universal):
```bash
flutter build apk --release
```
- Compatible con todos los dispositivos
- Tamaño más grande
- Un solo archivo APK

### APK Dividido por ABI (Arquitectura):
```bash
flutter build apk --split-per-abi
```
- Genera APKs separados por arquitectura (arm64-v8a, armeabi-v7a, x86_64)
- Tamaño más pequeño por APK
- Múltiples archivos APK

Los archivos estarán en:
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

**Recomendación:** Para la mayoría de casos, usa el APK universal.

## 🎯 Configuración del Proyecto

### Versión de la App

La versión se configura en `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

- `1.0.0` = versionName (versión visible para el usuario)
- `1` = versionCode (número de build interno)

### Nombre de la App

Se configura en `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:label="Ingenieria App"
    ...
```

### Icono de la App

Los iconos están en:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`

Puedes reemplazarlos con tus propios iconos.

### Permisos

Los permisos se declaran en `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

## ⚠️ Solución de Problemas

### Error: "Flutter command not found"
```bash
# Agrega Flutter al PATH
export PATH="$PATH:/ruta/a/flutter/bin"

# O usa la ruta completa
/path/to/flutter/bin/flutter build apk --release
```

### Error: "Android SDK not found"
- Instala Android Studio
- Configura ANDROID_HOME en las variables de entorno
- Ejecuta `flutter doctor --android-licenses`

### Error: "Gradle build failed"
```bash
# Limpia el proyecto
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

### El APK no se instala en el dispositivo
- Verifica que "Fuentes desconocidas" esté activado
- Asegúrate de que el APK no esté corrupto
- Verifica que haya suficiente espacio en el dispositivo
- Revisa los logs: `adb logcat`

## 🔒 Firmar el APK para Producción

Para publicar en Google Play, necesitas firmar el APK:

1. **Generar keystore:**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. **Configurar signing en `android/app/build.gradle.kts`:**
   ```kotlin
   signingConfigs {
       create("release") {
           storeFile = file("upload-keystore.jks")
           storePassword = System.getenv("KEYSTORE_PASSWORD")
           keyAlias = "upload"
           keyPassword = System.getenv("KEY_PASSWORD")
       }
   }
   buildTypes {
       getByName("release") {
           signingConfig = signingConfigs.getByName("release")
       }
   }
   ```

3. **Construir APK firmado:**
   ```bash
   flutter build apk --release
   ```

## 📊 Tamaños Típicos del APK

- **APK Universal**: ~15-30 MB
- **APK por ABI**: ~8-15 MB cada uno
- **APK Bundle (AAB)**: Para Google Play, más optimizado

## ✅ Checklist Antes de Distribuir

- [ ] APK construido en modo release
- [ ] Versión actualizada en `pubspec.yaml`
- [ ] Icono de la app actualizado
- [ ] Nombre de la app configurado
- [ ] Permisos necesarios declarados
- [ ] APK probado en dispositivo real
- [ ] APK firmado (para producción)

## 🎉 ¡Listo!

Una vez que tengas el APK, puedes:
- Instalarlo directamente en tu dispositivo
- Compartirlo con otros para pruebas
- Subirlo a Google Play Console
- Distribuirlo por cualquier medio

**¡Disfruta probando tu app! 🚀**

