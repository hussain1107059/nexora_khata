import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transaction_datasource.dart';

abstract class TransactionRepositoryBase<T> {
  final TransactionDataSource<T> dataSource;
  TransactionRepositoryBase(this.dataSource);

  Future<Either<Failure, List<T>>> getAll({
    String? search,
    String? status,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  }) async {
    try {
      final models = await dataSource.getAll(
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

  Future<Either<Failure, T?>> getById(int id) async {
    try {
      final model = await dataSource.getById(id);
      return Right(model);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> delete(int id) async {
    try {
      await dataSource.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<T>>> getByMonth(int year, int month) async {
    try {
      final models = await dataSource.getByMonth(year, month);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getMonthlySummary(
      int year, int month) async {
    try {
      final result = await dataSource.getMonthlySummary(year, month);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<Map<String, dynamic>>>> getMonthlyReport(
      int year) async {
    try {
      final result = await dataSource.getMonthlyReport(year);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<T>>> search(String query) async {
    try {
      final models = await dataSource.search(query);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<T>>> getByDate(String date) async {
    try {
      final models = await dataSource.getByDate(date);
      return Right(models);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getDailySummary(
      String date) async {
    try {
      final result = await dataSource.getDailySummary(date);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
