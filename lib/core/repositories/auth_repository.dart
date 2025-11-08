import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Repositorio para manejar autenticación
/// Ahora solo usa SecureStorage (a través de StorageService)
class AuthRepository {
  AuthRepository();

  /// Limpiar usuario autenticado
  /// Nota: El usuario y token se guardan en SecureStorage
  /// y se limpian a través de StorageService.clearAll()
  Future<void> clearUser() async {
    // No hay nada que hacer aquí, SecureStorage se limpia desde StorageService
  }
}

