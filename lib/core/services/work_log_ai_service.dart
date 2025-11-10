import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/api_config.dart';
import 'api_service.dart';
import 'connectivity_service.dart';

final workLogAiServiceProvider = Provider<WorkLogAiService>((ref) {
  return WorkLogAiService(
    ref.read(apiServiceProvider),
    ref.read(connectivityServiceProvider),
  );
});

class WorkLogAiService {
  final ApiService _apiService;
  final ConnectivityService _connectivityService;

  WorkLogAiService(
    this._apiService,
    this._connectivityService,
  );

  /// Generate work log report using AI
  Future<WorkLogReportResponse> generateReport({
    required String projectId,
    required List<String> activities,
    required int overallProgress,
    String? date,
    String? weather,
    List<String>? incidents,
    String? observations,
  }) async {
    final hasConnection = await _connectivityService.hasInternetConnection();

    if (!hasConnection) {
      throw Exception(
        'No internet connection. Please check your connection and try again.',
      );
    }

    try {
      final body = {
        'actividades': activities,
        'avanceGeneral': overallProgress,
        if (date != null) 'fecha': date,
        if (weather != null) 'clima': weather,
        if (incidents != null && incidents.isNotEmpty)
          'incidencias': incidents,
        if (observations != null) 'observaciones': observations,
      };

      final response = await _apiService.post(
        '/obras/$projectId/bitacoras/generar-informe-ia', // Keep backend endpoint
        data: body,
        options: Options(
          receiveTimeout: ApiConfig.aiReceiveTimeout,
        ),
      );

      final responseData = response.data;
      
      // Response may come in two formats:
      // 1. {success: true, data: {html: "...", tokensUsados: ...}, message: "..."}
      // 2. {success: true, data: {success: true, data: {html: "...", tokensUsados: ...}, message: "..."}, message: "..."}
      
      // If there's nested structure (data.data), use the inner one
      if (responseData is Map<String, dynamic> && 
          responseData['data'] is Map<String, dynamic> &&
          responseData['data']['data'] is Map<String, dynamic>) {
        // Nested structure: use data.data
        final nestedData = responseData['data'] as Map<String, dynamic>;
        return WorkLogReportResponse.fromJson(nestedData);
      }
      
      // Direct structure
      return WorkLogReportResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all pending drafts for a project
  /// Note: No longer saves drafts without SQLite
  Future<List<WorkLogDraft>> getPendingDrafts(
      String projectId) async {
    // Without SQLite, there are no saved drafts
    return [];
  }

  /// Generate report from a saved draft
  /// Note: No longer saves drafts without SQLite
  Future<WorkLogReportResponse> generateFromDraft(
      WorkLogDraft draft) async {
    return await generateReport(
      projectId: draft.projectId,
      activities: draft.activities,
      overallProgress: draft.overallProgress,
      date: draft.date,
      weather: draft.weather,
      incidents: draft.incidents,
      observations: draft.observations,
    );
  }

  /// Mark a draft as synchronized
  /// Note: No longer saves drafts without SQLite
  Future<void> markDraftSynchronized(String draftId) async {
    // Without SQLite, there's nothing to do
  }

  /// Delete a draft
  /// Note: No longer saves drafts without SQLite
  Future<void> deleteDraft(String draftId) async {
    // Without SQLite, there's nothing to do
  }

  /// Ask a question to AI about the project
  Future<WorkLogChatResponse> askQuestion({
    required String projectId,
    required String message,
  }) async {
    final hasConnection = await _connectivityService.hasInternetConnection();

    if (!hasConnection) {
      throw Exception(
        'No internet connection. Please check your connection and try again.',
      );
    }

    try {
      final body = {
        'mensaje': message, // Keep backend field name
      };

      final response = await _apiService.post(
        '/obras/$projectId/bitacoras/chat', // Keep backend endpoint
        data: body,
        options: Options(
          receiveTimeout: ApiConfig.aiReceiveTimeout,
        ),
      );

      final responseData = response.data;
      
      // Response may come in two formats:
      // 1. {success: true, data: {respuesta: "...", tokensUsados: ...}, message: "..."}
      // 2. {success: true, data: {success: true, data: {respuesta: "...", tokensUsados: ...}, message: "..."}, message: "..."}
      
      // If there's nested structure (data.data), use the inner one
      if (responseData is Map<String, dynamic> && 
          responseData['data'] is Map<String, dynamic> &&
          responseData['data']['data'] is Map<String, dynamic>) {
        // Nested structure: use data.data
        final nestedData = responseData['data'] as Map<String, dynamic>;
        return WorkLogChatResponse.fromJson(nestedData);
      }
      
      // Direct structure
      return WorkLogChatResponse.fromJson(responseData);
    } catch (e) {
      rethrow;
    }
  }
}

/// Work log report response model
class WorkLogReportResponse {
  final bool success;
  final WorkLogReportData data;
  final String message;

  WorkLogReportResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory WorkLogReportResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested structure: if data has a 'data' field inside, use that
    dynamic dataField = json['data'];
    if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
      // Nested structure: data.data contains the WorkLogReportData
      dataField = dataField['data'];
    }
    
    return WorkLogReportResponse(
      success: json['success'] ?? false,
      data: WorkLogReportData.fromJson(dataField ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class WorkLogReportData {
  final String html;
  final int? tokensUsed;

  WorkLogReportData({
    required this.html,
    this.tokensUsed,
  });

  factory WorkLogReportData.fromJson(Map<String, dynamic> json) {
    return WorkLogReportData(
      html: json['html'] ?? '',
      tokensUsed: json['tokensUsados'], // Keep backend field name
    );
  }
}

/// Draft model for work log report
/// Note: No longer used without SQLite, but kept for compatibility
class WorkLogDraft {
  final String id;
  final String projectId;
  final List<String> activities;
  final int overallProgress;
  final String? date;
  final String? weather;
  final List<String>? incidents;
  final String? observations;
  final DateTime createdAt;
  final bool synchronized;

  WorkLogDraft({
    required this.id,
    required this.projectId,
    required this.activities,
    required this.overallProgress,
    this.date,
    this.weather,
    this.incidents,
    this.observations,
    required this.createdAt,
    required this.synchronized,
  });
}

/// Chat response model with AI
class WorkLogChatResponse {
  final bool success;
  final WorkLogChatData data;
  final String message;

  WorkLogChatResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory WorkLogChatResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested structure: if data has a 'data' field inside, use that
    dynamic dataField = json['data'];
    if (dataField is Map<String, dynamic> && dataField.containsKey('data')) {
      // Nested structure: data.data contains the WorkLogChatData
      dataField = dataField['data'];
    }
    
    return WorkLogChatResponse(
      success: json['success'] ?? false,
      data: WorkLogChatData.fromJson(dataField ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class WorkLogChatData {
  final String answer;
  final int? tokensUsed;

  WorkLogChatData({
    required this.answer,
    this.tokensUsed,
  });

  factory WorkLogChatData.fromJson(Map<String, dynamic> json) {
    return WorkLogChatData(
      answer: json['respuesta'] ?? '', // Keep backend field name
      tokensUsed: json['tokensUsados'], // Keep backend field name
    );
  }
}

