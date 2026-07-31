import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? passwordHash;
  final String? pin;
  final String? avatarPath;
  final bool isActive;
  final DateTime? lastLoginAt;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.passwordHash,
    this.pin,
    this.avatarPath,
    this.isActive = true,
    this.lastLoginAt,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? passwordHash,
    String? pin,
    String? avatarPath,
    bool? isActive,
    DateTime? lastLoginAt,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AppUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    passwordHash: passwordHash ?? this.passwordHash,
    pin: pin ?? this.pin,
    avatarPath: avatarPath ?? this.avatarPath,
    isActive: isActive ?? this.isActive,
    lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id, name, email, phone, passwordHash, pin, avatarPath,
    isActive, lastLoginAt, status, createdAt, updatedAt,
  ];
}
