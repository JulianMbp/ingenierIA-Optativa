import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../core/models/work_log.dart';
import '../../../core/models/role.dart';
import '../../../core/models/task.dart';
import '../../../core/services/work_log_service.dart';
import '../../../core/services/task_service.dart';
import '../../../core/widgets/glass_container.dart';
import '../../auth/auth_provider.dart';
import 'generar_informe_ia_screen.dart';

class WorkLogsScreen extends ConsumerStatefulWidget {
  const WorkLogsScreen({super.key});

  @override
  ConsumerState<WorkLogsScreen> createState() => _WorkLogsScreenState();
}

class _WorkLogsScreenState extends ConsumerState<WorkLogsScreen> {
  List<WorkLog> workLogs = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWorkLogs();
  }

  Future<void> _loadWorkLogs() async {
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

      final workLogService = ref.read(workLogServiceProvider);
      final result = await workLogService.getWorkLogs(projectId);

      setState(() {
        workLogs = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading work logs: $e';
        isLoading = false;
      });
    }
  }

  bool _canCreate() {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role.type;
    // Everyone except RRHH can create work logs
    return userRole != RoleType.rrhh;
  }

  bool _canEdit(WorkLog workLog) {
    final authState = ref.read(authProvider);
    final userRole = authState.user?.role.type;
    final userId = authState.user?.id;
    
    // Admin General and Admin Obra can edit any work log
    if (userRole == RoleType.adminGeneral || userRole == RoleType.adminObra) {
      return true;
    }
    
    // Obreros can only edit their own work logs
    if (userRole == RoleType.obrero) {
      return workLog.authorId == userId.toString();
    }
    
    // SST can edit any
    return userRole == RoleType.sst;
  }

  Future<void> _showWorkLogDialog({WorkLog? workLog}) async {
    final isEdit = workLog != null;
    final descriptionController = TextEditingController(
      text: workLog?.description ?? '',
    );
    final progressController = TextEditingController(
      text: workLog?.progressPercentageInt.toString() ?? '',
    );
    DateTime selectedDate = workLog?.date ?? DateTime.now();
    List<Task> tasks = [];
    List<String> selectedTasks = [];
    bool loadingTasks = true;

    // Load project tasks
    final authState = ref.read(authProvider);
    final projectId = authState.currentProject?.id;
    if (projectId != null) {
      try {
        final taskService = ref.read(taskServiceProvider);
        tasks = await taskService.listTasks(projectId);
        loadingTasks = false;
      } catch (e) {
        loadingTasks = false;
      }
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Work Log' : 'New Work Log'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: progressController,
                  decoration: const InputDecoration(
                    labelText: 'Progress (%)',
                    suffixText: '%',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('dd/MM/yyyy').format(selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                const Divider(),
                const Text(
                  'Mark tasks as completed:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (loadingTasks)
                  const CircularProgressIndicator()
                else if (tasks.isEmpty)
                  const Text('No tasks available')
                else
                  ...tasks
                      .where((t) => !t.isCompleted)
                      .map(
                        (task) => CheckboxListTile(
                          title: Text(task.title),
                          subtitle: Text(
                            'Progress: ${task.progressPercentage}%',
                          ),
                          value: selectedTasks.contains(task.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedTasks.add(task.id);
                              } else {
                                selectedTasks.remove(task.id);
                              }
                            });
                          },
                        ),
                      )
                      .toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final progress = int.tryParse(progressController.text);
                  if (progress == null || progress < 0 || progress > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Progress must be between 0 and 100'),
                      ),
                    );
                    return;
                  }

                  final authState = ref.read(authProvider);
                  final projectId = authState.currentProject?.id;
                  final userId = authState.user?.id;

                  if (projectId == null || userId == null) return;

                  final workLogService = ref.read(workLogServiceProvider);
                  final data = {
                    'obra_id': projectId, // Keep backend field name
                    'usuario_id': userId, // Keep backend field name
                    'descripcion': descriptionController.text, // Keep backend field name
                    'avance_porcentaje': progress, // Keep backend field name
                    'fecha': selectedDate.toIso8601String().split('T').first, // Keep backend field name
                    'archivos': [], // Keep backend field name
                  };

                  if (isEdit) {
                    await workLogService.updateWorkLog(
                      projectId,
                      workLog.id,
                      data,
                    );
                  } else {
                    await workLogService.createWorkLog(projectId, data);
                  }

                  // Complete selected tasks
                  if (selectedTasks.isNotEmpty) {
                    final taskService = ref.read(taskServiceProvider);
                    for (final taskId in selectedTasks) {
                      try {
                        await taskService.completeTask(projectId, taskId);
                      } catch (e) {
                        // Continue with other tasks if one fails
                        print('Error completing task $taskId: $e');
                      }
                    }
                  }

                  if (context.mounted) {
                    Navigator.pop(context, true);
                    if (selectedTasks.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Work log saved and ${selectedTasks.length} task(s) completed',
                          ),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      _loadWorkLogs();
    }
  }

  Future<void> _deleteWorkLog(WorkLog workLog) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm deletion'),
        content: const Text('Delete this work log?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final authState = ref.read(authProvider);
        final projectId = authState.currentProject?.id;
        
        if (projectId == null) return;

        final workLogService = ref.read(workLogServiceProvider);
        await workLogService.deleteWorkLog(projectId, workLog.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Work log deleted')),
          );
        }

        _loadWorkLogs();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = _canCreate();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Logs'),
        backgroundColor: AppTheme.iosOrange,
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
                            onPressed: _loadWorkLogs,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadWorkLogs,
                      child: Column(
                        children: [
                          // Banner destacado para generar informe con IA
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.iosOrange,
                                  AppTheme.iosOrange.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.iosOrange.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Genera tu Bitácora con IA',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Crea informes profesionales automáticamente',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const GenerarInformeIaScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Generar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppTheme.iosOrange,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Work logs list
                          Expanded(
                            child: workLogs.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.description_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No work logs registered',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Create a new one or generate a report with AI',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: workLogs.length,
                                    itemBuilder: (context, index) {
                              final workLog = workLogs[index];
                              final canEdit = _canEdit(workLog);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: GlassContainer(
                                  blur: 15,
                                  opacity: 0.2,
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.all(0),
                                  child: ListTile(
                                    title: Text(
                                      DateFormat('dd/MM/yyyy').format(workLog.date),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(workLog.description),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: workLog.progressPercentageInt / 100,
                                                backgroundColor: Colors.grey.shade300,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  _getProgressColor(workLog.progressPercentageInt),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${workLog.progressPercentageInt}%',
                                              style: TextStyle(
                                                color: _getProgressColor(
                                                  workLog.progressPercentageInt,
                                                ),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (workLog.authorName != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'By: ${workLog.authorName}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: canEdit
                                        ? PopupMenuButton<String>(
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                _showWorkLogDialog(workLog: workLog);
                                              } else if (value == 'delete') {
                                                _deleteWorkLog(workLog);
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('Edit'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                            ],
                                          )
                                        : null,
                                  ),
                                ),
                              );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
      floatingActionButton: canCreate
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Larger and more visible AI button
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GenerarInformeIaScreen(),
                      ),
                    );
                  },
                  backgroundColor: AppTheme.iosOrange,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.auto_awesome, size: 28),
                  label: const Text(
                    'Generate with AI',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  elevation: 6,
                ),
                const SizedBox(height: 16),
                // Button to create manual work log
                FloatingActionButton(
                  onPressed: () => _showWorkLogDialog(),
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.iosOrange,
                  child: const Icon(Icons.add),
                  elevation: 4,
                ),
              ],
            )
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenerarInformeIaScreen(),
                  ),
                );
              },
              backgroundColor: AppTheme.iosOrange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.auto_awesome, size: 28),
              label: const Text(
                'Generate with AI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 6,
            ),
    );
  }

  Color _getProgressColor(int percentage) {
    if (percentage < 30) return Colors.red;
    if (percentage < 70) return Colors.orange;
    return Colors.green;
  }
}

