import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Logout the current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User>> getCurrentUser();

  /// Verify if token is valid
  Future<Either<Failure, bool>> verifyToken();

  /// Refresh authentication token
  Future<Either<Failure, String>> refreshToken();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}
