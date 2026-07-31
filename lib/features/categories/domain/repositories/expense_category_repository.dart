import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/categories/domain/entities/expense_category.dart';

abstract class ExpenseCategoryRepository {
  Future<Either<Failure, List<ExpenseCategory>>> getAll({String? status});

  Future<Either<Failure, ExpenseCategory?>> getById(int id);

  Future<Either<Failure, ExpenseCategory>> create(ExpenseCategory category);

  Future<Either<Failure, ExpenseCategory>> update(ExpenseCategory category);

  Future<Either<Failure, void>> delete(int id);
}
