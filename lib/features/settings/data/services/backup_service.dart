import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nexora_khata/core/services/database_helper.dart';

class BackupService {
  final DatabaseHelper _dbHelper;
  Timer? _autoTimer;
  bool _running = false;

  BackupService(this._dbHelper);

  String get dbPath => _dbHelper.db.path;

  Future<File> manualBackup() async {
    if (kIsWeb) {
      throw UnsupportedError('ওয়েব সংস্করণে ব্যাকআপ সমর্থিত নয়');
    }
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupDir.exists()) await backupDir.create(recursive: true);

    final ts = DateTime.now();
    final name = 'nexora_khata_${ts.year}${_p(ts.month)}${_p(ts.day)}_${_p(ts.hour)}${_p(ts.minute)}${_p(ts.second)}.db';
    final dest = p.join(backupDir.path, name);
    await File(dbPath).copy(dest);
    await _recordBackup(name, dest, 'manual');
    return File(dest);
  }

  Future<File?> autoBackup() async {
    try {
      final file = await manualBackup();
      await _recordBackup(p.basename(file.path), file.path, 'automatic');
      return file;
    } catch (_) {
      return null;
    }
  }

  Future<bool> restore(String backupPath) async {
    if (kIsWeb) return false;
    try {
      final dbPath = _dbHelper.db.path;
      await _dbHelper.close();
      await File(backupPath).copy(dbPath);
      await _dbHelper.open();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> shareBackup(String filePath) async {
    if (kIsWeb) {
      throw UnsupportedError('ওয়েব সংস্করণে ব্যাকআপ শেয়ার সমর্থিত নয়');
    }
    await Share.shareXFiles([XFile(filePath)], text: 'নেক্সোরা খাতা ব্যাকআপ');
  }

  Future<List<BackupEntry>> getBackupHistory({int limit = 50}) async {
    final rows = await _dbHelper.query('backup_logs',
      where: 'status = ?', whereArgs: ['completed'],
      orderBy: 'created_at DESC', limit: limit,
    );
    return rows.map((r) => BackupEntry(
      id: r['id'] as int,
      fileName: r['file_name'] as String,
      filePath: r['file_path'] as String?,
      fileSize: r['file_size'] as int? ?? 0,
      type: r['type'] as String? ?? 'manual',
      createdAt: DateTime.parse(r['created_at'] as String),
    )).toList();
  }

  Future<bool> deleteBackup(int id) async {
    try {
      final log = await _dbHelper.byId('backup_logs', id);
      if (log != null) {
        final path = log['file_path'] as String?;
        if (path != null && !kIsWeb) {
          final f = File(path);
          if (await f.exists()) await f.delete();
        }
      }
      await _dbHelper.delete('backup_logs', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<int> getBackupCount() async {
    return _dbHelper.count('backup_logs', where: 'status = ?', whereArgs: ['completed']);
  }

  Future<double> getTotalBackupSize() async {
    return _dbHelper.sum('backup_logs', 'file_size',
      where: 'status = ?', whereArgs: ['completed']);
  }

  void startAutoBackup({Duration interval = const Duration(hours: 24)}) {
    _interval = interval;
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(interval, (_) async {
      if (_running) return;
      _running = true;
      await autoBackup();
      await _cleanupOldBackups();
      _running = false;
    });
  }

  void stopAutoBackup() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  void pauseAutoBackup() {
    _autoTimer?.cancel();
  }

  Duration _interval = const Duration(hours: 24);

  void resumeAutoBackup() {
    if (_interval == const Duration(hours: 24)) return;
    startAutoBackup(interval: _interval);
  }

  Future<void> _cleanupOldBackups({int maxRetentionDays = 30}) async {
    final cutoff = DateTime.now().subtract(Duration(days: maxRetentionDays));
    final old = await _dbHelper.query('backup_logs',
      where: "status = ? AND created_at < ? AND type = 'automatic'",
      whereArgs: ['completed', cutoff.toIso8601String()],
    );
    for (final r in old) {
      final path = r['file_path'] as String?;
      if (path != null && !kIsWeb) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
      await _dbHelper.delete('backup_logs', r['id'] as int);
    }
  }

  Future<void> _recordBackup(String name, String path, String type) async {
    final f = File(path);
    final size = await f.length();
    await _dbHelper.insert('backup_logs', {
      'business_id': 0,
      'file_name': name,
      'file_path': path,
      'file_size': size,
      'type': type,
      'status': 'completed',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  String _p(int v) => v.toString().padLeft(2, '0');

  void dispose() {
    _autoTimer?.cancel();
  }

  bool get isAutoBackupRunning => _autoTimer != null;
}

class BackupEntry {
  final int id;
  final String fileName;
  final String? filePath;
  final int fileSize;
  final String type;
  final DateTime createdAt;

  const BackupEntry({
    required this.id, required this.fileName, this.filePath,
    required this.fileSize, required this.type, required this.createdAt,
  });

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
