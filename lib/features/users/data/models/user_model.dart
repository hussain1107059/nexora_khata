import '../../domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id, required super.name,
    super.email, super.phone, super.passwordHash, super.pin,
    super.avatarPath, super.isActive, super.lastLoginAt,
    super.status, required super.createdAt, required super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'] as int,
    name: m['name'] as String,
    email: m['email'] as String?,
    phone: m['phone'] as String?,
    passwordHash: m['password_hash'] as String?,
    pin: m['pin'] as String?,
    avatarPath: m['avatar_path'] as String?,
    isActive: (m['is_active'] as int?) == 1,
    lastLoginAt: m['last_login_at'] != null
        ? DateTime.tryParse(m['last_login_at'] as String) : null,
    status: m['status'] as String? ?? 'active',
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'name': name, 'email': email, 'phone': phone,
    'password_hash': passwordHash, 'pin': pin,
    'avatar_path': avatarPath,
    'is_active': isActive ? 1 : 0,
    'last_login_at': lastLoginAt?.toIso8601String(),
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
