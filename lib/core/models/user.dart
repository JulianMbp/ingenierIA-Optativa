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
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: Role.fromJson(json['role'] ?? {}),
      provider: json['provider'],
      socialId: json['socialId'],
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
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
