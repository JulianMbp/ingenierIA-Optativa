import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/router.dart';
import 'config/theme.dart';
import 'core/services/sync_service.dart';

void main() {
  runApp(
    const ProviderScope(
      child: IngenieriaApp(),
    ),
  );
}

class IngenieriaApp extends ConsumerStatefulWidget {
  const IngenieriaApp({super.key});

  @override
  ConsumerState<IngenieriaApp> createState() => _IngenieriaAppState();
}

class _IngenieriaAppState extends ConsumerState<IngenieriaApp> {
  @override
  void initState() {
    super.initState();
    // Inicializar servicio de sincronización después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncServiceProvider).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'IngenierIA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
