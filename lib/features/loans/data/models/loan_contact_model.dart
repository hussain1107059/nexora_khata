import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';

class LoanContactModel extends LoanContact {
  const LoanContactModel({
    required super.id,
    required super.businessId,
    required super.name,
    super.phone,
    super.note,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LoanContactModel.fromMap(Map<String, dynamic> m) => LoanContactModel(
    id: m['id'] as int,
    businessId: m['business_id'] as int,
    name: m['name'] as String,
    phone: m['phone'] as String?,
    note: m['note'] as String?,
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId,
    'name': name,
    'phone': phone,
    'note': note,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
