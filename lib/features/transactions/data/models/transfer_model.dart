import '../../domain/entities/transfer.dart';

class TransferModel extends Transfer {
  const TransferModel({
    required super.id, required super.businessId,
    required super.fromType, super.fromCashAccountId,
    super.fromBankAccountId, required super.toType,
    super.toCashAccountId, super.toBankAccountId,
    required super.amount, super.description, super.reference,
    required super.transferDate, super.fee, super.status,
    required super.createdAt, required super.updatedAt,
  });

  factory TransferModel.fromMap(Map<String, dynamic> m) => TransferModel(
    id: m['id'] as int,
    businessId: m['business_id'] as int,
    fromType: m['from_type'] as String,
    fromCashAccountId: m['from_cash_account_id'] as int?,
    fromBankAccountId: m['from_bank_account_id'] as int?,
    toType: m['to_type'] as String,
    toCashAccountId: m['to_cash_account_id'] as int?,
    toBankAccountId: m['to_bank_account_id'] as int?,
    amount: (m['amount'] as num).toDouble(),
    description: m['description'] as String?,
    reference: m['reference'] as String?,
    transferDate: DateTime.parse(m['transfer_date'] as String),
    fee: (m['fee'] as num?)?.toDouble() ?? 0,
    status: m['status'] as String? ?? 'completed',
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId, 'from_type': fromType,
    'from_cash_account_id': fromCashAccountId,
    'from_bank_account_id': fromBankAccountId,
    'to_type': toType,
    'to_cash_account_id': toCashAccountId,
    'to_bank_account_id': toBankAccountId,
    'amount': amount, 'description': description,
    'reference': reference,
    'transfer_date': transferDate.toIso8601String(),
    'fee': fee, 'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
