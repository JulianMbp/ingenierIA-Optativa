import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../core/models/bitacora.dart';
import '../../../core/models/role.dart';
import '../../../core/services/bitacora_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/auth_provider.dart';

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
    
    // Admin General y Admin Obra pueden editar cualquier bitácora
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

                  if (context.mounted) {
                    Navigator.pop(context, true);
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
                  : bitacoras.isEmpty
                      ? const Center(
                          child: Text('No hay bitácoras registradas'),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadBitacoras,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
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
        ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => _showBitacoraDialog(),
              backgroundColor: AppTheme.iosOrange,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 70) return Colors.orange;
    return Colors.green;
  }
}

