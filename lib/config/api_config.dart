class ApiConfig {
  static const String baseUrl = 'https://ingenieria.julian-mbp.pro/api/v1';
  static const String loginEndpoint = '/auth/login';
  static const String profileEndpoint = '/auth/me';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  static const Duration aiReceiveTimeout = Duration(seconds: 120);
}
