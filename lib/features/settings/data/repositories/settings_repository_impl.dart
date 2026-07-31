import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/settings/data/datasources/settings_datasource.dart';
import 'package:nexora_khata/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource _dataSource;
  SettingsRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, String?>> getValue(String key) async {
    try {
      final result = await _dataSource.getValue(key);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setValue(String key, String value) async {
    try {
      await _dataSource.setValue(key, value);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getAll() async {
    try {
      final result = await _dataSource.getAll();
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getDatabasePath() async {
    try {
      final result = await _dataSource.getDatabasePath();
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> exportDatabase(String destinationPath) async {
    try {
      final result = await _dataSource.exportDatabase(destinationPath);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> importDatabase(String sourcePath) async {
    try {
      final result = await _dataSource.importDatabase(sourcePath);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
