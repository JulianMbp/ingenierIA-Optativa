import '../utils/logger.dart';

/// Enum representing all possible user roles in the system.
enum UserRole {
  adminGeneral('admin_general', 'General Admin'),
  adminObra('admin_obra', 'Project Admin'),
  encargadoArea('encargado_area', 'Area Manager'),
  obrero('obrero', 'Worker'),
  sst('sst', 'Safety Officer'),
  compras('compras', 'Purchasing'),
  rrhh('rrhh', 'Human Resources'),
  consultor('consultor', 'Consultant');

  const UserRole(this.value, this.displayName);

  final String value;
  final String displayName;

  /// Parse a string value to UserRole enum
  /// Accepts both internal value (admin_general) and backend name (Admin General)
  static UserRole fromString(String value) {
    // Normalize the input to lowercase and replace spaces with underscores
    // Also remove accents and special characters
    final normalizedValue = value
        .toLowerCase()
        .replaceAll(' de ', '_')  // "Encargado de Área" → "Encargado_Área"
        .replaceAll(' ', '_')     // "Admin General" → "Admin_General"
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
    
    return UserRole.values.firstWhere(
      (role) => role.value == normalizedValue || 
                role.value == value.toLowerCase() ||
                role.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () {
        // Log available roles for debugging
        AppLogger.error('Invalid role: $value. Available roles: ${UserRole.values.map((r) => r.value).join(", ")}');
        throw ArgumentError('Invalid role: $value');
      },
    );
  }

  /// Check if role has admin privileges
  bool get isAdmin => this == UserRole.adminGeneral || this == UserRole.adminObra;

  /// Check if role can manage materials
  bool get canManageMaterials => 
      isAdmin || this == UserRole.encargadoArea || this == UserRole.compras;

  /// Check if role can view attendance
  bool get canViewAttendance => 
      isAdmin || this == UserRole.rrhh || this == UserRole.encargadoArea;

  /// Check if role can manage safety incidents
  bool get canManageSafety => isAdmin || this == UserRole.sst;

  /// Check if role can submit work logs
  bool get canSubmitWorkLogs => 
      this == UserRole.obrero || this == UserRole.encargadoArea;
}
