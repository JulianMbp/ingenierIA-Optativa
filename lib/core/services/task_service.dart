import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../repositories/task_repository.dart';

final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService(ref.read(taskRepositoryProvider));
});

class TaskService {
  final TaskRepository _repository;

  TaskService(this._repository);

  /// List all tasks for a project (uses repository with offline support)
  Future<List<Task>> listTasks(String projectId) async {
    return await _repository.listTasks(projectId);
  }

  /// Get my assigned tasks for a project (filters from complete list)
  Future<List<Task>> myTasks(String projectId) async {
    final allTasks = await listTasks(projectId);
    // Filter by assigned user (this would be better with a user parameter)
    return allTasks;
  }

  /// Get tasks assigned to a specific user (filters from complete list)
  Future<List<Task>> userAssignedTasks(String projectId, int userId) async {
    final allTasks = await listTasks(projectId);
    return allTasks.where((t) => t.assignedToId == userId).toList();
  }

  /// Get a task by ID (searches in local cache or API)
  Future<Task> getTask(String projectId, String taskId) async {
    final allTasks = await listTasks(projectId);
    final task = allTasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Task not found'),
    );
    return task;
  }

  /// Create a new task (uses repository with offline support)
  Future<Task> createTask(String projectId, Map<String, dynamic> taskData) async {
    return await _repository.createTask(projectId, taskData);
  }

  /// Update an existing task (uses repository with offline support)
  Future<Task> updateTask(
      String projectId, String taskId, Map<String, dynamic> taskData) async {
    return await _repository.updateTask(projectId, taskId, taskData);
  }

  /// Complete a task (shortcut to mark as 100% complete)
  Future<Task> completeTask(String projectId, String taskId) async {
    return updateTask(projectId, taskId, {
      'estado': 'completada', // Keep backend field value
      'avance_porcentaje': 100, // Keep backend field name
    });
  }

  /// Delete a task (uses repository with offline support)
  Future<void> deleteTask(String projectId, String taskId) async {
    await _repository.deleteTask(projectId, taskId);
  }

  /// Calculate average progress of all tasks in a project
  double calculateProjectProgress(List<Task> tasks) {
    if (tasks.isEmpty) return 0.0;

    int totalProgress =
        tasks.fold(0, (sum, task) => sum + task.progressPercentage);
    return totalProgress / tasks.length;
  }

  /// Get project progress by calculating from tasks
  /// This method fetches all tasks and calculates the average progress
  Future<Map<String, dynamic>> getProjectProgress(String projectId) async {
    try {
      final tasks = await listTasks(projectId);
      
      if (tasks.isEmpty) {
        return {
          'progress': 0.0,
          'totalTasks': 0,
          'completedTasks': 0,
          'inProgressTasks': 0,
          'pendingTasks': 0,
        };
      }

      final completed = tasks.where((t) => t.isCompleted).length;
      final inProgress = tasks.where((t) => t.isInProgress).length;
      final pending = tasks.where((t) => t.isPending).length;
      
      // Calculate sum of progresses
      final sum = tasks.fold<double>(
        0.0, 
        (sum, t) {
          final progress = t.progressPercentage.toDouble();
          return sum + progress;
        }
      );
      
      final progress = sum / tasks.length;

      return {
        'progress': progress,
        'totalTasks': tasks.length,
        'completedTasks': completed,
        'inProgressTasks': inProgress,
        'pendingTasks': pending,
      };
    } catch (e) {
      print('Error calculating project progress: $e');
      return {
        'progress': 0.0,
        'totalTasks': 0,
        'completedTasks': 0,
        'inProgressTasks': 0,
        'pendingTasks': 0,
        'error': e.toString(),
      };
    }
  }
}

