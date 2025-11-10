/// Work log model (maps to 'bitacora' from backend)
class WorkLog {
  final String id;
  final String projectId; // obra_id from backend
  final int userId; // usuario_id from backend
  final String description; // descripcion from backend
  final DateTime date; // fecha from backend
  final String progressPercentage; // avance_porcentaje from backend
  final List<dynamic> files; // archivos from backend
  final DateTime? createdAt;
  final Map<String, dynamic>? user;

  WorkLog({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.description,
    required this.date,
    required this.progressPercentage,
    required this.files,
    this.createdAt,
    this.user,
  });

  /// Helper to get author name
  String? get authorName {
    if (user != null) {
      final firstName = user!['firstName'] ?? '';
      final lastName = user!['lastName'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return null;
  }

  /// Helper to get author ID as String
  String get authorId => userId.toString();

  /// Helper to get progress as integer
  int get progressPercentageInt {
    try {
      return int.parse(progressPercentage.split('.').first);
    } catch (e) {
      return 0;
    }
  }

  factory WorkLog.fromJson(Map<String, dynamic> json) {
    return WorkLog(
      id: json['id'] as String,
      projectId: json['obra_id'] as String,
      userId: json['usuario_id'] is int 
          ? json['usuario_id'] 
          : int.parse(json['usuario_id'].toString()),
      description: json['descripcion'] as String,
      date: DateTime.parse(json['fecha'] as String),
      progressPercentage: json['avance_porcentaje'].toString(),
      files: json['archivos'] as List? ?? [],
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
      'descripcion': description,
      'fecha': date.toIso8601String().split('T').first,
      'avance_porcentaje': progressPercentage,
      'archivos': files,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

