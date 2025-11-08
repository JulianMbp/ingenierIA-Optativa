#!/bin/bash

# Script para construir un APK de Android
# El APK se puede instalar directamente en cualquier dispositivo Android

echo "🤖 Construyendo APK para Android..."
echo ""

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Construir el APK en modo release
echo "🔨 Construyendo APK Release (esto puede tardar varios minutos)..."
flutter build apk --release

# Verificar si se creó el APK
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    echo ""
    echo "✅ ¡APK construido exitosamente!"
    echo "📍 Ubicación: $APK_PATH"
    echo ""
    
    # Obtener el tamaño del archivo
    FILE_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "📊 Tamaño del APK: $FILE_SIZE"
    echo ""
    
    # Obtener información del APK
    echo "ℹ️  Información del APK:"
    echo "   - Nombre: app-release.apk"
    echo "   - Modo: Release"
    echo "   - Listo para instalar en dispositivos Android"
    echo ""
    
    echo "📱 Para instalar en tu dispositivo Android:"
    echo ""
    echo "OPCIÓN 1 - Transferencia directa (Recomendado):"
    echo "  1. Transfiere el archivo APK a tu dispositivo Android"
    echo "     - Usa USB: Copia el archivo a tu teléfono"
    echo "     - Usa Google Drive/Dropbox: Sube y descarga"
    echo "     - Usa email: Envíatelo a ti mismo"
    echo "     - Usa AirDroid o similar"
    echo ""
    echo "  2. En tu dispositivo Android:"
    echo "     - Abre el archivo APK desde el administrador de archivos"
    echo "     - Si aparece 'Instalar desde fuentes desconocidas',"
    echo "       permite la instalación en Configuración"
    echo "     - Toca 'Instalar'"
    echo "     - ¡Listo! La app estará instalada"
    echo ""
    echo "OPCIÓN 2 - ADB (si tienes el dispositivo conectado):"
    echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    echo "OPCIÓN 3 - Google Play Internal Testing:"
    echo "  - Sube el APK a Google Play Console"
    echo "  - Crea un grupo de prueba interna"
    echo "  - Comparte el enlace de prueba"
    echo ""
    
    # Crear una carpeta de distribución si no existe
    if [ ! -d "dist" ]; then
        mkdir -p dist
    fi
    
    # Copiar el APK a la carpeta dist con un nombre más amigable
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    DIST_APK="dist/ingenieria_app_${TIMESTAMP}.apk"
    cp "$APK_PATH" "$DIST_APK"
    echo "📋 También copiado a: $DIST_APK"
    echo ""
    
else
    echo "❌ Error: No se pudo construir el APK"
    echo "💡 Revisa los errores arriba y asegúrate de tener:"
    echo "  - Flutter instalado y en el PATH"
    echo "  - Android SDK instalado"
    echo "  - Java JDK instalado"
    echo "  - Variables de entorno configuradas correctamente"
    echo ""
    echo "Ejecuta 'flutter doctor' para verificar la configuración"
    exit 1
fi

echo "✨ ¡Proceso completado!"

