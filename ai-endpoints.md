# Documentación de Endpoints de IA

## Índice
1. [Generar Informe de Bitácora con IA](#1-generar-informe-de-bitácora-con-ia)
2. [Chat con IA sobre la Obra](#2-chat-con-ia-sobre-la-obra)
3. [Autenticación](#autenticación)
4. [Manejo de Errores](#manejo-de-errores)
5. [Ejemplos en Flutter/Dart](#ejemplos-en-flutterdart)

---

## 1. Generar Informe de Bitácora con IA

### Descripción
Genera un informe HTML profesional de bitácora usando inteligencia artificial. El informe incluye información de la obra (materiales, tareas, bitácoras anteriores) combinada con los datos proporcionados por el usuario. El HTML generado está listo para ser convertido a PDF en el frontend.

### Endpoint
```
POST /api/v1/obras/{obraId}/bitacoras/generar-informe-ia
```

### Headers Requeridos
```
Authorization: Bearer {token}
Content-Type: application/json
```

### Parámetros de URL
- `obraId` (string, requerido): UUID de la obra

### Body Request

```json
{
  "fecha": "2025-11-08",
  "clima": "Soleado, 25°C",
  "actividades": [
    "Vaciado de losa de concreto en el nivel 12",
    "Instalación de ductos HVAC en sector norte",
    "Revisión y ajuste de instalaciones eléctricas"
  ],
  "avanceGeneral": 76,
  "incidencias": [
    "Retraso de 2 horas en la entrega de hormigón"
  ],
  "observaciones": "Trabajo realizado según lo planeado..."
}
```

### Campos del Body

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `fecha` | string (ISO) | No | Fecha de la bitácora. Si no se proporciona, se usa la fecha actual |
| `clima` | string | No | Condiciones climáticas del día |
| `actividades` | string[] | **Sí** | Lista de actividades realizadas |
| `avanceGeneral` | number (0-100) | **Sí** | Porcentaje de avance general del proyecto |
| `incidencias` | string[] | No | Lista de incidencias o riesgos detectados |
| `observaciones` | string | No | Observaciones adicionales |

### Response Success (200)

```json
{
  "success": true,
  "data": {
    "html": "<div style=\"font-family: Arial, sans-serif; margin: 20px;\">...</div>",
    "tokensUsados": 2244
  },
  "message": "Informe generado exitosamente"
}
```

### Campos del Response

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `success` | boolean | Indica si la operación fue exitosa |
| `data.html` | string | HTML completo del informe generado (listo para PDF) |
| `data.tokensUsados` | number | Cantidad de tokens de OpenAI utilizados |
| `message` | string | Mensaje de confirmación |

### Información Incluida Automáticamente

El sistema automáticamente incluye en el informe:
- **Nombre de la obra** (desde la base de datos)
- **Ubicación completa** (dirección de la obra)
- **Materiales** de la obra (todos los registrados)
- **Tareas recientes** (últimas 5 tareas)
- **Bitácoras anteriores** (últimas 3 para contexto)
- **Firma del usuario** que genera el informe (nombre, cargo, fecha)

### Ejemplo de Request Completo

```bash
POST /api/v1/obras/90f90bc3-3303-464b-b4af-99333eb87771/bitacoras/generar-informe-ia
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "actividades": [
    "Vaciado de losa de concreto",
    "Instalación de ductos HVAC"
  ],
  "avanceGeneral": 76,
  "clima": "Soleado, 25°C",
  "observaciones": "Todo según lo planeado"
}
```

### Características del HTML Generado

- **Estilos inline**: El HTML incluye todos los estilos necesarios
- **Listo para PDF**: Puede convertirse directamente a PDF con librerías como `html2pdf.js` o `jsPDF`
- **Diseño profesional**: Colores diferenciados, tablas, barras de progreso
- **Tono narrativo**: Escrito como si un ingeniero lo hubiera redactado personalmente
- **Formato completo**: Incluye encabezado, resumen, actividades, materiales, incidencias, avance y firma

---

## 2. Chat con IA sobre la Obra

### Descripción
Permite hacer preguntas sobre la obra y recibir respuestas basadas en la información disponible (materiales, tareas, bitácoras, etc.). La IA responde como un experto que conoce la obra íntimamente.

### Endpoint
```
POST /api/v1/obras/{obraId}/bitacoras/chat
```

### Headers Requeridos
```
Authorization: Bearer {token}
Content-Type: application/json
```

### Parámetros de URL
- `obraId` (string, requerido): UUID de la obra

### Body Request

```json
{
  "mensaje": "¿Cuántos materiales tiene esta obra?"
}
```

### Campos del Body

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `mensaje` | string | **Sí** | Pregunta o mensaje sobre la obra |

### Response Success (200)

```json
{
  "success": true,
  "data": {
    "respuesta": "Esta obra tiene 7 materiales registrados: Cemento Gris (500 bultos), Varilla 3/8\" (200 varillas), Arena Lavada (50 m3), entre otros...",
    "tokensUsados": 456
  },
  "message": "Respuesta generada exitosamente"
}
```

### Campos del Response

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `success` | boolean | Indica si la operación fue exitosa |
| `data.respuesta` | string | Respuesta de la IA en texto plano |
| `data.tokensUsados` | number | Cantidad de tokens de OpenAI utilizados |
| `message` | string | Mensaje de confirmación |

### Información Disponible para la IA

La IA tiene acceso a:
- **Materiales**: Nombre, cantidad, unidad, categoría
- **Tareas**: Título, estado, porcentaje de avance
- **Bitácoras**: Fecha, avance, descripción
- **Último avance general** del proyecto
- **Ubicación** de la obra

### Ejemplos de Preguntas

- "¿Cuántos materiales tiene esta obra?"
- "¿Cuál es el avance actual del proyecto?"
- "¿Qué tareas están en progreso?"
- "¿Hay alguna incidencia reportada?"
- "¿Qué materiales de cemento tenemos?"
- "¿Cuándo fue la última bitácora?"
- "¿Cuántas tareas pendientes hay?"
- "¿Qué materiales tenemos en mayor cantidad?"
- "¿Cuál es el estado de las tareas de construcción?"
- "¿Hay retrasos reportados en las bitácoras?"

### Comportamiento de la IA

- **Respuestas directas**: Responde de forma clara y concisa
- **Tono conversacional**: Como si fuera un experto que conoce la obra
- **Honestidad**: Si no tiene información, lo dice claramente
- **Lenguaje técnico**: Usa terminología apropiada pero comprensible

### Ejemplo de Request Completo

```bash
POST /api/v1/obras/90f90bc3-3303-464b-b4af-99333eb87771/bitacoras/chat
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "mensaje": "¿Cuántos materiales tiene esta obra y cuáles son los más utilizados?"
}
```

---

## Autenticación

Ambos endpoints requieren autenticación JWT. El token debe incluirse en el header `Authorization` con el formato:

```
Authorization: Bearer {token}
```

### Obtención del Token

1. **Login**: `POST /api/v1/auth/login`
   ```json
   {
     "email": "usuario@ejemplo.com",
     "password": "password"
   }
   ```

2. **Response**: El token viene en el campo `token`
   ```json
   {
     "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
     "refreshToken": "...",
     "user": {...}
   }
   ```

### Validación de Obra

Los endpoints validan automáticamente que el usuario tenga acceso a la obra especificada mediante el `TenantGuard`. Si el usuario no tiene permisos, recibirá un error `403 Forbidden`.

---

## Manejo de Errores

### Errores Comunes

#### 401 Unauthorized
```json
{
  "statusCode": 401,
  "message": "Unauthorized"
}
```
**Causa**: Token inválido o ausente  
**Solución**: Verificar que el token sea válido y esté incluido en el header

#### 403 Forbidden
```json
{
  "statusCode": 403,
  "message": "User does not have access to this obra"
}
```
**Causa**: El usuario no tiene acceso a la obra especificada  
**Solución**: Verificar que el usuario esté asignado a la obra

#### 404 Not Found
```json
{
  "statusCode": 404,
  "message": "Obra con ID {obraId} no encontrada"
}
```
**Causa**: La obra no existe  
**Solución**: Verificar que el `obraId` sea correcto

#### 400 Bad Request
```json
{
  "statusCode": 400,
  "message": ["actividades should not be empty", "avanceGeneral must be a number"]
}
```
**Causa**: Validación de datos fallida  
**Solución**: Verificar que todos los campos requeridos estén presentes y sean válidos

#### 500 Internal Server Error - Cuota Agotada
```json
{
  "statusCode": 500,
  "message": "Cuota de OpenAI agotada. Por favor, revisa tu plan y facturación en https://platform.openai.com/account/billing"
}
```
**Causa**: No hay créditos disponibles en la cuenta de OpenAI  
**Solución**: Agregar créditos a la cuenta de OpenAI

#### 500 Internal Server Error - Rate Limit
```json
{
  "statusCode": 500,
  "message": "Límite de solicitudes excedido. Por favor, intenta más tarde."
}
```
**Causa**: Se excedió el límite de solicitudes por minuto/hora  
**Solución**: Esperar unos minutos antes de intentar nuevamente

#### 503 Service Unavailable
```json
{
  "statusCode": 503,
  "message": "Servicio de OpenAI no disponible temporalmente."
}
```
**Causa**: OpenAI está experimentando problemas  
**Solución**: Intentar más tarde

---

## Ejemplos en Flutter/Dart

### Configuración Inicial

```dart
// Configuración de la API
class ApiConfig {
  static const String baseUrl = 'http://tu-servidor.com/api/v1';
  static String? authToken;
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };
}
```

### 1. Generar Informe de Bitácora con IA

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BitacoraAiService {
  final String baseUrl;
  final String? token;

  BitacoraAiService({required this.baseUrl, this.token});

  Future<InformeBitacoraResponse> generarInforme({
    required String obraId,
    required List<String> actividades,
    required int avanceGeneral,
    String? fecha,
    String? clima,
    List<String>? incidencias,
    String? observaciones,
  }) async {
    final url = Uri.parse('$baseUrl/obras/$obraId/bitacoras/generar-informe-ia');
    
    final body = {
      'actividades': actividades,
      'avanceGeneral': avanceGeneral,
      if (fecha != null) 'fecha': fecha,
      if (clima != null) 'clima': clima,
      if (incidencias != null && incidencias.isNotEmpty) 'incidencias': incidencias,
      if (observaciones != null) 'observaciones': observaciones,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return InformeBitacoraResponse.fromJson(data);
    } else {
      throw Exception('Error al generar informe: ${response.statusCode}');
    }
  }
}

class InformeBitacoraResponse {
  final bool success;
  final InformeData data;
  final String message;

  InformeBitacoraResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory InformeBitacoraResponse.fromJson(Map<String, dynamic> json) {
    return InformeBitacoraResponse(
      success: json['success'],
      data: InformeData.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class InformeData {
  final String html;
  final int? tokensUsados;

  InformeData({
    required this.html,
    this.tokensUsados,
  });

  factory InformeData.fromJson(Map<String, dynamic> json) {
    return InformeData(
      html: json['html'],
      tokensUsados: json['tokensUsados'],
    );
  }
}
```

### Uso del Servicio - Generar Informe

```dart
// Ejemplo de uso
final service = BitacoraAiService(
  baseUrl: 'http://tu-servidor.com/api/v1',
  token: 'tu-token-jwt',
);

try {
  final respuesta = await service.generarInforme(
    obraId: '90f90bc3-3303-464b-b4af-99333eb87771',
    actividades: [
      'Vaciado de losa de concreto en el nivel 12',
      'Instalación de ductos HVAC en sector norte',
    ],
    avanceGeneral: 76,
    clima: 'Soleado, 25°C',
    observaciones: 'Todo según lo planeado',
  );

  // El HTML está en respuesta.data.html
  print('HTML generado: ${respuesta.data.html}');
  
  // Convertir a PDF (usando html2pdf o similar)
  // await convertirHtmlAPdf(respuesta.data.html);
  
} catch (e) {
  print('Error: $e');
}
```

### 2. Chat con IA sobre la Obra

```dart
class ChatObraService {
  final String baseUrl;
  final String? token;

  ChatObraService({required this.baseUrl, this.token});

  Future<ChatResponse> hacerPregunta({
    required String obraId,
    required String mensaje,
  }) async {
    final url = Uri.parse('$baseUrl/obras/$obraId/bitacoras/chat');
    
    final body = {
      'mensaje': mensaje,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatResponse.fromJson(data);
    } else {
      throw Exception('Error al obtener respuesta: ${response.statusCode}');
    }
  }
}

class ChatResponse {
  final bool success;
  final ChatData data;
  final String message;

  ChatResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      success: json['success'],
      data: ChatData.fromJson(json['data']),
      message: json['message'],
    );
  }
}

class ChatData {
  final String respuesta;
  final int? tokensUsados;

  ChatData({
    required this.respuesta,
    this.tokensUsados,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      respuesta: json['respuesta'],
      tokensUsados: json['tokensUsados'],
    );
  }
}
```

### Uso del Servicio - Chat

```dart
// Ejemplo de uso
final chatService = ChatObraService(
  baseUrl: 'http://tu-servidor.com/api/v1',
  token: 'tu-token-jwt',
);

try {
  final respuesta = await chatService.hacerPregunta(
    obraId: '90f90bc3-3303-464b-b4af-99333eb87771',
    mensaje: '¿Cuántos materiales tiene esta obra?',
  );

  // La respuesta está en respuesta.data.respuesta
  print('Respuesta de la IA: ${respuesta.data.respuesta}');
  
  // Mostrar en la UI
  // setState(() {
  //   mensajes.add(respuesta.data.respuesta);
  // });
  
} catch (e) {
  print('Error: $e');
}
```

### Widget de Chat Completo (Ejemplo)

```dart
import 'package:flutter/material.dart';

class ChatObraWidget extends StatefulWidget {
  final String obraId;
  final String token;

  const ChatObraWidget({
    Key? key,
    required this.obraId,
    required this.token,
  }) : super(key: key);

  @override
  _ChatObraWidgetState createState() => _ChatObraWidgetState();
}

class _ChatObraWidgetState extends State<ChatObraWidget> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatObraService _service = ChatObraService(
    baseUrl: 'http://tu-servidor.com/api/v1',
    token: widget.token,
  );
  bool _isLoading = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final mensaje = _controller.text;
    _controller.clear();

    // Agregar mensaje del usuario
    setState(() {
      _messages.add(ChatMessage(
        text: mensaje,
        isUser: true,
      ));
      _isLoading = true;
    });

    try {
      // Obtener respuesta de la IA
      final respuesta = await _service.hacerPregunta(
        obraId: widget.obraId,
        mensaje: mensaje,
      );

      // Agregar respuesta de la IA
      setState(() {
        _messages.add(ChatMessage(
          text: respuesta.data.respuesta,
          isUser: false,
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: $e',
          isUser: false,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ChatBubble(message: _messages[index]);
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'Pregunta sobre la obra...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
```

### Generar PDF desde HTML (Ejemplo)

```dart
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:html/parser.dart' as html_parser;

Future<void> generarPdfDesdeHtml(String html) async {
  // Parsear HTML
  final document = html_parser.parse(html);
  
  // Crear PDF
  final pdf = pw.Document();
  
  // Agregar contenido (simplificado)
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Text(document.body?.text ?? '');
      },
    ),
  );

  // Imprimir o compartir
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}
```

---

## Consideraciones Importantes

### 1. Tokens de OpenAI
- Cada solicitud consume tokens de OpenAI
- Monitorear el uso desde el dashboard de OpenAI
- Configurar límites de uso para evitar costos inesperados

### 2. Tiempo de Respuesta
- La generación de informes puede tardar 3-5 segundos
- El chat suele responder en 1-3 segundos
- Considerar mostrar un indicador de carga

### 3. Límites de Rate
- OpenAI tiene límites de solicitudes por minuto/hora
- Implementar reintentos con backoff exponencial
- Manejar errores 429 adecuadamente

### 4. Validación en el Frontend
- Validar que `actividades` no esté vacío
- Validar que `avanceGeneral` esté entre 0 y 100
- Validar que `mensaje` en el chat no esté vacío

### 5. Manejo de Errores
- Siempre manejar errores de red
- Mostrar mensajes de error amigables al usuario
- Logging de errores para debugging

### 6. Seguridad
- Nunca exponer el token en el código del frontend
- Almacenar el token de forma segura (SecureStorage)
- Implementar refresh token cuando expire

---

## Testing

### Ejemplos de Testing con Postman

1. **Generar Informe**:
   - Collection: "4. Bitácoras" → "4.6 Generar Informe con IA"
   - Asegúrate de tener `obraId` configurado en variables

2. **Chat**:
   - Collection: "4. Bitácoras" → "4.7 Chat con IA sobre la Obra"
   - Modifica el `mensaje` en el body para hacer diferentes preguntas

### Ejemplos de Testing Manual

```bash
# Generar Informe
curl -X POST "http://localhost:3000/api/v1/obras/{obraId}/bitacoras/generar-informe-ia" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "actividades": ["Actividad 1", "Actividad 2"],
    "avanceGeneral": 76
  }'

# Chat
curl -X POST "http://localhost:3000/api/v1/obras/{obraId}/bitacoras/chat" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "mensaje": "¿Cuántos materiales tiene esta obra?"
  }'
```

---

## Preguntas Frecuentes

### ¿Puedo usar el HTML directamente en Flutter?
Sí, puedes usar el widget `HtmlWidget` del paquete `flutter_widget_from_html` para mostrar el HTML, o convertirlo a PDF usando `pdf` y `printing`.

### ¿Qué pasa si la obra no tiene materiales?
La IA indicará que no hay materiales registrados y el informe se generará normalmente sin la sección de materiales.

### ¿Cuánto tiempo tarda en generar el informe?
Depende de la cantidad de información, pero generalmente toma entre 3-5 segundos.

### ¿Puedo personalizar el diseño del HTML?
El HTML viene con estilos inline predefinidos. Puedes modificarlo después de recibirlo, pero se recomienda mantener la estructura básica.

### ¿Qué información tiene acceso la IA en el chat?
La IA tiene acceso a: materiales, tareas, bitácoras, avance general y ubicación de la obra.

### ¿Qué pasa si hago una pregunta que no puede responder?
La IA responderá honestamente diciendo que no tiene esa información o que aún no hay datos registrados sobre ese tema.

---

## Soporte

Para más información o soporte, contactar al equipo de backend o revisar la documentación de la API en Swagger:
```
http://localhost:3000/docs
```

