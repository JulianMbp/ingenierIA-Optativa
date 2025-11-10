import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../config/api_config.dart';
import '../models/jwt_payload.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'api_service.dart';
import 'storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.read(apiServiceProvider),
    ref.read(storageServiceProvider),
    ref.read(authRepositoryProvider),
  );
});

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;
  final AuthRepository _authRepository;

  AuthService(this._apiService, this._storageService, this._authRepository);

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Login response: ${response.data}');

      // La respuesta viene directamente sin envolver en 'data'
      final token = response.data['token'];
      final refreshToken = response.data['refreshToken'];
      final tokenExpires = response.data['tokenExpires'];
      final user = User.fromJson(response.data['user']);

      // Save tokens and user data en almacenamiento seguro
      await _storageService.saveToken(token);
      await _storageService.saveUserData(jsonEncode(user.toJson()));

      return {
        'token': token,
        'refreshToken': refreshToken,
        'tokenExpires': tokenExpires,
        'user': user,
      };
    } catch (e) {
      print('Login error: $e');
      
      // Provide more user-friendly error messages
      String errorMessage = 'Error al iniciar sesión';
      
      if (e.toString().contains('CORS') || 
          e.toString().contains('XMLHttpRequest') ||
          e.toString().contains('connection error')) {
        errorMessage = 'Error de conexión: El servidor no permite peticiones desde este origen. Por favor, verifica la configuración CORS del backend.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Tiempo de espera agotado. Por favor, verifica tu conexión a internet.';
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        errorMessage = 'Credenciales incorrectas. Por favor, verifica tu email y contraseña.';
      } else if (e.toString().contains('404') || e.toString().contains('Not Found')) {
        errorMessage = 'Endpoint no encontrado. Por favor, verifica la configuración del servidor.';
      } else if (e.toString().contains('500') || e.toString().contains('Internal Server Error')) {
        errorMessage = 'Error del servidor. Por favor, intenta más tarde.';
      }
      
      throw Exception(errorMessage);
    }
  }

  // Get current user from storage
  Future<User?> getCurrentUser() async {
    try {
      // Intentar desde secure storage
      final userData = await _storageService.getUserData();
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get profile from API
  Future<User> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.profileEndpoint);
      final user = User.fromJson(response.data['data']);
      
      // Update stored user data
      await _storageService.saveUserData(jsonEncode(user.toJson()));
      
      return user;
    } catch (e) {
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  // Check if token is valid
  Future<bool> isTokenValid() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return false;

      // Check if token is expired
      final isExpired = JwtDecoder.isExpired(token);
      if (isExpired) {
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Get JWT payload
  Future<JwtPayload?> getTokenPayload() async {
    try {
      final token = await _storageService.getToken();
      if (token == null) return null;

      final decoded = JwtDecoder.decode(token);
      return JwtPayload.fromJson(decoded);
    } catch (e) {
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearAll();
    await _authRepository.clearUser();
  }

  // Refresh user data
  Future<User?> refreshUserData() async {
    try {
      return await getProfile();
    } catch (e) {
      return await getCurrentUser();
    }
  }
}
