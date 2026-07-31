import 'dart:io';
import 'package:nexora_khata/core/services/database_helper.dart';

class SettingsDataSource {
  final DatabaseHelper _dbHelper;
  SettingsDataSource(this._dbHelper);

  Future<String?> getValue(String key) async {
    final rows = await _dbHelper.query('settings',
      where: 'key = ? AND status = ?', whereArgs: [key, 'active'], limit: 1);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setValue(String key, String value) async {
    final existing = await _dbHelper.query('settings',
      where: 'key = ?', whereArgs: [key], limit: 1);
    if (existing.isNotEmpty) {
      await _dbHelper.updateWhere('settings', {
        'value': value, 'updated_at': DateTime.now().toIso8601String(),
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

  Future<Map<String, String>> getAll() async {
    final rows = await _dbHelper.query('settings',
      where: 'status = ?', whereArgs: ['active']);
    return {for (final r in rows) r['key'] as String: r['value'] as String};
  }

  Future<String> getDatabasePath() async {
    return _dbHelper.db.path;
  }

  Future<bool> exportDatabase(String destinationPath) async {
    try {
      final source = File(_dbHelper.db.path);
      await source.copy(destinationPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> importDatabase(String sourcePath) async {
    try {
      final dbPath = _dbHelper.db.path;
      await _dbHelper.close();
      final source = File(sourcePath);
      await source.copy(dbPath);
      await _dbHelper.open();
      return true;
    } catch (_) {
      return false;
    }
  }
}
