import 'package:clean_architecture/domain/entities/user.dart';
import 'package:clean_architecture/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  Future<Either<String, User?>> call() async {
    return await repository.getCurrentUser();
  }
}
