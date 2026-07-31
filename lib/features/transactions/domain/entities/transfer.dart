import 'package:equatable/equatable.dart';

class Transfer extends Equatable {
  final int id;
  final int businessId;
  final String fromType;
  final int? fromCashAccountId;
  final int? fromBankAccountId;
  final String toType;
  final int? toCashAccountId;
  final int? toBankAccountId;
  final double amount;
  final String? description;
  final String? reference;
  final DateTime transferDate;
  final double fee;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transfer({
    required this.id,
    required this.businessId,
    required this.fromType,
    this.fromCashAccountId,
    this.fromBankAccountId,
    required this.toType,
    this.toCashAccountId,
    this.toBankAccountId,
    required this.amount,
    this.description,
    this.reference,
    required this.transferDate,
    this.fee = 0,
    this.status = 'completed',
    required this.createdAt,
    required this.updatedAt,
  });

  Transfer copyWith({
    int? id, int? businessId, String? fromType,
    int? fromCashAccountId, int? fromBankAccountId,
    String? toType, int? toCashAccountId, int? toBankAccountId,
    double? amount, String? description, String? reference,
    DateTime? transferDate, double? fee, String? status,
    DateTime? createdAt, DateTime? updatedAt,
  }) => Transfer(
    id: id ?? this.id, businessId: businessId ?? this.businessId,
    fromType: fromType ?? this.fromType,
    fromCashAccountId: fromCashAccountId ?? this.fromCashAccountId,
    fromBankAccountId: fromBankAccountId ?? this.fromBankAccountId,
    toType: toType ?? this.toType,
    toCashAccountId: toCashAccountId ?? this.toCashAccountId,
    toBankAccountId: toBankAccountId ?? this.toBankAccountId,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    reference: reference ?? this.reference,
    transferDate: transferDate ?? this.transferDate,
    fee: fee ?? this.fee, status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id, businessId, fromType, fromCashAccountId, fromBankAccountId,
    toType, toCashAccountId, toBankAccountId, amount, description,
    reference, transferDate, fee, status, createdAt, updatedAt,
  ];
}
