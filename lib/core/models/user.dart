import 'role.dart';

class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final Role role;
  final String? provider;
  final String? socialId;
  final Map<String, dynamic>? status;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.provider,
    this.socialId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  // Helper getter para nombre completo
  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper para parsear int de forma segura
    int _parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    return User(
      id: _parseInt(json['id']),
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? json['first_name']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? json['last_name']?.toString() ?? '',
      role: json['role'] != null && json['role'] is Map<String, dynamic>
          ? Role.fromJson(json['role'] as Map<String, dynamic>)
          : Role(id: 0, name: 'obrero', type: RoleType.obrero),
      provider: json['provider']?.toString(),
      socialId: json['socialId']?.toString() ?? json['social_id']?.toString(),
      status: json['status'] is Map<String, dynamic> ? json['status'] as Map<String, dynamic> : null,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
      deletedAt: json['deletedAt']?.toString() ?? json['deleted_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toJson(),
      'provider': provider,
      'socialId': socialId,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'deletedAt': deletedAt,
    };
  }

  // Helper method to check role type
  bool hasRole(RoleType roleType) {
    return role.type == roleType;
  }

  // Helper method to check if user is admin
  bool get isAdmin {
    return role.type == RoleType.adminGeneral || role.type == RoleType.adminObra;
  }

  // Helper method to check if user is admin general
  bool get isAdminGeneral {
    return role.type == RoleType.adminGeneral;
  }

  // Helper method to check if user is admin obra
  bool get isAdminObra {
    return role.type == RoleType.adminObra;
  }
}
