import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';
import 'package:nexora_khata/features/reports/domain/repositories/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return getIt<ReportRepository>();
});

final reportDateProvider = StateProvider<String?>((ref) => null);

final reportMonthProvider = StateProvider<Map<String, int>>((ref) => {
  'year': DateTime.now().year,
  'month': DateTime.now().month,
});

final reportYearProvider = StateProvider<int>((ref) => DateTime.now().year);

final reportTabProvider = StateProvider<int>((ref) => 0);

final reportCategoryToggleProvider = StateProvider<int>((ref) => 0);

final dailyReportProvider = FutureProvider.family<List<DailyReportItem>, String>((ref, date) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getDailyReport(date);
  return result.fold((l) => throw l, (r) => r);
});

final weeklyReportProvider = FutureProvider.family<List<DailyReportItem>, String>((ref, date) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getWeeklyReport(date);
  return result.fold((l) => throw l, (r) => r);
});

final weeklySummaryProvider = FutureProvider.family<ReportSummary, String>((ref, date) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getWeeklySummary(date);
  return result.fold((l) => throw l, (r) => r);
});

final monthlyReportProvider = FutureProvider.family<List<DailyReportItem>, Map<String, int>>((ref, params) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getMonthlyReport(params['year']!, params['month']!);
  return result.fold((l) => throw l, (r) => r);
});

final monthlySummaryProvider = FutureProvider.family<ReportSummary, Map<String, int>>((ref, params) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getMonthlySummary(params['year']!, params['month']!);
  return result.fold((l) => throw l, (r) => r);
});

final yearlyReportProvider = FutureProvider.family<List<MonthlyReportItem>, int>((ref, year) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getYearlyReport(year);
  return result.fold((l) => throw l, (r) => r);
});

final yearlySummaryProvider = FutureProvider.family<ReportSummary, int>((ref, year) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getYearlySummary(year);
  return result.fold((l) => throw l, (r) => r);
});

final categoryIncomeProvider = FutureProvider.family<List<CategoryReportItem>, Map<String, int?>>((ref, params) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getCategoryWiseIncome(year: params['year'], month: params['month']);
  return result.fold((l) => throw l, (r) => r);
});

final categoryExpenseProvider = FutureProvider.family<List<CategoryReportItem>, Map<String, int?>>((ref, params) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getCategoryWiseExpense(year: params['year'], month: params['month']);
  return result.fold((l) => throw l, (r) => r);
});

final incomeVsExpenseProvider = FutureProvider.family<List<IncomeVsExpenseItem>, int>((ref, year) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getIncomeVsExpense(year);
  return result.fold((l) => throw l, (r) => r);
});

final cashFlowProvider = FutureProvider.family<List<CashFlowItem>, Map<String, int>>((ref, params) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getCashFlow(params['year']!, params['month']!);
  return result.fold((l) => throw l, (r) => r);
});

final availableYearsProvider = FutureProvider<List<int>>((ref) async {
  final repo = ref.read(reportRepositoryProvider);
  final result = await repo.getAvailableYears();
  return result.fold((l) => throw l, (r) => r);
});
