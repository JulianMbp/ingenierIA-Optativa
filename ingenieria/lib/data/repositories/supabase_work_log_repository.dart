import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/work_log.dart';
import '../../domain/repositories/work_log_repository.dart';

/// Supabase implementation of WorkLogRepository
/// Table: bitacoras (id, obra_id, usuario_id, descripcion, avance_porcentaje, archivos, fecha, created_at)
class SupabaseWorkLogRepository implements WorkLogRepository {
  final SupabaseClient _supabase;

  SupabaseWorkLogRepository(this._supabase);

  static const String _tableName = 'bitacoras';

  @override
  Future<List<WorkLog>> getWorkLogsByObra(String obraId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .order('fecha', ascending: false);

      return (response as List)
          .map((json) => WorkLog.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting work logs', e, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<List<WorkLog>> watchWorkLogsByObra(String obraId) {
    try {
      return _supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .eq('obra_id', obraId)
          .order('fecha', ascending: false)
          .map((data) => data
              .map((json) => WorkLog.fromJson(json))
              .toList());
    } catch (e, stackTrace) {
      AppLogger.error('Error watching work logs', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<WorkLog?> getWorkLogById(String logId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', logId)
          .maybeSingle();

      if (response == null) return null;

      return WorkLog.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting work log by ID', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> createWorkLog(WorkLog log) async {
    try {
      await _supabase.from(_tableName).insert(log.toJson());
      AppLogger.info('Work log created: ${log.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Error creating work log', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updateWorkLog(WorkLog log) async {
    try {
      await _supabase
          .from(_tableName)
          .update(log.toJson())
          .eq('id', log.id);
      AppLogger.info('Work log updated: ${log.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating work log', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteWorkLog(String logId) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', logId);
      AppLogger.info('Work log deleted: $logId');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting work log', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<String> generateAISummary(String logId) async {
    try {
      // Get the work log
      final log = await getWorkLogById(logId);
      if (log == null) {
        throw Exception('Work log not found');
      }

      // Call Supabase Edge Function for AI summary
      final response = await _supabase.functions.invoke(
        'generate-work-log-summary',
        body: {
          'log_id': logId,
          'descripcion': log.descripcion,
          'avance_porcentaje': log.avancePorcentaje,
        },
      );

      final summary = response.data['summary'] as String;

      AppLogger.info('AI summary generated for log: $logId');
      return summary;
    } catch (e, stackTrace) {
      AppLogger.error('Error generating AI summary', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<WorkLog>> searchWorkLogs(String obraId, String query) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .ilike('descripcion', '%$query%')
          .order('fecha', ascending: false);

      return (response as List)
          .map((json) => WorkLog.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error searching work logs', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<WorkLog>> getWorkLogsByDateRange(
    String obraId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .gte('fecha', startDateStr)
          .lte('fecha', endDateStr)
          .order('fecha', ascending: false);

      return (response as List)
          .map((json) => WorkLog.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting work logs by date range', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<WorkLog>> getWorkLogsByUser(String obraId, String userId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .eq('usuario_id', userId)
          .order('fecha', ascending: false);

      return (response as List)
          .map((json) => WorkLog.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting work logs by user', e, stackTrace);
      rethrow;
    }
  }
}


