/// Configuración de ambiente de la aplicación
enum Environment {
  development,
  production,
}

class ApiConfig {
  // ⚠️ IMPORTANTE: Cambia esto a Environment.production para builds de producción
  static const Environment _environment = Environment.development;
  
  // URLs de backend según ambiente
  static const String _developmentUrl = 'http://localhost:3000/api/v1';
  static const String _productionUrl = 'https://ingenieria.julian-mbp.pro/api/v1'; // 🔴 URL de producción
  
  // Selecciona la URL según el ambiente
  static String get baseUrl {
    switch (_environment) {
      case Environment.development:
        return _developmentUrl;
      case Environment.production:
        return _productionUrl;
    }
  }
  
  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/auth/me';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const Duration aiReceiveTimeout = Duration(seconds: 120);
  
  // Helper para saber si estamos en desarrollo
  static bool get isDevelopment => _environment == Environment.development;
  static bool get isProduction => _environment == Environment.production;
}
