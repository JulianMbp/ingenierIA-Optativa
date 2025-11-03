import 'role.dart';

class User {
  final String id;
  final String email;
  final String name;
  final Role role;
  final String? profileImage;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? json['nombre'] ?? '',
      role: Role.fromJson(json['role'] ?? {}),
      profileImage: json['profileImage'] ?? json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toJson(),
      'profileImage': profileImage,
    };
  }

  // Helper method to check permissions
  bool hasPermission(String permission) {
    return role.permissions.contains(permission);
  }

  // Helper method to check role type
  bool hasRole(RoleType roleType) {
    return role.type == roleType;
  }
}
