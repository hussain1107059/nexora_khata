import '../../domain/entities/supplier.dart';

class SupplierModel extends Supplier {
  const SupplierModel({
    required super.id, required super.businessId, required super.name,
    super.phone, super.email, super.address, super.company,
    super.openingBalance, super.creditLimit, super.notes,
    super.status, required super.createdAt, required super.updatedAt,
  });

  factory SupplierModel.fromMap(Map<String, dynamic> m) => SupplierModel(
    id: m['id'] as int,
    businessId: m['business_id'] as int,
    name: m['name'] as String,
    phone: m['phone'] as String?,
    email: m['email'] as String?,
    address: m['address'] as String?,
    company: m['company'] as String?,
    openingBalance: (m['opening_balance'] as num?)?.toDouble() ?? 0,
    creditLimit: (m['credit_limit'] as num?)?.toDouble(),
    notes: m['notes'] as String?,
    status: m['status'] as String? ?? 'active',
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId, 'name': name,
    'phone': phone, 'email': email, 'address': address,
    'company': company, 'opening_balance': openingBalance,
    'credit_limit': creditLimit, 'notes': notes, 'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
