import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/tarea.dart';
import '../../../core/providers/obra_progress_provider.dart';
import '../../../core/services/tarea_service.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/auth_provider.dart';

class TareasScreen extends ConsumerStatefulWidget {
  const TareasScreen({super.key});

  @override
  ConsumerState<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends ConsumerState<TareasScreen> {
  List<Tarea> _tareas = [];
  bool _isLoading = true;
  String _filtroEstado = 'todas';
  double _progresoGeneral = 0.0;
  bool _cargandoProgreso = false;
  Map<String, dynamic> _estadisticasObra = {};

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  Future<void> _cargarTareas() async {
    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authProvider);
      final obraId = authState.obraActual?.id;

      if (obraId == null) {
        throw Exception('No hay obra seleccionada');
      }

      final tareaService = ref.read(tareaServiceProvider);
      final tareas = await tareaService.listTasks(obraId);

      setState(() {
        _tareas = tareas;
        _isLoading = false;
      });
      
      // Calcular progreso directamente desde las tareas cargadas (sin llamar al API de nuevo)
      _calcularProgresoDesdeTareas(tareas);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        String errorMessage = 'Error al cargar tareas';
        if (e is DioException) {
          if (e.response != null) {
            final responseData = e.response!.data;
            if (responseData is Map) {
              errorMessage = responseData['message']?.toString() ??
                  responseData['error']?.toString() ??
                  'Error al cargar tareas';
            } else {
              errorMessage = 'Error al cargar tareas: ${e.response?.statusCode}';
            }
          } else {
            errorMessage = 'Error de conexión: ${e.message}';
          }
        } else {
          errorMessage = 'Error: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  /// Calcula el progreso de la obra directamente desde las tareas ya cargadas
  /// Evita hacer llamadas adicionales al API
  /// También actualiza el provider compartido para que el dashboard se actualice
  void _calcularProgresoDesdeTareas(List<Tarea> tareas) {
    // Actualizar el provider compartido para que el dashboard se actualice automáticamente
    ref.read(obraProgressProvider.notifier).updateFromTareas(tareas);
    
    if (tareas.isEmpty) {
      setState(() {
        _progresoGeneral = 0.0;
        _estadisticasObra = {
          'progreso': 0.0,
          'totalTareas': 0,
          'tareasCompletadas': 0,
          'tareasEnProgreso': 0,
          'tareasPendientes': 0,
        };
        _cargandoProgreso = false;
      });
      return;
    }

    final completadas = tareas.where((t) => t.isCompletada).length;
    final enProgreso = tareas.where((t) => t.isEnProgreso).length;
    final pendientes = tareas.where((t) => t.isPendiente).length;
    
    // Calcular suma de progresos
    final suma = tareas.fold<double>(
      0.0, 
      (sum, t) => sum + t.progresosPorcentaje.toDouble(),
    );
    
    final progreso = suma / tareas.length;

    setState(() {
      _progresoGeneral = progreso;
      _estadisticasObra = {
        'progreso': progreso,
        'totalTareas': tareas.length,
        'tareasCompletadas': completadas,
        'tareasEnProgreso': enProgreso,
        'tareasPendientes': pendientes,
      };
      _cargandoProgreso = false;
    });
  }

  List<Tarea> get _tareasFiltradas {
    if (_filtroEstado == 'todas') return _tareas;
    return _tareas.where((t) => t.estado == _filtroEstado).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarTareas,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de estado offline
          const OfflineBanner(),
          // General progress bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso General de la Obra',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    _cargandoProgreso
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '${_progresoGeneral.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                  ],
                ),
                if (_estadisticasObra.isNotEmpty && !_cargandoProgreso) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${_estadisticasObra['totalTareas'] ?? 0} | '
                    'Completadas: ${_estadisticasObra['tareasCompletadas'] ?? 0} | '
                    'En Progreso: ${_estadisticasObra['tareasEnProgreso'] ?? 0} | '
                    'Pendientes: ${_estadisticasObra['tareasPendientes'] ?? 0}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _cargandoProgreso ? null : _progresoGeneral / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _progresoGeneral < 30
                          ? Colors.red
                          : _progresoGeneral < 70
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'todas', label: Text('Todas')),
                ButtonSegment(value: 'pendiente', label: Text('Pendientes')),
                ButtonSegment(value: 'en_progreso', label: Text('En Progreso')),
                ButtonSegment(value: 'completada', label: Text('Completadas')),
              ],
              selected: {_filtroEstado},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _filtroEstado = newSelection.first;
                });
              },
            ),
          ),

          // Task list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tareasFiltradas.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay tareas',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _cargarTareas,
                        child: ListView.builder(
                          itemCount: _tareasFiltradas.length,
                          itemBuilder: (context, index) {
                            final tarea = _tareasFiltradas[index];
                            return _TareaCard(
                              tarea: tarea,
                              onTap: () => _mostrarDetalleTarea(tarea),
                              onToggleComplete: () =>
                                  _toggleCompletarTarea(tarea),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarFormularioTarea,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarDetalleTarea(Tarea tarea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _DetallesTareaSheet(
        tarea: tarea,
        onEditar: () {
          Navigator.pop(context);
          _mostrarFormularioTarea(tarea: tarea);
        },
        onEliminar: () {
          Navigator.pop(context);
          _deleteTask(tarea);
        },
        onActualizar: _cargarTareas,
      ),
    );
  }

  void _mostrarFormularioTarea({Tarea? tarea}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FormularioTareaSheet(
        tarea: tarea,
        onGuardado: _cargarTareas,
      ),
    );
  }

  Future<void> _toggleCompletarTarea(Tarea tarea) async {
    try {
      final authState = ref.read(authProvider);
      final obraId = authState.obraActual?.id;
      if (obraId == null) return;

      final tareaService = ref.read(tareaServiceProvider);

      if (tarea.isCompletada) {
        // Si la tarea está completada, desmarcarla y mantener el progreso actual
        // pero cambiar el estado a 'en_progreso'
        // Si el progreso era 100%, lo reducimos a 90% para indicar que falta algo
        final nuevoProgreso = tarea.progresosPorcentaje >= 100 
            ? 90 
            : tarea.progresosPorcentaje;
        
        await tareaService.updateTask(obraId, tarea.id, {
          'estado': 'en_progreso',
          'avance_porcentaje': nuevoProgreso,
        });
      } else {
        // Si la tarea no está completada, marcarla como completada
        await tareaService.completeTask(obraId, tarea.id);
      }

      // Recargar tareas (esto también recalculará el progreso automáticamente)
      _cargarTareas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(Tarea tarea) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Estás seguro de eliminar "${tarea.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final authState = ref.read(authProvider);
      final obraId = authState.obraActual?.id;
      if (obraId == null) return;

      final tareaService = ref.read(tareaServiceProvider);
      await tareaService.deleteTask(obraId, tarea.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea eliminada')),
        );
      }
      _cargarTareas();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }
}

