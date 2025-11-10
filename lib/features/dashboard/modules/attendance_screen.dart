import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../core/models/attendance.dart';
import '../../../core/models/role.dart';
import '../../../core/services/attendance_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/auth_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  List<Attendance> attendances = [];
  Attendance? todayAttendance;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAttendances();
  }

  Future<void> _loadAttendances() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;

      if (projectId == null) {
        setState(() {
          errorMessage = 'No project selected';
          isLoading = false;
        });
        return;
      }

      final attendanceService = ref.read(attendanceServiceProvider);
      
      // Load today's attendance
      final today = await attendanceService.getMyAttendanceToday(projectId);
      
      // Load attendance history
      final result = await attendanceService.getAttendances(projectId);

      setState(() {
        todayAttendance = today;
        attendances = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading attendances: $e';
        isLoading = false;
      });
    }
  }

  bool _isOperario() {
    final authState = ref.read(authProvider);
    return authState.user?.role.type == RoleType.obrero;
  }

  bool _isRRHH() {
    final authState = ref.read(authProvider);
    return authState.user?.role.type == RoleType.rrhh || 
           authState.user?.role.type == RoleType.adminGeneral;
  }

  Future<void> _markAttendance(String status) async {
    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;
      final userId = authState.user?.id;

      if (projectId == null || userId == null) return;

      final attendanceService = ref.read(attendanceServiceProvider);
      final today = DateTime.now();
      final data = {
        'obra_id': projectId, // Keep backend field name
        'usuario_id': userId, // Keep backend field name
        'fecha': '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}', // Keep backend field name
        'estado': status, // Keep backend field name
        'observaciones': null, // Keep backend field name
      };

      await attendanceService.createAttendance(projectId, data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked as $status')),
        );
      }

      _loadAttendances();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking attendance: $e')),
        );
      }
    }
  }

  Widget _buildTodayAttendanceCard() {
    return GlassContainer(
      blur: 15,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.today,
                color: AppTheme.iosGreen,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'Today\'s Attendance',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (todayAttendance != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getStatusIcon(todayAttendance!.status),
                  size: 64,
                  color: _getStatusColor(todayAttendance!.status),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(todayAttendance!.status),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(todayAttendance!.status),
                      ),
                    ),
                    if (todayAttendance!.createdAt != null)
                      Text(
                        DateFormat('HH:mm').format(todayAttendance!.createdAt!),
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
            if (todayAttendance!.observations != null) ...[
              const SizedBox(height: 12),
              Text(
                'Observations: ${todayAttendance!.observations}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ] else if (_isOperario()) ...[
            const Text(
              'You haven\'t marked attendance today',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _markAttendance('presente'), // Keep backend field value
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Present'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _markAttendance('tardanza'), // Keep backend field value
                  icon: const Icon(Icons.access_time),
                  label: const Text('Late'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ] else ...[
            const Text(
              'No attendance registered',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppTheme.iosGreen,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FB),
              Color(0xFFE9ECEF),
            ],
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAttendances,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAttendances,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildTodayAttendanceCard(),
                          const SizedBox(height: 24),
                          Text(
                            'History',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          if (attendances.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text('No attendances registered'),
                              ),
                            )
                          else
                            ...attendances.map((attendance) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassContainer(
                                  blur: 15,
                                  opacity: 0.2,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    leading: Icon(
                                      _getStatusIcon(attendance.status),
                                      color: _getStatusColor(attendance.status),
                                      size: 32,
                                    ),
                                    title: Text(
                                      DateFormat('dd/MM/yyyy').format(
                                        attendance.date,
                                      ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getStatusText(attendance.status),
                                          style: TextStyle(
                                            color: _getStatusColor(
                                              attendance.status,
                                            ),
                                          ),
                                        ),
                                        if (attendance.observations != null)
                                          Text(
                                            attendance.observations!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: _isRRHH()
                                        ? IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              // TODO: Implement edit for RRHH
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'presente': // Keep backend value
        return Icons.check_circle;
      case 'tardanza': // Keep backend value
        return Icons.access_time;
      case 'ausente': // Keep backend value
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'presente': // Keep backend value
        return Colors.green;
      case 'tardanza': // Keep backend value
        return Colors.orange;
      case 'ausente': // Keep backend value
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'presente': // Keep backend value
        return 'Present';
      case 'tardanza': // Keep backend value
        return 'Late';
      case 'ausente': // Keep backend value
        return 'Absent';
      default:
        return 'Unknown';
    }
  }
}

