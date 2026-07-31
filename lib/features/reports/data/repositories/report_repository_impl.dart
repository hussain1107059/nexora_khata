import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/reports/data/datasources/report_datasource.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';
import 'package:nexora_khata/features/reports/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportDataSource _dataSource;
  ReportRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<DailyReportItem>>> getDailyReport(String date) async {
    try {
      final result = await _dataSource.getDailyReport(date);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyReportItem>>> getWeeklyReport(String date) async {
    try {
      final result = await _dataSource.getWeeklyReport(date);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportSummary>> getWeeklySummary(String date) async {
    try {
      final result = await _dataSource.getWeeklySummary(date);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DailyReportItem>>> getMonthlyReport(int year, int month) async {
    try {
      final result = await _dataSource.getMonthlyReport(year, month);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportSummary>> getMonthlySummary(int year, int month) async {
    try {
      final result = await _dataSource.getMonthlySummary(year, month);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MonthlyReportItem>>> getYearlyReport(int year) async {
    try {
      final result = await _dataSource.getYearlyReport(year);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportSummary>> getYearlySummary(int year) async {
    try {
      final result = await _dataSource.getYearlySummary(year);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryReportItem>>> getCategoryWiseIncome({int? year, int? month}) async {
    try {
      final result = await _dataSource.getCategoryWiseIncome(year: year, month: month);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryReportItem>>> getCategoryWiseExpense({int? year, int? month}) async {
    try {
      final result = await _dataSource.getCategoryWiseExpense(year: year, month: month);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<IncomeVsExpenseItem>>> getIncomeVsExpense(int year) async {
    try {
      final result = await _dataSource.getIncomeVsExpense(year);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CashFlowItem>>> getCashFlow(int year, int month) async {
    try {
      final result = await _dataSource.getCashFlow(year, month);
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getAvailableYears() async {
    try {
      final result = await _dataSource.getAvailableYears();
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
