import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';

abstract class IncomeRepository {
  Future<Either<Failure, List<Income>>> getAll({
    String? search,
    String? status,
    int? categoryId,
    String? dateFrom,
    String? dateTo,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, Income?>> getById(int id);

  Future<Either<Failure, Income>> create(Income income);

  Future<Either<Failure, Income>> update(Income income);

  Future<Either<Failure, void>> delete(int id);

  Future<Either<Failure, List<Income>>> getByMonth(int year, int month);

  Future<Either<Failure, Map<String, dynamic>>> getMonthlySummary(
      int year, int month);

  Future<Either<Failure, List<Map<String, dynamic>>>> getMonthlyReport(
      int year);

  Future<Either<Failure, List<Income>>> search(String query);
}
