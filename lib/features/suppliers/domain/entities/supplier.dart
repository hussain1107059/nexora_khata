import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final int id;
  final int businessId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? company;
  final double openingBalance;
  final double? creditLimit;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Supplier({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.company,
    this.openingBalance = 0,
    this.creditLimit,
    this.notes,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  Supplier copyWith({
    int? id, int? businessId, String? name, String? phone,
    String? email, String? address, String? company,
    double? openingBalance, double? creditLimit, String? notes,
    String? status, DateTime? createdAt, DateTime? updatedAt,
  }) => Supplier(
    id: id ?? this.id, businessId: businessId ?? this.businessId,
    name: name ?? this.name, phone: phone ?? this.phone,
    email: email ?? this.email, address: address ?? this.address,
    company: company ?? this.company,
    openingBalance: openingBalance ?? this.openingBalance,
    creditLimit: creditLimit ?? this.creditLimit,
    notes: notes ?? this.notes, status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id, businessId, name, phone, email, address, company,
    openingBalance, creditLimit, notes, status, createdAt, updatedAt,
  ];
}
