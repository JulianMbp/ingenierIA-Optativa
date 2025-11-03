class Bitacora {
  final String id;
  final String descripcion;
  final DateTime fecha;
  final int avancePorcentaje;
  final String? autorId;
  final String? autorNombre;
  final String obraId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bitacora({
    required this.id,
    required this.descripcion,
    required this.fecha,
    required this.avancePorcentaje,
    this.autorId,
    this.autorNombre,
    required this.obraId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Bitacora.fromJson(Map<String, dynamic> json) {
    return Bitacora(
      id: json['id'] as String,
      descripcion: json['descripcion'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      avancePorcentaje: json['avancePorcentaje'] as int,
      autorId: json['autorId'] as String?,
      autorNombre: json['autorNombre'] as String?,
      obraId: json['obraId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'avancePorcentaje': avancePorcentaje,
      'autorId': autorId,
      'autorNombre': autorNombre,
      'obraId': obraId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
