import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser?>> getCurrentUser();
  Future<Either<Failure, AuthUser>> login(String username, String password);
  Future<Either<Failure, AuthUser>> signup({
    required String name,
    required String username,
    required String password,
    String? email,
    String? phone,
    String? securityQuestion,
    String? securityAnswer,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isUsernameTaken(String username);
  Future<Either<Failure, String?>> getSecurityQuestion(String email);
  Future<Either<Failure, bool>> verifySecurityAnswer(
      String email, String answer);
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
  });
}
