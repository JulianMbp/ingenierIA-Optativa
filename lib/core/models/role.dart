enum RoleType {
  adminGeneral,
  adminObra,
  obrero,
  rrhh,
  sst,
}

class Role {
  final String id;
  final String name;
  final RoleType type;
  final List<String> permissions;

  Role({
    required this.id,
    required this.name,
    required this.type,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: _parseRoleType(json['name']),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  static RoleType _parseRoleType(String name) {
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
      'permissions': permissions,
    };
  }
}
