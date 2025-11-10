import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../core/models/project.dart';
import '../../core/services/task_service.dart';
import '../../core/widgets/glass_container.dart';
import '../auth/auth_provider.dart';

class SelectProjectScreen extends ConsumerStatefulWidget {
  const SelectProjectScreen({super.key});

  @override
  ConsumerState<SelectProjectScreen> createState() => _SelectProjectScreenState();
}

class _SelectProjectScreenState extends ConsumerState<SelectProjectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState.myProjects.isEmpty) {
        ref.read(authProvider.notifier).loadMyProjects();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final projects = authState.myProjects;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Project'),
        backgroundColor: AppTheme.iosBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
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
          child: authState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : projects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.business_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'You have no assigned projects',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(authProvider.notifier).loadMyProjects();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select a project',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You have access to ${projects.length} project${projects.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: ListView.builder(
                              itemCount: projects.length,
                              itemBuilder: (context, index) {
                                final project = projects[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _ProjectCard(project: project),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}

// Project card widget with progress
class _ProjectCard extends ConsumerStatefulWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  ConsumerState<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends ConsumerState<_ProjectCard> {
  double _progress = 0.0;
  bool _loadingProgress = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final taskService = ref.read(taskServiceProvider);
      final tasks = await taskService.listTasks(widget.project.id);

      if (tasks.isEmpty) {
        setState(() {
          _progress = 0.0;
          _loadingProgress = false;
        });
        return;
      }

      final sum = tasks.fold<int>(0, (sum, t) => sum + t.progressPercentage);
      setState(() {
        _progress = sum / tasks.length;
        _loadingProgress = false;
      });
    } catch (e) {
      setState(() {
        _progress = 0.0;
        _loadingProgress = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final success =
            await ref.read(authProvider.notifier).selectProject(widget.project.id);

        if (success && context.mounted) {
          context.go('/dashboard');
        }
      },
      child: GlassContainer(
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
                  Icons.business,
                  color: AppTheme.iosBlue,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.project.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.iosBlue,
                ),
              ],
            ),
            if (widget.project.description != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.project.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            if (widget.project.address != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.project.address!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Progress bar
            Row(
              children: [
                const Icon(
                  Icons.show_chart,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Progress:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                if (_loadingProgress)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    '${_progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _progress < 30
                          ? Colors.red
                          : _progress < 70
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _loadingProgress ? null : _progress / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _progress < 30
                      ? Colors.red
                      : _progress < 70
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (widget.project.status != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.project.isActive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.project.status!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: widget.project.isActive ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (widget.project.roleName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.iosBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.project.roleName!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.iosBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

