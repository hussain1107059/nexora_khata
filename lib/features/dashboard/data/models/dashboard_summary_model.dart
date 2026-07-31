import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    super.todayIncome, super.todayExpense,
    super.cashBalance, super.bankBalance,
    super.totalIncome, super.totalExpense,
    super.monthlyReport, super.recentTransactions,
  });

  factory DashboardSummaryModel.fromEntity(DashboardSummary e) =>
      DashboardSummaryModel(
        todayIncome: e.todayIncome, todayExpense: e.todayExpense,
        cashBalance: e.cashBalance, bankBalance: e.bankBalance,
        totalIncome: e.totalIncome, totalExpense: e.totalExpense,
        monthlyReport: e.monthlyReport,
        recentTransactions: e.recentTransactions,
      );
}
