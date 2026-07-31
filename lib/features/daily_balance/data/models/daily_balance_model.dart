import '../../domain/entities/daily_balance.dart';

class DailyBalanceModel extends DailyBalance {
  const DailyBalanceModel({
    required super.id, required super.businessId, required super.date,
    super.totalCash, super.totalBank, super.totalIncome,
    super.totalExpense, super.netBalance, super.previousDayBalance,
    super.notes, super.status,
    required super.createdAt, required super.updatedAt,
  });

  factory DailyBalanceModel.fromMap(Map<String, dynamic> m) =>
      DailyBalanceModel(
        id: m['id'] as int,
        businessId: m['business_id'] as int,
        date: DateTime.parse(m['date'] as String),
        totalCash: (m['total_cash'] as num?)?.toDouble() ?? 0,
        totalBank: (m['total_bank'] as num?)?.toDouble() ?? 0,
        totalIncome: (m['total_income'] as num?)?.toDouble() ?? 0,
        totalExpense: (m['total_expense'] as num?)?.toDouble() ?? 0,
        netBalance: (m['net_balance'] as num?)?.toDouble() ?? 0,
        previousDayBalance:
            (m['previous_day_balance'] as num?)?.toDouble() ?? 0,
        notes: m['notes'] as String?,
        status: m['status'] as String? ?? 'active',
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId,
    'date': date.toIso8601String().substring(0, 10),
    'total_cash': totalCash, 'total_bank': totalBank,
    'total_income': totalIncome, 'total_expense': totalExpense,
    'net_balance': netBalance,
    'previous_day_balance': previousDayBalance,
    'notes': notes, 'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
