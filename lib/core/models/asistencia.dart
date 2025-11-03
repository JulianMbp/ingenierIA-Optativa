class Asistencia {
  final String id;
  final String obraId;
  final int usuarioId;
  final DateTime fecha;
  final String estado; // 'presente', 'ausente', 'tardanza'
  final String? observaciones;
  final DateTime? createdAt;
  final Map<String, dynamic>? usuario;

  Asistencia({
    required this.id,
    required this.obraId,
    required this.usuarioId,
    required this.fecha,
    required this.estado,
    this.observaciones,
    this.createdAt,
    this.usuario,
  });

  // Helper para obtener el nombre del usuario
  String? get usuarioNombre {
    if (usuario != null) {
      final firstName = usuario!['firstName'] ?? '';
      final lastName = usuario!['lastName'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return null;
  }

  bool get isPresente => estado == 'presente';
  bool get isAusente => estado == 'ausente';
  bool get isTardanza => estado == 'tardanza';

  factory Asistencia.fromJson(Map<String, dynamic> json) {
    return Asistencia(
      id: json['id'] as String,
      obraId: json['obra_id'] as String,
      usuarioId: json['usuario_id'] is int
          ? json['usuario_id']
          : int.parse(json['usuario_id'].toString()),
      fecha: DateTime.parse(json['fecha'] as String),
      estado: json['estado'] as String,
      observaciones: json['observaciones'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      usuario: json['usuario'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'obra_id': obraId,
      'usuario_id': usuarioId,
      'fecha': fecha.toIso8601String().split('T').first,
      'estado': estado,
      'observaciones': observaciones,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
