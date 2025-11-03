class Obra {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final DateTime createdAt;
  final DateTime updatedAt;

  Obra({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.fechaInicio,
    this.fechaFin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Obra.fromJson(Map<String, dynamic> json) {
    return Obra(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      direccion: json['direccion'] as String?,
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'] as String)
          : null,
      fechaFin: json['fechaFin'] != null
          ? DateTime.parse(json['fechaFin'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
