class Obra {
  final String id;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final String? estado;
  final String? roleName;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Obra({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.direccion,
    this.estado,
    this.roleName,
    this.fechaInicio,
    this.fechaFin,
    this.createdAt,
    this.updatedAt,
  });

  factory Obra.fromJson(Map<String, dynamic> json) {
    return Obra(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      direccion: json['direccion'] as String?,
      estado: json['estado'] as String?,
      roleName: json['roleName'] as String?,
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'direccion': direccion,
      'estado': estado,
      'roleName': roleName,
      'fecha_inicio': fechaInicio?.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Helper para saber si la obra está activa
  bool get isActiva => estado?.toLowerCase() == 'activa';
}
