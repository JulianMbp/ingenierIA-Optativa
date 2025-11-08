import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tarea.dart';
import 'api_service.dart';

final tareaServiceProvider = Provider<TareaService>((ref) {
  return TareaService(ref.read(apiServiceProvider));
});

class TareaService {
  final ApiService _apiService;

  TareaService(this._apiService);

  /// List all tasks for a project
  Future<List<Tarea>> listTasks(String obraId) async {
    final response = await _apiService.get('/obras/$obraId/tareas');
    
    // Manejar diferentes formatos de respuesta
    dynamic data = response.data;
    
    // Si la respuesta es un array directo
    if (data is List) {
      return data.map((json) => Tarea.fromJson(json as Map<String, dynamic>)).toList();
    }
    
    // Si la respuesta es un objeto con una propiedad 'data'
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List).map((json) => Tarea.fromJson(json as Map<String, dynamic>)).toList();
      }
      // Si el objeto contiene directamente las tareas como array en alguna propiedad
      // Intentar encontrar cualquier lista en el objeto
      for (var key in data.keys) {
        if (data[key] is List) {
          return (data[key] as List).map((json) => Tarea.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
    }
    
    // Si no se encuentra ningún formato reconocido, retornar lista vacía
    return [];
  }

  /// Get my assigned tasks for a project
  Future<List<Tarea>> myTasks(String obraId) async {
    final response = await _apiService.get('/obras/$obraId/tareas/mis-tareas');
    dynamic data = response.data;
    
    if (data is List) {
      return data.map((json) => Tarea.fromJson(json as Map<String, dynamic>)).toList();
    }
    
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List).map((json) => Tarea.fromJson(json as Map<String, dynamic>)).toList();
      }
    }
    
    return [];
  }

  /// Get tasks assigned to a specific user
  Future<List<Tarea>> userAssignedTasks(String obraId, int userId) async {
    final response =
        await _apiService.get('/obras/$obraId/tareas/asignadas/$userId');
    dynamic data = response.data;
    
    if (data is List) {
      return data.map((json) => Tarea.fromJson(json as Map<String, dynamic>)).toList();
    }
    
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data') && data['data'] is List) {
        return (data['data'] as List).map((json) => Tarea.fromJson(json as Map<String, dynamic>)).toList();
      }
    }
    
    return [];
  }

  /// Get a task by ID
  Future<Tarea> getTask(String obraId, String tareaId) async {
    final response = await _apiService.get('/obras/$obraId/tareas/$tareaId');
    return Tarea.fromJson(response.data);
  }

  /// Create a new task
  Future<Tarea> createTask(String obraId, Map<String, dynamic> tareaData) async {
    final response = await _apiService.post(
      '/obras/$obraId/tareas',
      data: tareaData,
    );
    return Tarea.fromJson(response.data);
  }

  /// Update an existing task
  Future<Tarea> updateTask(
      String obraId, String tareaId, Map<String, dynamic> tareaData) async {
    final response = await _apiService.patch(
      '/obras/$obraId/tareas/$tareaId',
      data: tareaData,
    );
    return Tarea.fromJson(response.data);
  }

  /// Complete a task (shortcut to mark as 100% complete)
  Future<Tarea> completeTask(String obraId, String tareaId) async {
    return updateTask(obraId, tareaId, {
      'estado': 'completada',
      'avance_porcentaje': 100,
    });
  }

  /// Delete a task
  Future<void> deleteTask(String obraId, String tareaId) async {
    await _apiService.delete('/obras/$obraId/tareas/$tareaId');
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