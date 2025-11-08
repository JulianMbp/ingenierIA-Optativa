import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/obra.dart';
import 'api_service.dart';

final obraServiceProvider = Provider<ObraService>((ref) {
  return ObraService(ref.read(apiServiceProvider));
});

class ObraService {
  final ApiService _apiService;

  ObraService(this._apiService);

  /// Get authenticated user's projects
  Future<List<Obra>> getMyObras() async {
    final response = await _apiService.get('/auth/my-obras');
    dynamic responseData = response.data;
    
    List<dynamic> obrasList = [];
    
    // El endpoint puede devolver directamente un array o un objeto con 'obra' dentro
    if (responseData is List) {
      obrasList = responseData;
    } else if (responseData is Map<String, dynamic>) {
      // Si viene como objeto, puede estar en 'data' o directamente en el objeto
      if (responseData.containsKey('data') && responseData['data'] is List) {
        obrasList = responseData['data'] as List;
      } else {
        // Intentar extraer 'obra' de cada elemento si viene como array de objetos con 'obra'
        obrasList = responseData.values.where((v) => v is List).expand((v) => v as List).toList();
      }
    }
    
    // Si aún no tenemos obras, intentar parsear cada elemento
    if (obrasList.isEmpty && responseData is List) {
      obrasList = responseData;
    }
    
    // Si el formato es array de objetos con 'obra' dentro (como en postman)
    if (obrasList.isNotEmpty && obrasList.first is Map<String, dynamic>) {
      final firstItem = obrasList.first as Map<String, dynamic>;
      if (firstItem.containsKey('obra')) {
        // El formato es: [{"obra": {...}, "roleName": "..."}]
        return obrasList.map((item) {
          final obraData = item['obra'] as Map<String, dynamic>;
          // Agregar roleName al objeto obra si está disponible
          if (item.containsKey('roleName')) {
            obraData['roleName'] = item['roleName'];
          }
          return Obra.fromJson(obraData);
        }).toList();
      }
    }
    
    // Formato estándar: array directo de obras
    return obrasList.map((json) => Obra.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Switch current user's project and get new token
  Future<String> switchObra(String obraId) async {
    final response = await _apiService.post(
      '/auth/switch-obra',
      data: {'obraId': obraId},
    );
    return response.data['token'] as String;
  }

  /// Get all projects (Admin General only)
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

  /// Create a new project (Admin General only)
  Future<Obra> createObra(Map<String, dynamic> data) async {
    final response = await _apiService.post('/obras', data: data);
    return Obra.fromJson(response.data);
  }

  /// Update a project (Admin General only)
  Future<Obra> updateObra(String obraId, Map<String, dynamic> data) async {
    final response = await _apiService.patch('/obras/$obraId', data: data);
    return Obra.fromJson(response.data);
  }

  /// Delete a project (Admin General only)
  Future<void> deleteObra(String obraId) async {
    await _apiService.delete('/obras/$obraId');
  }

  /// Assign a user to a project (Admin General only)
  Future<void> asignarUsuario(String obraId, String usuarioId) async {
    await _apiService.post(
      '/obras/$obraId/usuarios',
      data: {'usuarioId': usuarioId},
    );
  }

  /// Get users assigned to a project
  Future<List<Map<String, dynamic>>> getUsuariosObra(String obraId) async {
    final response = await _apiService.get('/obras/$obraId/usuarios');
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}