import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int id;
  final int businessId;
  final int? supplierId;
  final int? cashAccountId;
  final int? bankAccountId;
  final int categoryId;
  final double amount;
  final String? description;
  final String? reference;
  final String? imagePath;
  final String? catName;
  final String? supplierName;
  final DateTime expenseDate;
  final String? paymentMethod;
  final bool isRecurring;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.businessId,
    this.supplierId,
    this.cashAccountId,
    this.bankAccountId,
    required this.categoryId,
    required this.amount,
    this.description,
    this.reference,
    this.imagePath,
    this.catName,
    this.supplierName,
    required this.expenseDate,
    this.paymentMethod,
    this.isRecurring = false,
    this.status = 'completed',
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    int? id, int? businessId, int? supplierId,
    int? cashAccountId, int? bankAccountId, int? categoryId,
    double? amount, String? description, String? reference, String? imagePath,
    String? catName, String? supplierName,
    DateTime? expenseDate, String? paymentMethod, bool? isRecurring,
    String? status, DateTime? createdAt, DateTime? updatedAt,
  }) => Expense(
    id: id ?? this.id, businessId: businessId ?? this.businessId,
    supplierId: supplierId ?? this.supplierId,
    cashAccountId: cashAccountId ?? this.cashAccountId,
    bankAccountId: bankAccountId ?? this.bankAccountId,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    reference: reference ?? this.reference,
    imagePath: imagePath ?? this.imagePath,
    catName: catName ?? this.catName,
    supplierName: supplierName ?? this.supplierName,
    expenseDate: expenseDate ?? this.expenseDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    isRecurring: isRecurring ?? this.isRecurring,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id, businessId, supplierId, cashAccountId, bankAccountId,
    categoryId, amount, description, reference, imagePath, catName, supplierName, expenseDate,
    paymentMethod, isRecurring, status, createdAt, updatedAt,
  ];
}
