import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/obra.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/obra_service.dart';
import '../../core/services/storage_service.dart';

// Auth state
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final Obra? obraActual;
  final List<Obra> misObras;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.obraActual,
    this.misObras = const [],
  });

  bool get hasObraSelected => obraActual != null;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    Obra? obraActual,
    List<Obra>? misObras,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      obraActual: obraActual ?? this.obraActual,
      misObras: misObras ?? this.misObras,
    );
  }
}

// Auth notifier
class AuthNotifier extends Notifier<AuthState> {
  late AuthService _authService;
  late ObraService _obraService;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);
    _obraService = ref.read(obraServiceProvider);
    _checkAuth();
    return AuthState();
  }

  // Check if user is authenticated
  Future<void> _checkAuth() async {
    try {
      final isValid = await _authService.isTokenValid();
      if (isValid) {
        final user = await _authService.getCurrentUser();
        final storageService = ref.read(storageServiceProvider);
        final token = await storageService.getToken();
        state = state.copyWith(user: user, token: token);
        
        // Cargar obras después de autenticar
        await loadMyObras();
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.login(email, password);
      state = state.copyWith(
        user: result['user'],
        token: result['token'],
        isLoading: false,
      );
      
      // Cargar obras del usuario en segundo plano
      // No esperamos a que termine para no bloquear el login
      loadMyObras().catchError((e) {
        // Solo loguear el error, no bloquear el login
        print('Error cargando obras: $e');
      });
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Cargar las obras del usuario
  Future<void> loadMyObras() async {
    try {
      final obras = await _obraService.getMyObras();
      state = state.copyWith(misObras: obras);
      
      // Si solo hay una obra, seleccionarla automáticamente
      if (obras.length == 1) {
        await selectObra(obras.first.id);
      }
    } catch (e) {
      // No actualizamos el estado con error aquí
      // para no interferir con el flujo de login
      print('Error al cargar obras: $e');
      rethrow;
    }
  }

  // Seleccionar una obra
  Future<bool> selectObra(String obraId) async {
    state = state.copyWith(isLoading: true);
    try {
      final newToken = await _obraService.switchObra(obraId);
      final storageService = ref.read(storageServiceProvider);
      await storageService.saveToken(newToken);
      
      final obraSeleccionada = state.misObras.firstWhere(
        (obra) => obra.id == obraId,
      );
      
      state = state.copyWith(
        token: newToken,
        obraActual: obraSeleccionada,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error al seleccionar obra: $e',
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await _authService.refreshUserData();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
