import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../services/nestjs_api_client.dart';
import '../../services/ollama_ai_service.dart';
import '../../services/supabase_service.dart';

/// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider for NestJS API client
final nestJsApiClientProvider = Provider<NestJsApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return NestJsApiClient(secureStorage: secureStorage);
});

/// Provider for Supabase service
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return SupabaseService(secureStorage: secureStorage);
});

/// Provider for Ollama AI service
final ollamaAiServiceProvider = Provider<OllamaAiService>((ref) {
  return OllamaAiService();
});
