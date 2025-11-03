class Material {
  final String id;
  final String obraId;
  final String nombre;
  final String? categoria;
  final String? cantidad;
  final String? unidad;
  final String? proveedor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Material({
    required this.id,
    required this.obraId,
    required this.nombre,
    this.categoria,
    this.cantidad,
    this.unidad,
    this.proveedor,
    this.createdAt,
    this.updatedAt,
  });

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as String,
      obraId: json['obra_id'] as String,
      nombre: json['nombre'] as String,
      categoria: json['categoria'] as String?,
      cantidad: json['cantidad'] as String?,
      unidad: json['unidad'] as String?,
      proveedor: json['proveedor'] as String?,
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
      'obra_id': obraId,
      'nombre': nombre,
      'categoria': categoria,
      'cantidad': cantidad,
      'unidad': unidad,
      'proveedor': proveedor,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
