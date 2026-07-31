import 'package:equatable/equatable.dart';

class DashboardSummary extends Equatable {
  final double todayIncome;
  final double todayExpense;
  final double cashBalance;
  final double bankBalance;
  final double totalIncome;
  final double totalExpense;
  final List<MonthlyData> monthlyReport;
  final List<RecentTransaction> recentTransactions;

  const DashboardSummary({
    this.todayIncome = 0,
    this.todayExpense = 0,
    this.cashBalance = 0,
    this.bankBalance = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.monthlyReport = const [],
    this.recentTransactions = const [],
  });

  double get netBalance => cashBalance + bankBalance;
  double get totalBalance => totalIncome - totalExpense;

  DashboardSummary copyWith({
    double? todayIncome, double? todayExpense,
    double? cashBalance, double? bankBalance,
    double? totalIncome, double? totalExpense,
    List<MonthlyData>? monthlyReport,
    List<RecentTransaction>? recentTransactions,
  }) => DashboardSummary(
    todayIncome: todayIncome ?? this.todayIncome,
    todayExpense: todayExpense ?? this.todayExpense,
    cashBalance: cashBalance ?? this.cashBalance,
    bankBalance: bankBalance ?? this.bankBalance,
    totalIncome: totalIncome ?? this.totalIncome,
    totalExpense: totalExpense ?? this.totalExpense,
    monthlyReport: monthlyReport ?? this.monthlyReport,
    recentTransactions: recentTransactions ?? this.recentTransactions,
  );

  @override
  List<Object?> get props => [
    todayIncome, todayExpense, cashBalance, bankBalance,
    totalIncome, totalExpense, monthlyReport, recentTransactions,
  ];
}

class MonthlyData extends Equatable {
  final int month;
  final int year;
  final double income;
  final double expense;

  const MonthlyData({
    required this.month,
    required this.year,
    this.income = 0,
    this.expense = 0,
  });

  @override
  List<Object?> get props => [month, year, income, expense];
}

class RecentTransaction extends Equatable {
  final int id;
  final String type;
  final double amount;
  final String? description;
  final DateTime date;
  final int? categoryId;
  final int? customerId;
  final int? supplierId;
  final String? categoryName;
  final String? customerName;
  final String? supplierName;

  const RecentTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    required this.date,
    this.categoryId,
    this.customerId,
    this.supplierId,
    this.categoryName,
    this.customerName,
    this.supplierName,
  });

  @override
  List<Object?> get props => [
    id, type, amount, description, date, categoryId,
    customerId, supplierId, categoryName, customerName,
    supplierName,
  ];
}
