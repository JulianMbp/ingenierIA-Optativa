import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../core/models/role.dart';
import '../../core/providers/project_progress_provider.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/offline_banner.dart';
import '../auth/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final modules = _getModulesForRole(user.role.type);

    return Scaffold(
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
          child: Column(
            children: [
              // Banner de estado offline
              const OfflineBanner(),
              // Contenido principal
              Expanded(
                child: CustomScrollView(
                  slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'IngenierIA',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 20),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.iosBlue,
                          AppTheme.iosTeal,
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => context.push('/profile'),
                  ),
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

              // User info
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassContainer(
                    blur: 15,
                    opacity: 0.2,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.iosBlue.withOpacity(0.2),
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.iosBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontSize: 20),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.role.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppTheme.iosBlue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Project progress bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _ProjectProgressCard(projectId: authState.currentProject?.id),
                ),
              ),

              // Modules title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Text(
                    'Módulos Disponibles',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),

              // Modules grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final module = modules[index];
                      return _ModuleCard(module: module);
                    },
                    childCount: modules.length,
                  ),
                ),
              ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ModuleItem> _getModulesForRole(RoleType role) {
    switch (role) {
      case RoleType.adminGeneral:
        return [
          ModuleItem(
            title: 'Chat con IA',
            icon: Icons.auto_awesome,
            color: AppTheme.iosOrange,
            route: '/modules/chat-ia',
          ),
          ModuleItem(
            title: 'Tareas',
            icon: Icons.task_outlined,
            color: AppTheme.iosTeal,
            route: '/modules/tasks',
          ),
          ModuleItem(
            title: 'Materiales',
            icon: Icons.inventory_2_outlined,
            color: AppTheme.iosBlue,
            route: '/modules/materials',
          ),
          ModuleItem(
            title: 'Bitácoras',
            icon: Icons.note_alt_outlined,
            color: AppTheme.iosOrange,
            route: '/modules/work-logs',
          ),
          ModuleItem(
            title: 'Asistencias',
            icon: Icons.check_circle_outline,
            color: AppTheme.iosGreen,
            route: '/modules/attendance',
          ),
          ModuleItem(
            title: 'Documentos',
            icon: Icons.folder_outlined,
            color: AppTheme.iosPink,
            route: '/modules/documentos',
          ),
          ModuleItem(
            title: 'Logs',
            icon: Icons.history,
            color: Colors.grey,
            route: '/modules/logs',
          ),
        ];

      case RoleType.adminObra:
        return [
          ModuleItem(
            title: 'Chat con IA',
            icon: Icons.auto_awesome,
            color: AppTheme.iosOrange,
            route: '/modules/chat-ia',
          ),
          ModuleItem(
            title: 'Tareas',
            icon: Icons.task_outlined,
            color: AppTheme.iosTeal,
            route: '/modules/tasks',
          ),
          ModuleItem(
            title: 'Materiales',
            icon: Icons.inventory_2_outlined,
            color: AppTheme.iosBlue,
            route: '/modules/materials',
          ),
          ModuleItem(
            title: 'Bitácoras',
            icon: Icons.note_alt_outlined,
            color: AppTheme.iosOrange,
            route: '/modules/work-logs',
          ),
        ];

      case RoleType.obrero:
        return [
          ModuleItem(
            title: 'Chat con IA',
            icon: Icons.auto_awesome,
            color: AppTheme.iosOrange,
            route: '/modules/chat-ia',
          ),
          ModuleItem(
            title: 'Asistencias',
            icon: Icons.check_circle_outline,
            color: AppTheme.iosGreen,
            route: '/modules/attendance',
          ),
          ModuleItem(
            title: 'Bitácoras',
            icon: Icons.note_alt_outlined,
            color: AppTheme.iosOrange,
            route: '/modules/work-logs',
          ),
        ];

      case RoleType.rrhh:
        return [
          ModuleItem(
            title: 'Chat con IA',
            icon: Icons.auto_awesome,
            color: AppTheme.iosOrange,
            route: '/modules/chat-ia',
          ),
          ModuleItem(
            title: 'Asistencias',
            icon: Icons.check_circle_outline,
            color: AppTheme.iosGreen,
            route: '/modules/attendance',
          ),
        ];

      case RoleType.sst:
        return [
          ModuleItem(
            title: 'Chat con IA',
            icon: Icons.auto_awesome,
            color: AppTheme.iosOrange,
            route: '/modules/chat-ia',
          ),
          ModuleItem(
            title: 'Documentos',
            icon: Icons.folder_outlined,
            color: AppTheme.iosPurple,
            route: '/modules/documentos',
          ),
          ModuleItem(
            title: 'Bitácoras',
            icon: Icons.note_alt_outlined,
            color: AppTheme.iosOrange,
            route: '/modules/work-logs',
          ),
        ];
    }
  }
}

class ModuleItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  ModuleItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}

class _ModuleCard extends StatelessWidget {
  final ModuleItem module;

  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(module.route),
      child: GlassContainer(
        blur: 15,
        opacity: 0.15,
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: module.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                module.icon,
                size: 32,
                color: module.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              module.title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Project progress bar widget
class _ProjectProgressCard extends ConsumerWidget {
  final String? projectId;

  const _ProjectProgressCard({this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to project progress changes
    final progressState = ref.watch(projectProgressProvider);
    final authState = ref.watch(authProvider);
    final currentProject = authState.currentProject;

    // Load progress when projectId changes or when widget mounts
    ref.listen<String?>(
      authProvider.select((state) => state.currentProject?.id),
      (previous, next) {
        if (previous != next && next != null) {
          // When project changes, refresh progress
          ref.read(projectProgressProvider.notifier).refresh();
        }
      },
    );

    if (currentProject == null) {
      return const SizedBox.shrink();
    }

    final progress = progressState.progress;
    final isLoading = progressState.isLoading;

    return GlassContainer(
      blur: 15,
      opacity: 0.2,
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentProject.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Overall Progress',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: progress < 30
                        ? Colors.red.withOpacity(0.2)
                        : progress < 70
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: progress < 30
                          ? Colors.red
                          : progress < 70
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: isLoading ? null : progress / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress < 30
                    ? Colors.red
                    : progress < 70
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.task_alt, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${progressState.completedTasks}/${progressState.totalTasks} tasks completed',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () async {
                  // Navigate to tasks and wait for return
                  await context.push('/modules/tasks');
                  // When returning, refresh progress
                  if (context.mounted) {
                    ref.read(projectProgressProvider.notifier).refresh();
                  }
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View tasks'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
