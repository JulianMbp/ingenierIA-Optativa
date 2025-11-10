import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/work_log.dart';
import 'api_service.dart';

final workLogServiceProvider = Provider<WorkLogService>((ref) {
  return WorkLogService(ref.read(apiServiceProvider));
});

class WorkLogService {
  final ApiService _apiService;

  WorkLogService(this._apiService);

  /// Get work logs for a project
  Future<List<WorkLog>> getWorkLogs(
    String projectId, {
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.get(
      '/obras/$projectId/bitacoras', // Keep backend endpoint
      queryParameters: filters,
    );
    final responseData = response.data;
    final data = responseData['data'] as List;
    return data.map((json) => WorkLog.fromJson(json)).toList();
  }

  /// Get a specific work log
  Future<WorkLog> getWorkLog(String projectId, String workLogId) async {
    final response = await _apiService.get('/obras/$projectId/bitacoras/$workLogId'); // Keep backend endpoint
    final responseData = response.data;
    return WorkLog.fromJson(responseData['data']);
  }

  /// Create a new work log
  Future<WorkLog> createWorkLog(String projectId, Map<String, dynamic> data) async {
    final response = await _apiService.post('/obras/$projectId/bitacoras', data: data); // Keep backend endpoint
    final responseData = response.data;
    return WorkLog.fromJson(responseData['data']);
  }

  /// Update a work log
  Future<WorkLog> updateWorkLog(
    String projectId,
    String workLogId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/obras/$projectId/bitacoras/$workLogId', // Keep backend endpoint
      data: data,
    );
    final responseData = response.data;
    return WorkLog.fromJson(responseData['data']);
  }

  /// Delete a work log
  Future<void> deleteWorkLog(String projectId, String workLogId) async {
    await _apiService.delete('/obras/$projectId/bitacoras/$workLogId'); // Keep backend endpoint
  }
}

