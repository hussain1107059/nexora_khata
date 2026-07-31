import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/categories/data/datasources/expense_category_datasource.dart';
import 'package:nexora_khata/features/categories/data/models/expense_category_model.dart';
import 'package:nexora_khata/features/categories/domain/entities/expense_category.dart';
import 'package:nexora_khata/features/categories/domain/repositories/expense_category_repository.dart';

class ExpenseCategoryRepositoryImpl implements ExpenseCategoryRepository {
  final ExpenseCategoryDataSource _dataSource;
  ExpenseCategoryRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<ExpenseCategory>>> getAll(
      {String? status}) async {
    try {
      final models = await _dataSource.getAll(status: status);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory?>> getById(int id) async {
    try {
      final model = await _dataSource.getById(id);
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory>> create(
      ExpenseCategory category) async {
    try {
      final model = ExpenseCategoryModel(
        id: 0,
        businessId: category.businessId,
        name: category.name,
        description: category.description,
        icon: category.icon,
        color: category.color,
        parentId: category.parentId,
        sortOrder: category.sortOrder,
        status: category.status,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
      );
      final created = await _dataSource.create(model.toMap());
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseCategory>> update(
      ExpenseCategory category) async {
    try {
      final model = ExpenseCategoryModel(
        id: category.id,
        businessId: category.businessId,
        name: category.name,
        description: category.description,
        icon: category.icon,
        color: category.color,
        parentId: category.parentId,
        sortOrder: category.sortOrder,
        status: category.status,
        createdAt: category.createdAt,
        updatedAt: category.updatedAt,
      );
      final updated =
          await _dataSource.update(category.id, model.toMap());
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await _dataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
