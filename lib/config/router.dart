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
import '../features/dashboard/modules/tareas_screen.dart';
import '../features/obras/select_obra_screen.dart';
import '../features/profile/profile_screen.dart';

class RouterNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

final _routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier();
  
  ref.listen(authProvider, (previous, next) {
    notifier.notify();
  });
  
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);
  
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.token != null;
      final hasObraSelected = authState.hasObraSelected;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingObra = state.matchedLocation == '/select-obra';

      print('Router redirect - isLoggedIn: $isLoggedIn, hasObra: $hasObraSelected, location: ${state.matchedLocation}');

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        print('Redirigiendo a select-obra');
        return '/select-obra';
      }

      if (isLoggedIn && !hasObraSelected && !isSelectingObra && !isLoggingIn) {
        return '/select-obra';
      }

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
        path: '/modules/tareas',
        builder: (context, state) => const TareasScreen(),
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
