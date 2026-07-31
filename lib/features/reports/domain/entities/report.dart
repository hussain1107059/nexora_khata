import 'package:equatable/equatable.dart';

class ReportSummary extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final int totalTransactions;
  final String period;

  const ReportSummary({
    this.totalIncome = 0, this.totalExpense = 0, this.netAmount = 0,
    this.totalTransactions = 0, required this.period,
  });

  @override
  List<Object?> get props => [totalIncome, totalExpense, netAmount, totalTransactions, period];
}

class CategoryReportItem extends Equatable {
  final String category;
  final double amount;
  final double percentage;
  final int count;

  const CategoryReportItem({
    required this.category, required this.amount, required this.percentage, required this.count,
  });

  @override
  List<Object?> get props => [category, amount, percentage, count];
}

class DailyReportItem extends Equatable {
  final DateTime date;
  final double income;
  final double expense;
  final double net;

  const DailyReportItem({required this.date, this.income = 0, this.expense = 0, this.net = 0});

  @override
  List<Object?> get props => [date, income, expense, net];
}

class WeeklyReportItem extends Equatable {
  final int weekNumber;
  final int year;
  final DateTime startDate;
  final DateTime endDate;
  final double income;
  final double expense;
  final double net;

  const WeeklyReportItem({
    required this.weekNumber, required this.year, required this.startDate, required this.endDate,
    this.income = 0, this.expense = 0, this.net = 0,
  });

  @override
  List<Object?> get props => [weekNumber, year, startDate, endDate, income, expense, net];
}

class MonthlyReportItem extends Equatable {
  final int month;
  final int year;
  final double income;
  final double expense;
  final double net;

  const MonthlyReportItem({
    required this.month, required this.year, this.income = 0, this.expense = 0, this.net = 0,
  });

  @override
  List<Object?> get props => [month, year, income, expense, net];
}

class YearlyReportItem extends Equatable {
  final int year;
  final double income;
  final double expense;
  final double net;
  final int transactionCount;

  const YearlyReportItem({
    required this.year, this.income = 0, this.expense = 0, this.net = 0, this.transactionCount = 0,
  });

  @override
  List<Object?> get props => [year, income, expense, net, transactionCount];
}

class CashFlowItem extends Equatable {
  final DateTime date;
  final double cashBalance;
  final double bankBalance;
  final double totalBalance;

  const CashFlowItem({
    required this.date, this.cashBalance = 0, this.bankBalance = 0, this.totalBalance = 0,
  });

  @override
  List<Object?> get props => [date, cashBalance, bankBalance, totalBalance];
}

class IncomeVsExpenseItem extends Equatable {
  final String label;
  final double income;
  final double expense;

  const IncomeVsExpenseItem({
    required this.label, this.income = 0, this.expense = 0,
  });

  @override
  List<Object?> get props => [label, income, expense];
}
