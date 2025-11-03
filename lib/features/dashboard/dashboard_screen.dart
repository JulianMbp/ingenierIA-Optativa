import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/models/role.dart';
import '../../config/theme.dart';
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
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
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
                                user.name,
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
      ),
    );
  }

  List<ModuleItem> _getModulesForRole(RoleType role) {
    switch (role) {
      case RoleType.adminGeneral:
        return [
          ModuleItem(
            title: 'Materiales',
            icon: Icons.inventory_2_outlined,
            color: AppTheme.iosBlue,
            route: '/modules/materiales',
          ),
          ModuleItem(
            title: 'Bitácoras',
            icon: Icons.note_alt_outlined,
            color: AppTheme.iosOrange,
            route: '/modules/bitacoras',
          ),
          ModuleItem(
            title: 'Asistencias',
            icon: Icons.check_circle_outline,
            color: AppTheme.iosGreen,
            route: '/modules/asistencias',
          ),
          ModuleItem(
            title: 'Presupuestos',
            icon: Icons.attach_money_outlined,
            color: AppTheme.iosTeal,
            route: '/modules/presupuestos',
          ),
          ModuleItem(
            title: 'Documentos',
            icon: Icons.folder_outlined,
            color: AppTheme.iosPurple,
            route: '/modules/documentos',
          ),
          ModuleItem(
            title: 'Logs',
            icon: Icons.history,
            color: AppTheme.iosPink,
            route: '/modules/logs',
          ),
        ];

      case RoleType.adminObra:
        return [
          ModuleItem(
            title: 'Materiales',
            icon: Icons.inventory_2_outlined,
            color: AppTheme.iosBlue,
            route: '/modules/materiales',
          ),
          ModuleItem(
            title: 'Bitácoras',
            icon: Icons.note_alt_outlined,
            color: AppTheme.iosOrange,
            route: '/modules/bitacoras',
          ),
          ModuleItem(
            title: 'Presupuestos',
            icon: Icons.attach_money_outlined,
            color: AppTheme.iosTeal,
            route: '/modules/presupuestos',
          ),
        ];

      case RoleType.obrero:
        return [
          ModuleItem(
            title: 'Asistencias',
            icon: Icons.check_circle_outline,
            color: AppTheme.iosGreen,
            route: '/modules/asistencias',
          ),
          ModuleItem(
            title: 'Bitácoras',
            icon: Icons.note_alt_outlined,
            color: AppTheme.iosOrange,
            route: '/modules/bitacoras',
          ),
        ];

      case RoleType.rrhh:
        return [
          ModuleItem(
            title: 'Asistencias',
            icon: Icons.check_circle_outline,
            color: AppTheme.iosGreen,
            route: '/modules/asistencias',
          ),
        ];

      case RoleType.sst:
        return [
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
            route: '/modules/bitacoras',
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
