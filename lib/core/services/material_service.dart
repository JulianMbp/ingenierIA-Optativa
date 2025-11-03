import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/material.dart';
import 'api_service.dart';

final materialServiceProvider = Provider<MaterialService>((ref) {
  return MaterialService(ref.read(apiServiceProvider));
});

class MaterialService {
  final ApiService _apiService;

  MaterialService(this._apiService);

  /// Obtiene los materiales de una obra
  Future<List<Material>> getMateriales(
    String obraId, {
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.get(
      '/obras/$obraId/materiales',
      queryParameters: filters,
    );
    final data = response.data as List;
    return data.map((json) => Material.fromJson(json)).toList();
  }

  /// Obtiene un material específico
  Future<Material> getMaterial(String obraId, String materialId) async {
    final response = await _apiService.get(
      '/obras/$obraId/materiales/$materialId',
    );
    return Material.fromJson(response.data);
  }

  /// Crea un nuevo material
  Future<Material> createMaterial(
    String obraId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.post(
      '/obras/$obraId/materiales',
      data: data,
    );
    return Material.fromJson(response.data);
  }

  /// Actualiza un material
  Future<Material> updateMaterial(
    String obraId,
    String materialId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/obras/$obraId/materiales/$materialId',
      data: data,
    );
    return Material.fromJson(response.data);
  }

  /// Elimina un material
  Future<void> deleteMaterial(String obraId, String materialId) async {
    await _apiService.delete('/obras/$obraId/materiales/$materialId');
  }
}
