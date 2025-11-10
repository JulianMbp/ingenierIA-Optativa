import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/material.dart';
import 'api_service.dart';

final materialServiceProvider = Provider<MaterialService>((ref) {
  return MaterialService(ref.read(apiServiceProvider));
});

class MaterialService {
  final ApiService _apiService;

  MaterialService(this._apiService);

  /// Get materials for a project
  Future<List<Material>> getMaterials(
    String projectId, {
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.get(
      '/obras/$projectId/materiales', // Keep backend endpoint
      queryParameters: filters,
    );
    
    // API returns {success, data, message}
    final responseData = response.data;
    final data = responseData['data'] as List;
    return data.map((json) => Material.fromJson(json)).toList();
  }

  /// Get a specific material
  Future<Material> getMaterial(String projectId, String materialId) async {
    final response = await _apiService.get(
      '/obras/$projectId/materiales/$materialId', // Keep backend endpoint
    );
    final responseData = response.data;
    return Material.fromJson(responseData['data']);
  }

  /// Create a new material
  Future<Material> createMaterial(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.post(
      '/obras/$projectId/materiales', // Keep backend endpoint
      data: data,
    );
    final responseData = response.data;
    return Material.fromJson(responseData['data']);
  }

  /// Update a material
  Future<Material> updateMaterial(
    String projectId,
    String materialId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/obras/$projectId/materiales/$materialId', // Keep backend endpoint
      data: data,
    );
    final responseData = response.data;
    return Material.fromJson(responseData['data']);
  }

  /// Delete a material
  Future<void> deleteMaterial(String projectId, String materialId) async {
    await _apiService.delete('/obras/$projectId/materiales/$materialId'); // Keep backend endpoint
  }
}
