import 'package:equatable/equatable.dart';

class DailyBalance extends Equatable {
  final int id;
  final int businessId;
  final DateTime date;
  final double totalCash;
  final double totalBank;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final double previousDayBalance;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DailyBalance({
    required this.id,
    required this.businessId,
    required this.date,
    this.totalCash = 0,
    this.totalBank = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.netBalance = 0,
    this.previousDayBalance = 0,
    this.notes,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  double get todayChange => netBalance - previousDayBalance;

  @override
  List<Object?> get props => [
    id, businessId, date, totalCash, totalBank, totalIncome,
    totalExpense, netBalance, previousDayBalance, notes,
    status, createdAt, updatedAt,
  ];
}
