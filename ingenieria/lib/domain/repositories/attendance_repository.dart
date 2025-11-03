import '../entities/attendance.dart';

/// Abstract repository for attendance operations
abstract class AttendanceRepository {
  /// Get all attendance records for a specific obra
  Future<List<Attendance>> getAttendanceByObra(String obraId);

  /// Watch attendance records for real-time updates
  Stream<List<Attendance>> watchAttendanceByObra(String obraId);

  /// Get attendance records by date
  Future<List<Attendance>> getAttendanceByDate(String obraId, DateTime date);

  /// Get attendance records by date range
  Future<List<Attendance>> getAttendanceByDateRange(
    String obraId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get attendance records by worker
  Future<List<Attendance>> getAttendanceByWorker(
    String obraId,
    String workerId,
  );

  /// Get a specific attendance record by ID
  Future<Attendance?> getAttendanceById(String attendanceId);

  /// Create a new attendance record
  Future<void> createAttendance(Attendance attendance);

  /// Update an existing attendance record
  Future<void> updateAttendance(Attendance attendance);

  /// Delete an attendance record
  Future<void> deleteAttendance(String attendanceId);

  /// Mark check-in
  Future<void> checkIn(String attendanceId, DateTime checkInTime);

  /// Mark check-out
  Future<void> checkOut(String attendanceId, DateTime checkOutTime);

  /// Get attendance statistics for a date range
  Future<Map<String, int>> getAttendanceStats(
    String obraId,
    DateTime startDate,
    DateTime endDate,
  );
}
