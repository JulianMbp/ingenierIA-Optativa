import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/supabase_attendance_repository.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import 'auth_provider.dart';

/// Provider for AttendanceRepository instance
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseAttendanceRepository(supabase);
});

/// Stream provider for attendance records by obra
final attendanceStreamProvider =
    StreamProvider.autoDispose.family<List<Attendance>, String>((ref, obraId) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.watchAttendanceByObra(obraId);
});

/// Provider for current obra's attendance records
final currentObraAttendanceProvider =
    StreamProvider.autoDispose<List<Attendance>>((ref) {
  final authState = ref.watch(authProvider);
  final obraId = authState.user?.obraId;

  if (obraId == null) {
    return Stream.value([]);
  }

  return ref.watch(attendanceStreamProvider(obraId).stream);
});

/// Future provider for attendance by date
final attendanceByDateProvider = FutureProvider.autoDispose
    .family<List<Attendance>, ({String obraId, DateTime date})>((ref, params) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getAttendanceByDate(params.obraId, params.date);
});

/// Future provider for attendance statistics
final attendanceStatsProvider = FutureProvider.autoDispose.family<
    Map<String, int>,
    ({String obraId, DateTime startDate, DateTime endDate})>((ref, params) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return repository.getAttendanceStats(
    params.obraId,
    params.startDate,
    params.endDate,
  );
});

/// State for attendance operations
class AttendanceState {
  final bool isLoading;
  final String? error;
  final Attendance? selectedAttendance;
  final DateTime selectedDate;

  AttendanceState({
    this.isLoading = false,
    this.error,
    this.selectedAttendance,
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  AttendanceState copyWith({
    bool? isLoading,
    String? error,
    Attendance? selectedAttendance,
    DateTime? selectedDate,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedAttendance:
          clearSelected ? null : (selectedAttendance ?? this.selectedAttendance),
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

/// State notifier for attendance CRUD operations
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(AttendanceState());

  /// Create a new attendance record
  Future<void> createAttendance(Attendance attendance) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.createAttendance(attendance);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Update an existing attendance record
  Future<void> updateAttendance(Attendance attendance) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.updateAttendance(attendance);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Delete an attendance record
  Future<void> deleteAttendance(String attendanceId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.deleteAttendance(attendanceId);
      state = state.copyWith(isLoading: false, clearSelected: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Mark check-in
  Future<void> checkIn(String attendanceId, DateTime checkInTime) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.checkIn(attendanceId, checkInTime);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Mark check-out
  Future<void> checkOut(String attendanceId, DateTime checkOutTime) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.checkOut(attendanceId, checkOutTime);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Select an attendance record for viewing/editing
  void selectAttendance(Attendance attendance) {
    state = state.copyWith(selectedAttendance: attendance);
  }

  /// Set selected date for viewing attendance
  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for attendance state notifier
final attendanceNotifierProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return AttendanceNotifier(repository);
});
