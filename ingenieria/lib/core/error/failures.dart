import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, statusCode, originalError];

  @override
  String toString() => message;
}

/// Failure for server-related errors
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

/// Failure for network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'No internet connection',
    super.originalError,
  }) : super(message: message);
}

/// Failure for authentication/authorization errors
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.originalError,
  }) : super(statusCode: 400);
}

/// Failure for data not found errors
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'Data not found',
    super.originalError,
  }) : super(message: message, statusCode: 404);
}

/// Failure for cache-related errors
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.originalError,
  });
}

/// Failure for local database errors
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.originalError,
  });
}

/// Failure for permission-related errors
class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = 'Permission denied',
    super.originalError,
  }) : super(message: message, statusCode: 403);
}

/// Failure for timeout errors
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'Request timeout',
    super.originalError,
  }) : super(message: message, statusCode: 408);
}

/// Failure for unknown/unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'An unexpected error occurred',
    super.originalError,
  }) : super(message: message);
}
