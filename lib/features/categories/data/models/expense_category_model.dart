import '../../domain/entities/expense_category.dart';

class ExpenseCategoryModel extends ExpenseCategory {
  const ExpenseCategoryModel({
    required super.id, required super.businessId, required super.name,
    super.description, super.icon, super.color, super.parentId,
    super.sortOrder, super.status,
    required super.createdAt, required super.updatedAt,
  });

  factory ExpenseCategoryModel.fromMap(Map<String, dynamic> m) =>
      ExpenseCategoryModel(
        id: m['id'] as int,
        businessId: m['business_id'] as int,
        name: m['name'] as String,
        description: m['description'] as String?,
        icon: m['icon'] as String?,
        color: m['color'] as String?,
        parentId: m['parent_id'] as int?,
        sortOrder: (m['sort_order'] as int?) ?? 0,
        status: m['status'] as String? ?? 'active',
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId, 'name': name,
    'description': description, 'icon': icon, 'color': color,
    'parent_id': parentId, 'sort_order': sortOrder,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
