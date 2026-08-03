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

  Future<AuthUser?> findByEmail(String email) async {
    final rows = await _dbHelper.query('users',
        where: 'email = ?', whereArgs: [email.trim()], limit: 1);
    if (rows.isEmpty) return null;
    return _fromMap(rows.first);
  }

  Future<String?> getSecurityQuestionByEmail(String email) async {
    final rows = await _dbHelper.query('users',
        columns: ['security_question'],
        where: 'email = ?', whereArgs: [email.trim()], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['security_question'] as String?;
  }

  /// Hashes the security answer (salted) so it is never stored in plain text.
  String hashSecurityAnswer(String answer) {
    final salt = generateSalt();
    return '$salt:${hashPassword(answer, salt)}';
  }

  /// Returns true only when [answer] matches the stored, hashed answer.
  Future<bool> verifySecurityAnswer(String email, String answer) async {
    final rows = await _dbHelper.query('users',
        columns: ['security_answer_hash'],
        where: 'email = ?', whereArgs: [email.trim()], limit: 1);
    if (rows.isEmpty) return false;
    final stored = rows.first['security_answer_hash'] as String?;
    if (stored == null || stored.isEmpty) return false;
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    return hashPassword(answer, parts[0]) == parts[1];
  }

  /// Stores a new salted password hash (`salt:hash`, same layout as signup) for
  /// the account matching [email]. Returns the number of updated rows.
  Future<int> updatePassword(String email, String passwordHash) async {
    return _dbHelper.updateWhere('users', {
      'password_hash': passwordHash,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'email = ?', whereArgs: [email.trim()]);
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
    String? securityQuestion,
    String? securityAnswerHash,
  }) async {
    final now = DateTime.now().toIso8601String();
    final id = await _dbHelper.insert('users', {
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'password_hash': passwordHash,
      'security_question': securityQuestion,
      'security_answer_hash': securityAnswerHash,
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
