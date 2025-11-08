import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tarea.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';

final tareaRepositoryProvider = Provider<TareaRepository>((ref) {
  return TareaRepository(
    ref.read(offlineServiceProvider),
    ref.read(apiServiceProvider),
  );
});

/// Repositorio de tareas
/// Simplificado: solo usa API directamente
class TareaRepository {
  final OfflineService _offlineService;
  final ApiService _apiService;

  TareaRepository(
    this._offlineService,
    this._apiService,
  );

  /// Listar tareas desde la API
  Future<List<Tarea>> listTasks(String obraId) async {
    final hasConnection = await _offlineService.hasConnection();
    
    if (!hasConnection) {
      throw Exception('Sin conexión a internet. Por favor, verifica tu conexión.');
    }

    try {
      final response = await _apiService.get('/obras/$obraId/tareas');
      dynamic data = response.data;
      
      List<dynamic> tareasList = [];
      if (data is List) {
        tareasList = data;
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        tareasList = data['data'] as List;
      }
      
      return tareasList
          .map((json) => Tarea.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Crear tarea
  Future<Tarea> createTask(String obraId, Map<String, dynamic> tareaData) async {
    final hasConnection = await _offlineService.hasConnection();
    
    if (!hasConnection) {
      throw Exception('Sin conexión a internet. Por favor, verifica tu conexión.');
    }

    try {
      final response = await _apiService.post(
        '/obras/$obraId/tareas',
        data: tareaData,
      );
      return Tarea.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Actualizar tarea
  Future<Tarea> updateTask(
    String obraId,
    String tareaId,
    Map<String, dynamic> tareaData,
  ) async {
    final hasConnection = await _offlineService.hasConnection();
    
    if (!hasConnection) {
      throw Exception('Sin conexión a internet. Por favor, verifica tu conexión.');
    }

    try {
      final response = await _apiService.patch(
        '/obras/$obraId/tareas/$tareaId',
        data: tareaData,
      );
      return Tarea.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Eliminar tarea
  Future<void> deleteTask(String obraId, String tareaId) async {
    final hasConnection = await _offlineService.hasConnection();
    
    if (!hasConnection) {
      throw Exception('Sin conexión a internet. Por favor, verifica tu conexión.');
    }

    try {
      await _apiService.delete('/obras/$obraId/tareas/$tareaId');
    } catch (e) {
      rethrow;
    }
  }
}
