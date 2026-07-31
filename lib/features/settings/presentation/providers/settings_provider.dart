import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/settings/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return getIt<SettingsRepository>();
});

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier(ref);
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class DarkModeNotifier extends StateNotifier<bool> {
  final Ref _ref;
  DarkModeNotifier(this._ref) : super(false) {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(settingsRepositoryProvider);
    final result = await repo.getValue('dark_mode');
    result.fold((_) => null, (v) {
      if (v != null && mounted) {
        state = v == 'true';
      }
    });
  }

  Future<void> toggle() async {
    state = !state;
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setValue('dark_mode', state.toString());
  }
}

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref _ref;
  LocaleNotifier(this._ref) : super(const Locale('bn', 'BD')) {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(settingsRepositoryProvider);
    final result = await repo.getValue('locale');
    result.fold((_) => null, (v) {
      if (v != null && mounted) {
        state = Locale(v.split('_')[0], v.contains('_') ? v.split('_')[1] : null);
      }
    });
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final repo = _ref.read(settingsRepositoryProvider);
    await repo.setValue('locale', '${locale.languageCode}_${locale.countryCode ?? ''}');
  }
}
