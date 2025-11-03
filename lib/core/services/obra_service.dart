import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/obra.dart';
import 'api_service.dart';

final obraServiceProvider = Provider<ObraService>((ref) {
  return ObraService(ref.read(apiServiceProvider));
});

class ObraService {
  final ApiService _apiService;

  ObraService(this._apiService);

  /// Obtiene las obras del usuario autenticado
  Future<List<Obra>> getMyObras() async {
    final response = await _apiService.get('/auth/my-obras');
    final data = response.data as List;
    return data.map((json) => Obra.fromJson(json)).toList();
  }

  /// Cambia la obra actual del usuario y obtiene un nuevo token
  Future<String> switchObra(String obraId) async {
    final response = await _apiService.post(
      '/auth/switch-obra',
      data: {'obraId': obraId},
    );
    return response.data['token'] as String;
  }

  /// Obtiene todas las obras (solo Admin General)
  Future<List<Obra>> getAllObras({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get(
      '/obras',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    final data = response.data as List;
    return data.map((json) => Obra.fromJson(json)).toList();
  }

  /// Crea una nueva obra (solo Admin General)
  Future<Obra> createObra(Map<String, dynamic> data) async {
    final response = await _apiService.post('/obras', data: data);
    return Obra.fromJson(response.data);
  }

  /// Actualiza una obra (solo Admin General)
  Future<Obra> updateObra(String obraId, Map<String, dynamic> data) async {
    final response = await _apiService.patch('/obras/$obraId', data: data);
    return Obra.fromJson(response.data);
  }

  /// Elimina una obra (solo Admin General)
  Future<void> deleteObra(String obraId) async {
    await _apiService.delete('/obras/$obraId');
  }

  /// Asigna un usuario a una obra (solo Admin General)
  Future<void> asignarUsuario(String obraId, String usuarioId) async {
    await _apiService.post(
      '/obras/$obraId/usuarios',
      data: {'usuarioId': usuarioId},
    );
  }
}
