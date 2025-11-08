# Guía Rápida de Implementación - Flutter

## Endpoints de IA Disponibles

### 1. Generar Informe de Bitácora
**POST** `/api/v1/obras/{obraId}/bitacoras/generar-informe-ia`

### 2. Chat con IA sobre la Obra
**POST** `/api/v1/obras/{obraId}/bitacoras/chat`

---

## Implementación Paso a Paso

### Paso 1: Instalar Dependencias

Agrega estas dependencias a tu `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^9.0.0
  html: ^0.15.0
  printing: ^5.11.0
  pdf: ^3.10.0
```

### Paso 2: Crear Servicio de API

Crea el archivo `lib/services/bitacora_ai_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class BitacoraAiService {
  final String baseUrl;
  final String Function()? getToken;

  BitacoraAiService({
    required this.baseUrl,
    this.getToken,
  });

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (getToken != null) 'Authorization': 'Bearer ${getToken!()}',
      };

  /// Genera un informe HTML de bitácora usando IA
  Future<InformeResponse> generarInforme({
    required String obraId,
    required List<String> actividades,
    required int avanceGeneral,
    String? fecha,
    String? clima,
    List<String>? incidencias,
    String? observaciones,
  }) async {
    final url = Uri.parse(
        '$baseUrl/obras/$obraId/bitacoras/generar-informe-ia');

    final body = {
      'actividades': actividades,
      'avanceGeneral': avanceGeneral,
      if (fecha != null) 'fecha': fecha,
      if (clima != null) 'clima': clima,
      if (incidencias != null && incidencias.isNotEmpty)
        'incidencias': incidencias,
      if (observaciones != null) 'observaciones': observaciones,
    };

    final response = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return InformeResponse.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al generar informe');
    }
  }

  /// Hace una pregunta a la IA sobre la obra
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
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatResponse.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Error al obtener respuesta');
    }
  }
}

// Modelos de respuesta
class InformeResponse {
  final bool success;
  final InformeData data;
  final String message;

  InformeResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory InformeResponse.fromJson(Map<String, dynamic> json) {
    return InformeResponse(
      success: json['success'] ?? false,
      data: InformeData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
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
      html: json['html'] ?? '',
      tokensUsados: json['tokensUsados'],
    );
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
      success: json['success'] ?? false,
      data: ChatData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
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
      respuesta: json['respuesta'] ?? '',
      tokensUsados: json['tokensUsados'],
    );
  }
}
```

### Paso 3: Usar el Servicio

#### Ejemplo 1: Generar Informe

```dart
import 'package:flutter/material.dart';
import 'services/bitacora_ai_service.dart';

class GenerarInformeScreen extends StatefulWidget {
  final String obraId;
  final String token;

  const GenerarInformeScreen({
    Key? key,
    required this.obraId,
    required this.token,
  }) : super(key: key);

  @override
  _GenerarInformeScreenState createState() => _GenerarInformeScreenState();
}

class _GenerarInformeScreenState extends State<GenerarInformeScreen> {
  final _service = BitacoraAiService(
    baseUrl: 'http://tu-servidor.com/api/v1',
    getToken: () => widget.token,
  );

  bool _isLoading = false;
  String? _htmlGenerado;

  Future<void> _generarInforme() async {
    setState(() {
      _isLoading = true;
      _htmlGenerado = null;
    });

    try {
      final respuesta = await _service.generarInforme(
        obraId: widget.obraId,
        actividades: [
          'Vaciado de losa de concreto',
          'Instalación de ductos HVAC',
        ],
        avanceGeneral: 76,
        clima: 'Soleado, 25°C',
        observaciones: 'Todo según lo planeado',
      );

      setState(() {
        _htmlGenerado = respuesta.data.html;
        _isLoading = false;
      });

      // Aquí puedes mostrar el HTML o convertirlo a PDF
      _mostrarInforme(respuesta.data.html);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _mostrarInforme(String html) {
    // Opción 1: Mostrar en un WebView
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => WebViewScreen(html: html),
    //   ),
    // );

    // Opción 2: Convertir a PDF y mostrar
    // _convertirAPdf(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Informe')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _generarInforme,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Generar Informe con IA'),
          ),
          if (_htmlGenerado != null)
            Expanded(
              child: SingleChildScrollView(
                child: HtmlWidget(_htmlGenerado!),
              ),
            ),
        ],
      ),
    );
  }
}
```

