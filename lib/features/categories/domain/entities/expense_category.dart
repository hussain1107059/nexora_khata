import 'package:equatable/equatable.dart';

class ExpenseCategory extends Equatable {
  final int id;
  final int businessId;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int? parentId;
  final int sortOrder;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseCategory({
    required this.id,
    required this.businessId,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.parentId,
    this.sortOrder = 0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  ExpenseCategory copyWith({
    int? id, int? businessId, String? name, String? description,
    String? icon, String? color, int? parentId, int? sortOrder,
    String? status, DateTime? createdAt, DateTime? updatedAt,
  }) => ExpenseCategory(
    id: id ?? this.id, businessId: businessId ?? this.businessId,
    name: name ?? this.name, description: description ?? this.description,
    icon: icon ?? this.icon, color: color ?? this.color,
    parentId: parentId ?? this.parentId,
    sortOrder: sortOrder ?? this.sortOrder, status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id, businessId, name, description, icon, color,
    parentId, sortOrder, status, createdAt, updatedAt,
  ];
}
