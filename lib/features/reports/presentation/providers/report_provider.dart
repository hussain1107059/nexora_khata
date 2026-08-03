import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';
import 'package:nexora_khata/features/reports/domain/repositories/report_repository.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';

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

class CustomReportFilter {
  final String from;
  final String to;
  final String? type;
  final int? incomeCategoryId;
  final int? expenseCategoryId;

  const CustomReportFilter({
    required this.from,
    required this.to,
    this.type,
    this.incomeCategoryId,
    this.expenseCategoryId,
  });
}

class CustomReportData {
  final List<TransactionEntry> entries;
  final ReportSummary summary;

  const CustomReportData({required this.entries, required this.summary});
}

final customReportFilterProvider = StateProvider<CustomReportFilter?>((ref) => null);

final customReportProvider = FutureProvider<CustomReportData>((ref) async {
  final filter = ref.watch(customReportFilterProvider);
  if (filter == null) {
    return const CustomReportData(
      entries: [],
      summary: ReportSummary(period: ''),
    );
  }

  final includeIncome = filter.type == null || filter.type == 'income';
  final includeExpense = filter.type == null || filter.type == 'expense';
  final includeLoan = filter.type == null || filter.type == 'loan';

  final incomeRepo = ref.read(incomeRepositoryProvider);
  final expenseRepo = ref.read(expenseRepositoryProvider);
  final loanRepo = ref.read(loanRepositoryProvider);

  final entries = <TransactionEntry>[];
  var incomeTotal = 0.0;
  var expenseTotal = 0.0;

  if (includeIncome) {
    final result = await incomeRepo.getAll(
      dateFrom: filter.from,
      dateTo: filter.to,
      categoryId: filter.incomeCategoryId,
    );
    final incomes = result.fold((l) => throw l, (r) => r);
    incomeTotal += incomes.fold<double>(0, (s, i) => s + i.amount);
    for (final inc in incomes) {
      entries.add(TransactionEntry(
        type: 'income',
        id: inc.id,
        amount: inc.amount,
        description: inc.description,
        date: inc.incomeDate,
        categoryName: inc.catName,
        status: inc.status,
      ));
    }
  }

  if (includeExpense) {
    final result = await expenseRepo.getAll(
      dateFrom: filter.from,
      dateTo: filter.to,
      categoryId: filter.expenseCategoryId,
    );
    final expenses = result.fold((l) => throw l, (r) => r);
    expenseTotal += expenses.fold<double>(0, (s, e) => s + e.amount);
    for (final exp in expenses) {
      entries.add(TransactionEntry(
        type: 'expense',
        id: exp.id,
        amount: exp.amount,
        description: exp.description,
        date: exp.expenseDate,
        categoryName: exp.catName,
        status: exp.status,
      ));
    }
  }

  if (includeLoan) {
    final contactsResult = await loanRepo.getContacts();
    final contacts = contactsResult.fold((l) => throw l, (r) => r);
    final contactNames = {for (final c in contacts) c.id: c.name};

    final txnsResult = await loanRepo.getAllTransactions();
    final txns = txnsResult.fold((l) => throw l, (r) => r);
    for (final txn in txns) {
      final dateStr =
          AppDateUtils.formatDate(txn.date, format: AppDateUtils.dateFormat);
      if (dateStr.compareTo(filter.from) < 0 ||
          dateStr.compareTo(filter.to) > 0) {
        continue;
      }
      if (txn.isBorrow || txn.repaysLend) {
        incomeTotal += txn.amount;
      } else {
        expenseTotal += txn.amount;
      }
      entries.add(TransactionEntry(
        type: 'loan',
        id: txn.id,
        amount: txn.amount,
        description: txn.note,
        date: txn.date,
        categoryName: contactNames[txn.contactId],
        status: 'completed',
        contactName: contactNames[txn.contactId],
        contactId: txn.contactId,
        loanType: txn.isRepay ? 'repay' : (txn.isBorrow ? 'borrow' : 'lend'),
      ));
    }
  }

  entries.sort((a, b) {
    final d = b.date.compareTo(a.date);
    if (d != 0) return d;
    return b.id.compareTo(a.id);
  });

  final summary = ReportSummary(
    totalIncome: incomeTotal,
    totalExpense: expenseTotal,
    netAmount: incomeTotal - expenseTotal,
    totalTransactions: entries.length,
    period: _formatCustomPeriod(filter.from, filter.to),
  );

  return CustomReportData(entries: entries, summary: summary);
});

String _formatCustomPeriod(String from, String to) {
  final fromDate = DateTime.tryParse(from);
  final toDate = DateTime.tryParse(to);
  if (fromDate == null || toDate == null) return '$from - $to';
  return '${AppDateUtils.formatDate(fromDate)} to ${AppDateUtils.formatDate(toDate)}';
}
