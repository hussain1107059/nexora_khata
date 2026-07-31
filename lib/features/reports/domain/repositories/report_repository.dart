import 'package:dartz/dartz.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<DailyReportItem>>> getDailyReport(String date);
  Future<Either<Failure, List<DailyReportItem>>> getWeeklyReport(String date);
  Future<Either<Failure, ReportSummary>> getWeeklySummary(String date);
  Future<Either<Failure, List<DailyReportItem>>> getMonthlyReport(int year, int month);
  Future<Either<Failure, ReportSummary>> getMonthlySummary(int year, int month);
  Future<Either<Failure, List<MonthlyReportItem>>> getYearlyReport(int year);
  Future<Either<Failure, ReportSummary>> getYearlySummary(int year);
  Future<Either<Failure, List<CategoryReportItem>>> getCategoryWiseIncome({int? year, int? month});
  Future<Either<Failure, List<CategoryReportItem>>> getCategoryWiseExpense({int? year, int? month});
  Future<Either<Failure, List<IncomeVsExpenseItem>>> getIncomeVsExpense(int year);
  Future<Either<Failure, List<CashFlowItem>>> getCashFlow(int year, int month);
  Future<Either<Failure, List<int>>> getAvailableYears();
}
