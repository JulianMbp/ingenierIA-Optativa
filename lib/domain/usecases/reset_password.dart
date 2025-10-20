import 'package:clean_architecture/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<Either<String, void>> call(String email) async {
    // Validaciones básicas
    if (email.isEmpty) {
      return const Left('El email es requerido');
    }

    if (!_isValidEmail(email)) {
      return const Left('El formato del email no es válido');
    }

    return await repository.resetPassword(email);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
