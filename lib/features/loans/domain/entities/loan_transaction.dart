import 'package:equatable/equatable.dart';

class LoanTransaction extends Equatable {
  final int id;
  final int businessId;
  final int contactId;
  final String type;
  final double amount;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoanTransaction({
    required this.id,
    required this.businessId,
    required this.contactId,
    required this.type,
    required this.amount,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  LoanTransaction copyWith({
    int? id,
    int? businessId,
    int? contactId,
    String? type,
    double? amount,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LoanTransaction(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    contactId: contactId ?? this.contactId,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  bool get isBorrow => type == 'borrow';

  bool get isLend => type == 'lend';

  @override
  List<Object?> get props => [
    id,
    businessId,
    contactId,
    type,
    amount,
    date,
    note,
    createdAt,
    updatedAt,
  ];
}
