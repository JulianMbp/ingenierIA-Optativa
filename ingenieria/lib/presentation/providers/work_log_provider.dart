import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/supabase_work_log_repository.dart';
import '../../domain/entities/work_log.dart';
import '../../domain/repositories/work_log_repository.dart';
import 'auth_provider.dart';

/// Provider for WorkLogRepository instance
final workLogRepositoryProvider = Provider<WorkLogRepository>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseWorkLogRepository(supabase);
});

/// Stream provider for work logs by obra
final workLogsStreamProvider =
    StreamProvider.autoDispose.family<List<WorkLog>, String>((ref, obraId) {
  final repository = ref.watch(workLogRepositoryProvider);
  return repository.watchWorkLogsByObra(obraId);
});

/// Provider for current obra's work logs
final currentObraWorkLogsProvider =
    StreamProvider.autoDispose<List<WorkLog>>((ref) {
  final authState = ref.watch(authProvider);
  final obraId = authState.user?.obraId;

  if (obraId == null) {
    return Stream.value([]);
  }

  return ref.watch(workLogsStreamProvider(obraId).stream);
});

/// State for work log operations
class WorkLogState {
  final bool isLoading;
  final String? error;
  final WorkLog? selectedLog;
  final bool isGeneratingAI;

  const WorkLogState({
    this.isLoading = false,
    this.error,
    this.selectedLog,
    this.isGeneratingAI = false,
  });

  WorkLogState copyWith({
    bool? isLoading,
    String? error,
    WorkLog? selectedLog,
    bool? isGeneratingAI,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return WorkLogState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedLog: clearSelected ? null : (selectedLog ?? this.selectedLog),
      isGeneratingAI: isGeneratingAI ?? this.isGeneratingAI,
    );
  }
}

/// State notifier for work log CRUD operations
class WorkLogNotifier extends StateNotifier<WorkLogState> {
  final WorkLogRepository _repository;

  WorkLogNotifier(this._repository) : super(const WorkLogState());

  /// Create a new work log
  Future<void> createWorkLog(WorkLog log) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.createWorkLog(log);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update an existing work log
  Future<void> updateWorkLog(WorkLog log) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateWorkLog(log);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete a work log
  Future<void> deleteWorkLog(String logId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteWorkLog(logId);
      state = state.copyWith(isLoading: false, clearSelected: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Generate AI summary for a work log
  Future<String> generateAISummary(String logId) async {
    state = state.copyWith(isGeneratingAI: true, clearError: true);
    try {
      final summary = await _repository.generateAISummary(logId);
      state = state.copyWith(isGeneratingAI: false);
      return summary;
    } catch (e) {
      state = state.copyWith(
        isGeneratingAI: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Select a work log for viewing/editing
  void selectLog(WorkLog log) {
    state = state.copyWith(selectedLog: log);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for work log state notifier
final workLogNotifierProvider =
    StateNotifierProvider<WorkLogNotifier, WorkLogState>((ref) {
  final repository = ref.watch(workLogRepositoryProvider);
  return WorkLogNotifier(repository);
});

/// Future provider for searching work logs
final searchWorkLogsProvider = FutureProvider.autoDispose
    .family<List<WorkLog>, ({String obraId, String query})>((ref, params) {
  final repository = ref.watch(workLogRepositoryProvider);
  return repository.searchWorkLogs(params.obraId, params.query);
});

/// Future provider for work logs by date range
final workLogsByDateRangeProvider = FutureProvider.autoDispose.family<
    List<WorkLog>,
    ({String obraId, DateTime startDate, DateTime endDate})>((ref, params) {
  final repository = ref.watch(workLogRepositoryProvider);
  return repository.getWorkLogsByDateRange(
    params.obraId,
    params.startDate,
    params.endDate,
  );
});
