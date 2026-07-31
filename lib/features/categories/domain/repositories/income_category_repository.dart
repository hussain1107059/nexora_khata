import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/categories/domain/entities/income_category.dart';

abstract class IncomeCategoryRepository {
  Future<Either<Failure, List<IncomeCategory>>> getAll({String? status});

  Future<Either<Failure, IncomeCategory?>> getById(int id);

  Future<Either<Failure, IncomeCategory>> create(IncomeCategory category);

  Future<Either<Failure, IncomeCategory>> update(IncomeCategory category);

  Future<Either<Failure, void>> delete(int id);
}
