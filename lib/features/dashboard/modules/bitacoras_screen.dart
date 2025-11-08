import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../core/models/bitacora.dart';
import '../../../core/models/role.dart';
import '../../../core/models/tarea.dart';
import '../../../core/services/bitacora_service.dart';
import '../../../core/services/tarea_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/auth_provider.dart';
import 'generar_informe_ia_screen.dart';

class BitacorasScreen extends ConsumerStatefulWidget {
  const BitacorasScreen({super.key});

  @override
  ConsumerState<BitacorasScreen> createState() => _BitacorasScreenState();
}

class _BitacorasScreenState extends ConsumerState<BitacorasScreen> {
  List<Bitacora> bitacoras = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBitacoras();
  }

  Future<void> _loadBitacoras() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final obraId = authState.obraActual?.id;

      if (obraId == null) {
        setState(() {
          errorMessage = 'No hay obra seleccionada';
          isLoading = false;
        });
        return;
      }

      final bitacoraService = ref.read(bitacoraServiceProvider);
      final result = await bitacoraService.getBitacoras(obraId);

      setState(() {
        bitacoras = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar bitácoras: $e';
        isLoading = false;
      });
    }
  }

  bool _canCreate() {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role.type;
    // Todos menos RRHH pueden crear bitácoras
    return userRole != RoleType.rrhh;
  }

  bool _canEdit(Bitacora bitacora) {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role.type;
    final userId = authState.user?.id;
    
    // Admin General and Admin Obra can edit any work log
    if (userRole == RoleType.adminGeneral || userRole == RoleType.adminObra) {
      return true;
    }
    
    // Obreros solo pueden editar sus propias bitácoras
    if (userRole == RoleType.obrero) {
      return bitacora.autorId == userId.toString();
    }
    
    // SST puede editar cualquiera
    return userRole == RoleType.sst;
  }

  Future<void> _showBitacoraDialog({Bitacora? bitacora}) async {
    final isEdit = bitacora != null;
    final descripcionController = TextEditingController(
      text: bitacora?.descripcion ?? '',
    );
    final avanceController = TextEditingController(
      text: bitacora?.avancePorcentajeInt.toString() ?? '',
    );
    DateTime selectedDate = bitacora?.fecha ?? DateTime.now();
    List<Tarea> tareas = [];
    List<String> tareasSeleccionadas = [];
    bool cargandoTareas = true;

    // Load project tasks
    final authState = ref.read(authProvider);
    final obraId = authState.obraActual?.id;
    if (obraId != null) {
      try {
        final tareaService = ref.read(tareaServiceProvider);
        tareas = await tareaService.listTasks(obraId);
        cargandoTareas = false;
      } catch (e) {
        cargandoTareas = false;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Editar Bitácora' : 'Nueva Bitácora'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: avanceController,
                  decoration: const InputDecoration(
                    labelText: 'Avance (%)',
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Fecha'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const Divider(),
                const Text(
                  'Marcar tareas como completadas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (cargandoTareas)
                  const CircularProgressIndicator()
                else if (tareas.isEmpty)
                  const Text('No hay tareas disponibles')
                else
                  ...tareas
                      .where((t) => !t.isCompletada)
                      .map(
                        (tarea) => CheckboxListTile(
                          title: Text(tarea.titulo),
                          subtitle: Text(
                            'Progreso: ${tarea.progresosPorcentaje}%',
                          ),
                          value: tareasSeleccionadas.contains(tarea.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                tareasSeleccionadas.add(tarea.id);
                              } else {
                                tareasSeleccionadas.remove(tarea.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final avance = int.tryParse(avanceController.text);
                  if (avance == null || avance < 0 || avance > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('El avance debe ser entre 0 y 100'),
                      ),
                    );
                    return;
                  }

                  final authState = ref.read(authProvider);
                  final obraId = authState.obraActual?.id;
                  final usuarioId = authState.user?.id;

                  if (obraId == null || usuarioId == null) return;

                  final bitacoraService = ref.read(bitacoraServiceProvider);
                  final data = {
                    'obra_id': obraId,
                    'usuario_id': usuarioId,
                    'descripcion': descripcionController.text,
                    'avance_porcentaje': avance,
                    'fecha': selectedDate.toIso8601String().split('T').first,
                    'archivos': [],
                  };

                  if (isEdit) {
                    await bitacoraService.updateBitacora(
                      obraId,
                      bitacora.id,
                      data,
                    );
                  } else {
                    await bitacoraService.createBitacora(obraId, data);
                  }

                  // Complete selected tasks
                  if (tareasSeleccionadas.isNotEmpty) {
                    final tareaService = ref.read(tareaServiceProvider);
                    for (final tareaId in tareasSeleccionadas) {
                      try {
                        await tareaService.completeTask(obraId, tareaId);
                      } catch (e) {
                        // Continue with other tasks if one fails
                        print('Error al completar tarea $tareaId: $e');
                      }
                    }
                  }

                  if (context.mounted) {
                    Navigator.pop(context, true);
                    if (tareasSeleccionadas.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Bitácora guardada y ${tareasSeleccionadas.length} tarea(s) completada(s)',
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadBitacoras();
    }
  }

  Future<void> _deleteBitacora(Bitacora bitacora) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Eliminar esta bitácora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authState = ref.read(authProvider);
        final obraId = authState.obraActual?.id;
        
        if (obraId == null) return;

        final bitacoraService = ref.read(bitacoraServiceProvider);
        await bitacoraService.deleteBitacora(obraId, bitacora.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bitácora eliminada')),
          );
        }

        _loadBitacoras();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = _canCreate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácoras'),
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadBitacoras,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBitacoras,
                      child: Column(
                        children: [
                          // Banner destacado para generar informe con IA
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.iosOrange,
                                  AppTheme.iosOrange.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.iosOrange.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Genera tu Bitácora con IA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Crea informes profesionales automáticamente',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const GenerarInformeIaScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Generar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.iosOrange,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Lista de bitácoras
                          Expanded(
                            child: bitacoras.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.description_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No hay bitácoras registradas',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Crea una nueva o genera un informe con IA',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: bitacoras.length,
                                    itemBuilder: (context, index) {
                              final bitacora = bitacoras[index];
                              final canEdit = _canEdit(bitacora);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassContainer(
                                  blur: 15,
                                  opacity: 0.2,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    title: Text(
                                      DateFormat('dd/MM/yyyy').format(bitacora.fecha),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(bitacora.descripcion),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: bitacora.avancePorcentajeInt / 100,
                                                backgroundColor: Colors.grey.shade300,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  _getProgressColor(bitacora.avancePorcentajeInt),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${bitacora.avancePorcentajeInt}%',
                                              style: TextStyle(
                                                color: _getProgressColor(
                                                  bitacora.avancePorcentajeInt,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (bitacora.autorNombre != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Por: ${bitacora.autorNombre}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: canEdit
                                        ? PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showBitacoraDialog(bitacora: bitacora);
                                              } else if (value == 'delete') {
                                                _deleteBitacora(bitacora);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Editar'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Eliminar'),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                              );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
      floatingActionButton: canCreate
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Botón de IA más grande y visible
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenerarInformeIaScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppTheme.iosOrange,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.auto_awesome, size: 28),
                  label: const Text(
                    'Generar con IA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  elevation: 6,
                ),
                const SizedBox(height: 16),
                // Botón para crear bitácora manual
                FloatingActionButton(
                  onPressed: () => _showBitacoraDialog(),
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.iosOrange,
                  child: const Icon(Icons.add),
                  elevation: 4,
                ),
              ],
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenerarInformeIaScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.iosOrange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.auto_awesome, size: 28),
              label: const Text(
                'Generar con IA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 6,
            ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 70) return Colors.orange;
    return Colors.green;
  }
}

