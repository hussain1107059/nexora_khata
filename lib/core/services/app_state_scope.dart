import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/features/categories/presentation/providers/expense_category_provider.dart';
import 'package:nexora_khata/features/categories/presentation/providers/income_category_provider.dart';
import 'package:nexora_khata/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';
import 'package:nexora_khata/features/reports/presentation/providers/report_provider.dart';
import 'package:nexora_khata/features/settings/presentation/providers/backup_provider.dart';
import 'package:nexora_khata/features/settings/presentation/providers/settings_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/all_transactions_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/transfer_provider.dart';

/// Owns the single Riverpod [ProviderContainer] so the session layer can fully
/// wipe the cached in-memory state of every data provider (and thus any
/// previously loaded user data) whenever the signed-in user changes.
///
/// Keeping the container outside the widget tree lets the auth flow hard-reset
/// all user-data providers without depending on the widget layer.
///
/// History: riverpod 2.6 has no `ProviderContainer.invalidateAll`, so [clearAll]
/// invalidates each user-scoped provider explicitly. The auth state provider is
/// intentionally excluded: it is mutated directly by the logout flow.
abstract final class AppStateScope {
  AppStateScope._();

  static ProviderContainer? _container;

  static void bind(ProviderContainer container) {
    _container = container;
  }

  /// Marks every user-data provider's cached state as stale so they recompute
  /// against the currently-scoped [CurrentUserScope] on the next read. Called
  /// after logout so no in-memory data from the previous user survives.
  static void clearAll() {
    final c = _container;
    if (c == null) return;

    // Dashboard.
    c.invalidate(dashboardProvider);
    c.invalidate(dashboardRefreshProvider);

    // Income.
    c.invalidate(incomeListProvider);
    c.invalidate(incomeSearchProvider);
    c.invalidate(incomeStatusFilterProvider);
    c.invalidate(incomeCategoryFilterProvider);
    c.invalidate(incomeDateFromFilterProvider);
    c.invalidate(incomeDateToFilterProvider);
    c.invalidate(incomeFilteredListProvider);
    c.invalidate(incomeRefreshProvider);
    c.invalidate(incomeDetailProvider);
    c.invalidate(incomeFormProvider);
    c.invalidate(incomeMonthlyReportProvider);
    c.invalidate(incomeMonthlySummaryProvider);
    c.invalidate(incomeByMonthProvider);

    // Expense.
    c.invalidate(expenseListProvider);
    c.invalidate(expenseSearchProvider);
    c.invalidate(expenseStatusFilterProvider);
    c.invalidate(expenseCategoryFilterProvider);
    c.invalidate(expenseDateFromFilterProvider);
    c.invalidate(expenseDateToFilterProvider);
    c.invalidate(expenseFilteredListProvider);
    c.invalidate(expenseRefreshProvider);
    c.invalidate(expenseDetailProvider);
    c.invalidate(expenseFormProvider);
    c.invalidate(expenseMonthlyReportProvider);
    c.invalidate(expenseMonthlySummaryProvider);
    c.invalidate(expenseByMonthProvider);
    c.invalidate(expenseDailyReportProvider);
    c.invalidate(expenseDailySummaryProvider);

    // Transfers.
    c.invalidate(transferRefreshProvider);
    c.invalidate(transferAccountOptionsProvider);
    c.invalidate(transferListProvider);
    c.invalidate(transferFormProvider);

    // All-transactions aggregate.
    c.invalidate(allTxSearchProvider);
    c.invalidate(allTxStatusProvider);
    c.invalidate(allTxTypeProvider);
    c.invalidate(allTxRefreshProvider);
    c.invalidate(allTransactionsProvider);

    // Categories.
    c.invalidate(incomeCategoryListProvider);
    c.invalidate(incomeCategoryRefreshProvider);
    c.invalidate(incomeCategoryFormProvider);
    c.invalidate(expenseCategoryListProvider);
    c.invalidate(expenseCategoryRefreshProvider);
    c.invalidate(expenseCategoryFormProvider);

    // Loans.
    c.invalidate(loanRefreshProvider);
    c.invalidate(loanContactListProvider);
    c.invalidate(loanDashboardProvider);
    c.invalidate(loanContactDetailProvider);
    c.invalidate(loanTransactionsProvider);
    c.invalidate(loanContactFormProvider);
    c.invalidate(loanTransactionFormProvider);

    // Reports.
    c.invalidate(reportDateProvider);
    c.invalidate(reportMonthProvider);
    c.invalidate(reportYearProvider);
    c.invalidate(reportTabProvider);
    c.invalidate(reportCategoryToggleProvider);
    c.invalidate(dailyReportProvider);
    c.invalidate(weeklyReportProvider);
    c.invalidate(weeklySummaryProvider);
    c.invalidate(monthlyReportProvider);
    c.invalidate(monthlySummaryProvider);
    c.invalidate(yearlyReportProvider);
    c.invalidate(yearlySummaryProvider);
    c.invalidate(categoryIncomeProvider);
    c.invalidate(categoryExpenseProvider);
    c.invalidate(incomeVsExpenseProvider);
    c.invalidate(cashFlowProvider);
    c.invalidate(availableYearsProvider);

    // Backup.
    c.invalidate(backupHistoryProvider);
    c.invalidate(backupCountProvider);
    c.invalidate(backupTotalSizeProvider);
    c.invalidate(autoBackupEnabledProvider);
    c.invalidate(autoBackupFrequencyProvider);

    // Device/app preferences (reloaded from store on next read).
    c.invalidate(darkModeProvider);
    c.invalidate(localeProvider);
  }
}