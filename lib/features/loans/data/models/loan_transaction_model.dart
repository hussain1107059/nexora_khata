import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';

class LoanTransactionModel extends LoanTransaction {
  const LoanTransactionModel({
    required super.id,
    required super.businessId,
    required super.contactId,
    required super.type,
    required super.amount,
    required super.date,
    super.note,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LoanTransactionModel.fromMap(Map<String, dynamic> m) =>
      LoanTransactionModel(
        id: m['id'] as int,
        businessId: m['business_id'] as int,
        contactId: m['contact_id'] as int,
        type: m['type'] as String,
        amount: (m['amount'] as num).toDouble(),
        date: DateTime.parse(m['date'] as String),
        note: m['note'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId,
    'contact_id': contactId,
    'type': type,
    'amount': amount,
    'date': AppDateUtils.formatDate(date, format: AppDateUtils.dateFormat),
    'note': note,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
