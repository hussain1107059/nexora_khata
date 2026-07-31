import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/settings/data/services/backup_service.dart';
import 'package:nexora_khata/features/settings/presentation/providers/settings_provider.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  final dbHelper = getIt<DatabaseHelper>();
  final service = BackupService(dbHelper);
  ref.onDispose(() => service.dispose());
  return service;
});

final backupHistoryProvider = FutureProvider<List<BackupEntry>>((ref) async {
  final service = ref.read(backupServiceProvider);
  return service.getBackupHistory();
});

final backupCountProvider = FutureProvider<int>((ref) async {
  final service = ref.read(backupServiceProvider);
  return service.getBackupCount();
});

final backupTotalSizeProvider = FutureProvider<double>((ref) async {
  final service = ref.read(backupServiceProvider);
  return service.getTotalBackupSize();
});

final autoBackupEnabledProvider = StateNotifierProvider<AutoBackupNotifier, bool>((ref) {
  return AutoBackupNotifier(ref);
});

final autoBackupFrequencyProvider = StateNotifierProvider<AutoBackupFrequencyNotifier, String>((ref) {
  return AutoBackupFrequencyNotifier(ref);
});

class AutoBackupNotifier extends StateNotifier<bool> {
  final Ref _ref;
  AutoBackupNotifier(this._ref) : super(false) {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(settingsRepositoryProvider);
    final result = await repo.getValue('auto_backup_enabled');
    result.fold((_) => null, (v) {
      if (v != null && mounted) state = v == 'true';
    });
  }

  Future<void> toggle(bool value) async {
    state = value;
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setValue('auto_backup_enabled', value.toString());
    final service = _ref.read(backupServiceProvider);
    if (value) {
      final freqResult = await repo.getValue('auto_backup_frequency');
      String freq = 'daily';
      freqResult.fold((_) => null, (v) { if (v != null) freq = v; });
      service.startAutoBackup(interval: _parseInterval(freq));
    } else {
      service.stopAutoBackup();
    }
  }

  Duration _parseInterval(String freq) {
    switch (freq) {
      case 'hourly': return const Duration(hours: 1);
      case 'daily': return const Duration(hours: 24);
      case 'weekly': return const Duration(days: 7);
      case 'monthly': return const Duration(days: 30);
      default: return const Duration(hours: 24);
    }
  }
}

class AutoBackupFrequencyNotifier extends StateNotifier<String> {
  final Ref _ref;
  AutoBackupFrequencyNotifier(this._ref) : super('daily') {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(settingsRepositoryProvider);
    final result = await repo.getValue('auto_backup_frequency');
    result.fold((_) => null, (v) {
      if (v != null && mounted) state = v;
    });
  }

  Future<void> setFrequency(String value) async {
    state = value;
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setValue('auto_backup_frequency', value);
    final enabled = _ref.read(autoBackupEnabledProvider);
    if (enabled) {
      final service = _ref.read(backupServiceProvider);
      service.stopAutoBackup();
      final interval = switch (value) {
        'hourly' => const Duration(hours: 1),
        'daily' => const Duration(hours: 24),
        'weekly' => const Duration(days: 7),
        'monthly' => const Duration(days: 30),
        _ => const Duration(hours: 24),
      };
      service.startAutoBackup(interval: interval);
    }
  }
}
