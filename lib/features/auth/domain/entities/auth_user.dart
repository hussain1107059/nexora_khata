import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final String? avatarPath;

  const AuthUser({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.phone,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [id, name, username, email, phone, avatarPath];
}
