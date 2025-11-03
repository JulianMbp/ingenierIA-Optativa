import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/work_log.dart';
import '../../providers/auth_provider.dart';
import '../../providers/work_log_provider.dart';

/// Glass-style modal sheet for adding/editing work logs
class WorkLogFormSheet extends ConsumerStatefulWidget {
  final WorkLog? log;

  const WorkLogFormSheet({
    super.key,
    this.log,
  });

  @override
  ConsumerState<WorkLogFormSheet> createState() => _WorkLogFormSheetState();
}

class _WorkLogFormSheetState extends ConsumerState<WorkLogFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descripcionController;
  late double _avancePorcentaje;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _descripcionController =
        TextEditingController(text: widget.log?.descripcion ?? '');
    _avancePorcentaje = widget.log?.avancePorcentaje ?? 50.0;
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.log != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.9),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          isEditing ? 'Editar Bitácora' : 'Agregar Bitácora',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        if (isEditing)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: AppTheme.errorColor,
                            onPressed: _confirmDelete,
                          ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Form
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        children: [
                          _buildTextField(
                            controller: _descripcionController,
                            label: 'Descripción',
                            hint: 'Describe el trabajo realizado hoy...',
                            icon: Icons.description,
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingrese una descripción';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          _buildProgressSlider(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(isEditing),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildProgressSlider() {
    Color progressColor;
    if (_avancePorcentaje >= 80) {
      progressColor = Colors.green;
    } else if (_avancePorcentaje >= 60) {
      progressColor = Colors.blue;
    } else if (_avancePorcentaje >= 40) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: progressColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: progressColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: progressColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Avance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_avancePorcentaje.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: progressColor,
              inactiveTrackColor: progressColor.withOpacity(0.2),
              thumbColor: progressColor,
              overlayColor: progressColor.withOpacity(0.2),
              trackHeight: 8,
            ),
            child: Slider(
              value: _avancePorcentaje,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) {
                setState(() {
                  _avancePorcentaje = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isEditing) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: _isLoading
          ? const CircularProgressIndicator()
          : Text(
              isEditing ? 'Actualizar Bitácora' : 'Agregar Bitácora',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authState = ref.read(authProvider);
      final obraId = authState.user?.obraId;
      final usuarioId = authState.user?.id.toString();

      if (obraId == null || usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }

      final log = WorkLog(
        id: widget.log?.id ?? const Uuid().v4(),
        obraId: obraId,
        usuarioId: usuarioId,
        descripcion: _descripcionController.text.trim(),
        avancePorcentaje: _avancePorcentaje,
        archivos: widget.log?.archivos ?? [],
        fecha: widget.log?.fecha ?? DateTime.now(),
        createdAt: widget.log?.createdAt ?? DateTime.now(),
      );

      final notifier = ref.read(workLogNotifierProvider.notifier);

      if (widget.log != null) {
        await notifier.updateWorkLog(log);
      } else {
        await notifier.createWorkLog(log);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.log != null
                  ? 'Bitácora actualizada exitosamente'
                  : 'Bitácora agregada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Bitácora'),
        content: const Text('¿Está seguro que desea eliminar esta bitácora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.log != null) {
      await _deleteLog();
    }
  }

  Future<void> _deleteLog() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifier = ref.read(workLogNotifierProvider.notifier);
      await notifier.deleteWorkLog(widget.log!.id);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitácora eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
