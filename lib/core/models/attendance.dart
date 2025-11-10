/// Attendance model (maps to 'asistencia' from backend)
class Attendance {
  final String id;
  final String projectId; // obra_id from backend
  final int userId; // usuario_id from backend
  final DateTime date; // fecha from backend
  final String status; // estado: 'presente', 'ausente', 'tardanza'
  final String? observations; // observaciones from backend
  final DateTime? createdAt;
  final Map<String, dynamic>? user;

  Attendance({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.date,
    required this.status,
    this.observations,
    this.createdAt,
    this.user,
  });

  /// Helper to get user name
  String? get userName {
    if (user != null) {
      final firstName = user!['firstName'] ?? '';
      final lastName = user!['lastName'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return null;
  }

  bool get isPresent => status == 'presente';
  bool get isAbsent => status == 'ausente';
  bool get isLate => status == 'tardanza';

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      projectId: json['obra_id'] as String,
      userId: json['usuario_id'] is int
          ? json['usuario_id']
          : int.parse(json['usuario_id'].toString()),
      date: DateTime.parse(json['fecha'] as String),
      status: json['estado'] as String,
      observations: json['observaciones'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      user: json['usuario'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'obra_id': projectId, // Keep backend field name
      'usuario_id': userId,
      'fecha': date.toIso8601String().split('T').first,
      'estado': status,
      'observaciones': observations,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

