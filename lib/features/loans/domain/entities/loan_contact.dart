import 'package:equatable/equatable.dart';

class LoanContact extends Equatable {
  final int id;
  final int businessId;
  final String name;
  final String? phone;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoanContact({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  LoanContact copyWith({
    int? id,
    int? businessId,
    String? name,
    String? phone,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LoanContact(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id,
    businessId,
    name,
    phone,
    note,
    createdAt,
    updatedAt,
  ];
}
