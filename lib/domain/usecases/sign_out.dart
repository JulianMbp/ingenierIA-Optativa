import 'package:clean_architecture/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignOut {
  final AuthRepository repository;

  SignOut(this.repository);

  Future<Either<String, void>> call() async {
    return await repository.signOut();
  }
}
