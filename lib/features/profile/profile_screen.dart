import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../core/widgets/glass_container.dart';
import '../auth/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppTheme.iosBlue,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile header
                GlassContainer(
                  blur: 15,
                  opacity: 0.2,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.iosBlue.withOpacity(0.2),
                        child: Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.iosBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.fullName,
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.iosBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.iosBlue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // User info
                GlassContainer(
                  blur: 15,
                  opacity: 0.2,
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Personal',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 20),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Correo',
                        value: user.email,
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'ID',
                        value: user.id.toString(),
                      ),
                      const SizedBox(height: 16),
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'Descripción',
                        value: user.role.descripcion ?? 'Sin descripción',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                GlassContainer(
                  blur: 15,
                  opacity: 0.2,
                  borderRadius: BorderRadius.circular(20),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.refresh,
                          color: AppTheme.iosBlue,
                        ),
                        title: const Text('Actualizar información'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await ref.read(authProvider.notifier).refreshUser();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Información actualizada'),
                              ),
                            );
                          }
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: AppTheme.iosRed,
                        ),
                        title: const Text(
                          'Cerrar sesión',
                          style: TextStyle(color: AppTheme.iosRed),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await ref.read(authProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                      ),
                    ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppTheme.iosBlue,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.black.withOpacity(0.6)),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
