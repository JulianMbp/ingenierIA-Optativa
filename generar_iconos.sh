#!/bin/bash

# Script para generar los iconos de la aplicación IngenierIA

echo "🔧 Generando iconos de la aplicación..."
echo ""

# Verificar que Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter no está instalado o no está en el PATH"
    echo "Por favor, instala Flutter o agrégalo al PATH"
    exit 1
fi

# Verificar que la imagen existe
if [ ! -f "assets/image.png" ]; then
    echo "❌ Error: No se encuentra la imagen assets/image.png"
    exit 1
fi

echo "✅ Imagen encontrada: assets/image.png"
echo ""

# Instalar dependencias
echo "📦 Instalando dependencias..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Error al instalar dependencias"
    exit 1
fi

echo ""
echo "🎨 Generando iconos..."
flutter pub run flutter_launcher_icons

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ ¡Iconos generados exitosamente!"
    echo ""
    echo "Los iconos se han generado en:"
    echo "  - Android: android/app/src/main/res/mipmap-*/"
    echo "  - iOS: ios/Runner/Assets.xcassets/AppIcon.appiconset/"
    echo ""
    echo "💡 Ahora puedes reconstruir la aplicación para ver los nuevos iconos:"
    echo "   flutter run"
else
    echo ""
    echo "❌ Error al generar los iconos"
    exit 1
fi

