import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bitacora.dart';
import 'api_service.dart';

final bitacoraServiceProvider = Provider<BitacoraService>((ref) {
  return BitacoraService(ref.read(apiServiceProvider));
});

class BitacoraService {
  final ApiService _apiService;

  BitacoraService(this._apiService);

  /// Obtiene las bitácoras de una obra
  Future<List<Bitacora>> getBitacoras(
    String obraId, {
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.get(
      '/obras/$obraId/bitacoras',
      queryParameters: filters,
    );
    final responseData = response.data;
    final data = responseData['data'] as List;
    return data.map((json) => Bitacora.fromJson(json)).toList();
  }

  /// Obtiene una bitácora específica
  Future<Bitacora> getBitacora(String obraId, String bitacoraId) async {
    final response = await _apiService.get('/obras/$obraId/bitacoras/$bitacoraId');
    final responseData = response.data;
    return Bitacora.fromJson(responseData['data']);
  }

  /// Crea una nueva bitácora
  Future<Bitacora> createBitacora(String obraId, Map<String, dynamic> data) async {
    final response = await _apiService.post('/obras/$obraId/bitacoras', data: data);
    final responseData = response.data;
    return Bitacora.fromJson(responseData['data']);
  }

  /// Actualiza una bitácora
  Future<Bitacora> updateBitacora(
    String obraId,
    String bitacoraId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/obras/$obraId/bitacoras/$bitacoraId',
      data: data,
    );
    final responseData = response.data;
    return Bitacora.fromJson(responseData['data']);
  }

  /// Elimina una bitácora
  Future<void> deleteBitacora(String obraId, String bitacoraId) async {
    await _apiService.delete('/obras/$obraId/bitacoras/$bitacoraId');
  }
}
