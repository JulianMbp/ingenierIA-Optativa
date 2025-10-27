import 'package:clean_architecture/presentation/bloc/auth/auth_bloc.dart';
import 'package:clean_architecture/presentation/bloc/auth/auth_event.dart';
import 'package:clean_architecture/presentation/bloc/auth/auth_state.dart';
import 'package:clean_architecture/presentation/pages/login_page.dart';
import 'package:clean_architecture/presentation/theme/app_theme.dart';
import 'package:clean_architecture/presentation/widgets/animated_scale_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1200;
    final isTablet = size.width > 600 && size.width <= 1200;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return CustomScrollView(
                slivers: [
                  // AppBar moderno
                  _buildModernAppBar(context, state, isDesktop),
                  
                  // Contenido
                  SliverPadding(
                    padding: EdgeInsets.all(isDesktop ? 32 : 16),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tarjeta de bienvenida
                          _buildWelcomeCard(state, isDesktop),
                          const SizedBox(height: 32),
                          
                          // Título de módulos
                          Text(
                            'Módulos Disponibles',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Grid de módulos
                          _buildModulesGrid(context, isDesktop, isTablet),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return const Center(
                child: Text('Error al cargar la información'),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, AuthAuthenticated state, bool isDesktop) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: EdgeInsets.only(
            left: isDesktop ? 32 : 16,
            bottom: 16,
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppTheme.radiusSm,
                ),
                child: const Icon(
                  Icons.construction,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Gestión de Obra',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppTheme.radiusLg,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                context.read<AuthBloc>().add(AuthSignOutRequested());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.user.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (state.user.roleName != null)
                      Text(
                        state.user.roleName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    const Divider(),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 20, color: AppTheme.primaryColor),
                    const SizedBox(width: 12),
                    const Text('Mi Perfil'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppTheme.errorColor),
                    const SizedBox(width: 12),
                    const Text('Cerrar Sesión'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(AuthAuthenticated state, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.radiusLg,
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: AppTheme.radiusLg,
              boxShadow: AppTheme.shadowMd,
            ),
            child: const Icon(
              Icons.waving_hand,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Bienvenido de nuevo!',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.user.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (state.user.roleName != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: AppTheme.radiusSm,
                    ),
                    child: Text(
                      state.user.roleName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModulesGrid(BuildContext context, bool isDesktop, bool isTablet) {
    final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.1 : 1.0,
      children: [
        _buildModuleCard(
          context,
          icon: Icons.business,
          title: 'Proyectos',
          subtitle: 'Gestionar obras',
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
          ),
          onTap: () => _showComingSoon(context, 'Gestión de Proyectos'),
        ),
        _buildModuleCard(
          context,
          icon: Icons.people,
          title: 'Trabajadores',
          subtitle: 'Control de personal',
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          ),
          onTap: () => _showComingSoon(context, 'Gestión de Trabajadores'),
        ),
        _buildModuleCard(
          context,
          icon: Icons.access_time,
          title: 'Asistencia',
          subtitle: 'Control diario',
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
          ),
          onTap: () => _showComingSoon(context, 'Control de Asistencia'),
        ),
        _buildModuleCard(
          context,
          icon: Icons.inventory_2,
          title: 'Materiales',
          subtitle: 'Stock y pedidos',
          gradient: const LinearGradient(
            colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
          ),
          onTap: () => _showComingSoon(context, 'Gestión de Materiales'),
        ),
        _buildModuleCard(
          context,
          icon: Icons.attach_money,
          title: 'Presupuestos',
          subtitle: 'Control de costos',
          gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          ),
          onTap: () => _showComingSoon(context, 'Control de Presupuestos'),
        ),
        _buildModuleCard(
          context,
          icon: Icons.security,
          title: 'Seguridad',
          subtitle: 'ATS y reportes',
          gradient: const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          ),
          onTap: () => _showComingSoon(context, 'Seguridad y Salud'),
        ),
        _buildModuleCard(
          context,
          icon: Icons.bar_chart,
          title: 'Reportes',
          subtitle: 'Análisis y métricas',
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
          ),
          onTap: () => _showComingSoon(context, 'Reportes y Análisis'),
        ),
        _buildModuleCard(
          context,
          icon: Icons.settings,
          title: 'Configuración',
          subtitle: 'Ajustes del sistema',
          gradient: const LinearGradient(
            colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
          ),
          onTap: () => _showComingSoon(context, 'Configuración'),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppTheme.radiusLg,
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: AppTheme.radiusMd,
                boxShadow: AppTheme.shadowMd,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String module) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusLg,
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: AppTheme.radiusSm,
              ),
              child: const Icon(
                Icons.rocket_launch,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Próximamente'),
          ],
        ),
        content: Text(
          'El módulo "$module" estará disponible en una próxima actualización.',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
