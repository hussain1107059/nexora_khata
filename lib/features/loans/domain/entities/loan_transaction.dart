import 'package:equatable/equatable.dart';

class LoanTransaction extends Equatable {
  final int id;
  final int businessId;
  final int contactId;
  final String type;
  final String? repayType;
  final double amount;
  final DateTime date;
  final String? note;
  final String? paymentMethod;
  final int? cashAccountId;
  final int? bankAccountId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoanTransaction({
    required this.id,
    required this.businessId,
    required this.contactId,
    required this.type,
    this.repayType,
    required this.amount,
    required this.date,
    this.note,
    this.paymentMethod,
    this.cashAccountId,
    this.bankAccountId,
    required this.createdAt,
    required this.updatedAt,
  });

  LoanTransaction copyWith({
    int? id,
    int? businessId,
    int? contactId,
    String? type,
    String? repayType,
    double? amount,
    DateTime? date,
    String? note,
    String? paymentMethod,
    int? cashAccountId,
    int? bankAccountId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LoanTransaction(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    contactId: contactId ?? this.contactId,
    type: type ?? this.type,
    repayType: repayType ?? this.repayType,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note ?? this.note,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    cashAccountId: cashAccountId ?? this.cashAccountId,
    bankAccountId: bankAccountId ?? this.bankAccountId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  bool get isBorrow => type == 'borrow';

  bool get isLend => type == 'lend';

  bool get isRepay => type == 'repay';

  bool get repaysBorrow => isRepay && repayType == 'borrow';

  bool get repaysLend => isRepay && repayType == 'lend';

  bool get isCash => paymentMethod == null || paymentMethod == 'cash';

  @override
  List<Object?> get props => [
    id,
    businessId,
    contactId,
    type,
    repayType,
    amount,
    date,
    note,
    paymentMethod,
    cashAccountId,
    bankAccountId,
    createdAt,
    updatedAt,
  ];
}
