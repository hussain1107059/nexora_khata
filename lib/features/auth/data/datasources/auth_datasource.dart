import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/features/auth/domain/entities/auth_user.dart';

class AuthDataSource {
  final DatabaseHelper _dbHelper;
  AuthDataSource(this._dbHelper);

  static const String _sessionKey = 'auth_session_user_id';
  static const String _sessionActiveKey = 'auth_session_last_active';
  static const Duration sessionMaxAge = Duration(days: 5);

  AuthUser _fromMap(Map<String, dynamic> m) => AuthUser(
        id: m['id'] as int,
        name: m['name'] as String,
        username: m['username'] as String?,
        email: m['email'] as String?,
        phone: m['phone'] as String?,
        avatarPath: m['avatar_path'] as String?,
      );

  Future<AuthUser?> findById(int id) async {
    final rows = await _dbHelper.query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<AuthUser?> findByUsernameOrEmail(String username, String email) async {
    final rows = await _dbHelper.query('users',
        where: 'username = ? OR email = ?', whereArgs: [username, email], limit: 1);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<String?> getPasswordHash(int id) async {
    final rows = await _dbHelper.query('users',
        columns: ['password_hash'], where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['password_hash'] as String?;
  }

  Future<bool> isUsernameTaken(String username) async {
    return _dbHelper.exists('users', where: 'username = ?', whereArgs: [username]);
  }

  Future<AuthUser> create({
    required String name,
    required String username,
    required String passwordHash,
    String? email,
    String? phone,
  }) async {
    final now = DateTime.now().toIso8601String();
    final id = await _dbHelper.insert('users', {
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'is_active': 1,
      'status': 'active',
      'created_at': now,
      'updated_at': now,
    });
    final user = await findById(id);
    if (user == null) {
      throw StateError('Failed to create user');
    }
    return user;
  }

  Future<void> touchLogin(int id) async {
    await _dbHelper.update('users', {
      'last_login_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }, id);
  }

  String hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  String generateSalt() {
    return DateTime.now().microsecondsSinceEpoch.toString() + (identityHashCode(this)).toString();
  }

  Future<void> saveSession(int userId) async {
    await _setSetting(_sessionKey, userId.toString());
    await _setSetting(_sessionActiveKey, DateTime.now().toIso8601String());
  }

  Future<void> claimLegacyData(int userId) async {
    await _dbHelper.claimLegacyDataForUser(userId);
  }

  Future<void> _setSetting(String key, String value) async {
    final rows = await _dbHelper.query('settings',
        where: 'key = ?', whereArgs: [key], limit: 1);
    if (rows.isNotEmpty) {
      await _dbHelper.updateWhere('settings', {
        'value': value,
        'updated_at': DateTime.now().toIso8601String(),
      }, where: 'key = ?', whereArgs: [key]);
    } else {
      await _dbHelper.insert('settings', {
        'business_id': 0,
        'key': key,
        'value': value,
        'type': 'string',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int?> getSessionUserId() async {
    final rows = await _dbHelper.query('settings',
        where: 'key = ?', whereArgs: [_sessionKey], limit: 1);
    if (rows.isEmpty) return null;
    return int.tryParse(rows.first['value'] as String? ?? '');
  }

  Future<DateTime?> getSessionLastActive() async {
    final rows = await _dbHelper.query('settings',
        where: 'key = ?', whereArgs: [_sessionActiveKey], limit: 1);
    if (rows.isEmpty) return null;
    return DateTime.tryParse(rows.first['value'] as String? ?? '');
  }

  Future<void> updateSessionActivity() async {
    await _setSetting(_sessionActiveKey, DateTime.now().toIso8601String());
  }

  Future<void> clearSession() async {
    await _dbHelper.deleteWhere('settings',
        where: 'key = ?', whereArgs: [_sessionKey]);
    await _dbHelper.deleteWhere('settings',
        where: 'key = ?', whereArgs: [_sessionActiveKey]);
  }
}
