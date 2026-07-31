import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/data/datasources/expense_datasource.dart';
import 'package:nexora_khata/features/transactions/data/models/expense_model.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';
import 'package:nexora_khata/features/transactions/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDataSource _dataSource;
  ExpenseRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Expense>>> getAll({
    String? search,
    String? status,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await _dataSource.getAll(
        search: search,
        status: status,
        categoryId: categoryId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        limit: limit,
        offset: offset,
      );
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense?>> getById(int id) async {
    try {
      final model = await _dataSource.getById(id);
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> create(Expense expense) async {
    try {
      final model = ExpenseModel(
        id: 0,
        businessId: expense.businessId,
        supplierId: expense.supplierId,
        cashAccountId: expense.cashAccountId,
        bankAccountId: expense.bankAccountId,
        categoryId: expense.categoryId,
        amount: expense.amount,
        description: expense.description,
        reference: expense.reference,
        imagePath: expense.imagePath,
        expenseDate: expense.expenseDate,
        paymentMethod: expense.paymentMethod,
        isRecurring: expense.isRecurring,
        status: expense.status,
        createdAt: expense.createdAt,
        updatedAt: expense.updatedAt,
      );
      final created = await _dataSource.create(model.toMap());
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> update(Expense expense) async {
    try {
      final model = ExpenseModel(
        id: expense.id,
        businessId: expense.businessId,
        supplierId: expense.supplierId,
        cashAccountId: expense.cashAccountId,
        bankAccountId: expense.bankAccountId,
        categoryId: expense.categoryId,
        amount: expense.amount,
        description: expense.description,
        reference: expense.reference,
        imagePath: expense.imagePath,
        expenseDate: expense.expenseDate,
        paymentMethod: expense.paymentMethod,
        isRecurring: expense.isRecurring,
        status: expense.status,
        createdAt: expense.createdAt,
        updatedAt: expense.updatedAt,
      );
      final updated = await _dataSource.update(expense.id, model.toMap());
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

  @override
  Future<Either<Failure, List<Expense>>> getByMonth(
      int year, int month) async {
    try {
      final models = await _dataSource.getByMonth(year, month);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getMonthlySummary(
      int year, int month) async {
    try {
      final result = await _dataSource.getMonthlySummary(year, month);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getMonthlyReport(
      int year) async {
    try {
      final result = await _dataSource.getMonthlyReport(year);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> search(String query) async {
    try {
      final models = await _dataSource.search(query);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getByDate(String date) async {
    try {
      final models = await _dataSource.getByDate(date);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDailySummary(
      String date) async {
    try {
      final result = await _dataSource.getDailySummary(date);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
