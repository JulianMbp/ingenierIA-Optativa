import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/asistencia.dart';
import 'api_service.dart';

final asistenciaServiceProvider = Provider<AsistenciaService>((ref) {
  return AsistenciaService(ref.read(apiServiceProvider));
});

class AsistenciaService {
  final ApiService _apiService;

  AsistenciaService(this._apiService);

  /// Obtiene las asistencias de una obra
  Future<List<Asistencia>> getAsistencias(
    String obraId, {
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.get(
      '/obras/$obraId/asistencias',
      queryParameters: filters,
    );
    final responseData = response.data;
    final data = responseData['data'] as List;
    return data.map((json) => Asistencia.fromJson(json)).toList();
  }

  /// Obtiene la asistencia del usuario autenticado para hoy
  Future<Asistencia?> getMyAsistenciaHoy(String obraId) async {
    try {
      final hoy = DateTime.now();
      final fecha = '${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}';
      
      final response = await _apiService.get(
        '/asistencias/my-asistencia-hoy',
        queryParameters: {
          'obraId': obraId,
          'fecha': fecha,
        },
      );
      final responseData = response.data;
      return Asistencia.fromJson(responseData['data']);
    } catch (e) {
      return null; // No hay asistencia registrada hoy
    }
  }

  /// Obtiene una asistencia específica
  Future<Asistencia> getAsistencia(String obraId, String asistenciaId) async {
    final response = await _apiService.get('/obras/$obraId/asistencias/$asistenciaId');
    final responseData = response.data;
    return Asistencia.fromJson(responseData['data']);
  }

  /// Crea una nueva asistencia
  Future<Asistencia> createAsistencia(String obraId, Map<String, dynamic> data) async {
    final response = await _apiService.post('/obras/$obraId/asistencias', data: data);
    final responseData = response.data;
    return Asistencia.fromJson(responseData['data']);
  }

  /// Actualiza una asistencia
  Future<Asistencia> updateAsistencia(
    String obraId,
    String asistenciaId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/obras/$obraId/asistencias/$asistenciaId',
      data: data,
    );
    final responseData = response.data;
    return Asistencia.fromJson(responseData['data']);
  }

  /// Elimina una asistencia
  Future<void> deleteAsistencia(String obraId, String asistenciaId) async {
    await _apiService.delete('/obras/$obraId/asistencias/$asistenciaId');
  }
}
