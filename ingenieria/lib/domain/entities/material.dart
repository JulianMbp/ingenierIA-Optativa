import 'package:equatable/equatable.dart';

/// Entity representing a construction material.
class Material extends Equatable {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final String unit; // 'kg', 'm3', 'units', etc.
  final double quantity;
  final double? unitPrice;
  final String? supplier;
  final DateTime registrationDate;
  final String? registeredBy;
  final String status; // 'ordered', 'received', 'in_use', 'depleted'
  final DateTime? updatedAt;

  const Material({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.unit,
    required this.quantity,
    this.unitPrice,
    this.supplier,
    required this.registrationDate,
    this.registeredBy,
    required this.status,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        projectId,
        name,
        description,
        unit,
        quantity,
        unitPrice,
        supplier,
        registrationDate,
        registeredBy,
        status,
        updatedAt,
      ];

  /// Calculate total cost
  double? get totalCost {
    if (unitPrice == null) return null;
    return quantity * unitPrice!;
  }

  /// Check if material is low stock (less than 10 units)
  bool get isLowStock => quantity < 10;

  /// Check if material is available
  bool get isAvailable => status == 'received' || status == 'in_use';

  /// Create a copy with updated fields
  Material copyWith({
    String? id,
    String? projectId,
    String? name,
    String? description,
    String? unit,
    double? quantity,
    double? unitPrice,
    String? supplier,
    DateTime? registrationDate,
    String? registeredBy,
    String? status,
    DateTime? updatedAt,
  }) {
    return Material(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      supplier: supplier ?? this.supplier,
      registrationDate: registrationDate ?? this.registrationDate,
      registeredBy: registeredBy ?? this.registeredBy,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
