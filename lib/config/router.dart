import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/dashboard/modules/attendance_screen.dart';
import '../features/dashboard/modules/work_logs_screen.dart';
import '../features/dashboard/modules/chat_ia_screen.dart';
import '../features/dashboard/modules/documentos_screen.dart';
import '../features/dashboard/modules/logs_screen.dart';
import '../features/dashboard/modules/materials_screen.dart';
import '../features/dashboard/modules/tasks_screen.dart';
import '../features/projects/select_project_screen.dart';
import '../features/profile/profile_screen.dart';

class RouterNotifier extends ChangeNotifier {
  void notify() {
    notifyListeners();
  }
}

final _routerNotifierProvider = Provider<RouterNotifier>((ref) {
  final notifier = RouterNotifier();
  
  // Listen to authentication state changes
  ref.listen(authProvider, (previous, next) {
    // Notify router to reevaluate routes
    // Use a small delay to ensure state has been updated
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
      final hasProjectSelected = authState.hasProjectSelected;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSelectingProject = state.matchedLocation == '/select-project';
      final isLoading = authState.isLoading;

      print('Router redirect - isLoggedIn: $isLoggedIn, hasProject: $hasProjectSelected, isLoading: $isLoading, location: ${state.matchedLocation}');

      // If loading during login, wait
      if (isLoading && isLoggingIn) {
        return null; // Don't redirect while logging in
      }

      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      // After successful login, redirect to select-project
      if (isLoggedIn && isLoggingIn) {
        print('Redirecting to select-project after login');
        return '/select-project';
      }

      // If logged in but no project selected, go to select-project
      if (isLoggedIn && !hasProjectSelected && !isSelectingProject && !isLoggingIn) {
        return '/select-project';
      }

      // If in select-project but already has project selected, go to dashboard
      if (isLoggedIn && hasProjectSelected && isSelectingProject) {
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
        path: '/select-project',
        builder: (context, state) => const SelectProjectScreen(),
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
        path: '/modules/materials',
        builder: (context, state) => const MaterialsScreen(),
      ),
      GoRoute(
        path: '/modules/tasks',
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: '/modules/work-logs',
        builder: (context, state) => const WorkLogsScreen(),
      ),
      GoRoute(
        path: '/modules/attendance',
        builder: (context, state) => const AttendanceScreen(),
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