#### Ejemplo 2: Chat con IA

```dart
import 'package:flutter/material.dart';
import 'services/bitacora_ai_service.dart';

class ChatObraScreen extends StatefulWidget {
  final String obraId;
  final String token;

  const ChatObraScreen({
    Key? key,
    required this.obraId,
    required this.token,
  }) : super(key: key);

  @override
  _ChatObraScreenState createState() => _ChatObraScreenState();
}

class _ChatObraScreenState extends State<ChatObraScreen> {
  final _service = BitacoraAiService(
    baseUrl: 'http://tu-servidor.com/api/v1',
    getToken: () => widget.token,
  );

  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  void _enviarMensaje() async {
    if (_controller.text.isEmpty) return;

    final mensaje = _controller.text;
    _controller.clear();

    // Agregar mensaje del usuario
    setState(() {
      _messages.add(ChatMessage(
        text: mensaje,
        isUser: true,
        timestamp: DateTime.now(),
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
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Error: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat sobre la Obra'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
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
                    onSubmitted: (_) => _enviarMensaje(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Colors.white70
                    : Colors.black54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
```

### Paso 4: Convertir HTML a PDF (Opcional)

```dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

Future<void> convertirHtmlAPdf(String html, String nombreArchivo) async {
  // Método 1: Usando html2pdf (si está disponible para Flutter)
  // O usar un WebView para renderizar y luego capturar como PDF

  // Método 2: Parsear HTML manualmente y crear PDF
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        // Simplificar HTML a texto plano para PDF
        final texto = _htmlToPlainText(html);
        return pw.Text(
          texto,
          style: pw.TextStyle(fontSize: 12),
        );
      },
    ),
  );

  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

String _htmlToPlainText(String html) {
  // Simplificación básica - en producción usar un parser HTML
  return html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
```

---

## Validaciones en el Frontend

### Validación para Generar Informe

```dart
String? validarDatosInforme({
  required List<String> actividades,
  required int avanceGeneral,
}) {
  if (actividades.isEmpty) {
    return 'Debes agregar al menos una actividad';
  }

  if (avanceGeneral < 0 || avanceGeneral > 100) {
    return 'El avance debe estar entre 0 y 100';
  }

  return null;
}
```

### Validación para Chat

```dart
String? validarMensaje(String mensaje) {
  if (mensaje.trim().isEmpty) {
    return 'El mensaje no puede estar vacío';
  }

  if (mensaje.length > 500) {
    return 'El mensaje es demasiado largo';
  }

  return null;
}
```

---

## Manejo de Errores

```dart
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

Future<T> _handleResponse<T>(
  http.Response response,
  T Function(Map<String, dynamic>) fromJson,
) async {
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return fromJson(data);
  } else if (response.statusCode == 401) {
    throw ApiException('No autorizado. Por favor, inicia sesión nuevamente.', 401);
  } else if (response.statusCode == 403) {
    throw ApiException('No tienes acceso a esta obra.', 403);
  } else if (response.statusCode == 404) {
    throw ApiException('Obra no encontrada.', 404);
  } else if (response.statusCode == 429) {
    throw ApiException('Demasiadas solicitudes. Intenta más tarde.', 429);
  } else {
    final error = jsonDecode(response.body);
    throw ApiException(
      error['message'] ?? 'Error desconocido',
      response.statusCode,
    );
  }
}
```

---

## Ejemplos de Uso Completo

### Ejemplo Completo - Generar Informe

