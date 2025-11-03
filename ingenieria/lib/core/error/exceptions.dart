/// Base class for all exceptions in the application.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;

  AppException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Exception for server errors
class ServerException extends AppException {
  ServerException({
    required super.message,
    super.statusCode,
    super.originalException,
  });
}

/// Exception for network errors
class NetworkException extends AppException {
  NetworkException({
    String message = 'No internet connection',
    super.originalException,
  }) : super(message: message);
}

/// Exception for authentication errors
class AuthException extends AppException {
  AuthException({
    required super.message,
    super.statusCode,
    super.originalException,
  });
}

/// Exception for validation errors
class ValidationException extends AppException {
  ValidationException({
    required super.message,
    super.originalException,
  }) : super(statusCode: 400);
}

/// Exception for cache errors
class CacheException extends AppException {
  CacheException({
    required super.message,
    super.originalException,
  });
}

/// Exception for database errors
class DatabaseException extends AppException {
  DatabaseException({
    required super.message,
    super.originalException,
  });
}

/// Exception for timeout errors
class TimeoutException extends AppException {
  TimeoutException({
    String message = 'Request timeout',
    super.originalException,
  }) : super(message: message, statusCode: 408);
}
