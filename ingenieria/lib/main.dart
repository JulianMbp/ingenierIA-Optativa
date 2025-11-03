import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/api_config.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/view/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await ApiConfig.load();

  // Initialize Supabase
  await Supabase.initialize(
    url: ApiConfig.supabaseUrl,
    anonKey: ApiConfig.supabaseAnonKey,
  );

  runApp(
    const ProviderScope(
      child: IngenierIAApp(),
    ),
  );
}

/// Main application widget
class IngenierIAApp extends StatelessWidget {
  const IngenierIAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IngenierIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
