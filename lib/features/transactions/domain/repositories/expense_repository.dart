import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getAll({
    String? search,
    String? status,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, Expense?>> getById(int id);

  Future<Either<Failure, Expense>> create(Expense expense);

  Future<Either<Failure, Expense>> update(Expense expense);

  Future<Either<Failure, void>> delete(int id);

  Future<Either<Failure, List<Expense>>> getByMonth(int year, int month);

  Future<Either<Failure, Map<String, dynamic>>> getMonthlySummary(
      int year, int month);

  Future<Either<Failure, List<Map<String, dynamic>>>> getMonthlyReport(
      int year);

  Future<Either<Failure, List<Expense>>> search(String query);

  Future<Either<Failure, List<Expense>>> getByDate(String date);

  Future<Either<Failure, Map<String, dynamic>>> getDailySummary(String date);
}
