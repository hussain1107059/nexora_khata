import 'package:flutter/widgets.dart';
import 'package:nexora_khata/generated/l10n/app_localizations.dart';

/// Global access to the active [AppLocalizations] without needing a
/// [BuildContext]. Useful for non-widget utilities (validators, date/number
/// formatters, PDF/Excel export services).
class AppStrings {
  AppStrings._();

  static AppLocalizations? _current;

  static AppLocalizations get s {
    final current = _current;
    if (current != null) return current;
    final fallback = lookupAppLocalizations(const Locale('bn'));
    _current = fallback;
    return fallback;
  }

  static set current(AppLocalizations value) => _current = value;

  /// Registers a dependency on the active locale so the calling widget is
  /// rebuilt when the language changes.
  static void dependOnLocale(BuildContext context) {
    AppLocalizations.of(context);
  }
}
