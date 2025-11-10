import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/material.dart' as material_model;
import '../../../core/models/task.dart';
import '../../../core/providers/project_progress_provider.dart';
import '../../../core/services/material_service.dart';
import '../../../core/services/task_service.dart';
import '../../../core/widgets/materials_progress_widget.dart';
import '../../../core/widgets/offline_banner.dart';
import '../../auth/auth_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  List<Task> _tasks = [];
  List<material_model.Material> _materials = [];
  bool _isLoading = true;
  bool _isLoadingMaterials = false;
  String _statusFilter = 'all';
  double _generalProgress = 0.0;
  bool _loadingProgress = false;
  Map<String, dynamic> _projectStats = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadMaterials();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;

      if (projectId == null) {
        throw Exception('No project selected');
      }

      final taskService = ref.read(taskServiceProvider);
      final tasks = await taskService.listTasks(projectId);

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
      
      // Calculate progress directly from loaded tasks (without calling API again)
      _calculateProgressFromTasks(tasks);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        String errorMessage = 'Error loading tasks';
        if (e is DioException) {
          if (e.response != null) {
            final responseData = e.response!.data;
            if (responseData is Map) {
              errorMessage = responseData['message']?.toString() ??
                  responseData['error']?.toString() ??
                  'Error loading tasks';
            } else {
              errorMessage = 'Error loading tasks: ${e.response?.statusCode}';
            }
          } else {
            errorMessage = 'Connection error: ${e.message}';
          }
        } else {
          errorMessage = 'Error: $e';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  Future<void> _loadMaterials() async {
    setState(() => _isLoadingMaterials = true);
    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;

      if (projectId == null) {
        setState(() => _isLoadingMaterials = false);
        return;
      }

      final materialService = ref.read(materialServiceProvider);
      final materials = await materialService.getMaterials(projectId);

      setState(() {
        _materials = materials;
        _isLoadingMaterials = false;
      });
    } catch (e) {
      setState(() => _isLoadingMaterials = false);
      // Silently fail for materials - don't show error to user
      // Materials progress is optional information
    }
  }

  /// Calculate project progress directly from already loaded tasks
  /// Avoids additional API calls
  /// Also updates shared provider so dashboard updates automatically
  void _calculateProgressFromTasks(List<Task> tasks) {
    // Update shared provider so dashboard updates automatically
    ref.read(projectProgressProvider.notifier).updateFromTasks(tasks);
    
    if (tasks.isEmpty) {
      setState(() {
        _generalProgress = 0.0;
        _projectStats = {
          'progress': 0.0,
          'totalTasks': 0,
          'completedTasks': 0,
          'inProgressTasks': 0,
          'pendingTasks': 0,
        };
        _loadingProgress = false;
      });
      return;
    }

    final completed = tasks.where((t) => t.isCompleted).length;
    final inProgress = tasks.where((t) => t.isInProgress).length;
    final pending = tasks.where((t) => t.isPending).length;
    
    // Calculate sum of progresses
    final sum = tasks.fold<double>(
      0.0, 
      (sum, t) => sum + t.progressPercentage.toDouble(),
    );
    
    final progress = sum / tasks.length;

    setState(() {
      _generalProgress = progress;
      _projectStats = {
        'progress': progress,
        'totalTasks': tasks.length,
        'completedTasks': completed,
        'inProgressTasks': inProgress,
        'pendingTasks': pending,
      };
      _loadingProgress = false;
    });
  }

  List<Task> get _filteredTasks {
    if (_statusFilter == 'all') return _tasks;
    return _tasks.where((t) => t.status == _statusFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadTasks();
              _loadMaterials();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de estado offline
          const OfflineBanner(),
          // General progress bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Overall Project Progress',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    _loadingProgress
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '${_generalProgress.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                  ],
                ),
                if (_projectStats.isNotEmpty && !_loadingProgress) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${_projectStats['totalTasks'] ?? 0} | '
                    'Completed: ${_projectStats['completedTasks'] ?? 0} | '
                    'In Progress: ${_projectStats['inProgressTasks'] ?? 0} | '
                    'Pending: ${_projectStats['pendingTasks'] ?? 0}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _loadingProgress ? null : _generalProgress / 100,
                    minHeight: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _generalProgress < 30
                          ? Colors.red
                          : _generalProgress < 70
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Materials progress widget
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: MaterialsProgressWidget(
              materials: _materials,
              isLoading: _isLoadingMaterials,
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('All')),
                ButtonSegment(value: 'pendiente', label: Text('Pending')),
                ButtonSegment(value: 'en_progreso', label: Text('In Progress')),
                ButtonSegment(value: 'completada', label: Text('Completed')),
              ],
              selected: {_statusFilter},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _statusFilter = newSelection.first;
                });
              },
            ),
          ),

          // Task list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await _loadTasks();
                          await _loadMaterials();
                        },
                        child: ListView.builder(
                          itemCount: _filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = _filteredTasks[index];
                            return _TaskCard(
                              task: task,
                              onTap: () => _showTaskDetail(task),
                              onToggleComplete: () =>
                                  _toggleCompleteTask(task),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskForm,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTaskDetail(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TaskDetailSheet(
        task: task,
        onEdit: () {
          Navigator.pop(context);
          _showTaskForm(task: task);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteTask(task);
        },
        onUpdate: _loadTasks,
      ),
    );
  }

  void _showTaskForm({Task? task}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TaskFormSheet(
        task: task,
        onSaved: _loadTasks,
      ),
    );
  }

  Future<void> _toggleCompleteTask(Task task) async {
    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;
      if (projectId == null) return;

      final taskService = ref.read(taskServiceProvider);

      if (task.isCompleted) {
        // If task is completed, unmark it and keep current progress
        // but change status to 'en_progreso'
        // If progress was 100%, reduce it to 90% to indicate something is missing
        final newProgress = task.progressPercentage >= 100 
            ? 90 
            : task.progressPercentage;
        
        await taskService.updateTask(projectId, task.id, {
          'estado': 'en_progreso', // Keep backend field value
          'avance_porcentaje': newProgress, // Keep backend field name
        });
      } else {
        // If task is not completed, mark it as completed
        await taskService.completeTask(projectId, task.id);
      }

      // Reload tasks (this will also recalculate progress automatically)
      _loadTasks();
      // Also reload materials to keep progress updated
      _loadMaterials();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;
      if (projectId == null) return;

      final taskService = ref.read(taskServiceProvider);
      await taskService.deleteTask(projectId, task.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted')),
        );
      }
      _loadTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }
}

