import 'package:clean_architecture/presentation/bloc/auth/auth_bloc.dart';
import 'package:clean_architecture/presentation/bloc/auth/auth_event.dart';
import 'package:clean_architecture/presentation/bloc/auth/auth_state.dart';
import 'package:clean_architecture/presentation/pages/home_page.dart';
import 'package:clean_architecture/presentation/pages/register_page.dart';
import 'package:clean_architecture/presentation/theme/app_theme.dart';
import 'package:clean_architecture/presentation/widgets/gradient_button.dart';
import 'package:clean_architecture/presentation/widgets/modern_text_field.dart';
import 'package:clean_architecture/presentation/widgets/animated_scale_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;
    final isTablet = size.width > 600 && size.width <= 900;

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMd,
                ),
              ),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomePage()),
            );
          }
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF3F4F6),
                Color(0xFFE5E7EB),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 0 : 24,
                  vertical: 24,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: isDesktop
                      ? _buildDesktopLayout()
                      : _buildMobileLayout(isTablet),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusXl,
        ),
        child: Row(
          children: [
            // Panel izquierdo - Branding
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(60),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: AppTheme.radiusLg,
                      ),
                      child: const Icon(
                        Icons.construction,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Gestión de Obra',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Administra tus proyectos de construcción de manera eficiente y profesional',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildFeatureItem(
                      'Control total de trabajadores y asistencia',
                      Icons.people_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      'Gestión de materiales e inventario',
                      Icons.inventory_2_outlined,
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      'Seguimiento de presupuestos en tiempo real',
                      Icons.attach_money,
                    ),
                  ],
                ),
              ),
            ),
            // Panel derecho - Formulario
            Expanded(
              flex: 4,
              child: Container(
                padding: const EdgeInsets.all(60),
                child: _buildLoginForm(true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(bool isTablet) {
    return Container(
      constraints: BoxConstraints(maxWidth: isTablet ? 500 : 400),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusXl,
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 40 : 28),
          child: _buildLoginForm(false),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isDesktop) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDesktop) ...[
            // Logo para móvil
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: AppTheme.radiusLg,
                boxShadow: AppTheme.shadowMd,
              ),
              child: const Icon(
                Icons.construction,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Título
          Text(
            isDesktop ? 'Bienvenido' : 'Gestión de Obra',
            style: TextStyle(
              fontSize: isDesktop ? 32 : 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inicia sesión para continuar',
            style: TextStyle(
              fontSize: isDesktop ? 16 : 15,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: isDesktop ? 40 : 32),
          
          // Campo de email
          ModernTextField(
            controller: _emailController,
            label: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El email es requerido';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Ingresa un email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Campo de contraseña
          ModernTextField(
            controller: _passwordController,
            label: 'Contraseña',
            prefixIcon: Icons.lock_outlined,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < 6) {
                return 'La contraseña debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Olvidaste tu contraseña
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          const SizedBox(height: 24),
          
          // Botón de login
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return GradientButton(
                text: 'Iniciar Sesión',
                icon: Icons.login,
                isLoading: state is AuthLoading,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthBloc>().add(
                      AuthSignInRequested(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                      ),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 24),
          
          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey.shade300)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'o',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey.shade300)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Botón de registro
          AnimatedScaleButton(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 1.5,
                ),
                borderRadius: AppTheme.radiusMd,
              ),
              child: const Center(
                child: Text(
                  'Crear Nueva Cuenta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: AppTheme.radiusSm,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusLg,
        ),
        title: const Text(
          'Recuperar Contraseña',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ingresa tu email para recibir un enlace de recuperación:',
            ),
            const SizedBox(height: 20),
            ModernTextField(
              controller: emailController,
              label: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El email es requerido';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Ingresa un email válido';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthPasswordResetSent) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Se ha enviado un enlace de recuperación a ${state.email}',
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.accentColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppTheme.radiusMd,
                    ),
                  ),
                );
              }
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state is AuthLoading
                      ? null
                      : () {
                          if (emailController.text.isNotEmpty) {
                            context.read<AuthBloc>().add(
                              AuthPasswordResetRequested(
                                emailController.text.trim(),
                              ),
                            );
                          }
                        },
                  child: state is AuthLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Enviar'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
