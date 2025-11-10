/// Material model (maps to 'material' from backend)
class Material {
  final String id;
  final String projectId; // obra_id from backend
  final String name; // nombre from backend
  final String? category; // categoria from backend
  final String? quantity; // cantidad from backend
  final String? unit; // unidad from backend
  final String? supplier; // proveedor from backend
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
    this.createdAt,
    this.updatedAt,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as String,
      projectId: json['obra_id'] as String,
      name: json['nombre'] as String,
      category: json['categoria'] as String?,
      quantity: json['cantidad'] as String?,
      unit: json['unidad'] as String?,
      supplier: json['proveedor'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'obra_id': projectId, // Keep backend field name
      'nombre': name,
      'categoria': category,
      'cantidad': quantity,
      'unidad': unit,
      'proveedor': supplier,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
