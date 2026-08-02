import 'package:nexora_khata/core/utils/date_utils.dart';
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id, required super.businessId,
    super.supplierId, super.cashAccountId, super.bankAccountId,
    required super.categoryId, required super.amount,
    super.description, super.reference, super.imagePath, super.catName, super.supplierName,
    required super.expenseDate,
    super.paymentMethod, super.isRecurring, super.status,
    required super.createdAt, required super.updatedAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> m) => ExpenseModel(
    id: m['id'] as int,
    businessId: m['business_id'] as int,
    supplierId: m['supplier_id'] as int?,
    cashAccountId: m['cash_account_id'] as int?,
    bankAccountId: m['bank_account_id'] as int?,
    categoryId: m['category_id'] as int,
    amount: (m['amount'] as num).toDouble(),
    description: m['description'] as String?,
    reference: m['reference'] as String?,
    imagePath: m['image_path'] as String?,
    catName: m['cat_name'] as String?,
    supplierName: m['supplier_name'] as String?,
    expenseDate: DateTime.parse(m['expense_date'] as String),
    paymentMethod: m['payment_method'] as String?,
    isRecurring: (m['is_recurring'] as int?) == 1,
    status: m['status'] as String? ?? 'completed',
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId, 'supplier_id': supplierId,
    'cash_account_id': cashAccountId,
    'bank_account_id': bankAccountId,
    'category_id': categoryId, 'amount': amount,
    'description': description, 'reference': reference,
    'image_path': imagePath,
    'expense_date': AppDateUtils.formatDate(expenseDate, format: AppDateUtils.dateFormat),
    'payment_method': paymentMethod,
    'is_recurring': isRecurring ? 1 : 0, 'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
