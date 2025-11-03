class Material {
  final String id;
  final String nombre;
  final String? descripcion;
  final int cantidad;
  final int cantidadDisponible;
  final double precioUnitario;
  final String unidadMedida;
  final String obraId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Material({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.cantidad,
    required this.cantidadDisponible,
    required this.precioUnitario,
    required this.unidadMedida,
    required this.obraId,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calcula el valor total del material
  double get valorTotal => cantidad * precioUnitario;

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      cantidad: json['cantidad'] as int,
      cantidadDisponible: json['cantidadDisponible'] as int,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      unidadMedida: json['unidadMedida'] as String,
      obraId: json['obraId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'cantidadDisponible': cantidadDisponible,
      'precioUnitario': precioUnitario,
      'unidadMedida': unidadMedida,
      'obraId': obraId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
