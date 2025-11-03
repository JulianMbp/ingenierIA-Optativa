import 'package:flutter/material.dart';

import '../../core/constants/user_roles.dart';

/// Extension to get accent colors based on user role
extension RoleColors on UserRole {
  /// Primary accent color for the role
  Color get accentColor {
    switch (this) {
      case UserRole.adminGeneral:
        return const Color(0xFF3B82F6); // Blue
      case UserRole.adminObra:
        return const Color(0xFF14B8A6); // Teal
      case UserRole.encargadoArea:
        return const Color(0xFFF97316); // Orange
      case UserRole.obrero:
        return const Color(0xFF10B981); // Green
      case UserRole.sst:
        return const Color(0xFFEF4444); // Red
      case UserRole.rrhh:
        return const Color(0xFFA855F7); // Purple
      case UserRole.compras:
        return const Color(0xFFF59E0B); // Yellow
      case UserRole.consultor:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  /// Light variant of accent color
  Color get accentColorLight {
    return accentColor.withOpacity(0.1);
  }

  /// Gradient colors for glass cards
  List<Color> get gradientColors {
    return [
      accentColor.withOpacity(0.15),
      accentColor.withOpacity(0.05),
    ];
  }

  /// Icon for role
  IconData get icon {
    switch (this) {
      case UserRole.adminGeneral:
        return Icons.admin_panel_settings;
      case UserRole.adminObra:
        return Icons.engineering;
      case UserRole.encargadoArea:
        return Icons.supervisor_account;
      case UserRole.obrero:
        return Icons.construction;
      case UserRole.sst:
        return Icons.health_and_safety;
      case UserRole.rrhh:
        return Icons.people;
      case UserRole.compras:
        return Icons.shopping_cart;
      case UserRole.consultor:
        return Icons.analytics;
    }
  }
}

/// Role-based theme configuration
class RoleTheme {
  /// Get theme data based on user role
  static ThemeData getThemeForRole(UserRole role, {bool isDark = false}) {
    final accentColor = role.accentColor;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
