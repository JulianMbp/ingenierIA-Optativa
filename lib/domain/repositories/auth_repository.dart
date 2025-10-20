import 'package:clean_architecture/domain/entities/role.dart';
import 'package:clean_architecture/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  // Authentication methods
  Future<Either<String, User>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<String, User>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? roleId,
  });

  Future<Either<String, void>> signOut();

  Future<Either<String, User?>> getCurrentUser();

  Future<Either<String, void>> resetPassword(String email);

  // User profile methods
  Future<Either<String, User>> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? roleId,
  });

  Future<Either<String, List<Role>>> getRoles();

  // Session management
  Stream<User?> get authStateChanges;
}
