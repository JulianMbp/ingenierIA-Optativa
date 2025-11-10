import 'user.dart';

/// Task model (maps to 'tarea' from backend)
class Task {
  final String id;
  final String projectId; // obra_id from backend
  final String title; // titulo from backend
  final String? description; // descripcion from backend
  final String status; // estado from backend
  final String priority; // prioridad from backend
  final int? assignedToId; // asignado_a_id from backend
  final int createdById; // creado_por_id from backend
  final DateTime? startDate; // fecha_inicio from backend
  final DateTime? dueDate; // fecha_vencimiento from backend
  final int progressPercentage; // progreso_porcentaje from backend
  final String? notes; // notas from backend
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? assignedTo;
  final User? createdBy;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.assignedToId,
    required this.createdById,
    this.startDate,
    this.dueDate,
    required this.progressPercentage,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.assignedTo,
    this.createdBy,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse int
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper to safely parse date
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    // Parse progress safely
    int _parseProgress() {
      final progress = json['progreso_porcentaje'] ?? json['avance_porcentaje'];
      if (progress == null) return 0;
      if (progress is int) return progress;
      if (progress is String) {
        // Backend may send "45.00" or "100.00", parse as double first
        final doubleValue = double.tryParse(progress);
        if (doubleValue != null) return doubleValue.round();
        return 0;
      }
      if (progress is double) return progress.round();
      return 0;
    }

    return Task(
      id: json['id']?.toString() ?? '',
      projectId: json['obra_id']?.toString() ?? json['obraId']?.toString() ?? '',
      title: json['titulo']?.toString() ?? '',
      description: json['descripcion']?.toString(),
      status: json['estado']?.toString() ?? 'pendiente',
      priority: json['prioridad']?.toString() ?? 'media',
      assignedToId: _parseInt(json['asignado_a_id']),
      createdById: _parseInt(json['creado_por_id']) ?? 
                   _parseInt(json['creadoPorId']) ?? 
                   _parseInt(json['usuario_id']) ?? 
                   0,
      startDate: _parseDate(json['fecha_inicio']),
      dueDate: _parseDate(json['fecha_vencimiento']) ?? _parseDate(json['fecha_limite']),
      progressPercentage: _parseProgress(),
      notes: json['notas']?.toString(),
      createdAt: _parseDate(json['created_at']) ?? _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? _parseDate(json['updatedAt']) ?? DateTime.now(),
      assignedTo: (json['asignadoA'] != null && json['asignadoA'] is Map<String, dynamic>)
          ? User.fromJson(json['asignadoA'] as Map<String, dynamic>)
          : (json['asignado_a'] != null && json['asignado_a'] is Map<String, dynamic>)
              ? User.fromJson(json['asignado_a'] as Map<String, dynamic>)
              : null,
      createdBy: (json['usuario'] != null && json['usuario'] is Map<String, dynamic>)
          ? User.fromJson(json['usuario'] as Map<String, dynamic>)
          : (json['creado_por'] != null && json['creado_por'] is Map<String, dynamic>)
              ? User.fromJson(json['creado_por'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'obra_id': projectId, // Keep backend field name
      'titulo': title,
      'descripcion': description,
      'estado': status,
      'prioridad': priority,
      'asignado_a_id': assignedToId,
      'creado_por_id': createdById,
      'fecha_inicio': startDate?.toIso8601String().split('T')[0],
      'fecha_vencimiento': dueDate?.toIso8601String().split('T')[0],
      'progreso_porcentaje': progressPercentage,
      'notas': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? status,
    String? priority,
    int? assignedToId,
    int? createdById,
    DateTime? startDate,
    DateTime? dueDate,
    int? progressPercentage,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? assignedTo,
    User? createdBy,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedToId: assignedToId ?? this.assignedToId,
      createdById: createdById ?? this.createdById,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  bool get isCompleted => status == 'completada';
  bool get isPending => status == 'pendiente';
  bool get isInProgress => status == 'en_progreso';

  String get statusDisplay {
    switch (status) {
      case 'completada':
        return 'Completada';
      case 'en_progreso':
        return 'En Progreso';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }

  String get priorityDisplay {
    switch (priority) {
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return priority;
    }
  }
}

