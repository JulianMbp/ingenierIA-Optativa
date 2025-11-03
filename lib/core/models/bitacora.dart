class Bitacora {
  final String id;
  final String obraId;
  final int usuarioId;
  final String descripcion;
  final DateTime fecha;
  final String avancePorcentaje;
  final List<dynamic> archivos;
  final DateTime? createdAt;
  final Map<String, dynamic>? usuario;

  Bitacora({
    required this.id,
    required this.obraId,
    required this.usuarioId,
    required this.descripcion,
    required this.fecha,
    required this.avancePorcentaje,
    required this.archivos,
    this.createdAt,
    this.usuario,
  });

  // Helper para obtener el nombre del autor
  String? get autorNombre {
    if (usuario != null) {
      final firstName = usuario!['firstName'] ?? '';
      final lastName = usuario!['lastName'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return null;
  }

  // Helper para obtener el ID del autor como String
  String get autorId => usuarioId.toString();

  // Helper para obtener avance como número
  int get avancePorcentajeInt {
    try {
      return int.parse(avancePorcentaje.split('.').first);
    } catch (e) {
      return 0;
    }
  }

  factory Bitacora.fromJson(Map<String, dynamic> json) {
    return Bitacora(
      id: json['id'] as String,
      obraId: json['obra_id'] as String,
      usuarioId: json['usuario_id'] is int 
          ? json['usuario_id'] 
          : int.parse(json['usuario_id'].toString()),
      descripcion: json['descripcion'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      avancePorcentaje: json['avance_porcentaje'].toString(),
      archivos: json['archivos'] as List? ?? [],
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
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String().split('T').first,
      'avance_porcentaje': avancePorcentaje,
      'archivos': archivos,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
