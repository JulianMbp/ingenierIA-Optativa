import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';

/// Supabase implementation of AttendanceRepository
/// Table: asistencias (id, obra_id, usuario_id, fecha, estado, observaciones, created_at)
class SupabaseAttendanceRepository implements AttendanceRepository {
  final SupabaseClient _supabase;

  SupabaseAttendanceRepository(this._supabase);

  static const String _tableName = 'asistencias';

  @override
  Future<List<Attendance>> getAttendanceByObra(String obraId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .order('fecha', ascending: false);

      return (response as List)
          .map((json) => Attendance.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting attendance records', e, stackTrace);
      rethrow;
    }
  }

  @override
  Stream<List<Attendance>> watchAttendanceByObra(String obraId) {
    try {
      return _supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .eq('obra_id', obraId)
          .order('fecha', ascending: false)
          .map((data) =>
              data.map((json) => Attendance.fromJson(json)).toList());
    } catch (e, stackTrace) {
      AppLogger.error('Error watching attendance records', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Attendance>> getAttendanceByDate(
    String obraId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];

      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .eq('fecha', dateStr)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => Attendance.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting attendance by date', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Attendance>> getAttendanceByDateRange(
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
          .map((json) => Attendance.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting attendance by date range', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<List<Attendance>> getAttendanceByWorker(
    String obraId,
    String workerId,
  ) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('obra_id', obraId)
          .eq('usuario_id', workerId)
          .order('fecha', ascending: false);

      return (response as List)
          .map((json) => Attendance.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      AppLogger.error('Error getting attendance by worker', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Attendance?> getAttendanceById(String attendanceId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', attendanceId)
          .maybeSingle();

      if (response == null) return null;

      return Attendance.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error('Error getting attendance by ID', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> createAttendance(Attendance attendance) async {
    try {
      await _supabase.from(_tableName).insert(attendance.toJson());
      AppLogger.info('Attendance created: ${attendance.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Error creating attendance', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> updateAttendance(Attendance attendance) async {
    try {
      await _supabase
          .from(_tableName)
          .update(attendance.toJson())
          .eq('id', attendance.id);
      AppLogger.info('Attendance updated: ${attendance.id}');
    } catch (e, stackTrace) {
      AppLogger.error('Error updating attendance', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', attendanceId);
      AppLogger.info('Attendance deleted: $attendanceId');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting attendance', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> checkIn(String attendanceId, DateTime checkInTime) async {
    try {
      await _supabase
          .from(_tableName)
          .update({
            'estado': AttendanceStatus.presente.name,
          })
          .eq('id', attendanceId);
      AppLogger.info('Check-in recorded: $attendanceId');
    } catch (e, stackTrace) {
      AppLogger.error('Error recording check-in', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> checkOut(String attendanceId, DateTime checkOutTime) async {
    try {
      // No hay campo check_out_time en la tabla, solo actualizamos el estado si es necesario
      AppLogger.info('Check-out not supported in current schema: $attendanceId');
    } catch (e, stackTrace) {
      AppLogger.error('Error recording check-out', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<Map<String, int>> getAttendanceStats(
    String obraId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final records = await getAttendanceByDateRange(
        obraId,
        startDate,
        endDate,
      );

      final stats = <String, int>{
        'presente': 0,
        'ausente': 0,
        'justificado': 0,
      };

      for (final record in records) {
        final statusKey = record.estado.name;
        stats[statusKey] = (stats[statusKey] ?? 0) + 1;
      }

      return stats;
    } catch (e, stackTrace) {
      AppLogger.error('Error getting attendance stats', e, stackTrace);
      rethrow;
    }
  }
}

