import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../config/theme.dart';
import '../../../core/services/work_log_ai_service.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/pdf_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/auth_provider.dart';

class GenerarInformeIaScreen extends ConsumerStatefulWidget {
  const GenerarInformeIaScreen({super.key});

  @override
  ConsumerState<GenerarInformeIaScreen> createState() =>
      _GenerarInformeIaScreenState();
}

class _GenerarInformeIaScreenState
    extends ConsumerState<GenerarInformeIaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _actividadesController = TextEditingController();
  final _avanceController = TextEditingController();
  final _climaController = TextEditingController();
  final _incidenciasController = TextEditingController();
  final _observacionesController = TextEditingController();

  List<String> _actividades = [];
  List<String> _incidencias = [];
  bool _isGenerating = false;
  String? _generatedHtml;
  bool _hasConnection = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _setupConnectionListener();
  }

  void _setupConnectionListener() {
    ref.read(connectivityServiceProvider).connectivityStream.listen((result) {
      final hasConnection = !result.contains(ConnectivityResult.none);
      if (hasConnection != _hasConnection) {
        setState(() {
          _hasConnection = hasConnection;
        });
      }
    });
  }

  Future<void> _checkConnection() async {
    final hasConnection =
        await ref.read(connectivityServiceProvider).hasInternetConnection();
    setState(() {
      _hasConnection = hasConnection;
    });
  }


  void _addActividad() {
    if (_actividadesController.text.trim().isNotEmpty) {
      setState(() {
        _actividades.add(_actividadesController.text.trim());
        _actividadesController.clear();
      });
    }
  }

  void _removeActividad(int index) {
    setState(() {
      _actividades.removeAt(index);
    });
  }

  void _addIncidencia() {
    if (_incidenciasController.text.trim().isNotEmpty) {
      setState(() {
        _incidencias.add(_incidenciasController.text.trim());
        _incidenciasController.clear();
      });
    }
  }

  void _removeIncidencia(int index) {
    setState(() {
      _incidencias.removeAt(index);
    });
  }

  Future<void> _generarInforme() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_actividades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar al menos una actividad'),
        ),
      );
      return;
    }

    final avance = int.tryParse(_avanceController.text);
    if (avance == null || avance < 0 || avance > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El avance debe ser un número entre 0 y 100'),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generatedHtml = null;
    });

    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;

      if (projectId == null) {
        throw Exception('No project selected');
      }

      final service = ref.read(workLogAiServiceProvider);
      final response = await service.generateReport(
        projectId: projectId,
        activities: _actividades,
        overallProgress: avance,
        weather: _climaController.text.trim().isEmpty
            ? null
            : _climaController.text.trim(),
        incidents: _incidencias.isEmpty ? null : _incidencias,
        observations: _observacionesController.text.trim().isEmpty
            ? null
            : _observacionesController.text.trim(),
      );

      final htmlContent = response.data.html;
      
      // Verificar que el HTML no esté vacío
      if (htmlContent.isEmpty) {
        throw Exception('El HTML recibido está vacío');
      }
      
      // Debug: imprimir el HTML para verificar que se recibió correctamente
      print('HTML recibido - Longitud: ${htmlContent.length} caracteres');
      print('HTML preview: ${htmlContent.substring(0, htmlContent.length > 200 ? 200 : htmlContent.length)}...');
      
      setState(() {
        _generatedHtml = htmlContent;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }


  Future<void> _descargarPDF() async {
    if (_generatedHtml == null) return;

    try {
      final pdf = await PdfService.htmlToPdf(_generatedHtml!);
      await PdfService.showPdf(pdf);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
          ),
        );
      }
    }
  }

  Future<void> _compartirPDF() async {
    if (_generatedHtml == null) return;

    try {
      final pdf = await PdfService.htmlToPdf(_generatedHtml!);
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/informe_bitacora_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(pdf);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Informe de Bitácora generado con IA',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir PDF: $e'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _actividadesController.dispose();
    _avanceController.dispose();
    _climaController.dispose();
    _incidenciasController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generar Informe con IA'),
        backgroundColor: AppTheme.iosOrange,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FB),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SafeArea(
          child: _generatedHtml != null
              ? _buildPreviewScreen()
              : _buildFormScreen(),
        ),
      ),
    );
  }

  Widget _buildFormScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de conexión
            if (!_hasConnection)
              GlassContainer(
                blur: 15,
                opacity: 0.3,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sin conexión a internet',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Los datos se guardarán localmente y podrás generar el informe cuando vuelvas a tener conexión.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


            const SizedBox(height: 16),

            // Actividades
            GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actividades *',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _actividadesController,
                          decoration: const InputDecoration(
                            hintText: 'Escribe una actividad',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addActividad(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addActividad,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.iosOrange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_actividades.isNotEmpty)
                    ...List.generate(_actividades.length, (index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(_actividades[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeActividad(index),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Avance General
            GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _avanceController,
                decoration: const InputDecoration(
                  labelText: 'Avance General (%) *',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  final avance = int.tryParse(value);
                  if (avance == null || avance < 0 || avance > 100) {
                    return 'Debe ser un número entre 0 y 100';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            // Clima
            GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _climaController,
                decoration: const InputDecoration(
                  labelText: 'Clima (opcional)',
                  hintText: 'Ej: Soleado, 25°C',
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Incidencias
            GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incidencias (opcional)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _incidenciasController,
                          decoration: const InputDecoration(
                            hintText: 'Escribe una incidencia',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addIncidencia(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addIncidencia,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_incidencias.isNotEmpty)
                    ...List.generate(_incidencias.length, (index) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.red.shade50,
                        child: ListTile(
                          title: Text(_incidencias[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeIncidencia(index),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Observaciones
            GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _observacionesController,
                decoration: const InputDecoration(
                  labelText: 'Observaciones (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ),

            const SizedBox(height: 24),

            // Botón generar
            ElevatedButton(
              onPressed: _isGenerating ? null : _generarInforme,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.iosOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isGenerating
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Generando informe...'),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome),
                        SizedBox(width: 8),
                        Text(
                          'Generar Informe con IA',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewScreen() {
    return Column(
      children: [
        // Header con acciones
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _generatedHtml = null;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'Vista Previa del Informe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: _descargarPDF,
                tooltip: 'Imprimir PDF',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _compartirPDF,
                tooltip: 'Compartir PDF',
              ),
            ],
          ),
        ),

        // Vista previa del HTML
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildHtmlPreview(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHtmlPreview() {
    if (_generatedHtml == null || _generatedHtml!.isEmpty) {
      return const Center(
        child: Text('No hay contenido para mostrar'),
      );
    }
    
    // Extraer solo el contenido del body si viene con <html> y <body>
    String htmlToRender = _generatedHtml!;
    
    // Si tiene DOCTYPE o html completo, extraer solo el body
    if (htmlToRender.contains('<!DOCTYPE') || htmlToRender.contains('<html')) {
      if (htmlToRender.contains('<body')) {
        final bodyStart = htmlToRender.indexOf('<body');
        if (bodyStart != -1) {
          // Buscar el cierre de la etiqueta body (puede tener atributos)
          var bodyTagEnd = htmlToRender.indexOf('>', bodyStart);
          if (bodyTagEnd != -1) {
            final bodyEnd = htmlToRender.indexOf('</body>');
            if (bodyEnd != -1) {
              htmlToRender = htmlToRender.substring(bodyTagEnd + 1, bodyEnd).trim();
            }
          }
        }
      }
    }
    
    // Si después de extraer está vacío, usar el HTML original
    if (htmlToRender.isEmpty) {
      htmlToRender = _generatedHtml!;
    }
    
    print('Renderizando HTML de ${htmlToRender.length} caracteres');
    print('Preview HTML: ${htmlToRender.substring(0, htmlToRender.length > 300 ? 300 : htmlToRender.length)}...');
    
    try {
      return HtmlWidget(
        htmlToRender,
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.5,
        ),
        enableCaching: true,
        onErrorBuilder: (context, element, error) {
          print('Error renderizando elemento HTML: $error');
          print('Elemento: $element');
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Error al renderizar elemento: ${error.toString()}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
        onLoadingBuilder: (context, element, loadingProgress) {
          return const Center(child: CircularProgressIndicator());
        },
        renderMode: RenderMode.column,
      );
    } catch (e) {
      print('Error crítico renderizando HTML: $e');
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Error al renderizar el HTML',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Mostrar el HTML en un diálogo de texto
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('HTML Recibido'),
                    content: SingleChildScrollView(
                      child: SelectableText(
                        htmlToRender,
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Ver HTML Raw'),
            ),
          ],
        ),
      );
    }
  }
}

