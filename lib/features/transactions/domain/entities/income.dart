import 'package:equatable/equatable.dart';

class Income extends Equatable {
  final int id;
  final int businessId;
  final int? customerId;
  final int? cashAccountId;
  final int? bankAccountId;
  final int categoryId;
  final double amount;
  final String? description;
  final String? reference;
  final String? imagePath;
  final String? catName;
  final String? customerName;
  final DateTime incomeDate;
  final String? paymentMethod;
  final bool isRecurring;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Income({
    required this.id,
    required this.businessId,
    this.customerId,
    this.cashAccountId,
    this.bankAccountId,
    required this.categoryId,
    required this.amount,
    this.description,
    this.reference,
    this.imagePath,
    this.catName,
    this.customerName,
    required this.incomeDate,
    this.paymentMethod,
    this.isRecurring = false,
    this.status = 'completed',
    required this.createdAt,
    required this.updatedAt,
  });

  Income copyWith({
    int? id, int? businessId, int? customerId,
    int? cashAccountId, int? bankAccountId, int? categoryId,
    double? amount, String? description, String? reference, String? imagePath,
    String? catName, String? customerName,
    DateTime? incomeDate, String? paymentMethod, bool? isRecurring,
    String? status, DateTime? createdAt, DateTime? updatedAt,
  }) => Income(
    id: id ?? this.id, businessId: businessId ?? this.businessId,
    customerId: customerId ?? this.customerId,
    cashAccountId: cashAccountId ?? this.cashAccountId,
    bankAccountId: bankAccountId ?? this.bankAccountId,
    categoryId: categoryId ?? this.categoryId,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    reference: reference ?? this.reference,
    imagePath: imagePath ?? this.imagePath,
    catName: catName ?? this.catName,
    customerName: customerName ?? this.customerName,
    incomeDate: incomeDate ?? this.incomeDate,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    isRecurring: isRecurring ?? this.isRecurring,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id, businessId, customerId, cashAccountId, bankAccountId,
    categoryId, amount, description, reference, imagePath, catName, customerName, incomeDate,
    paymentMethod, isRecurring, status, createdAt, updatedAt,
  ];
}
