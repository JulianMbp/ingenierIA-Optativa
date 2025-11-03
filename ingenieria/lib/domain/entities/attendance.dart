import 'package:equatable/equatable.dart';

/// Attendance status enum - matches Supabase check constraint
enum AttendanceStatus {
  presente,
  ausente,
  justificado;

  /// Get display name
  String get displayName {
    switch (this) {
      case AttendanceStatus.presente:
        return 'Present';
      case AttendanceStatus.ausente:
        return 'Absent';
      case AttendanceStatus.justificado:
        return 'Justified';
    }
  }

  /// Parse from string
  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => AttendanceStatus.ausente,
    );
  }
}

/// Entity representing worker attendance record - matches Supabase table 'asistencias'
/// Schema: id, obra_id, usuario_id, fecha, estado, observaciones, created_at
class Attendance extends Equatable {
  final String id;
  final String? obraId;
  final String usuarioId;
  final DateTime fecha;
  final AttendanceStatus estado;
  final String? observaciones;
  final DateTime createdAt;

  const Attendance({
    required this.id,
    this.obraId,
    required this.usuarioId,
    required this.fecha,
    required this.estado,
    this.observaciones,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        obraId,
        usuarioId,
        fecha,
        estado,
        observaciones,
        createdAt,
      ];

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final attendanceDate = DateTime(fecha.year, fecha.month, fecha.day);

    if (attendanceDate == today) {
      return 'Today';
    } else if (attendanceDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  /// Check if has observaciones
  bool get hasObservaciones =>
      observaciones != null && observaciones!.isNotEmpty;

  Attendance copyWith({
    String? id,
    String? obraId,
    String? usuarioId,
    DateTime? fecha,
    AttendanceStatus? estado,
    String? observaciones,
    DateTime? createdAt,
  }) {
    return Attendance(
      id: id ?? this.id,
      obraId: obraId ?? this.obraId,
      usuarioId: usuarioId ?? this.usuarioId,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'obra_id': obraId,
      'usuario_id': usuarioId,
      'fecha': fecha.toIso8601String().split('T')[0], // Solo la fecha
      'estado': estado.name,
      'observaciones': observaciones,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      obraId: json['obra_id'] as String?,
      usuarioId: json['usuario_id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      estado: AttendanceStatus.fromString(json['estado'] as String),
      observaciones: json['observaciones'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

