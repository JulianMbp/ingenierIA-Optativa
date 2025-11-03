import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/material.dart';
import '../../domain/repositories/material_repository.dart';

/// Supabase implementation of MaterialRepository
class SupabaseMaterialRepository implements MaterialRepository {
  final SupabaseClient _supabase;
  static const String _tableName = 'materiales';

  SupabaseMaterialRepository(this._supabase);

  @override
  Future<List<Material>> getMaterialsByObra(String obraId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _materialFromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching materials', e);
      rethrow;
    }
  }

  @override
  Stream<List<Material>> watchMaterialsByObra(String obraId) {
    return _supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('obra_id', obraId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => _materialFromJson(json)).toList());
  }

  @override
  Future<Material?> getMaterialById(String materialId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', materialId)
          .maybeSingle();

      if (response == null) return null;
      return _materialFromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching material by ID', e);
      rethrow;
    }
  }

  @override
  Future<Material> createMaterial(Material material) async {
    try {
      final data = {
        'obra_id': material.projectId,
        'name': material.name,
        'description': material.description,
        'unit': material.unit,
        'quantity': material.quantity,
        'unit_price': material.unitPrice,
        'supplier': material.supplier,
        'status': material.status,
        'registered_by': material.registeredBy,
      };

      final response = await _supabase
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      AppLogger.info('Material created: ${response['id']}');
      return _materialFromJson(response);
    } catch (e) {
      AppLogger.error('Error creating material', e);
      rethrow;
    }
  }

  @override
  Future<Material> updateMaterial(Material material) async {
    try {
      final data = {
        'name': material.name,
        'description': material.description,
        'unit': material.unit,
        'quantity': material.quantity,
        'unit_price': material.unitPrice,
        'supplier': material.supplier,
        'status': material.status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from(_tableName)
          .update(data)
          .eq('id', material.id)
          .select()
          .single();

      AppLogger.info('Material updated: ${material.id}');
      return _materialFromJson(response);
    } catch (e) {
      AppLogger.error('Error updating material', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteMaterial(String materialId) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', materialId);
      AppLogger.info('Material deleted: $materialId');
    } catch (e) {
      AppLogger.error('Error deleting material', e);
      rethrow;
    }
  }

  @override
  Future<List<Material>> searchMaterials(String obraId, String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _materialFromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error searching materials', e);
      rethrow;
    }
  }

  @override
  Future<List<Material>> getMaterialsByStatus(
      String obraId, String status) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .eq('status', status)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => _materialFromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching materials by status', e);
      rethrow;
    }
  }

  @override
  Future<List<Material>> getLowStockMaterials(String obraId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .lt('quantity', 10)
          .order('quantity', ascending: true);

      return (response as List)
          .map((json) => _materialFromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching low stock materials', e);
      rethrow;
    }
  }

  /// Convert Supabase JSON to Material entity
  Material _materialFromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'].toString(),
      projectId: json['obra_id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String?,
      unit: json['unit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: json['unit_price'] != null
          ? (json['unit_price'] as num).toDouble()
          : null,
      supplier: json['supplier'] as String?,
      registrationDate: DateTime.parse(json['created_at'] as String),
      registeredBy: json['registered_by'] as String?,
      status: json['status'] as String? ?? 'ordered',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
