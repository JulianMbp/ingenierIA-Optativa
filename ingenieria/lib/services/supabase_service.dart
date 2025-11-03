import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/api_config.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/logger.dart';

/// Service for Supabase database operations.
class SupabaseService {
  static SupabaseClient? _client;
  final FlutterSecureStorage _secureStorage;

  SupabaseService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Initialize Supabase client
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: ApiConfig.supabaseUrl,
      anonKey: ApiConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    AppLogger.info('Supabase initialized successfully');
  }

  /// Get the Supabase client instance
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Set the JWT token for authenticated requests
  /// 
  /// Note: Currently, Supabase operations use the anon key for authentication.
  /// The JWT token from NestJS is stored for future RLS (Row Level Security) implementation.
  /// 
  /// TODO: Implement RLS policies in Supabase to validate the NestJS JWT token
  /// and restrict access based on user roles and project assignments.
  Future<void> setAuthToken(String token) async {
    try {
      // Store token in secure storage for future RLS implementation
      await _secureStorage.write(key: AppConstants.tokenKey, value: token);
      
      AppLogger.info('Auth token stored for Supabase requests');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set auth token', e, stackTrace);
      rethrow;
    }
  }

  /// Clear authentication token
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await client.auth.signOut();
    AppLogger.info('Auth token cleared from Supabase');
  }

  // ========== Materials Operations ==========

  /// Get all materials for a project
  Future<List<Map<String, dynamic>>> getMaterials(String projectId) async {
    try {
      final response = await client
          .from('materiales')
          .select()
          .eq('obra_id', projectId)
          .order('fecha_registro', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch materials', e, stackTrace);
      rethrow;
    }
  }

  /// Add a new material
  Future<Map<String, dynamic>> addMaterial(Map<String, dynamic> material) async {
    try {
      final response = await client
          .from('materiales')
          .insert(material)
          .select()
          .single();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add material', e, stackTrace);
      rethrow;
    }
  }

  /// Update a material
  Future<Map<String, dynamic>> updateMaterial(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await client
          .from('materiales')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to update material', e, stackTrace);
      rethrow;
    }
  }

  // ========== Attendance Operations ==========

  /// Get attendance records for a project
  Future<List<Map<String, dynamic>>> getAttendance(
    String projectId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = client
          .from('asistencias')
          .select()
          .eq('obra_id', projectId);

      if (startDate != null) {
        query = query.gte('fecha', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('fecha', endDate.toIso8601String());
      }

      final response = await query.order('fecha', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch attendance', e, stackTrace);
      rethrow;
    }
  }

  /// Submit attendance record
  Future<Map<String, dynamic>> submitAttendance(
    Map<String, dynamic> attendance,
  ) async {
    try {
      final response = await client
          .from('asistencias')
          .insert(attendance)
          .select()
          .single();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to submit attendance', e, stackTrace);
      rethrow;
    }
  }

  // ========== Work Logs Operations ==========

  /// Get work logs for a project
  Future<List<Map<String, dynamic>>> getWorkLogs(String projectId) async {
    try {
      final response = await client
          .from('bitacora')
          .select()
          .eq('obra_id', projectId)
          .order('fecha', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch work logs', e, stackTrace);
      rethrow;
    }
  }

  /// Add a work log entry
  Future<Map<String, dynamic>> addWorkLog(Map<String, dynamic> log) async {
    try {
      final response = await client
          .from('bitacora')
          .insert(log)
          .select()
          .single();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add work log', e, stackTrace);
      rethrow;
    }
  }

  // ========== Safety Incidents Operations ==========

  /// Get safety incidents for a project
  Future<List<Map<String, dynamic>>> getSafetyIncidents(String projectId) async {
    try {
      final response = await client
          .from('incidentes_sst')
          .select()
          .eq('obra_id', projectId)
          .order('fecha', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch safety incidents', e, stackTrace);
      rethrow;
    }
  }

  /// Add a safety incident
  Future<Map<String, dynamic>> addSafetyIncident(
    Map<String, dynamic> incident,
  ) async {
    try {
      final response = await client
          .from('incidentes_sst')
          .insert(incident)
          .select()
          .single();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add safety incident', e, stackTrace);
      rethrow;
    }
  }

  // ========== Documents/Reports Operations ==========

  /// Get documents for a project
  Future<List<Map<String, dynamic>>> getDocuments(String projectId) async {
    try {
      final response = await client
          .from('documentos')
          .select()
          .eq('obra_id', projectId)
          .order('fecha_generacion', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch documents', e, stackTrace);
      rethrow;
    }
  }

  /// Add a document
  Future<Map<String, dynamic>> addDocument(Map<String, dynamic> document) async {
    try {
      final response = await client
          .from('documentos')
          .insert(document)
          .select()
          .single();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add document', e, stackTrace);
      rethrow;
    }
  }

  // ========== Projects Operations ==========

  /// Get all projects (obras)
  Future<List<Map<String, dynamic>>> getProjects() async {
    try {
      final response = await client
          .from('obras')
          .select()
          .order('nombre', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch projects', e, stackTrace);
      rethrow;
    }
  }

  /// Get a specific project by ID
  Future<Map<String, dynamic>> getProjectById(String projectId) async {
    try {
      final response = await client
          .from('obras')
          .select()
          .eq('id', projectId)
          .single();

      return response;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to fetch project', e, stackTrace);
      rethrow;
    }
  }
}
