import '../entities/material.dart';

/// Abstract repository for materials management
abstract class MaterialRepository {
  /// Get all materials for a specific obra
  Future<List<Material>> getMaterialsByObra(String obraId);

  /// Stream of materials for real-time updates
  Stream<List<Material>> watchMaterialsByObra(String obraId);

  /// Get a single material by ID
  Future<Material?> getMaterialById(String materialId);

  /// Create a new material
  Future<Material> createMaterial(Material material);

  /// Update an existing material
  Future<Material> updateMaterial(Material material);

  /// Delete a material
  Future<void> deleteMaterial(String materialId);

  /// Search materials by name or category
  Future<List<Material>> searchMaterials(String obraId, String query);

  /// Get materials by status
  Future<List<Material>> getMaterialsByStatus(String obraId, String status);

  /// Get low stock materials
  Future<List<Material>> getLowStockMaterials(String obraId);
}
