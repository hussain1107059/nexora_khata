import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/auth/data/datasources/auth_datasource.dart';
import 'package:nexora_khata/features/auth/domain/entities/auth_user.dart';
import 'package:nexora_khata/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final sessionId = await _dataSource.getSessionUserId();
      if (sessionId == null) return const Right(null);
      final lastActive = await _dataSource.getSessionLastActive();
      if (lastActive == null ||
          DateTime.now().difference(lastActive) > AuthDataSource.sessionMaxAge) {
        await _dataSource.clearSession();
        return const Right(null);
      }
      final user = await _dataSource.findById(sessionId);
      if (user == null) {
        await _dataSource.clearSession();
        return const Right(null);
      }
      await _dataSource.updateSessionActivity();
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> login(String username, String password) async {
    try {
      final usernameTrim = username.trim();
      final user = await _dataSource.findByUsernameOrEmail(usernameTrim, usernameTrim);
      if (user == null) {
        return const Left(NotFoundFailure(message: 'User not found'));
      }
      final hash = await _dataSource.getPasswordHash(user.id);
      if (hash == null || hash.isEmpty) {
        return const Left(NotFoundFailure(message: 'User has no password'));
      }
      final salt = hash.split(':').first;
      final expected = hash.split(':').last;
      final actual = _dataSource.hashPassword(password, salt);
      if (actual != expected) {
        return const Left(ValidationFailure(message: 'Invalid credentials'));
      }
      await _dataSource.touchLogin(user.id);
      await _dataSource.saveSession(user.id);
      await _dataSource.claimLegacyData(user.id);
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signup({
    required String name,
    required String username,
    required String password,
    String? email,
    String? phone,
  }) async {
    try {
      final usernameTrim = username.trim();
      if (await _dataSource.isUsernameTaken(usernameTrim)) {
        return const Left(ValidationFailure(message: 'Username already taken'));
      }
      final salt = _dataSource.generateSalt();
      final hash = _dataSource.hashPassword(password, salt);
      final user = await _dataSource.create(
        name: name.trim(),
        username: usernameTrim,
        passwordHash: '$salt:$hash',
        email: email?.trim(),
        phone: phone?.trim(),
      );
      await _dataSource.saveSession(user.id);
      await _dataSource.claimLegacyData(user.id);
      return Right(user);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _dataSource.clearSession();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isUsernameTaken(String username) async {
    try {
      return Right(await _dataSource.isUsernameTaken(username.trim()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
