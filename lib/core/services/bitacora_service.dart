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
      '/bitacoras',
      queryParameters: {...?filters, 'obraId': obraId},
    );
    final data = response.data as List;
    return data.map((json) => Bitacora.fromJson(json)).toList();
  }

  /// Obtiene una bitácora específica
  Future<Bitacora> getBitacora(String bitacoraId) async {
    final response = await _apiService.get('/bitacoras/$bitacoraId');
    return Bitacora.fromJson(response.data);
  }

  /// Crea una nueva bitácora
  Future<Bitacora> createBitacora(Map<String, dynamic> data) async {
    final response = await _apiService.post('/bitacoras', data: data);
    return Bitacora.fromJson(response.data);
  }

  /// Actualiza una bitácora
  Future<Bitacora> updateBitacora(
    String bitacoraId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/bitacoras/$bitacoraId',
      data: data,
    );
    return Bitacora.fromJson(response.data);
  }

  /// Elimina una bitácora
  Future<void> deleteBitacora(String bitacoraId) async {
    await _apiService.delete('/bitacoras/$bitacoraId');
  }
}
