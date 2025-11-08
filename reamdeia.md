Skip to content
 
Search Gists
Search...
All gists
Back to GitHub
@JulianMbp
JulianMbp/markdown
Created now
Code
Revisions
2
Clone this repository at &lt;script src=&quot;https://gist.github.com/JulianMbp/a5062aaa3afe81beb3eea29be589d7ea.js&quot;&gt;&lt;/script&gt;
<script src="https://gist.github.com/JulianMbp/a5062aaa3afe81beb3eea29be589d7ea.js"></script>
readme.md
markdown
# 🔍 Sistema de Detección de Objetos Peligrosos en Equipaje por Rayos X

Sistema completo de visión computacional para detectar objetos prohibidos (armas, cuchillos, líquidos) en escáneres de rayos X como apoyo a seguridad aeroportuaria.

## 📋 Tabla de Contenidos

1. [Características](#-características)
2. [Arquitectura del Sistema](#-arquitectura-del-sistema)
3. [Arquitectura de YOLOv8](#-arquitectura-de-yolov8-detallada)
4. [Instalación](#-instalación)
5. [Uso](#-uso)
6. [Modelos Utilizados](#-modelos-utilizados)
7. [Sistema de Aprendizaje](#-sistema-de-aprendizaje)
8. [Estructura del Proyecto](#-estructura-del-proyecto)

---

## ✨ Características

- 🔍 **Detección automática** de objetos peligrosos en imágenes de rayos X
- 🖼️ **Interfaz gráfica** intuitiva para carga y visualización de imágenes
- 🤖 **Asistente inteligente** para consultas sobre normativa de objetos peligrosos
- 📊 **Visualización** con cuadros delimitadores de objetos detectados
- 🎯 **Modelo híbrido** YOLOv8 + YOLOv3 para máxima cobertura
- 📚 **Sistema de aprendizaje** por retroalimentación manual
- 🎨 **Código de colores** para diferenciar tipos de objetos

---

## 🏗️ Arquitectura del Sistema

### Visión General

El sistema utiliza un enfoque híbrido que combina dos modelos de detección para maximizar la precisión y cobertura:

```
┌─────────────────────────────────────────────────────────┐
│              IMAGEN DE RAYOS X                         │
└─────────────────────────────────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   PREPROCESAMIENTO             │
        │   (Redimensionar, Normalizar)  │
        └───────────────────────────────┘
                        ↓
    ┌───────────────────┴───────────────────┐
    ↓                                       ↓
┌───────────────────┐              ┌───────────────────┐
│   YOLOv8          │              │   YOLOv3          │
│   (Principal)     │              │   (Complementario)│
│                   │              │                   │
│ • Especializado   │              │ • Dataset COCO    │
│   en armas        │              │ • 80 clases       │
│ • Alta precisión  │              │ • Detecta:        │
│ • Anchor-free     │              │   - Botellas      │
│                   │              │   - Cuchillos     │
│ Detecta:          │              │   - Rifles        │
│ - Pistolas        │              │                   │
│ - Rifles          │              │                   │
│ - Armas           │              │                   │
└───────────────────┘              └───────────────────┘
    ↓                                       ↓
    └───────────────────┬───────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   COMBINACIÓN Y FILTRADO       │
        │   - Eliminar duplicados (NMS) │
        │   - Detección por forma        │
        │   - Categorización             │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   ANOTACIONES MANUALES         │
        │   (Si existen para la imagen)  │
        └───────────────────────────────┘
                        ↓
        ┌───────────────────────────────┐
        │   RESULTADOS FINALES           │
        │   - Bounding boxes coloreados   │
        │   - Categorías                 │
        │   - Probabilidades             │
        └───────────────────────────────┘
```

### Componentes Principales

1. **Detector YOLOv8**: Modelo principal especializado en detección de armas
2. **Detector YOLOv3**: Modelo complementario para objetos adicionales
3. **Sistema de Aprendizaje**: Ajusta parámetros basado en retroalimentación
4. **Asistente de Normativa**: Proporciona información sobre objetos peligrosos
5. **Interfaz Gráfica**: Permite carga de imágenes y visualización de resultados

---

## 🧠 Arquitectura de YOLOv8 (Detallada)

### ¿Qué es YOLOv8?

YOLOv8 (You Only Look Once version 8) es una red neuronal convolucional (CNN) de última generación diseñada para detectar objetos en tiempo real con alta precisión. A diferencia de sistemas que requieren múltiples pasadas, YOLOv8 detecta todos los objetos en una sola pasada por la red.

### Estructura de la Arquitectura

YOLOv8 se compone de tres componentes principales que trabajan en conjunto:

```
┌─────────────────────────────────────────────────────────┐
│           IMAGEN DE ENTRADA (640x640x3)                │
│           [Alto x Ancho x Canales RGB]                 │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│              BACKBONE (Columna Vertebral)              │
│                                                         │
│  Función: Extraer características de la imagen        │
│                                                         │
│  Arquitectura: CSPDarknet                              │
│  - Capas Convolucionales (Conv2D)                      │
│  - Bloques CSP (Cross Stage Partial)                   │
│  - Batch Normalization                                 │
│  - Activación SiLU                                     │
│                                                         │
│  Proceso:                                              │
│  640x640x3 → Conv → 320x320x64  (Bordes)              │
│            → CSP → 160x160x128  (Formas simples)      │
│            → CSP → 80x80x256    (Patrones complejos)   │
│            → CSP → 40x40x512    (Características)      │
│            → CSP → 20x20x1024   (Objetos completos)   │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│              NECK (Cuello)                              │
│                                                         │
│  Función: Combinar características a múltiples escalas │
│                                                         │
│  Componentes:                                          │
│  - FPN (Feature Pyramid Network)                      │
│  - PAN (Path Aggregation Network)                      │
│                                                         │
│  Proceso:                                              │
│  P5 (20x20)  ← Alto nivel, objetos grandes            │
│  P4 (40x40)  ← Nivel medio                            │
│  P3 (80x80)  ← Bajo nivel, objetos pequeños           │
│      ↓                                                  │
│  FPN: Combina de arriba hacia abajo                    │
│      ↓                                                  │
│  PAN: Combina de abajo hacia arriba                    │
│      ↓                                                  │
│  Características multi-escala listas                   │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│              HEAD (Cabeza de Detección)                 │
│                                                         │
│  Función: Convertir características en predicciones    │
│                                                         │
│  Arquitectura: DESACOPLADA (Decoupled Head)            │
│                                                         │
│  ┌─────────────────────────────────────┐              │
│  │  Características del Neck           │              │
│  └──────────────┬──────────────────────┘              │
│                 ↓                                      │
│      ┌──────────┴──────────┐                          │
│      ↓                     ↓                          │
│  Clasificación        Localización                    │
│  (¿Qué es?)           (¿Dónde está?)                 │
│      ↓                     ↓                          │
│    Clase              Bounding Box                    │
│  Probabilidad        (x, y, w, h)                    │
│                                                         │
│  Ventajas:                                            │
│  ✓ Mejor precisión                                    │
│  ✓ Entrenamiento más estable                          │
│  ✓ Mayor flexibilidad                                 │
└─────────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────────┐
│         RESULTADOS: Objetos Detectados                 │
│                                                         │
│  Para cada objeto:                                     │
│  - Coordenadas (x1, y1, x2, y2)                      │
│  - Clase (pistol, knife, bottle, etc.)                │
│  - Confianza (0.0 - 1.0)                              │
│  - Probabilidad (%)                                    │
└─────────────────────────────────────────────────────────┘
```

### Componentes Detallados

#### 1. Backbone (CSPDarknet)

**¿Qué hace?**
El backbone es la "columna vertebral" de la red. Su función es extraer características relevantes de la imagen de entrada mediante capas convolucionales.

**Cómo funciona:**
- **Capas Convolucionales**: Detectan patrones locales (bordes, texturas, formas)
- **Bloques CSP**: Mejoran el flujo de información y reducen el costo computacional
- **Batch Normalization**: Normaliza las activaciones para acelerar el entrenamiento
- **Activación SiLU**: Introduce no-linealidad necesaria para aprender patrones complejos

**Progresión de características:**
```
Nivel 1 (320x320): Detecta bordes y texturas básicas
Nivel 2 (160x160): Detecta formas simples (círculos, rectángulos)
Nivel 3 (80x80):   Detecta patrones complejos (partes de objetos)
Nivel 4 (40x40):   Detecta características de objetos (mango de pistola)
Nivel 5 (20x20):   Detecta objetos completos (pistola completa)
```

#### 2. Neck (FPN + PAN)

**¿Qué hace?**
El neck combina información de diferentes niveles de abstracción para detectar objetos de todos los tamaños.

**FPN (Feature Pyramid Network):**
- Combina características de niveles altos (objetos grandes) con niveles bajos (objetos pequeños)
- Permite detectar rifles grandes y pistolas pequeñas en la misma imagen

**PAN (Path Aggregation Network):**
- Refuerza la información de bajo nivel hacia arriba
- Mejora la detección de objetos pequeños y detalles finos

**Ventaja:**
Un rifle grande (detectado en nivel alto) y una pistola pequeña (detectado en nivel bajo) pueden ser identificados simultáneamente.

#### 3. Head (Decoupled Detection Head)

**¿Qué hace?**
Convierte las características procesadas en predicciones finales: qué objeto es y dónde está.

**Arquitectura Desacoplada:**
- **Clasificación**: Determina qué tipo de objeto es (pistol, knife, bottle)
- **Localización**: Determina dónde está el objeto (coordenadas del bounding box)
- **Separación**: Estas dos tareas se realizan en ramas separadas

**Ventajas sobre arquitectura acoplada:**
- Mayor precisión en ambas tareas
- Entrenamiento más estable
- Mejor generalización

### Redes Neuronales Convolucionales (CNNs)

#### Concepto Fundamental

Las CNNs imitan el procesamiento visual del cerebro humano:
1. **Primeras capas**: Detectan características simples (bordes, colores)
2. **Capas intermedias**: Detectan patrones complejos (formas, texturas)
3. **Capas finales**: Detectan objetos completos (armas, cuchillos)

#### Tipos de Capas

**A) Convolución (Conv2D)**
```python
# Concepto:
Filtro 3x3 se desliza sobre la imagen
    ↓
Multiplica y suma valores
    ↓
Detecta patrones específicos
```

**Ejemplos de filtros:**
- Filtro vertical → detecta bordes verticales (lados de pistolas)
- Filtro horizontal → detecta bordes horizontales (cañones)
- Filtros complejos → detectan formas específicas de armas

**B) Pooling (MaxPool)**
```python
# Reduce tamaño manteniendo información importante
4x4 → MaxPool → 2x2
# Mantiene el valor máximo de cada región
```

**C) Batch Normalization**
- Normaliza las activaciones entre capas
- Acelera el entrenamiento
- Mejora la estabilidad

**D) Activación (SiLU)**
```python
SiLU(x) = x * sigmoid(x)
# Introduce no-linealidad necesaria para aprender
```

### Proceso de Detección Completo

#### Paso 1: Preprocesamiento
```python
Imagen original (cualquier tamaño)
    ↓
Redimensionar a 640x640 (tamaño estándar YOLOv8)
    ↓
Normalizar valores [0-255] → [0-1]
    ↓
Convertir a tensor PyTorch
    ↓
Tensor: (1, 3, 640, 640)
# [batch_size, canales, alto, ancho]
```

#### Paso 2: Forward Pass (Backbone)
```python
Tensor (1, 3, 640, 640)
    ↓ [Backbone procesa]
Características multi-escala:
    - P3: (1, 256, 80, 80)   # Objetos pequeños
    - P4: (1, 512, 40, 40)   # Objetos medianos
    - P5: (1, 1024, 20, 20)  # Objetos grandes
```

#### Paso 3: Neck (Combinación)
```python
P3, P4, P5 → FPN (Feature Pyramid Network)
    ↓
Características fusionadas de arriba hacia abajo
    ↓
P3, P4, P5 → PAN (Path Aggregation Network)
    ↓
Características fusionadas de abajo hacia arriba
    ↓
Características multi-escala optimizadas
```

#### Paso 4: Head (Predicción)
```python
Para cada escala (P3, P4, P5):
    ↓
Rama de Clasificación:
    - ¿Qué objeto es? (pistol, knife, bottle)
    - Probabilidad para cada clase
    ↓
Rama de Localización:
    - ¿Dónde está? (x, y, ancho, alto)
    - Coordenadas del bounding box
    ↓
Confianza:
    - ¿Qué tan seguro está? (0.0 - 1.0)
```

#### Paso 5: Post-procesamiento
```python
# En nuestro código (detector_yolov8.py):
results = self.model(ruta_imagen, conf=0.05, iou=0.25)

# Procesar resultados:
for result in results:
    boxes = result.boxes
    for box in boxes:
        # Extraer información
        x1, y1, x2, y2 = box.xyxy[0]      # Coordenadas
        confidence = box.conf[0]           # Confianza
        class_id = box.cls[0]              # ID de clase
        class_name = model.names[class_id]  # Nombre
        
        # Determinar categoría
        if 'gun' in class_name.lower():
            categoria = 'arma'
        elif 'knife' in class_name.lower():
            categoria = 'arma blanca'
        # ...
```

### Características Específicas de YOLOv8

#### 1. Anchor-Free (Sin Anclas)

**YOLOv3 (Anchor-based):**
```python
# Usa anclas predefinidas de diferentes tamaños
Anclas: [10x13, 16x30, 33x23, ...]
    ↓
Predice offset desde anclas
    ↓
Bounding box final
```

**YOLOv8 (Anchor-free):**
```python
# Predice directamente las coordenadas
Características
    ↓
Predicción directa (x, y, w, h)
    ↓
Bounding box final
```

**Ventajas:**
- Más simple (menos parámetros)
- Más rápido
- Mejor precisión

#### 2. C2f Block (CSP with 2 convolutions)

```python
Input
  ↓
Split (dividir en dos caminos)
  ↓
Camino 1: Conv → Conv → Conv
Camino 2: (directo)
  ↓
Concat (combinar caminos)
  ↓
Output (características más ricas)
```

**Ventaja:** Mejor flujo de información y características más ricas.

#### 3. Loss Function Mejorada

- **Clasificación**: BCE Loss (Binary Cross Entropy)
- **Localización**: Distribution Focal Loss
- **Objetos**: BCE Loss

**Resultado:** Mejor convergencia durante el entrenamiento.

### Comparación: YOLOv8 vs YOLOv3

| Característica | YOLOv3 | YOLOv8 |
|----------------|--------|--------|
| **Backbone** | Darknet-53 | CSPDarknet (mejorado) |
| **Anclas** | Sí (anchor-based) | No (anchor-free) |
| **Head** | Acoplado | Desacoplado |
| **Detección** | 3 escalas fijas | Múltiples escalas optimizadas |
| **Precisión** | Buena | Mejor |
| **Velocidad** | Buena | Mejor |
| **Objetos pequeños** | Buena | Mejor |
| **Especialización** | Genérico | Puede ser especializado |

---

## 🚀 Instalación

### Requisitos Previos

- Python 3.8 o superior
- 8GB RAM mínimo (recomendado 16GB)
- Espacio en disco: ~2GB (para modelos)

### Instalación Rápida

```bash
# 1. Clonar o descargar el proyecto
git clone <url-del-repositorio>
cd "inteligencia artificial"

# 2. Instalar dependencias
pip install -r requirements.txt

# 3. Ejecutar la aplicación
python main.py
```

**Nota:** Los modelos se descargarán automáticamente la primera vez:
- YOLOv8: ~50MB (desde Hugging Face)
- YOLOv3: ~250MB (desde ImageAI)

### Dependencias Principales

```
ultralytics>=8.0.0      # YOLOv8
imageai>=3.0.0          # YOLOv3
opencv-python>=4.5.0    # Procesamiento de imágenes
pillow>=9.0.0           # Manipulación de imágenes
numpy>=1.21.0           # Operaciones numéricas
tkinter                 # Interfaz gráfica (incluido en Python)
```

---

## 📖 Uso

### Interfaz Gráfica

Ejecutar la aplicación principal:
```bash
python main.py
```

**Funcionalidades:**
1. 📁 **Cargar imagen**: Botón "Seleccionar Imagen"
2. 🔍 **Detectar objetos**: Botón "Detectar Objetos"
3. ✏️ **Marcar manualmente**: Botón "Marcar Objetos Manualmente"
4. 📊 **Ver resultados**: Imagen con bounding boxes coloreados

### Código de Colores

- 🔴 **Rojo**: Objetos peligrosos con alta confianza (armas)
- 🟠 **Naranja**: Líquidos detectados
- 🔵 **Azul**: Objetos que necesitan revisión (baja confianza)
- 🟢 **Verde**: Objetos aprendidos de anotaciones manuales

### Uso Programático

Ver `ejemplo_uso.py` para ejemplos de código:

```python
from detector_yolov8 import DetectorYOLOv8

# Inicializar detector
detector = DetectorYOLOv8()

# Detectar objetos
resultados = detector.detectar_objetos(
    ruta_imagen="imagen.jpg",
    imagen_salida="resultado.jpg"
)

# Procesar resultados
print(f"Objetos detectados: {resultados['total_detectados']}")
print(f"Objetos peligrosos: {resultados['total_peligrosos']}")

for obj in resultados['objetos_peligrosos']:
    print(f"- {obj['nombre']}: {obj['probabilidad']:.1f}%")
```

---

## 🤖 Modelos Utilizados

### 1. YOLOv8 (Modelo Principal)

**Fuente:** Hugging Face - `Hadi959/weapon-detection-yolov8`

**Características:**
- ✅ Pre-entrenado específicamente para detección de armas
- ✅ Arquitectura YOLOv8 (última generación)
- ✅ Alta precisión en armas de fuego
- ✅ No requiere entrenamiento adicional

**Objetos que detecta:**
- Pistolas (pistol)
- Rifles (rifle)
- Armas en general (gun, weapon, firearm)

### 2. YOLOv3 (Modelo Complementario)

**Fuente:** ImageAI - Modelo pre-entrenado COCO

**Características:**
- ✅ Dataset COCO (80 clases)
- ✅ Detecta objetos que YOLOv8 puede pasar por alto
- ✅ Especialmente útil para botellas y cuchillos

**Objetos que detecta:**
- Cuchillos (knife)
- Botellas (bottle)
- Rifles (rifle)
- Objetos adicionales del dataset COCO

### ¿Por qué Combinar Ambos?

1. **Cobertura más amplia**: YOLOv8 para armas + YOLOv3 para otros objetos
2. **Redundancia**: Si uno falla, el otro puede detectar
3. **Mejor precisión**: Combinación de fortalezas de ambos modelos
4. **Especialización**: YOLOv8 especializado + YOLOv3 generalista

---

## 🧠 Sistema de Aprendizaje

### ¿Cómo Funciona?

El sistema aprende de las correcciones manuales del usuario para mejorar la detección automática.

#### Proceso:

1. **Detección Automática**
   - Sistema detecta objetos automáticamente
   - Puede pasar por alto algunos objetos

2. **Corrección Manual**
   - Usuario marca objetos faltantes manualmente
   - Selecciona categoría (arma, arma blanca, líquido)

3. **Guardado de Anotaciones**
   - Se guardan en `anotaciones_manuales/`
   - Formato JSON con coordenadas y categorías

4. **Análisis de Patrones**
   - Sistema analiza las anotaciones manuales
   - Identifica patrones (objetos pequeños, formas específicas)

5. **Ajuste de Parámetros**
   - Ajusta `conf_threshold` (umbral de confianza)
   - Ajusta `iou_threshold` (umbral de NMS)
   - Ajusta `relacion_aspecto_minima` (detección por forma)

6. **Aplicación Automática**
   - Parámetros ajustados se aplican en futuras detecciones
   - Sistema se vuelve más sensible a objetos similares

### Memoria por Imagen

Cuando procesas la misma imagen nuevamente:
- ✅ Sistema carga automáticamente anotaciones guardadas
- ✅ Aumenta sensibilidad para esa imagen específica
- ✅ Muestra objetos aprendidos en verde con etiqueta `[APRENDIDO]`
- ✅ No necesitas marcar de nuevo

### Parámetros Ajustables

| Parámetro | Descripción | Valor por Defecto | Ajuste Automático |
|-----------|-------------|-------------------|-------------------|
| `conf_threshold` | Umbral de confianza mínimo | 0.05 | Se reduce si hay muchos objetos pequeños |
| `iou_threshold` | Umbral para NMS (eliminar duplicados) | 0.25 | Se ajusta según patrones de duplicados |
| `max_det` | Máximo de detecciones | 300 | Se ajusta según cantidad de objetos |
| `min_probabilidad_peligroso` | Probabilidad mínima para considerar peligroso | 5% | Se ajusta según anotaciones |
| `relacion_aspecto_minima` | Relación aspecto mínima para detección por forma | 1.5 | Se ajusta según formas de objetos marcados |

---

## 📁 Estructura del Proyecto

```
inteligencia artificial/
│
├── main.py                          # Aplicación principal con interfaz gráfica
├── detector_yolov8.py               # Detector YOLOv8 (modelo principal)
├── detector.py                      # Detector YOLOv3 (modelo complementario)
├── asistente.py                     # Asistente de normativa
├── marcador_manual.py               # Interfaz para marcar objetos manualmente
├── sistema_retroalimentacion.py     # Sistema de aprendizaje
│
├── models/                          # Modelos YOLOv3
│   └── yolov3.pt
│
├── models_huggingface/              # Modelos YOLOv8
│   └── weapon-detection-yolov8/
│       └── best.pt
│
├── anotaciones_manuales/            # Anotaciones guardadas
│   ├── imagen1_manual.json
│   ├── imagen2_manual.json
│   └── estadisticas_aprendizaje.json
│
├── training/                        # Datos para entrenamiento (opcional)
│   └── datasets/
│
├── requirements.txt                  # Dependencias del proyecto
└── README.md                        # Este archivo
```

---

## 🎯 Flujo Completo del Sistema

```
1. Usuario carga imagen de rayos X
        ↓
2. YOLOv8 procesa imagen:
   - Backbone extrae características
   - Neck combina escalas
   - Head predice objetos
        ↓
3. YOLOv3 procesa imagen (complementario):
   - Detecta objetos adicionales
   - Especialmente botellas y cuchillos
        ↓
4. Resultados combinados:
   - Eliminación de duplicados (NMS)
   - Detección por forma adicional
   - Categorización (arma, arma blanca, líquido)
        ↓
5. Carga de anotaciones manuales:
   - Si la imagen tiene anotaciones guardadas
   - Se cargan automáticamente
   - Se muestran en verde [APRENDIDO]
        ↓
6. Visualización:
   - Bounding boxes coloreados
   - Etiquetas con categorías
   - Probabilidades
        ↓
7. Usuario puede:
   - Marcar objetos faltantes manualmente
   - Consultar asistente de normativa
   - Guardar anotaciones para aprendizaje
```

---

## 📊 Resultados y Métricas

### Objetos Detectados

El sistema puede detectar:
- ✅ **Armas de fuego**: Pistolas, rifles, armas en general
- ✅ **Armas blancas**: Cuchillos, navajas, tijeras
- ✅ **Líquidos**: Botellas, contenedores de líquidos

### Precisión

- **YOLOv8**: Alta precisión en armas (modelo especializado)
- **YOLOv3**: Buena precisión en objetos generales (dataset COCO)
- **Combinación**: Mejora la cobertura total

### Velocidad

- **Tiempo de detección**: ~0.3-0.5 segundos por imagen
- **Carga de modelo**: ~2-5 segundos (primera vez)
- **Procesamiento**: Tiempo real en hardware moderno

---

## 🔧 Configuración Avanzada

### Ajustar Parámetros de Detección

Editar `detector_yolov8.py`:

```python
# Línea 188: Ajustar umbrales
results = self.model(
    ruta_imagen,
    conf=0.05,      # Umbral de confianza (0.0-1.0)
    iou=0.25,      # Umbral IoU para NMS (0.0-1.0)
    max_det=300    # Máximo de detecciones
)
```

### Deshabilitar YOLOv3

Comentar las líneas 300-371 en `detector_yolov8.py` para usar solo YOLOv8.

---

## 📚 Referencias

- **YOLOv8**: [Ultralytics Documentation](https://docs.ultralytics.com/)
- **Modelo Hugging Face**: [Hadi959/weapon-detection-yolov8](https://huggingface.co/Hadi959/weapon-detection-yolov8)
- **ImageAI**: [ImageAI Documentation](https://github.com/OlafenwaMoses/ImageAI)
- **YOLOv3 Paper**: [YOLOv3: An Incremental Improvement](https://arxiv.org/abs/1804.02767)

---

## 🤝 Contribuciones

Este proyecto fue desarrollado como parte de un proyecto académico de visión computacional para detección de objetos peligrosos en seguridad aeroportuaria.

---

## 📝 Licencia

Este proyecto es de uso educativo y académico.

---

## 👥 Autores

Desarrollado para el curso de Inteligencia Artificial.

---

**¡Gracias por usar el Sistema de Detección de Objetos Peligrosos!** 🎯
@JulianMbp
Comment
 
Leave a comment
 
Footer
© 2025 GitHub, Inc.
Footer navigation
Terms
Privacy
Security
Status
Community
Docs
Contact
Manage cookies
Do not share my personal information
