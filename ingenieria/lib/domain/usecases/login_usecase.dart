import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Validate input
    if (email.isEmpty || !email.contains('@')) {
      return const Left(
        ValidationFailure(message: 'Invalid email address'),
      );
    }

    if (password.isEmpty || password.length < 6) {
      return const Left(
        ValidationFailure(message: 'Password must be at least 6 characters'),
      );
    }

    return await repository.login(email: email, password: password);
  }
}
