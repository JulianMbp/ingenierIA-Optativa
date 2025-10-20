import 'package:clean_architecture/domain/entities/user.dart';
import 'package:clean_architecture/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignUp {
  final AuthRepository repository;

  SignUp(this.repository);

  Future<Either<String, User>> call({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? roleId,
  }) async {
    // Validaciones básicas
    if (email.isEmpty) {
      return const Left('El email es requerido');
    }
    
    if (password.isEmpty) {
      return const Left('La contraseña es requerida');
    }

    if (fullName.isEmpty) {
      return const Left('El nombre completo es requerido');
    }

    if (!_isValidEmail(email)) {
      return const Left('El formato del email no es válido');
    }

    if (password.length < 6) {
      return const Left('La contraseña debe tener al menos 6 caracteres');
    }

    if (fullName.length < 2) {
      return const Left('El nombre debe tener al menos 2 caracteres');
    }

    return await repository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
      roleId: roleId,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
