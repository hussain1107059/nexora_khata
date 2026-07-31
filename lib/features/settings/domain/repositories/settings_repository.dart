import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, String?>> getValue(String key);
  Future<Either<Failure, void>> setValue(String key, String value);
  Future<Either<Failure, Map<String, String>>> getAll();
  Future<Either<Failure, String>> getDatabasePath();
  Future<Either<Failure, bool>> exportDatabase(String destinationPath);
  Future<Either<Failure, bool>> importDatabase(String sourcePath);
}
