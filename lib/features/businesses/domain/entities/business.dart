import 'package:equatable/equatable.dart';

class Business extends Equatable {
  final int id;
  final int userId;
  final String name;
  final String? type;
  final String? phone;
  final String? email;
  final String? address;
  final String? logoPath;
  final String currency;
  final String? fiscalYearStart;
  final String? registrationNo;
  final String? taxId;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Business({
    required this.id,
    required this.userId,
    required this.name,
    this.type,
    this.phone,
    this.email,
    this.address,
    this.logoPath,
    this.currency = 'BDT',
    this.fiscalYearStart,
    this.registrationNo,
    this.taxId,
    this.notes,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  Business copyWith({
    int? id, int? userId, String? name, String? type,
    String? phone, String? email, String? address, String? logoPath,
    String? currency, String? fiscalYearStart, String? registrationNo,
    String? taxId, String? notes, String? status,
    DateTime? createdAt, DateTime? updatedAt,
  }) => Business(
    id: id ?? this.id, userId: userId ?? this.userId,
    name: name ?? this.name, type: type ?? this.type,
    phone: phone ?? this.phone, email: email ?? this.email,
    address: address ?? this.address, logoPath: logoPath ?? this.logoPath,
    currency: currency ?? this.currency,
    fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
    registrationNo: registrationNo ?? this.registrationNo,
    taxId: taxId ?? this.taxId, notes: notes ?? this.notes,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id, userId, name, type, phone, email, address, logoPath,
    currency, fiscalYearStart, registrationNo, taxId, notes,
    status, createdAt, updatedAt,
  ];
}
