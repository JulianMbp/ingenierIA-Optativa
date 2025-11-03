import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/modules/asistencias_screen.dart';
import '../features/dashboard/modules/bitacoras_screen.dart';
import '../features/dashboard/modules/documentos_screen.dart';
import '../features/dashboard/modules/logs_screen.dart';
import '../features/dashboard/modules/materiales_screen.dart';
import '../features/dashboard/modules/presupuestos_screen.dart';
import '../features/obras/select_obra_screen.dart';
import '../features/profile/profile_screen.dart';

// Notifier para refrescar el router cuando cambie el estado de auth
class AuthStateNotifier extends ChangeNotifier {
  final Ref ref;
  
  AuthStateNotifier(this.ref) {
    ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = AuthStateNotifier(ref);
  
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.token != null;
      final hasObraSelected = authState.hasObraSelected;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingObra = state.matchedLocation == '/select-obra';

      // Debug: imprimir estado
      print('Router redirect - isLoggedIn: $isLoggedIn, hasObra: $hasObraSelected, location: ${state.matchedLocation}');

      // No está logueado y no está en login -> redirigir a login
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // Está logueado pero está en login -> redirigir a select-obra
      if (isLoggedIn && isLoggingIn) {
        print('Redirigiendo a select-obra');
        return '/select-obra';
      }

      // Está logueado pero no ha seleccionado obra y no está en select-obra
      if (isLoggedIn && !hasObraSelected && !isSelectingObra && !isLoggingIn) {
        return '/select-obra';
      }

      // Está logueado, tiene obra seleccionada y está en select-obra -> ir a dashboard
      if (isLoggedIn && hasObraSelected && isSelectingObra) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/select-obra',
        builder: (context, state) => const SelectObraScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/modules/materiales',
        builder: (context, state) => const MaterialesScreen(),
      ),
      GoRoute(
        path: '/modules/bitacoras',
        builder: (context, state) => const BitacorasScreen(),
      ),
      GoRoute(
        path: '/modules/asistencias',
        builder: (context, state) => const AsistenciasScreen(),
      ),
      GoRoute(
        path: '/modules/presupuestos',
        builder: (context, state) => const PresupuestosScreen(),
      ),
      GoRoute(
        path: '/modules/documentos',
        builder: (context, state) => const DocumentosScreen(),
      ),
      GoRoute(
        path: '/modules/logs',
        builder: (context, state) => const LogsScreen(),
      ),
    ],
  );
});
