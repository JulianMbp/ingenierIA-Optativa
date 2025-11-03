import 'package:equatable/equatable.dart';

/// Work log entity for daily progress tracking - matches Supabase table 'bitacoras'
/// Schema: id, obra_id, usuario_id, descripcion, avance_porcentaje, archivos, fecha, created_at
class WorkLog extends Equatable {
  final String id;
  final String? obraId;
  final String usuarioId;
  final String? descripcion;
  final double? avancePorcentaje;
  final List<String> archivos;
  final DateTime fecha;
  final DateTime createdAt;

  const WorkLog({
    required this.id,
    this.obraId,
    required this.usuarioId,
    this.descripcion,
    this.avancePorcentaje,
    this.archivos = const [],
    required this.fecha,
    required this.createdAt,
  });

  /// Check if log has archivos
  bool get hasArchivos => archivos.isNotEmpty;

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDate = DateTime(fecha.year, fecha.month, fecha.day);

    if (logDate == today) {
      return 'Today';
    } else if (logDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  /// Get progress status color
  String get progressStatus {
    if (avancePorcentaje == null) return 'none';
    if (avancePorcentaje! >= 80) return 'excellent';
    if (avancePorcentaje! >= 60) return 'good';
    if (avancePorcentaje! >= 40) return 'moderate';
    return 'low';
  }

  @override
  List<Object?> get props => [
        id,
        obraId,
        usuarioId,
        descripcion,
        avancePorcentaje,
        archivos,
        fecha,
        createdAt,
      ];

  WorkLog copyWith({
    String? id,
    String? obraId,
    String? usuarioId,
    String? descripcion,
    double? avancePorcentaje,
    List<String>? archivos,
    DateTime? fecha,
    DateTime? createdAt,
  }) {
    return WorkLog(
      id: id ?? this.id,
      obraId: obraId ?? this.obraId,
      usuarioId: usuarioId ?? this.usuarioId,
      descripcion: descripcion ?? this.descripcion,
      avancePorcentaje: avancePorcentaje ?? this.avancePorcentaje,
      archivos: archivos ?? this.archivos,
      fecha: fecha ?? this.fecha,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'obra_id': obraId,
      'usuario_id': usuarioId,
      'descripcion': descripcion,
      'avance_porcentaje': avancePorcentaje,
      'archivos': archivos,
      'fecha': fecha.toIso8601String().split('T')[0], // Solo la fecha
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory WorkLog.fromJson(Map<String, dynamic> json) {
    return WorkLog(
      id: json['id'] as String,
      obraId: json['obra_id'] as String?,
      usuarioId: json['usuario_id'] as String,
      descripcion: json['descripcion'] as String?,
      avancePorcentaje: json['avance_porcentaje'] != null
          ? (json['avance_porcentaje'] as num).toDouble()
          : null,
      archivos: (json['archivos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fecha: DateTime.parse(json['fecha'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
