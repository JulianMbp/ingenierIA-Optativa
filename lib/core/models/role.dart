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
    return Role(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      descripcion: json['descripcion'],
      type: _parseRoleType(json['name']),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
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
