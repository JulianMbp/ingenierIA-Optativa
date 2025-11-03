import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for all API endpoints and URLs used in the application.
/// Values are loaded from the `.env` file at runtime.
class ApiConfig {
  ApiConfig._();

  /// Loads environment variables.
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  /// Base URL for NestJS authentication microservice.
  static String get nestJsBaseUrl => dotenv.env['NESTJS_BASE_URL'] ?? '';

  /// Base URL for Supabase project.
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';

  /// Supabase anonymous key.
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// Base URL for Ollama AI service (local).
  static String get ollamaBaseUrl => dotenv.env['OLLAMA_BASE_URL'] ?? '';

  /// Connection timeout duration.
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// Receive timeout duration.
  static const Duration receiveTimeout = Duration(seconds: 30);

  // -----------------------------
  // NestJS Endpoints
  // -----------------------------
  
  /// Login inicial con email/password (sin obra)
  static const String emailLoginEndpoint = '/auth/email/login';
  
  /// Login con obra seleccionada (segundo paso)
  static const String ingenieriaLoginEndpoint = '/auth/ingenieria/login';
  
  /// Refresh token endpoint
  static const String refreshTokenEndpoint = '/auth/refresh';
  
  /// Logout endpoint
  static const String logoutEndpoint = '/auth/logout';
  
  /// Get current authenticated user info
  static const String getMeEndpoint = '/auth/me';
  
  /// Obras endpoints
  static const String obrasEndpoint = '/obras';
  static const String asignarUsuarioObraEndpoint = '/obras/asignar-usuario';
  
  /// Users endpoints
  static const String usersEndpoint = '/users';

  // -----------------------------
  // Ollama Endpoints
  // -----------------------------
  static const String ollamaGenerateEndpoint = '/api/generate';
  static const String ollamaEmbeddingsEndpoint = '/api/embeddings';
}
