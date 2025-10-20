import 'package:clean_architecture/domain/entities/user.dart';
import 'package:clean_architecture/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<Either<String, User>> call({
    required String email,
    required String password,
  }) async {
    // Validaciones básicas
    if (email.isEmpty) {
      return const Left('El email es requerido');
    }
    
    if (password.isEmpty) {
      return const Left('La contraseña es requerida');
    }

    if (!_isValidEmail(email)) {
      return const Left('El formato del email no es válido');
    }

    if (password.length < 6) {
      return const Left('La contraseña debe tener al menos 6 caracteres');
    }

    return await repository.signInWithEmail(
      email: email,
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
