import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/data/datasources/income_datasource.dart';
import 'package:nexora_khata/features/transactions/data/models/income_model.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';
import 'package:nexora_khata/features/transactions/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeDataSource _dataSource;
  IncomeRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Income>>> getAll({
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
      print('[IncomeRepo] getAll failed: $e');
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Income?>> getById(int id) async {
    try {
      final model = await _dataSource.getById(id);
      return Right(model);
    } catch (e) {
      print('[IncomeRepo] getById failed: $e');
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Income>> create(Income income) async {
    try {
      final model = IncomeModel(
        id: 0,
        businessId: income.businessId,
        customerId: income.customerId,
        cashAccountId: income.cashAccountId,
        bankAccountId: income.bankAccountId,
        categoryId: income.categoryId,
        amount: income.amount,
        description: income.description,
        reference: income.reference,
        imagePath: income.imagePath,
        incomeDate: income.incomeDate,
        paymentMethod: income.paymentMethod,
        isRecurring: income.isRecurring,
        status: income.status,
        createdAt: income.createdAt,
        updatedAt: income.updatedAt,
      );
      final created = await _dataSource.create(model.toMap());
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Income>> update(Income income) async {
    try {
      final model = IncomeModel(
        id: income.id,
        businessId: income.businessId,
        customerId: income.customerId,
        cashAccountId: income.cashAccountId,
        bankAccountId: income.bankAccountId,
        categoryId: income.categoryId,
        amount: income.amount,
        description: income.description,
        reference: income.reference,
        imagePath: income.imagePath,
        incomeDate: income.incomeDate,
        paymentMethod: income.paymentMethod,
        isRecurring: income.isRecurring,
        status: income.status,
        createdAt: income.createdAt,
        updatedAt: income.updatedAt,
      );
      final updated = await _dataSource.update(income.id, model.toMap());
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
  Future<Either<Failure, List<Income>>> getByMonth(
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
  Future<Either<Failure, List<Income>>> search(String query) async {
    try {
      final models = await _dataSource.search(query);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
