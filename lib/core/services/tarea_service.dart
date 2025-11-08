import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tarea.dart';
import '../repositories/tarea_repository.dart';

final tareaServiceProvider = Provider<TareaService>((ref) {
  return TareaService(ref.read(tareaRepositoryProvider));
});

class TareaService {
  final TareaRepository _repository;

  TareaService(this._repository);

  /// List all tasks for a project (usa repositorio con soporte offline)
  Future<List<Tarea>> listTasks(String obraId) async {
    return await _repository.listTasks(obraId);
  }

  /// Get my assigned tasks for a project (filtra desde la lista completa)
  Future<List<Tarea>> myTasks(String obraId) async {
    final allTasks = await listTasks(obraId);
    // Filtrar por usuario asignado (esto se haría mejor con un parámetro del usuario)
    return allTasks;
  }

  /// Get tasks assigned to a specific user (filtra desde la lista completa)
  Future<List<Tarea>> userAssignedTasks(String obraId, int userId) async {
    final allTasks = await listTasks(obraId);
    return allTasks.where((t) => t.asignadoAId == userId).toList();
  }

  /// Get a task by ID (busca en cache local o API)
  Future<Tarea> getTask(String obraId, String tareaId) async {
    final allTasks = await listTasks(obraId);
    final task = allTasks.firstWhere(
      (t) => t.id == tareaId,
      orElse: () => throw Exception('Tarea no encontrada'),
    );
    return task;
  }

  /// Create a new task (usa repositorio con soporte offline)
  Future<Tarea> createTask(String obraId, Map<String, dynamic> tareaData) async {
    return await _repository.createTask(obraId, tareaData);
  }

  /// Update an existing task (usa repositorio con soporte offline)
  Future<Tarea> updateTask(
      String obraId, String tareaId, Map<String, dynamic> tareaData) async {
    return await _repository.updateTask(obraId, tareaId, tareaData);
  }

  /// Complete a task (shortcut to mark as 100% complete)
  Future<Tarea> completeTask(String obraId, String tareaId) async {
    return updateTask(obraId, tareaId, {
      'estado': 'completada',
      'avance_porcentaje': 100,
    });
  }

  /// Delete a task (usa repositorio con soporte offline)
  Future<void> deleteTask(String obraId, String tareaId) async {
    await _repository.deleteTask(obraId, tareaId);
  }

  /// Calculate average progress of all tasks in a project
  double calculateProjectProgress(List<Tarea> tareas) {
    if (tareas.isEmpty) return 0.0;

    int totalProgress =
        tareas.fold(0, (sum, tarea) => sum + tarea.progresosPorcentaje);
    return totalProgress / tareas.length;
  }

  /// Get obra progress by calculating from tasks
  /// This method fetches all tasks and calculates the average progress
  Future<Map<String, dynamic>> getObraProgress(String obraId) async {
    try {
      final tareas = await listTasks(obraId);
      
      if (tareas.isEmpty) {
        return {
          'progreso': 0.0,
          'totalTareas': 0,
          'tareasCompletadas': 0,
          'tareasEnProgreso': 0,
          'tareasPendientes': 0,
        };
      }

      final completadas = tareas.where((t) => t.isCompletada).length;
      final enProgreso = tareas.where((t) => t.isEnProgreso).length;
      final pendientes = tareas.where((t) => t.isPendiente).length;
      
      // Calcular suma de progresos
      final suma = tareas.fold<double>(
        0.0, 
        (sum, t) {
          final progreso = t.progresosPorcentaje.toDouble();
          return sum + progreso;
        }
      );
      
      final progreso = suma / tareas.length;

      return {
        'progreso': progreso,
        'totalTareas': tareas.length,
        'tareasCompletadas': completadas,
        'tareasEnProgreso': enProgreso,
        'tareasPendientes': pendientes,
      };
    } catch (e) {
      print('Error al calcular progreso de obra: $e');
      return {
        'progreso': 0.0,
        'totalTareas': 0,
        'tareasCompletadas': 0,
        'tareasEnProgreso': 0,
        'tareasPendientes': 0,
        'error': e.toString(),
      };
    }
  }
}