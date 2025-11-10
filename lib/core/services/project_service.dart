import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/project.dart';
import 'api_service.dart';

final projectServiceProvider = Provider<ProjectService>((ref) {
  return ProjectService(ref.read(apiServiceProvider));
});

class ProjectService {
  final ApiService _apiService;

  ProjectService(this._apiService);

  /// Get authenticated user's projects
  Future<List<Project>> getMyProjects() async {
    final response = await _apiService.get('/auth/my-obras');
    dynamic responseData = response.data;
    
    List<dynamic> projectsList = [];
    
    // Endpoint may return array directly or object with 'obra' inside
    if (responseData is List) {
      projectsList = responseData;
    } else if (responseData is Map<String, dynamic>) {
      // If it comes as object, may be in 'data' or directly in the object
      if (responseData.containsKey('data') && responseData['data'] is List) {
        projectsList = responseData['data'] as List;
      } else {
        // Try to extract 'obra' from each element if comes as array of objects with 'obra'
        projectsList = responseData.values.where((v) => v is List).expand((v) => v as List).toList();
      }
    }
    
    // If we still don't have projects, try to parse each element
    if (projectsList.isEmpty && responseData is List) {
      projectsList = responseData;
    }
    
    // If format is array of objects with 'obra' inside (like in postman)
    if (projectsList.isNotEmpty && projectsList.first is Map<String, dynamic>) {
      final firstItem = projectsList.first as Map<String, dynamic>;
      if (firstItem.containsKey('obra')) {
        // Format is: [{"obra": {...}, "roleName": "..."}]
        return projectsList.map((item) {
          final projectData = item['obra'] as Map<String, dynamic>;
          // Add roleName to project object if available
          if (item.containsKey('roleName')) {
            projectData['roleName'] = item['roleName'];
          }
          return Project.fromJson(projectData);
        }).toList();
      }
    }
    
    // Standard format: direct array of projects
    return projectsList.map((json) => Project.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Switch current user's project and get new token
  Future<String> switchProject(String projectId) async {
    final response = await _apiService.post(
      '/auth/switch-obra',
      data: {'obraId': projectId}, // Keep backend field name
    );
    return response.data['token'] as String;
  }

  /// Get all projects (Admin General only)
  Future<List<Project>> getAllProjects({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.get(
      '/obras', // Keep backend endpoint
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    final data = response.data as List;
    return data.map((json) => Project.fromJson(json)).toList();
  }

  /// Create a new project (Admin General only)
  Future<Project> createProject(Map<String, dynamic> data) async {
    final response = await _apiService.post('/obras', data: data); // Keep backend endpoint
    return Project.fromJson(response.data);
  }

  /// Update a project (Admin General only)
  Future<Project> updateProject(String projectId, Map<String, dynamic> data) async {
    final response = await _apiService.patch('/obras/$projectId', data: data); // Keep backend endpoint
    return Project.fromJson(response.data);
  }

  /// Delete a project (Admin General only)
  Future<void> deleteProject(String projectId) async {
    await _apiService.delete('/obras/$projectId'); // Keep backend endpoint
  }

  /// Assign a user to a project (Admin General only)
  Future<void> assignUser(String projectId, String userId) async {
    await _apiService.post(
      '/obras/$projectId/usuarios', // Keep backend endpoint
      data: {'usuarioId': userId}, // Keep backend field name
    );
  }

  /// Get users assigned to a project
  Future<List<Map<String, dynamic>>> getProjectUsers(String projectId) async {
    final response = await _apiService.get('/obras/$projectId/usuarios'); // Keep backend endpoint
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}

