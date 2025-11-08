# Instrucciones para Generar el Icono de la Aplicación

Se ha configurado `flutter_launcher_icons` para generar automáticamente los iconos de la aplicación usando la imagen `assets/image.png`.

## Pasos para generar los iconos:

### Opción 1: Usar el script automatizado (Recomendado)

Simplemente ejecuta el script que se creó:

```bash
./generar_iconos.sh
```

### Opción 2: Comandos manuales

1. **Instalar las dependencias:**
   ```bash
   flutter pub get
   ```

2. **Generar los iconos:**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

   O si prefieres usar el comando más corto:
   ```bash
   dart run flutter_launcher_icons
   ```

3. **Verificar que los iconos se generaron correctamente:**
   - En Android: Los iconos se generarán en `android/app/src/main/res/mipmap-*/`
   - En iOS: Los iconos se generarán en `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Configuración aplicada:

- **Imagen fuente:** `assets/image.png`
- **Plataformas:** Android e iOS
- **Nota:** Se usa la imagen completa. Si deseas usar iconos adaptativos de Android (mejor apariencia), necesitarías una versión de la imagen sin fondo transparente.

## Notas:

- Si la imagen es muy grande, el paquete la redimensionará automáticamente
- Los iconos adaptativos de Android usarán el color de fondo especificado
- Después de generar los iconos, reconstruye la aplicación para ver los cambios

## Solución de problemas:

Si encuentras algún problema al generar los iconos:

1. Verifica que la imagen `assets/image.png` existe en la carpeta `assets/`
2. Asegúrate de que la imagen tenga un formato válido (PNG recomendado)
3. Verifica que el archivo `pubspec.yaml` tenga la configuración correcta de `flutter_launcher_icons`
4. Si el problema persiste, intenta limpiar el proyecto:
   ```bash
   flutter clean
   flutter pub get
   dart run flutter_launcher_icons
   ```

