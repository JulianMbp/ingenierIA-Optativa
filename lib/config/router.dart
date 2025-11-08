import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/modules/asistencias_screen.dart';
import '../features/dashboard/modules/bitacoras_screen.dart';
import '../features/dashboard/modules/chat_ia_screen.dart';
import '../features/dashboard/modules/documentos_screen.dart';
import '../features/dashboard/modules/logs_screen.dart';
import '../features/dashboard/modules/materiales_screen.dart';
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
  
  // Escuchar cambios en el estado de autenticación
  ref.listen(authProvider, (previous, next) {
    // Notificar al router para que reevalúe las rutas
    // Usar un pequeño delay para asegurar que el estado se haya actualizado
    Future.microtask(() {
      notifier.notify();
    });
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
      final isLoggedIn = authState.token != null && authState.user != null;
      final hasObraSelected = authState.hasObraSelected;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingObra = state.matchedLocation == '/select-obra';
      final isLoading = authState.isLoading;

      print('Router redirect - isLoggedIn: $isLoggedIn, hasObra: $hasObraSelected, isLoading: $isLoading, location: ${state.matchedLocation}');

      // Si está cargando durante el login, esperar
      if (isLoading && isLoggingIn) {
        return null; // No redirigir mientras se está haciendo login
      }

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // Después del login exitoso, redirigir a select-obra
      if (isLoggedIn && isLoggingIn) {
        print('Redirigiendo a select-obra después del login');
        return '/select-obra';
      }

      // Si está logueado pero no tiene obra seleccionada, ir a select-obra
      if (isLoggedIn && !hasObraSelected && !isSelectingObra && !isLoggingIn) {
        return '/select-obra';
      }

      // Si está en select-obra pero ya tiene obra seleccionada, ir a dashboard
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
        path: '/modules/documentos',
        builder: (context, state) => const DocumentosScreen(),
      ),
      GoRoute(
        path: '/modules/logs',
        builder: (context, state) => const LogsScreen(),
      ),
      GoRoute(
        path: '/modules/chat-ia',
        builder: (context, state) => const ChatIaScreen(),
      ),
    ],
  );
});
