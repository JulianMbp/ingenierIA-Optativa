import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../core/models/asistencia.dart';
import '../../../core/models/role.dart';
import '../../../core/services/asistencia_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/auth_provider.dart';

class AsistenciasScreen extends ConsumerStatefulWidget {
  const AsistenciasScreen({super.key});

  @override
  ConsumerState<AsistenciasScreen> createState() => _AsistenciasScreenState();
}

class _AsistenciasScreenState extends ConsumerState<AsistenciasScreen> {
  List<Asistencia> asistencias = [];
  Asistencia? asistenciaHoy;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAsistencias();
  }

  Future<void> _loadAsistencias() async {
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

      final asistenciaService = ref.read(asistenciaServiceProvider);
      
      // Cargar asistencia de hoy
      final hoy = await asistenciaService.getMyAsistenciaHoy(obraId);
      
      // Cargar historial de asistencias
      final result = await asistenciaService.getAsistencias(obraId);

      setState(() {
        asistenciaHoy = hoy;
        asistencias = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar asistencias: $e';
        isLoading = false;
      });
    }
  }

  bool _isOperario() {
    final authState = ref.read(authProvider);
    return authState.user?.role.type == RoleType.obrero;
  }

  bool _isRRHH() {
    final authState = ref.read(authProvider);
    return authState.user?.role.type == RoleType.rrhh || 
           authState.user?.role.type == RoleType.adminGeneral;
  }

  Future<void> _marcarAsistencia(String estado) async {
    try {
      final authState = ref.read(authProvider);
      final obraId = authState.obraActual?.id;
      final usuarioId = authState.user?.id;

      if (obraId == null || usuarioId == null) return;

      final asistenciaService = ref.read(asistenciaServiceProvider);
      final hoy = DateTime.now();
      final data = {
        'obra_id': obraId,
        'usuario_id': usuarioId,
        'fecha': '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}',
        'estado': estado,
        'observaciones': null,
      };

      await asistenciaService.createAsistencia(obraId, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Asistencia marcada como $estado')),
        );
      }

      _loadAsistencias();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al marcar asistencia: $e')),
        );
      }
    }
  }

  Widget _buildAsistenciaHoyCard() {
    return GlassContainer(
      blur: 15,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today,
                color: AppTheme.iosGreen,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Asistencia de Hoy',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (asistenciaHoy != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getEstadoIcon(asistenciaHoy!.estado),
                  size: 64,
                  color: _getEstadoColor(asistenciaHoy!.estado),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getEstadoText(asistenciaHoy!.estado),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getEstadoColor(asistenciaHoy!.estado),
                      ),
                    ),
                    if (asistenciaHoy!.createdAt != null)
                      Text(
                        DateFormat('HH:mm').format(asistenciaHoy!.createdAt!),
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            if (asistenciaHoy!.observaciones != null) ...[
              const SizedBox(height: 12),
              Text(
                'Observaciones: ${asistenciaHoy!.observaciones}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ] else if (_isOperario()) ...[
            const Text(
              'No has marcado asistencia hoy',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _marcarAsistencia('presente'),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Presente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _marcarAsistencia('tardanza'),
                  icon: const Icon(Icons.access_time),
                  label: const Text('Tardanza'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'Sin asistencia registrada',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencias'),
        backgroundColor: AppTheme.iosGreen,
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
                            onPressed: _loadAsistencias,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAsistencias,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildAsistenciaHoyCard(),
                          const SizedBox(height: 24),
                          Text(
                            'Historial',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          if (asistencias.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No hay asistencias registradas'),
                              ),
                            )
                          else
                            ...asistencias.map((asistencia) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassContainer(
                                  blur: 15,
                                  opacity: 0.2,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    leading: Icon(
                                      _getEstadoIcon(asistencia.estado),
                                      color: _getEstadoColor(asistencia.estado),
                                      size: 32,
                                    ),
                                    title: Text(
                                      DateFormat('dd/MM/yyyy').format(
                                        asistencia.fecha,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getEstadoText(asistencia.estado),
                                          style: TextStyle(
                                            color: _getEstadoColor(
                                              asistencia.estado,
                                            ),
                                          ),
                                        ),
                                        if (asistencia.observaciones != null)
                                          Text(
                                            asistencia.observaciones!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: _isRRHH()
                                        ? IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              // TODO: Implementar edición para RRHH
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'presente':
        return Icons.check_circle;
      case 'tardanza':
        return Icons.access_time;
      case 'ausente':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'presente':
        return Colors.green;
      case 'tardanza':
        return Colors.orange;
      case 'ausente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getEstadoText(String estado) {
    switch (estado) {
      case 'presente':
        return 'Presente';
      case 'tardanza':
        return 'Tardanza';
      case 'ausente':
        return 'Ausente';
      default:
        return 'Desconocido';
    }
  }
}

