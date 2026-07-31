import '../../domain/entities/income.dart';

class IncomeModel extends Income {
  const IncomeModel({
    required super.id, required super.businessId,
    super.customerId, super.cashAccountId, super.bankAccountId,
    required super.categoryId, required super.amount,
    super.description, super.reference, super.imagePath, super.catName, super.customerName,
    required super.incomeDate, super.paymentMethod, super.isRecurring, super.status,
    required super.createdAt, required super.updatedAt,
  });

  factory IncomeModel.fromMap(Map<String, dynamic> m) => IncomeModel(
    id: m['id'] as int,
    businessId: m['business_id'] as int,
    customerId: m['customer_id'] as int?,
    cashAccountId: m['cash_account_id'] as int?,
    bankAccountId: m['bank_account_id'] as int?,
    categoryId: m['category_id'] as int,
    amount: (m['amount'] as num).toDouble(),
    description: m['description'] as String?,
    reference: m['reference'] as String?,
    imagePath: m['image_path'] as String?,
    catName: m['cat_name'] as String?,
    customerName: m['customer_name'] as String?,
    incomeDate: DateTime.parse(m['income_date'] as String),
    paymentMethod: m['payment_method'] as String?,
    isRecurring: (m['is_recurring'] as int?) == 1,
    status: m['status'] as String? ?? 'completed',
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId, 'customer_id': customerId,
    'cash_account_id': cashAccountId,
    'bank_account_id': bankAccountId,
    'category_id': categoryId, 'amount': amount,
    'description': description, 'reference': reference,
    'image_path': imagePath,
    'income_date': incomeDate.toIso8601String(),
    'payment_method': paymentMethod,
    'is_recurring': isRecurring ? 1 : 0, 'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
