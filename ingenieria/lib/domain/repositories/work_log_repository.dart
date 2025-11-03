import '../entities/work_log.dart';

/// Abstract repository for work log operations
abstract class WorkLogRepository {
  /// Get all work logs for a specific obra
  Future<List<WorkLog>> getWorkLogsByObra(String obraId);

  /// Watch work logs for real-time updates
  Stream<List<WorkLog>> watchWorkLogsByObra(String obraId);

  /// Get a specific work log by ID
  Future<WorkLog?> getWorkLogById(String logId);

  /// Create a new work log
  Future<void> createWorkLog(WorkLog log);

  /// Update an existing work log
  Future<void> updateWorkLog(WorkLog log);

  /// Delete a work log
  Future<void> deleteWorkLog(String logId);

  /// Generate AI summary for a work log
  Future<String> generateAISummary(String logId);

  /// Search work logs by title or description
  Future<List<WorkLog>> searchWorkLogs(String obraId, String query);

  /// Get work logs by date range
  Future<List<WorkLog>> getWorkLogsByDateRange(
    String obraId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get work logs by user
  Future<List<WorkLog>> getWorkLogsByUser(String obraId, String userId);
}
