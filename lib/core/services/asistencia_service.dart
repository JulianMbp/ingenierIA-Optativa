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
      '/asistencias',
      queryParameters: {...?filters, 'obraId': obraId},
    );
    final data = response.data as List;
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
      return Asistencia.fromJson(response.data);
    } catch (e) {
      return null; // No hay asistencia registrada hoy
    }
  }

  /// Obtiene una asistencia específica
  Future<Asistencia> getAsistencia(String asistenciaId) async {
    final response = await _apiService.get('/asistencias/$asistenciaId');
    return Asistencia.fromJson(response.data);
  }

  /// Crea una nueva asistencia
  Future<Asistencia> createAsistencia(Map<String, dynamic> data) async {
    final response = await _apiService.post('/asistencias', data: data);
    return Asistencia.fromJson(response.data);
  }

  /// Actualiza una asistencia
  Future<Asistencia> updateAsistencia(
    String asistenciaId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/asistencias/$asistenciaId',
      data: data,
    );
    return Asistencia.fromJson(response.data);
  }

  /// Elimina una asistencia
  Future<void> deleteAsistencia(String asistenciaId) async {
    await _apiService.delete('/asistencias/$asistenciaId');
  }
}
