import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/user_roles.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/user.dart';
import '../../services/nestjs_api_client.dart';
import '../../services/supabase_service.dart';
import 'service_providers.dart';

/// State class for authentication
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Notifier for authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final NestJsApiClient _apiClient;
  final SupabaseService _supabaseService;
  final FlutterSecureStorage _secureStorage;

  AuthNotifier({
    required NestJsApiClient apiClient,
    required SupabaseService supabaseService,
    required FlutterSecureStorage secureStorage,
  })  : _apiClient = apiClient,
        _supabaseService = supabaseService,
        _secureStorage = secureStorage,
        super(const AuthState());

  /// Login user - Paso 1: Login inicial sin obra (usa /auth/email/login)
  /// Para el paso 2 con obra seleccionada, usar loginWithObra()
  Future<void> login(String email, String password, {String? obraId}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Determinar qué endpoint usar basado en si hay obraId
      final response = obraId != null && obraId.isNotEmpty
          ? await _apiClient.loginWithObra(
              email: email,
              password: password,
              obraId: obraId,
            )
          : await _apiClient.loginWithEmail(
              email: email,
              password: password,
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        
        // 2. Extract tokens (backend returns 'token', not 'access_token')
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String?;
        
        // 3. Store tokens securely
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: token,
        );
        
        if (refreshToken != null) {
          await _secureStorage.write(
            key: AppConstants.refreshTokenKey,
            value: refreshToken,
          );
        }

        // 4. Extract user data from response
        final userData = data['user'] as Map<String, dynamic>;
        final userEmail = userData['email'] as String;
        final firstName = userData['firstName'] as String? ?? '';
        final lastName = userData['lastName'] as String? ?? '';
        final userName = '$firstName $lastName'.trim();
        
        // 5. Extract role from user data
        final roleData = userData['role'] as Map<String, dynamic>;
        final roleName = roleData['name'] as String;
        final role = UserRole.fromString(roleName);

        // 6. Decode JWT to extract user_uuid and obra_id
        final decodedToken = JwtDecoder.decode(token);
        String? userUuid = decodedToken['user_uuid'] as String?;
        String? jwtObraId = decodedToken['obra_id'] as String?;

        // TEMPORARY FIX: If backend doesn't provide user_uuid, query Supabase
        if (userUuid == null) {
          AppLogger.warning('JWT does not contain user_uuid. Querying Supabase to find user by email...');
          
          try {
            final response = await _supabaseService.client
                .from('usuarios')
                .select('id, obra_id')
                .eq('email', userEmail)
                .single();
            
            userUuid = response['id'] as String;
            jwtObraId = jwtObraId ?? (response['obra_id'] as String?);
            
            AppLogger.info('Found user in Supabase. UUID: $userUuid, ObraId: $jwtObraId');
          } catch (e) {
            AppLogger.error('Failed to find user in Supabase: $e');
            throw Exception('User not found in Supabase. Please ensure the user exists in the usuarios table.');
          }
        }

        AppLogger.info('Login successful. User: $userEmail, Role: $roleName, UUID: $userUuid, ObraId: $jwtObraId');

        // 7. Set auth token for Supabase
        await _supabaseService.setAuthToken(token);

        // 8. Create user entity with UUID from JWT
        final user = User(
          id: userUuid, // Use UUID from JWT (Supabase user_uuid)
          email: userEmail,
          name: userName.isNotEmpty ? userName : userEmail,
          role: role,
          obraId: jwtObraId ?? obraId,
          createdAt: DateTime.now(),
        );

        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
        );
      } else {
        throw Exception('Login failed');
      }
    } catch (e) {
      String errorMessage = 'Authentication failed';
      
      if (e.toString().contains('401') || e.toString().contains('422')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains('Network')) {
        errorMessage = 'No internet connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Connection timeout';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        isAuthenticated: false,
      );
    }
  }

  /// Logout user - Clear tokens and session
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // 1. Call NestJS logout endpoint
      await _apiClient.logout();

      // 2. Clear tokens from secure storage
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);

      // 3. Clear Supabase auth
      await _supabaseService.clearAuthToken();

      // 4. Reset state
      state = const AuthState();
    } catch (e) {
      // Even if API call fails, clear local session
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);
      await _supabaseService.clearAuthToken();
      
      state = const AuthState();
    }
  }

  /// Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    try {
      final token = await _secureStorage.read(key: AppConstants.tokenKey);

      if (token != null && !JwtDecoder.isExpired(token)) {
        // Token exists and is valid
        final decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['sub'] as String;
        final roleString = decodedToken['rol'] as String;
        final userName = decodedToken['name'] as String? ?? '';
        final email = decodedToken['email'] as String? ?? '';

        final role = UserRole.fromString(roleString);

        final user = User(
          id: userId,
          email: email,
          name: userName,
          role: role,
          createdAt: DateTime.now(),
        );

        // Set token for Supabase
        await _supabaseService.setAuthToken(token);

        state = state.copyWith(
          user: user,
          isAuthenticated: true,
        );
      }
    } catch (e) {
      // Token invalid or error, clear it
      await _secureStorage.delete(key: AppConstants.tokenKey);
      state = const AuthState();
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Get available obras for the authenticated user
  /// Should be called after initial login
  Future<List<Map<String, dynamic>>> getAvailableObras() async {
    try {
      final response = await _apiClient.getObras(page: 1, limit: 100);
      
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final obras = data['data'] as List;
        return obras.cast<Map<String, dynamic>>();
      }
      
      return [];
    } catch (e) {
      // Extract error details
      String errorMsg = 'Error desconocido al obtener obras';
      
      if (e.toString().contains('500')) {
        errorMsg = 'Error del servidor (500). Verifique:\n'
                  '1. El usuario tiene obras asignadas en la BD\n'
                  '2. Las políticas RLS de Supabase están configuradas\n'
                  '3. Los logs del backend NestJS para más detalles';
      } else if (e.toString().contains('404')) {
        errorMsg = 'Endpoint de obras no encontrado. Verifique el backend.';
      } else if (e.toString().contains('401')) {
        errorMsg = 'No autorizado. El token JWT puede ser inválido.';
      }
      
      AppLogger.error('Failed to fetch obras: $errorMsg', e);
      throw Exception(errorMsg);
    }
  }

  /// Login with selected obra (Paso 2 del flujo)
  /// Después de que el usuario selecciona una obra, este método
  /// hace re-login con el endpoint /auth/ingenieria/login para
  /// obtener un JWT que incluya obra_id en el payload
  Future<bool> loginWithObra(String email, String password, String obraId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Login con obra para obtener JWT con obra_id
      await login(email, password, obraId: obraId);
      return state.isAuthenticated;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to login with selected project',
      );
      return false;
    }
  }
}

/// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(nestJsApiClientProvider);
  final supabaseService = ref.watch(supabaseServiceProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  return AuthNotifier(
    apiClient: apiClient,
    supabaseService: supabaseService,
    secureStorage: secureStorage,
  );
});