// Task card widget
class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final Color priorityColor = task.priority == 'alta'
        ? Colors.red
        : task.priority == 'media'
            ? Colors.orange
            : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: task.isCompleted,
                    onChanged: (_) => onToggleComplete(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                        ),
                        if (task.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task.priorityDisplay,
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: task.progressPercentage / 100,
                  minHeight: 6,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    task.assignedTo?.fullName ?? 'Unassigned',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (task.dueDate != null) ...[
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(task.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Details sheet
class _TaskDetailSheet extends ConsumerWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUpdate;

  const _TaskDetailSheet({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              _buildDetailRow(context, 'Status', task.statusDisplay),
              _buildDetailRow(context, 'Priority', task.priorityDisplay),
              _buildDetailRow(
                context,
                'Progress',
                '${task.progressPercentage}%',
              ),
              if (task.description != null)
                _buildDetailRow(context, 'Description', task.description!),
              if (task.assignedTo != null)
                _buildDetailRow(
                  context,
                  'Assigned to',
                  task.assignedTo!.fullName,
                ),
              if (task.startDate != null)
                _buildDetailRow(
                  context,
                  'Start Date',
                  DateFormat('dd/MM/yyyy').format(task.startDate!),
                ),
              if (task.dueDate != null)
                _buildDetailRow(
                  context,
                  'Due Date',
                  DateFormat('dd/MM/yyyy').format(task.dueDate!),
                ),
              if (task.notes != null)
                _buildDetailRow(context, 'Notes', task.notes!),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}

// Form sheet
class _TaskFormSheet extends ConsumerStatefulWidget {
  final Task? task;
  final VoidCallback onSaved;

  const _TaskFormSheet({
    this.task,
    required this.onSaved,
  });

  @override
  ConsumerState<_TaskFormSheet> createState() =>
      _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<_TaskFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  String _status = 'pendiente';
  String _priority = 'media';
  int _progress = 0;
  DateTime? _startDate;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title);
    _descriptionController =
        TextEditingController(text: widget.task?.description);
    _notesController = TextEditingController(text: widget.task?.notes);
    _status = widget.task?.status ?? 'pendiente';
    _priority = widget.task?.priority ?? 'media';
    _progress = widget.task?.progressPercentage ?? 0;
    _startDate = widget.task?.startDate;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.task == null ? 'New Task' : 'Edit Task',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'baja', child: Text('Low')),
                    DropdownMenuItem(value: 'media', child: Text('Medium')),
                    DropdownMenuItem(value: 'alta', child: Text('High')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _priority = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'pendiente', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'en_progreso', child: Text('In Progress')),
                    DropdownMenuItem(
                        value: 'completada', child: Text('Completed')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 16),
                Text('Progress: $_progress%'),
                Slider(
                  value: _progress.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '$_progress%',
                  onChanged: (value) {
                    setState(() => _progress = value.toInt());
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(_startDate != null
                      ? DateFormat('dd/MM/yyyy').format(_startDate!)
                      : 'Not set'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => _startDate = date);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(_dueDate != null
                      ? DateFormat('dd/MM/yyyy').format(_dueDate!)
                      : 'Not set'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authState = ref.read(authProvider);
      final projectId = authState.currentProject?.id;
      final userId = authState.user?.id;
      
      if (projectId == null) return;
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not authenticated')),
          );
        }
        return;
      }

      final taskService = ref.read(taskServiceProvider);

      // Prepare data according to format expected by backend
      final data = <String, dynamic>{
        'titulo': _titleController.text.trim(), // Keep backend field name
        'prioridad': _priority, // Keep backend field name
        'estado': _status, // Keep backend field name
        'asignado_a_id': userId, // Keep backend field name
        'avance_porcentaje': _progress, // Keep backend field name
      };

      // Optional fields
      if (_descriptionController.text.trim().isNotEmpty) {
        data['descripcion'] = _descriptionController.text.trim(); // Keep backend field name
      }
      if (_notesController.text.trim().isNotEmpty) {
        data['notas'] = _notesController.text.trim(); // Keep backend field name
      }
      if (_startDate != null) {
        data['fecha_inicio'] = _startDate!.toIso8601String().split('T')[0]; // Keep backend field name
      }
      if (_dueDate != null) {
        // Backend expects 'fecha_limite' when creating/updating
        data['fecha_limite'] =
            _dueDate!.toIso8601String().split('T')[0]; // Keep backend field name
      }

      // Debug: print data to be sent
      print('Data to send: $data');

      if (widget.task == null) {
        // Create new task
        await taskService.createTask(projectId, data);
      } else {
        // Update existing task
        // When updating, some fields may have different names
        final updateData = <String, dynamic>{
          'titulo': _titleController.text.trim(), // Keep backend field name
          'prioridad': _priority, // Keep backend field name
          'estado': _status, // Keep backend field name
          'avance_porcentaje': _progress, // Keep backend field name
        };
        
        if (_descriptionController.text.trim().isNotEmpty) {
          updateData['descripcion'] = _descriptionController.text.trim(); // Keep backend field name
        }
        if (_notesController.text.trim().isNotEmpty) {
          updateData['notas'] = _notesController.text.trim(); // Keep backend field name
        }
        if (_startDate != null) {
          updateData['fecha_inicio'] = _startDate!.toIso8601String().split('T')[0]; // Keep backend field name
        }
        if (_dueDate != null) {
          updateData['fecha_limite'] =
              _dueDate!.toIso8601String().split('T')[0]; // Keep backend field name
        }
        
        await taskService.updateTask(projectId, widget.task!.id, updateData);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.task == null
                ? 'Task created'
                : 'Task updated'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Extract more detailed error message
        String errorMessage = 'Unknown error';
        
        if (e is DioException) {
          if (e.response != null) {
            // Server responded with an error
            final responseData = e.response!.data;
            if (responseData is Map) {
              // Try to extract error message from server
              errorMessage = responseData['message']?.toString() ??
                  responseData['error']?.toString() ??
                  responseData.toString();
            } else {
              errorMessage = responseData?.toString() ?? e.message ?? 'Unknown error';
            }
          } else {
            errorMessage = e.message ?? 'Connection error';
          }
        } else {
          errorMessage = e.toString();
        }
        
        print('Error saving task: $e');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
