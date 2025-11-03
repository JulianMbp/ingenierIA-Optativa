import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/user_roles.dart';
import '../../../core/theme/app_theme.dart';
import '../../modules/materials/materials_screen.dart';
import '../../modules/work_logs/work_logs_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

/// Main dashboard screen with role-based navigation.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final projectState = ref.watch(projectProvider);
    final user = authState.user;
    final project = projectState.selectedProject;

    if (user == null || project == null) {
      return const Scaffold(
        body: Center(
          child: Text('User or project not selected'),
        ),
      );
    }

    // Get dashboard items based on user role
    final dashboardItems = _getDashboardItems(user.role);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              user.role.displayName,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white70
                    : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Switch Project'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
              PopupMenuItem(
                child: const Text('Profile'),
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  ref.read(authProvider.notifier).logout();
                  // Navigate to login
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A2E)
                  : const Color(0xFFF0F4FF),
              Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF16213E)
                  : const Color(0xFFE8EEFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card with glassmorphism
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryColor,
                                  AppTheme.primaryColor.withOpacity(0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              child: Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                ),
                                Text(
                                  user.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),

                // Dashboard Title
                Text(
                  'Dashboard',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingMd),

                // Dashboard Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppTheme.spacingMd,
                      mainAxisSpacing: AppTheme.spacingMd,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: dashboardItems.length,
                    itemBuilder: (context, index) {
                      final item = dashboardItems[index];
                      return _DashboardCard(
                        title: item.title,
                        icon: item.icon,
                        color: item.color,
                        onTap: () => _handleNavigation(context, item.route),
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

  /// Handle navigation based on route
  void _handleNavigation(BuildContext context, String? route) {
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Feature coming soon'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    switch (route) {
      case '/materials':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MaterialsScreen()),
        );
        break;
      case '/work-logs':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const WorkLogsScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feature coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
    }
  }

  /// Get dashboard items based on user role
  List<_DashboardItem> _getDashboardItems(UserRole role) {
    switch (role) {
      case UserRole.adminGeneral:
      case UserRole.adminObra:
        return [
          _DashboardItem(
            title: 'Materials',
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
            route: '/materials',
          ),
          _DashboardItem(
            title: 'Attendance',
            icon: Icons.people_outline,
            color: Colors.green,
            route: null,
          ),
          _DashboardItem(
            title: 'Work Logs',
            icon: Icons.description_outlined,
            color: Colors.orange,
            route: '/work-logs',
          ),
          _DashboardItem(
            title: 'Safety',
            icon: Icons.health_and_safety_outlined,
            color: Colors.red,
            route: null,
          ),
          _DashboardItem(
            title: 'Reports',
            icon: Icons.assessment_outlined,
            color: Colors.purple,
            route: null,
          ),
          _DashboardItem(
            title: 'AI Assistant',
            icon: Icons.smart_toy_outlined,
            color: Colors.teal,
            route: null,
          ),
        ];

      case UserRole.encargadoArea:
        return [
          _DashboardItem(
            title: 'Materials',
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
            route: '/materials',
          ),
          _DashboardItem(
            title: 'Work Logs',
            icon: Icons.description_outlined,
            color: Colors.orange,
            route: '/work-logs',
          ),
          _DashboardItem(
            title: 'Team',
            icon: Icons.people_outline,
            color: Colors.green,
            route: null,
          ),
          _DashboardItem(
            title: 'Reports',
            icon: Icons.assessment_outlined,
            color: Colors.purple,
            route: null,
          ),
        ];

      case UserRole.obrero:
        return [
          _DashboardItem(
            title: 'Check In/Out',
            icon: Icons.access_time,
            color: Colors.green,
            route: null,
          ),
          _DashboardItem(
            title: 'My Work Logs',
            icon: Icons.description_outlined,
            color: Colors.orange,
            route: '/work-logs',
          ),
          _DashboardItem(
            title: 'Schedule',
            icon: Icons.calendar_today,
            color: Colors.blue,
            route: null,
          ),
        ];

      case UserRole.sst:
        return [
          _DashboardItem(
            title: 'Safety Incidents',
            icon: Icons.health_and_safety_outlined,
            color: Colors.red,
            route: null,
          ),
          _DashboardItem(
            title: 'Inspections',
            icon: Icons.checklist,
            color: Colors.orange,
            route: null,
          ),
          _DashboardItem(
            title: 'Reports',
            icon: Icons.assessment_outlined,
            color: Colors.purple,
            route: null,
          ),
        ];

      case UserRole.compras:
        return [
          _DashboardItem(
            title: 'Materials',
            icon: Icons.inventory_2_outlined,
            color: Colors.blue,
            route: '/materials',
          ),
          _DashboardItem(
            title: 'Orders',
            icon: Icons.shopping_cart_outlined,
            color: Colors.green,
            route: null,
          ),
          _DashboardItem(
            title: 'Suppliers',
            icon: Icons.business_outlined,
            color: Colors.orange,
            route: null,
          ),
        ];

      case UserRole.rrhh:
        return [
          _DashboardItem(
            title: 'Attendance',
            icon: Icons.people_outline,
            color: Colors.green,
            route: null,
          ),
          _DashboardItem(
            title: 'Employees',
            icon: Icons.badge_outlined,
            color: Colors.blue,
            route: null,
          ),
          _DashboardItem(
            title: 'Payroll',
            icon: Icons.payments_outlined,
            color: Colors.purple,
            route: null,
          ),
        ];

      case UserRole.consultor:
        return [
          _DashboardItem(
            title: 'Project Info',
            icon: Icons.info_outline,
            color: Colors.blue,
            route: null,
          ),
          _DashboardItem(
            title: 'Reports',
            icon: Icons.assessment_outlined,
            color: Colors.purple,
            route: null,
          ),
          _DashboardItem(
            title: 'Documents',
            icon: Icons.folder_outlined,
            color: Colors.orange,
            route: null,
          ),
        ];
    }
  }
}

/// Dashboard item model
class _DashboardItem {
  final String title;
  final IconData icon;
  final Color color;
  final String? route;

  _DashboardItem({
    required this.title,
    required this.icon,
    required this.color,
    this.route,
  });
}

/// Dashboard card widget
class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.15),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(24),
              splashColor: color.withOpacity(0.2),
              highlightColor: color.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius:
                            BorderRadius.circular(AppTheme.borderRadiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
