import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(
    ref.read(offlineServiceProvider),
    ref.read(apiServiceProvider),
  );
});

/// Task repository
/// Simplified: only uses API directly
class TaskRepository {
  final OfflineService _offlineService;
  final ApiService _apiService;

  TaskRepository(
    this._offlineService,
    this._apiService,
  );

  /// List tasks from API
  Future<List<Task>> listTasks(String projectId) async {
    final hasConnection = await _offlineService.hasConnection();
    
    if (!hasConnection) {
      throw Exception('No internet connection. Please check your connection.');
    }

    try {
      final response = await _apiService.get('/obras/$projectId/tareas'); // Keep backend endpoint
      dynamic data = response.data;
      
      List<dynamic> tasksList = [];
      if (data is List) {
        tasksList = data;
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        tasksList = data['data'] as List;
      }
      
      return tasksList
          .map((json) => Task.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Create task
  Future<Task> createTask(String projectId, Map<String, dynamic> taskData) async {
    final hasConnection = await _offlineService.hasConnection();
    
    if (!hasConnection) {
      throw Exception('No internet connection. Please check your connection.');
    }

    try {
      final response = await _apiService.post(
        '/obras/$projectId/tareas', // Keep backend endpoint
        data: taskData,
      );
      return Task.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Update task
  Future<Task> updateTask(
    String projectId,
    String taskId,
    Map<String, dynamic> taskData,
  ) async {
    final hasConnection = await _offlineService.hasConnection();
    
    if (!hasConnection) {
      throw Exception('No internet connection. Please check your connection.');
    }

    try {
      final response = await _apiService.patch(
        '/obras/$projectId/tareas/$taskId', // Keep backend endpoint
        data: taskData,
      );
      return Task.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete task
  Future<void> deleteTask(String projectId, String taskId) async {
    final hasConnection = await _offlineService.hasConnection();
    
    if (!hasConnection) {
      throw Exception('No internet connection. Please check your connection.');
    }

    try {
      await _apiService.delete('/obras/$projectId/tareas/$taskId'); // Keep backend endpoint
    } catch (e) {
      rethrow;
    }
  }
}

