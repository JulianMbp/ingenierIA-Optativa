import 'user.dart';

class Tarea {
  final String id;
  final String obraId;
  final String titulo;
  final String? descripcion;
  final String estado; 
  final String prioridad;
  final int? asignadoAId;
  final int creadoPorId;
  final DateTime? fechaInicio;
  final DateTime? fechaVencimiento;
  final int progresosPorcentaje;
  final String? notas;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? asignadoA;
  final User? creadoPor;

  Tarea({
    required this.id,
    required this.obraId,
    required this.titulo,
    this.descripcion,
    required this.estado,
    required this.prioridad,
    this.asignadoAId,
    required this.creadoPorId,
    this.fechaInicio,
    this.fechaVencimiento,
    required this.progresosPorcentaje,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
    this.asignadoA,
    this.creadoPor,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    // Helper para parsear int de forma segura
    int? _parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    // Helper para parsear fecha de forma segura
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

    // Parsear progreso de forma segura
    int _parseProgreso() {
      final progreso = json['progreso_porcentaje'] ?? json['avance_porcentaje'];
      if (progreso == null) return 0;
      if (progreso is int) return progreso;
      if (progreso is String) {
        // El backend puede enviar "45.00" o "100.00", necesitamos parsear como double primero
        final doubleValue = double.tryParse(progreso);
        if (doubleValue != null) return doubleValue.round();
        return 0;
      }
      if (progreso is double) return progreso.round();
      return 0;
    }

    return Tarea(
      id: json['id']?.toString() ?? '',
      obraId: json['obra_id']?.toString() ?? json['obraId']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      estado: json['estado']?.toString() ?? 'pendiente',
      prioridad: json['prioridad']?.toString() ?? 'media',
      asignadoAId: _parseInt(json['asignado_a_id']),
      creadoPorId: _parseInt(json['creado_por_id']) ?? 
                   _parseInt(json['creadoPorId']) ?? 
                   _parseInt(json['usuario_id']) ?? 
                   0,
      fechaInicio: _parseDate(json['fecha_inicio']),
      fechaVencimiento: _parseDate(json['fecha_vencimiento']) ?? _parseDate(json['fecha_limite']),
      progresosPorcentaje: _parseProgreso(),
      notas: json['notas']?.toString(),
      createdAt: _parseDate(json['created_at']) ?? _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at']) ?? _parseDate(json['updatedAt']) ?? DateTime.now(),
      asignadoA: (json['asignadoA'] != null && json['asignadoA'] is Map<String, dynamic>)
          ? User.fromJson(json['asignadoA'] as Map<String, dynamic>)
          : (json['asignado_a'] != null && json['asignado_a'] is Map<String, dynamic>)
              ? User.fromJson(json['asignado_a'] as Map<String, dynamic>)
              : null,
      creadoPor: (json['usuario'] != null && json['usuario'] is Map<String, dynamic>)
          ? User.fromJson(json['usuario'] as Map<String, dynamic>)
          : (json['creado_por'] != null && json['creado_por'] is Map<String, dynamic>)
              ? User.fromJson(json['creado_por'] as Map<String, dynamic>)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'obra_id': obraId,
      'titulo': titulo,
      'descripcion': descripcion,
      'estado': estado,
      'prioridad': prioridad,
      'asignado_a_id': asignadoAId,
      'creado_por_id': creadoPorId,
      'fecha_inicio': fechaInicio?.toIso8601String().split('T')[0],
      'fecha_vencimiento': fechaVencimiento?.toIso8601String().split('T')[0],
      'progreso_porcentaje': progresosPorcentaje,
      'notas': notas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Tarea copyWith({
    String? id,
    String? obraId,
    String? titulo,
    String? descripcion,
    String? estado,
    String? prioridad,
    int? asignadoAId,
    int? creadoPorId,
    DateTime? fechaInicio,
    DateTime? fechaVencimiento,
    int? progresosPorcentaje,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? asignadoA,
    User? creadoPor,
  }) {
    return Tarea(
      id: id ?? this.id,
      obraId: obraId ?? this.obraId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      estado: estado ?? this.estado,
      prioridad: prioridad ?? this.prioridad,
      asignadoAId: asignadoAId ?? this.asignadoAId,
      creadoPorId: creadoPorId ?? this.creadoPorId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      progresosPorcentaje: progresosPorcentaje ?? this.progresosPorcentaje,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      asignadoA: asignadoA ?? this.asignadoA,
      creadoPor: creadoPor ?? this.creadoPor,
    );
  }

  bool get isCompletada => estado == 'completada';
  bool get isPendiente => estado == 'pendiente';
  bool get isEnProgreso => estado == 'en_progreso';

  String get estadoDisplay {
    switch (estado) {
      case 'completada':
        return 'Completada';
      case 'en_progreso':
        return 'En Progreso';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }

  String get prioridadDisplay {
    switch (prioridad) {
      case 'alta':
        return 'Alta';
      case 'media':
        return 'Media';
      case 'baja':
        return 'Baja';
      default:
        return prioridad;
    }
  }
}
