/// Project model (maps to 'obra' from backend)
class Project {
  final String id;
  final String name; // nombre from backend
  final String? description; // descripcion from backend
  final String? address; // direccion from backend
  final String? status; // estado from backend
  final String? roleName;
  final DateTime? startDate; // fecha_inicio from backend
  final DateTime? endDate; // fecha_fin from backend
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.status,
    this.roleName,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['nombre'] as String,
      description: json['descripcion'] as String?,
      address: json['direccion'] as String?,
      status: json['estado'] as String?,
      roleName: json['roleName'] as String?,
      startDate: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'] as String)
          : null,
      endDate: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': name, // Keep backend field name
      'descripcion': description,
      'direccion': address,
      'estado': status,
      'roleName': roleName,
      'fecha_inicio': startDate?.toIso8601String(),
      'fecha_fin': endDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Helper to check if project is active
  bool get isActive => status?.toLowerCase() == 'activa';
}

