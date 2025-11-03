class Asistencia {
  final String id;
  final DateTime fecha;
  final String estado; // 'presente', 'ausente', 'tardanza'
  final String? observaciones;
  final String usuarioId;
  final String? usuarioNombre;
  final String obraId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Asistencia({
    required this.id,
    required this.fecha,
    required this.estado,
    this.observaciones,
    required this.usuarioId,
    this.usuarioNombre,
    required this.obraId,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPresente => estado == 'presente';
  bool get isAusente => estado == 'ausente';
  bool get isTardanza => estado == 'tardanza';

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      estado: json['estado'] as String,
      observaciones: json['observaciones'] as String?,
      usuarioId: json['usuarioId'] as String,
      usuarioNombre: json['usuarioNombre'] as String?,
      obraId: json['obraId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'estado': estado,
      'observaciones': observaciones,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'obraId': obraId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
