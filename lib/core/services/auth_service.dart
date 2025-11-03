import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../config/api_config.dart';
import '../models/jwt_payload.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.read(apiServiceProvider),
    ref.read(storageServiceProvider),
  );
});

class AuthService {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthService(this._apiService, this._storageService);

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

      final data = response.data['data'];
      final token = data['access_token'];
      final user = User.fromJson(data['user']);

      // Save token and user data
      await _storageService.saveToken(token);
      await _storageService.saveUserData(jsonEncode(user.toJson()));

      return {
        'token': token,
        'user': user,
      };
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Get current user from storage
  Future<User?> getCurrentUser() async {
    try {
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
