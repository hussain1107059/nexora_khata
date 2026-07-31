import '../../domain/entities/business.dart';

class BusinessModel extends Business {
  const BusinessModel({
    required super.id, required super.userId, required super.name,
    super.type, super.phone, super.email, super.address,
    super.logoPath, super.currency, super.fiscalYearStart,
    super.registrationNo, super.taxId, super.notes,
    super.status, required super.createdAt, required super.updatedAt,
  });

  factory BusinessModel.fromMap(Map<String, dynamic> m) => BusinessModel(
    id: m['id'] as int,
    userId: m['user_id'] as int,
    name: m['name'] as String,
    type: m['type'] as String?,
    phone: m['phone'] as String?,
    email: m['email'] as String?,
    address: m['address'] as String?,
    logoPath: m['logo_path'] as String?,
    currency: m['currency'] as String? ?? 'BDT',
    fiscalYearStart: m['fiscal_year_start'] as String?,
    registrationNo: m['registration_no'] as String?,
    taxId: m['tax_id'] as String?,
    notes: m['notes'] as String?,
    status: m['status'] as String? ?? 'active',
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'user_id': userId, 'name': name, 'type': type,
    'phone': phone, 'email': email, 'address': address,
    'logo_path': logoPath, 'currency': currency,
    'fiscal_year_start': fiscalYearStart,
    'registration_no': registrationNo, 'tax_id': taxId,
    'notes': notes, 'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
