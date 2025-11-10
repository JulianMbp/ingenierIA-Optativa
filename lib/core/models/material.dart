import 'package:flutter/material.dart';

/// Material model (maps to 'material' from backend)
class Material {
  final String id;
  final String projectId; // obra_id from backend
  final String name; // nombre from backend
  final String? category; // categoria from backend
  final String? quantity; // cantidad from backend (legacy field)
  final String? unit; // unidad from backend
  final String? supplier; // proveedor from backend
  final double? availableQuantity; // cantidad_disponible from backend
  final double? requiredQuantity; // cantidad_requerida from backend
  final double missingQuantity; // cantidad_faltante from backend (calculated)
  final String? status; // estado from backend: 'pendiente' | 'comprado' | 'en_transito' | 'disponible'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Material({
    required this.id,
    required this.projectId,
    required this.name,
    this.category,
    this.quantity,
    this.unit,
    this.supplier,
    this.availableQuantity,
    this.requiredQuantity,
    this.missingQuantity = 0.0,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    // Helper to parse number (int or double)
    double? _parseNumber(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    // Parse cantidad_faltante (always present in response, calculated by backend)
    double _parseMissingQuantity() {
      final missing = json['cantidad_faltante'];
      if (missing == null) return 0.0;
      if (missing is double) return missing;
      if (missing is int) return missing.toDouble();
      if (missing is String) {
        return double.tryParse(missing) ?? 0.0;
      }
      return 0.0;
    }

    return Material(
      id: json['id'] as String,
      projectId: json['obra_id'] as String,
      name: json['nombre'] as String,
      category: json['categoria'] as String?,
      quantity: json['cantidad']?.toString(),
      unit: json['unidad'] as String?,
      supplier: json['proveedor'] as String?,
      availableQuantity: _parseNumber(json['cantidad_disponible']),
      requiredQuantity: _parseNumber(json['cantidad_requerida'] ?? json['cantidad']),
      missingQuantity: _parseMissingQuantity(),
      status: json['estado'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'obra_id': projectId, // Keep backend field name
      'nombre': name,
    };

    // Optional fields
    if (category != null) json['categoria'] = category;
    if (quantity != null) json['cantidad'] = quantity;
    if (unit != null) json['unidad'] = unit;
    if (supplier != null) json['proveedor'] = supplier;
    
    // New optional fields
    if (availableQuantity != null) json['cantidad_disponible'] = availableQuantity;
    if (requiredQuantity != null) json['cantidad_requerida'] = requiredQuantity;
    if (status != null) json['estado'] = status;
    
    if (createdAt != null) json['created_at'] = createdAt!.toIso8601String();
    if (updatedAt != null) json['updated_at'] = updatedAt!.toIso8601String();

    return json;
  }

  /// Calculate material availability percentage
  /// Returns 0-100 based on availableQuantity / requiredQuantity
  double get availabilityPercentage {
    if (requiredQuantity == null || requiredQuantity == 0) {
      // If no required quantity, check if we have available quantity
      if (availableQuantity != null && availableQuantity! > 0) return 100.0;
      return 0.0;
    }
    if (availableQuantity == null) return 0.0;
    
    final percentage = (availableQuantity! / requiredQuantity!) * 100;
    return percentage.clamp(0.0, 100.0);
  }

  /// Get status display name
  String get statusDisplay {
    switch (status) {
      case 'pendiente':
        return 'Pending';
      case 'comprado':
        return 'Purchased';
      case 'en_transito':
        return 'In Transit';
      case 'disponible':
        return 'Available';
      default:
        return status ?? 'N/A';
    }
  }

  /// Get status color for UI
  Color get statusColor {
    switch (status) {
      case 'pendiente':
        return Colors.orange;
      case 'comprado':
        return Colors.blue;
      case 'en_transito':
        return Colors.purple;
      case 'disponible':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
