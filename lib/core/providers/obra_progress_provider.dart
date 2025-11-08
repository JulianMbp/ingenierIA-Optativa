import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tarea.dart';
import '../services/tarea_service.dart';
import '../../features/auth/auth_provider.dart';

/// Estado del progreso de la obra
class ObraProgressState {
  final double progreso;
  final int totalTareas;
  final int tareasCompletadas;
  final int tareasEnProgreso;
  final int tareasPendientes;
  final bool isLoading;
  final String? error;

  ObraProgressState({
    this.progreso = 0.0,
    this.totalTareas = 0,
    this.tareasCompletadas = 0,
    this.tareasEnProgreso = 0,
    this.tareasPendientes = 0,
    this.isLoading = false,
    this.error,
  });

  ObraProgressState copyWith({
    double? progreso,
    int? totalTareas,
    int? tareasCompletadas,
    int? tareasEnProgreso,
    int? tareasPendientes,
    bool? isLoading,
    String? error,
  }) {
    return ObraProgressState(
      progreso: progreso ?? this.progreso,
      totalTareas: totalTareas ?? this.totalTareas,
      tareasCompletadas: tareasCompletadas ?? this.tareasCompletadas,
      tareasEnProgreso: tareasEnProgreso ?? this.tareasEnProgreso,
      tareasPendientes: tareasPendientes ?? this.tareasPendientes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier para el progreso de la obra
class ObraProgressNotifier extends Notifier<ObraProgressState> {
  @override
  ObraProgressState build() {
    // Cargar progreso inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProgress();
    });
    return ObraProgressState();
  }

  /// Calcula el progreso desde una lista de tareas
  void _calcularDesdeTareas(List<Tarea> tareas) {
    if (tareas.isEmpty) {
      state = ObraProgressState(
        progreso: 0.0,
        totalTareas: 0,
        tareasCompletadas: 0,
        tareasEnProgreso: 0,
        tareasPendientes: 0,
        isLoading: false,
      );
      return;
    }

    final completadas = tareas.where((t) => t.isCompletada).length;
    final enProgreso = tareas.where((t) => t.isEnProgreso).length;
    final pendientes = tareas.where((t) => t.isPendiente).length;
    
    final suma = tareas.fold<double>(
      0.0,
      (sum, t) => sum + t.progresosPorcentaje.toDouble(),
    );
    
    final progreso = suma / tareas.length;

    state = ObraProgressState(
      progreso: progreso,
      totalTareas: tareas.length,
      tareasCompletadas: completadas,
      tareasEnProgreso: enProgreso,
      tareasPendientes: pendientes,
      isLoading: false,
    );
  }

  /// Cargar el progreso desde el API
  Future<void> loadProgress() async {
    final authState = ref.read(authProvider);
    final obraId = authState.obraActual?.id;

    if (obraId == null) {
      state = ObraProgressState(
        progreso: 0.0,
        totalTareas: 0,
        tareasCompletadas: 0,
        tareasEnProgreso: 0,
        tareasPendientes: 0,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final tareaService = ref.read(tareaServiceProvider);
      final tareas = await tareaService.listTasks(obraId);
      _calcularDesdeTareas(tareas);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Actualizar el progreso desde una lista de tareas (sin llamar al API)
  void updateFromTareas(List<Tarea> tareas) {
    _calcularDesdeTareas(tareas);
  }

  /// Refrescar el progreso (forzar recarga desde el API)
  Future<void> refresh() async {
    await loadProgress();
  }
}

/// Provider para el progreso de la obra
final obraProgressProvider =
    NotifierProvider<ObraProgressNotifier, ObraProgressState>(() {
  return ObraProgressNotifier();
});

