import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/project.dart';

/// State class for selected project
class ProjectState {
  final Project? selectedProject;
  final List<Project> projects;
  final bool isLoading;
  final String? error;

  const ProjectState({
    this.selectedProject,
    this.projects = const [],
    this.isLoading = false,
    this.error,
  });

  ProjectState copyWith({
    Project? selectedProject,
    List<Project>? projects,
    bool? isLoading,
    String? error,
  }) {
    return ProjectState(
      selectedProject: selectedProject ?? this.selectedProject,
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for project state
class ProjectNotifier extends StateNotifier<ProjectState> {
  ProjectNotifier() : super(const ProjectState());

  /// Load all projects
  Future<void> loadProjects() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual project loading logic
      await Future.delayed(const Duration(seconds: 1));

      // Mock projects for demonstration
      final mockProjects = [
        Project(
          id: '1',
          name: 'Construction Project A',
          description: 'Residential building project',
          address: '123 Main St',
          city: 'Bogotá',
          country: 'Colombia',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          status: 'active',
          createdAt: DateTime.now(),
        ),
        Project(
          id: '2',
          name: 'Construction Project B',
          description: 'Commercial complex',
          address: '456 Business Ave',
          city: 'Medellín',
          country: 'Colombia',
          startDate: DateTime.now().subtract(const Duration(days: 60)),
          status: 'active',
          createdAt: DateTime.now(),
        ),
      ];

      state = state.copyWith(
        projects: mockProjects,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Select a project
  void selectProject(Project project) {
    state = state.copyWith(selectedProject: project);
  }

  /// Clear selected project
  void clearSelection() {
    state = state.copyWith(selectedProject: null);
  }
}

/// Provider for project state
final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier();
});
