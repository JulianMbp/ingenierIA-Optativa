enum RoleType {
  adminGeneral,
  adminObra,
  obrero,
  rrhh,
  sst,
}

class Role {
  final int id;
  final String name;
  final String? descripcion;
  final RoleType type;
  final String? createdAt;
  final String? updatedAt;

  Role({
    required this.id,
    required this.name,
    this.descripcion,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    // Helper para parsear int de forma segura
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return Role(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      type: _parseRoleType(json['name']?.toString()),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  static RoleType _parseRoleType(String? name) {
    if (name == null) return RoleType.obrero;
    
    switch (name.toLowerCase()) {
      case 'admin general':
      case 'admin_general':
        return RoleType.adminGeneral;
      case 'admin obra':
      case 'admin_obra':
        return RoleType.adminObra;
      case 'obrero':
        return RoleType.obrero;
      case 'rrhh':
        return RoleType.rrhh;
      case 'sst':
        return RoleType.sst;
      default:
        return RoleType.obrero;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'descripcion': descripcion,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