// Task card widget
class _TareaCard extends StatelessWidget {
  final Tarea tarea;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const _TareaCard({
    required this.tarea,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final Color prioridadColor = tarea.prioridad == 'alta'
        ? Colors.red
        : tarea.prioridad == 'media'
            ? Colors.orange
            : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: tarea.isCompletada,
                    onChanged: (_) => onToggleComplete(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tarea.titulo,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                decoration: tarea.isCompletada
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                        if (tarea.descripcion != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            tarea.descripcion!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: prioridadColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tarea.prioridadDisplay,
                      style: TextStyle(
                        color: prioridadColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: tarea.progresosPorcentaje / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    tarea.asignadoA?.fullName ?? 'Sin asignar',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (tarea.fechaVencimiento != null) ...[
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(tarea.fechaVencimiento!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Details sheet
class _DetallesTareaSheet extends ConsumerWidget {
  final Tarea tarea;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  final VoidCallback onActualizar;

  const _DetallesTareaSheet({
    required this.tarea,
    required this.onEditar,
    required this.onEliminar,
    required this.onActualizar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tarea.titulo,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              _buildDetailRow(context, 'Estado', tarea.estadoDisplay),
              _buildDetailRow(context, 'Prioridad', tarea.prioridadDisplay),
              _buildDetailRow(
                context,
                'Progreso',
                '${tarea.progresosPorcentaje}%',
              ),
              if (tarea.descripcion != null)
                _buildDetailRow(context, 'Descripción', tarea.descripcion!),
              if (tarea.asignadoA != null)
                _buildDetailRow(
                  context,
                  'Asignado a',
                  tarea.asignadoA!.fullName,
                ),
              if (tarea.fechaInicio != null)
                _buildDetailRow(
                  context,
                  'Fecha Inicio',
                  DateFormat('dd/MM/yyyy').format(tarea.fechaInicio!),
                ),
              if (tarea.fechaVencimiento != null)
                _buildDetailRow(
                  context,
                  'Fecha Vencimiento',
                  DateFormat('dd/MM/yyyy').format(tarea.fechaVencimiento!),
                ),
              if (tarea.notas != null)
                _buildDetailRow(context, 'Notas', tarea.notas!),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEditar,
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEliminar,
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

// Form sheet
class _FormularioTareaSheet extends ConsumerStatefulWidget {
  final Tarea? tarea;
  final VoidCallback onGuardado;

  const _FormularioTareaSheet({
    this.tarea,
    required this.onGuardado,
  });

  @override
  ConsumerState<_FormularioTareaSheet> createState() =>
      _FormularioTareaSheetState();
}

class _FormularioTareaSheetState extends ConsumerState<_FormularioTareaSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _notasController;
  String _estado = 'pendiente';
  String _prioridad = 'media';
  int _progreso = 0;
  DateTime? _fechaInicio;
  DateTime? _fechaVencimiento;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tarea?.titulo);
    _descripcionController =
        TextEditingController(text: widget.tarea?.descripcion);
    _notasController = TextEditingController(text: widget.tarea?.notas);
    _estado = widget.tarea?.estado ?? 'pendiente';
    _prioridad = widget.tarea?.prioridad ?? 'media';
    _progreso = widget.tarea?.progresosPorcentaje ?? 0;
    _fechaInicio = widget.tarea?.fechaInicio;
    _fechaVencimiento = widget.tarea?.fechaVencimiento;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.tarea == null ? 'Nueva Tarea' : 'Editar Tarea',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _prioridad,
                  decoration: const InputDecoration(
                    labelText: 'Prioridad',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'baja', child: Text('Baja')),
                    DropdownMenuItem(value: 'media', child: Text('Media')),
                    DropdownMenuItem(value: 'alta', child: Text('Alta')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _prioridad = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _estado,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(
                        value: 'en_progreso', child: Text('En Progreso')),
                    DropdownMenuItem(
                        value: 'completada', child: Text('Completada')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _estado = value);
                  },
                ),
                const SizedBox(height: 16),
                Text('Progreso: $_progreso%'),
                Slider(
                  value: _progreso.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '$_progreso%',
                  onChanged: (value) {
                    setState(() => _progreso = value.toInt());
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Fecha de Inicio'),
                  subtitle: Text(_fechaInicio != null
                      ? DateFormat('dd/MM/yyyy').format(_fechaInicio!)
                      : 'No definida'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: _fechaInicio ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (fecha != null) {
                      setState(() => _fechaInicio = fecha);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Fecha de Vencimiento'),
                  subtitle: Text(_fechaVencimiento != null
                      ? DateFormat('dd/MM/yyyy').format(_fechaVencimiento!)
                      : 'No definida'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final fecha = await showDatePicker(
                      context: context,
                      initialDate: _fechaVencimiento ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (fecha != null) {
                      setState(() => _fechaVencimiento = fecha);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notasController,
                  decoration: const InputDecoration(
                    labelText: 'Notas',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _guardar,
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authState = ref.read(authProvider);
      final obraId = authState.obraActual?.id;
      final userId = authState.user?.id;
      
      if (obraId == null) return;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Usuario no autenticado')),
          );
        }
        return;
      }

      final tareaService = ref.read(tareaServiceProvider);

      // Preparar datos según el formato esperado por el backend
      final data = <String, dynamic>{
        'titulo': _tituloController.text.trim(),
        'prioridad': _prioridad,
        'estado': _estado,
        'asignado_a_id': userId, // ID del usuario autenticado
        'avance_porcentaje': _progreso, // El backend espera 'avance_porcentaje' al crear
      };

      // Campos opcionales
      if (_descripcionController.text.trim().isNotEmpty) {
        data['descripcion'] = _descripcionController.text.trim();
      }
      if (_notasController.text.trim().isNotEmpty) {
        data['notas'] = _notasController.text.trim();
      }
      if (_fechaInicio != null) {
        data['fecha_inicio'] = _fechaInicio!.toIso8601String().split('T')[0];
      }
      if (_fechaVencimiento != null) {
        // El backend espera 'fecha_limite' al crear/actualizar
        data['fecha_limite'] =
            _fechaVencimiento!.toIso8601String().split('T')[0];
      }

      // Debug: imprimir datos que se van a enviar
      print('Datos a enviar: $data');

      if (widget.tarea == null) {
        // Crear nueva tarea
        await tareaService.createTask(obraId, data);
      } else {
        // Actualizar tarea existente
        // Al actualizar, algunos campos pueden tener nombres diferentes
        final updateData = <String, dynamic>{
          'titulo': _tituloController.text.trim(),
          'prioridad': _prioridad,
          'estado': _estado,
          'avance_porcentaje': _progreso,
        };
        
        if (_descripcionController.text.trim().isNotEmpty) {
          updateData['descripcion'] = _descripcionController.text.trim();
        }
        if (_notasController.text.trim().isNotEmpty) {
          updateData['notas'] = _notasController.text.trim();
        }
        if (_fechaInicio != null) {
          updateData['fecha_inicio'] = _fechaInicio!.toIso8601String().split('T')[0];
        }
        if (_fechaVencimiento != null) {
          updateData['fecha_limite'] =
              _fechaVencimiento!.toIso8601String().split('T')[0];
        }
        
        await tareaService.updateTask(obraId, widget.tarea!.id, updateData);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onGuardado();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.tarea == null
                ? 'Tarea creada'
                : 'Tarea actualizada'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Extraer mensaje de error más detallado
        String errorMessage = 'Error desconocido';
        
        if (e is DioException) {
          if (e.response != null) {
            // El servidor respondió con un error
            final responseData = e.response!.data;
            if (responseData is Map) {
              // Intentar extraer mensaje de error del servidor
              errorMessage = responseData['message']?.toString() ??
                  responseData['error']?.toString() ??
                  responseData.toString();
            } else {
              errorMessage = responseData?.toString() ?? e.message ?? 'Error desconocido';
            }
          } else {
            errorMessage = e.message ?? 'Error de conexión';
          }
        } else {
          errorMessage = e.toString();
        }
        
        print('Error al guardar tarea: $e');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
