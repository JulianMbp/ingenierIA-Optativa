import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../../features/auth/auth_provider.dart';

/// Project progress state
class ProjectProgressState {
  final double progress;
  final int totalTasks;
  final int completedTasks;
  final int inProgressTasks;
  final int pendingTasks;
  final bool isLoading;
  final String? error;

  ProjectProgressState({
    this.progress = 0.0,
    this.totalTasks = 0,
    this.completedTasks = 0,
    this.inProgressTasks = 0,
    this.pendingTasks = 0,
    this.isLoading = false,
    this.error,
  });

  ProjectProgressState copyWith({
    double? progress,
    int? totalTasks,
    int? completedTasks,
    int? inProgressTasks,
    int? pendingTasks,
    bool? isLoading,
    String? error,
  }) {
    return ProjectProgressState(
      progress: progress ?? this.progress,
      totalTasks: totalTasks ?? this.totalTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Notifier for project progress
class ProjectProgressNotifier extends Notifier<ProjectProgressState> {
  @override
  ProjectProgressState build() {
    // Load initial progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadProgress();
    });
    return ProjectProgressState();
  }

  /// Calculate progress from a list of tasks
  void _calculateFromTasks(List<Task> tasks) {
    if (tasks.isEmpty) {
      state = ProjectProgressState(
        progress: 0.0,
        totalTasks: 0,
        completedTasks: 0,
        inProgressTasks: 0,
        pendingTasks: 0,
        isLoading: false,
      );
      return;
    }

    final completed = tasks.where((t) => t.isCompleted).length;
    final inProgress = tasks.where((t) => t.isInProgress).length;
    final pending = tasks.where((t) => t.isPending).length;
    
    final sum = tasks.fold<double>(
      0.0,
      (sum, t) => sum + t.progressPercentage.toDouble(),
    );
    
    final progress = sum / tasks.length;

    state = ProjectProgressState(
      progress: progress,
      totalTasks: tasks.length,
      completedTasks: completed,
      inProgressTasks: inProgress,
      pendingTasks: pending,
      isLoading: false,
    );
  }

  /// Load progress from API
  Future<void> loadProgress() async {
    final authState = ref.read(authProvider);
    final projectId = authState.currentProject?.id;

    if (projectId == null) {
      state = ProjectProgressState(
        progress: 0.0,
        totalTasks: 0,
        completedTasks: 0,
        inProgressTasks: 0,
        pendingTasks: 0,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final taskService = ref.read(taskServiceProvider);
      final tasks = await taskService.listTasks(projectId);
      _calculateFromTasks(tasks);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update progress from a list of tasks (without calling API)
  void updateFromTasks(List<Task> tasks) {
    _calculateFromTasks(tasks);
  }

  /// Refresh progress (force reload from API)
  Future<void> refresh() async {
    await loadProgress();
  }
}

/// Provider for project progress
final projectProgressProvider =
    NotifierProvider<ProjectProgressNotifier, ProjectProgressState>(() {
  return ProjectProgressNotifier();
});