```dart
class GenerarInformeCompleto extends StatelessWidget {
  final String obraId;
  final String token;

  const GenerarInformeCompleto({
    Key? key,
    required this.obraId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generar Informe')),
      body: _GenerarInformeForm(
        obraId: obraId,
        token: token,
      ),
    );
  }
}

class _GenerarInformeForm extends StatefulWidget {
  final String obraId;
  final String token;

  const _GenerarInformeForm({
    required this.obraId,
    required this.token,
  });

  @override
  _GenerarInformeFormState createState() => _GenerarInformeFormState();
}

class _GenerarInformeFormState extends State<_GenerarInformeForm> {
  final _formKey = GlobalKey<FormState>();
  final _actividadesController = TextEditingController();
  final _avanceController = TextEditingController();
  final _climaController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  final List<String> _actividades = [];
  bool _isLoading = false;

  final _service = BitacoraAiService(
    baseUrl: 'http://tu-servidor.com/api/v1',
    getToken: () => widget.token,
  );

  void _agregarActividad() {
    if (_actividadesController.text.isNotEmpty) {
      setState(() {
        _actividades.add(_actividadesController.text);
        _actividadesController.clear();
      });
    }
  }

  Future<void> _generarInforme() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final respuesta = await _service.generarInforme(
        obraId: widget.obraId,
        actividades: _actividades,
        avanceGeneral: int.parse(_avanceController.text),
        clima: _climaController.text.isEmpty ? null : _climaController.text,
        observaciones: _observacionesController.text.isEmpty
            ? null
            : _observacionesController.text,
      );

      // Navegar a pantalla de visualización
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerInformeScreen(html: respuesta.data.html),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Actividades
          TextFormField(
            controller: _actividadesController,
            decoration: const InputDecoration(
              labelText: 'Actividad',
              hintText: 'Ej: Vaciado de losa de concreto',
            ),
            onFieldSubmitted: (_) => _agregarActividad(),
          ),
          ElevatedButton(
            onPressed: _agregarActividad,
            child: const Text('Agregar Actividad'),
          ),
          const SizedBox(height: 8),
          ..._actividades.map((act) => Chip(
                label: Text(act),
                onDeleted: () {
                  setState(() => _actividades.remove(act));
                },
              )),

          // Avance
          TextFormField(
            controller: _avanceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Avance General (%)',
              hintText: '0-100',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El avance es requerido';
              }
              final avance = int.tryParse(value);
              if (avance == null || avance < 0 || avance > 100) {
                return 'El avance debe estar entre 0 y 100';
              }
              return null;
            },
          ),

          // Clima
          TextFormField(
            controller: _climaController,
            decoration: const InputDecoration(
              labelText: 'Clima (Opcional)',
              hintText: 'Ej: Soleado, 25°C',
            ),
          ),

          // Observaciones
          TextFormField(
            controller: _observacionesController,
            decoration: const InputDecoration(
              labelText: 'Observaciones (Opcional)',
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 24),

          // Botón generar
          ElevatedButton(
            onPressed: _isLoading ? null : _generarInforme,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Generar Informe con IA'),
          ),
        ],
      ),
    );
  }
}
```

---

## Checklist de Implementación

- [ ] Instalar dependencias (`http`, `flutter_secure_storage`, etc.)
- [ ] Crear servicio `BitacoraAiService`
- [ ] Configurar base URL y método para obtener token
- [ ] Implementar pantalla de generar informe
- [ ] Implementar pantalla de chat
- [ ] Agregar validaciones en el frontend
- [ ] Manejar errores apropiadamente
- [ ] Agregar indicadores de carga
- [ ] Probar con diferentes casos de uso
- [ ] Implementar conversión a PDF (opcional)

---

## Notas Importantes

1. **Token**: Asegúrate de obtener el token después del login y almacenarlo de forma segura
2. **ObraId**: Debe ser el UUID de la obra a la que el usuario tiene acceso
3. **Validación**: Valida los datos antes de enviarlos al backend
4. **Errores**: Maneja todos los posibles errores y muestra mensajes amigables
5. **Loading**: Siempre muestra un indicador de carga durante las solicitudes
6. **Testing**: Prueba con diferentes escenarios (obra sin materiales, sin tareas, etc.)

---

## Contacto

Para dudas o soporte, contactar al equipo de backend.

