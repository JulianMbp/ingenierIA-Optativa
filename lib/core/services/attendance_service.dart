import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/attendance.dart';
import 'api_service.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService(ref.read(apiServiceProvider));
});

class AttendanceService {
  final ApiService _apiService;

  AttendanceService(this._apiService);

  /// Get attendances for a project
  Future<List<Attendance>> getAttendances(
    String projectId, {
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiService.get(
      '/obras/$projectId/asistencias', // Keep backend endpoint
      queryParameters: filters,
    );
    final responseData = response.data;
    final data = responseData['data'] as List;
    return data.map((json) => Attendance.fromJson(json)).toList();
  }

  /// Get authenticated user's attendance for today
  Future<Attendance?> getMyAttendanceToday(String projectId) async {
    try {
      final today = DateTime.now();
      final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final response = await _apiService.get(
        '/asistencias/my-asistencia-hoy', // Keep backend endpoint
        queryParameters: {
          'obraId': projectId, // Keep backend field name
          'fecha': date,
        },
      );
      final responseData = response.data;
      return Attendance.fromJson(responseData['data']);
    } catch (e) {
      return null; // No attendance registered today
    }
  }

  /// Get a specific attendance
  Future<Attendance> getAttendance(String projectId, String attendanceId) async {
    final response = await _apiService.get('/obras/$projectId/asistencias/$attendanceId'); // Keep backend endpoint
    final responseData = response.data;
    return Attendance.fromJson(responseData['data']);
  }

  /// Create a new attendance
  Future<Attendance> createAttendance(String projectId, Map<String, dynamic> data) async {
    final response = await _apiService.post('/obras/$projectId/asistencias', data: data); // Keep backend endpoint
    final responseData = response.data;
    return Attendance.fromJson(responseData['data']);
  }

  /// Update an attendance
  Future<Attendance> updateAttendance(
    String projectId,
    String attendanceId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.patch(
      '/obras/$projectId/asistencias/$attendanceId', // Keep backend endpoint
      data: data,
    );
    final responseData = response.data;
    return Attendance.fromJson(responseData['data']);
  }

  /// Delete an attendance
  Future<void> deleteAttendance(String projectId, String attendanceId) async {
    await _apiService.delete('/obras/$projectId/asistencias/$attendanceId'); // Keep backend endpoint
  }
}

