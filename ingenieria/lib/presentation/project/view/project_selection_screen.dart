import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/project.dart';
import '../../dashboard/view/dashboard_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';

/// Screen for selecting a project/obra to manage.
class ProjectSelectionScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>>? obras;
  final String? email;
  final String? password;

  const ProjectSelectionScreen({
    super.key,
    this.obras,
    this.email,
    this.password,
  });

  @override
  ConsumerState<ProjectSelectionScreen> createState() =>
      _ProjectSelectionScreenState();
}

class _ProjectSelectionScreenState
    extends ConsumerState<ProjectSelectionScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load projects when screen is initialized (only if obras not provided)
    if (widget.obras == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(projectProvider.notifier).loadProjects();
      });
    }
  }

  Future<void> _selectObra(
    String obraId,
    String obraName,
    String? obraAddress,
  ) async {
    if (widget.email == null || widget.password == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Re-login with selected obra to get JWT with obra_id
      final authNotifier = ref.read(authProvider.notifier);
      final success = await authNotifier.loginWithObra(
        widget.email!,
        widget.password!,
        obraId,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (success) {
          // Create Project entity from selected obra
          final project = Project(
            id: obraId,
            name: obraName,
            description: '', // Backend doesn't provide this yet
            address: obraAddress ?? 'No address',
            status: 'active',
            startDate: DateTime.now(), // Backend doesn't provide this yet
            createdAt: DateTime.now(),
          );

          // Set selected project in projectProvider
          ref.read(projectProvider.notifier).selectProject(project);

          // Navigate to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const DashboardScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to select project. Please try again.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use provided obras if available, otherwise use projectState
    final displayObras = widget.obras;
    final projectState = widget.obras == null ? ref.watch(projectProvider) : null;

    final isLoading = _isLoading || (projectState?.isLoading ?? false);
    final error = projectState?.error;
    final obrasList = displayObras ?? projectState?.projects.map((p) => {
      'id': p.id,
      'nombre': p.name,
      'direccion': p.address,
    }).toList() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Project'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authNotifier = ref.read(authProvider.notifier);
              await authNotifier.logout();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        'Error: $error',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(projectProvider.notifier).loadProjects();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : obrasList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 64,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(
                            'No projects available',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      itemCount: obrasList.length,
                      itemBuilder: (context, index) {
                        final obra = obrasList[index];
                        final obraId = obra['id']?.toString() ?? '';
                        final obraName = obra['nombre']?.toString() ?? 'Unnamed Project';
                        final obraAddress = obra['direccion']?.toString() ?? 'No address';

                        return Card(
                          margin: const EdgeInsets.only(
                            bottom: AppTheme.spacingMd,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(
                              AppTheme.spacingMd,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                obraName.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              obraName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: AppTheme.spacingXs),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        obraAddress,
                                        style: TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              if (widget.email != null && widget.password != null) {
                                // Re-login with selected obra
                                _selectObra(obraId, obraName, obraAddress);
                              } else {
                                // Navigate directly to dashboard
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
