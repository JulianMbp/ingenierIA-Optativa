import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/project.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/project_service.dart';
import '../../core/services/storage_service.dart';

// Auth state
class AuthState {
  final User? user;
  final String? token;
  final bool isLoading;
  final String? error;
  final Project? currentProject;
  final List<Project> myProjects;

  AuthState({
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
    this.currentProject,
    this.myProjects = const [],
  });

  bool get hasProjectSelected => currentProject != null;

  AuthState copyWith({
    User? user,
    String? token,
    bool? isLoading,
    String? error,
    Project? currentProject,
    List<Project>? myProjects,
  }) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentProject: currentProject ?? this.currentProject,
      myProjects: myProjects ?? this.myProjects,
    );
  }
}

// Auth notifier
class AuthNotifier extends Notifier<AuthState> {
  late AuthService _authService;
  late ProjectService _projectService;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);
    _projectService = ref.read(projectServiceProvider);
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
        
        // Load projects after authentication
        await loadMyProjects();
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
      
      // Update state immediately after login
      // This will allow the router to redirect immediately
      state = state.copyWith(
        user: result['user'],
        token: result['token'],
        isLoading: false,
        myProjects: const [], // Initialize with empty list to allow navigation
      );
      
      // Load user projects in background
      // We don't wait for it to finish to avoid blocking login
      // Router will redirect to /select-project while projects are loading
      loadMyProjects().catchError((e) {
        // Only log the error, don't block login
        print('Error loading projects: $e');
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

  // Load user projects
  Future<void> loadMyProjects() async {
    try {
      final projects = await _projectService.getMyProjects();
      print('Projects loaded: ${projects.length}');
      
      state = state.copyWith(myProjects: projects);
      
      // If there's only one project, select it automatically
      if (projects.length == 1) {
        try {
          print('Selecting project automatically: ${projects.first.id}');
          await selectProject(projects.first.id);
        } catch (e) {
          // If automatic selection fails, don't block
          print('Error selecting project automatically: $e');
        }
      } else if (projects.isEmpty) {
        print('No projects available for user');
      }
    } catch (e) {
      // Don't update state with error here
      // to avoid interfering with login flow
      print('Error loading projects: $e');
      // Ensure state has at least an empty list
      // so router can navigate correctly
      state = state.copyWith(myProjects: []);
    }
  }

  // Select a project
  Future<bool> selectProject(String projectId) async {
    state = state.copyWith(isLoading: true);
    try {
      final newToken = await _projectService.switchProject(projectId);
      final storageService = ref.read(storageServiceProvider);
      await storageService.saveToken(newToken);
      
      final selectedProject = state.myProjects.firstWhere(
        (project) => project.id == projectId,
      );
      
      state = state.copyWith(
        token: newToken,
        currentProject: selectedProject,
        isLoading: false,
      );
      
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error selecting project: $e',
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
