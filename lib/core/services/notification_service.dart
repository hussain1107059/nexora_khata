import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/intl.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/dashboard/data/datasources/dashboard_datasource.dart';
import 'package:nexora_khata/generated/l10n/app_localizations.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._dbHelper);

  final DatabaseHelper _dbHelper;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'nexora_khata_reminders';
  static const String _channelName = 'Nexora Khata';
  static const String _channelDescription =
      'Daily reminders and loan notifications';

  static const int idMorning = 101;
  static const int idAfternoon = 102;
  static const int idNight = 103;
  static const int idDaySummary = 104;
  static const int loanReminderBase = 1000;

  static const int loanReminderDays = 3;

  static const int morningHour = 8;
  static const int afternoonHour = 13;
  static const int nightHour = 22;
  static const int daySummaryHour = 21;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  NotificationDetails get _details => NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        ),
      );

  /// Re-schedules the daily greeting and day-summary notifications with the
  /// current app language and the latest figures.
  Future<void> syncSchedules() async {
    await init();
    final localeCode = await _storedLocaleCode();
    final loc = _localizations(localeCode);

    await _scheduleDaily(
      idMorning,
      loc.notifGoodMorningTitle,
      loc.notifGoodMorningBody,
      morningHour,
    );
    await _scheduleDaily(
      idAfternoon,
      loc.notifGoodAfternoonTitle,
      loc.notifGoodAfternoonBody,
      afternoonHour,
    );
    await _scheduleDaily(
      idNight,
      loc.notifGoodNightTitle,
      loc.notifGoodNightBody,
      nightHour,
    );

    final summary = await _daySummary(localeCode);
    await _scheduleDaily(
      idDaySummary,
      summary.title,
      summary.body,
      daySummaryHour,
    );
  }

  Future<void> scheduleLoanReminder({
    required int txnId,
    required String contactName,
    required double amount,
    required DateTime date,
    required String type,
  }) async {
    await init();
    if (type != 'borrow' && type != 'lend') return;
    final localeCode = await _storedLocaleCode();
    final loc = _localizations(localeCode);

    final base = tz.TZDateTime.from(date, tz.local);
    var when = tz.TZDateTime(tz.local, base.year, base.month, base.day, 10)
        .add(const Duration(days: loanReminderDays));
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) {
      when = _nextInstanceOf(10, 0);
    }

    final amountStr = AppNumberUtils.formatNumber(amount);
    final dateStr = _formatDate(date, localeCode);
    final body = type == 'borrow'
        ? loc.notifLoanBorrowBody(amountStr, contactName, dateStr)
        : loc.notifLoanLendBody(amountStr, contactName, dateStr);

    await _plugin.zonedSchedule(
      id: loanReminderBase + txnId,
      title: loc.notifLoanTitle,
      body: body,
      scheduledDate: when,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelLoanReminder(int txnId) async {
    if (!_initialized) return;
    await _plugin.cancel(id: loanReminderBase + txnId);
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
  }

  Future<void> _scheduleDaily(
    int id,
    String title,
    String body,
    int hour, [
    int minute = 0,
  ]) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOf(hour, minute),
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<({String title, String body})> _daySummary(String localeCode) async {
    final loc = _localizations(localeCode);
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final ds = getIt<DashboardDataSource>();
    final income = await ds.getTodayIncome(date);
    final expense = await ds.getTodayExpense(date);
    final balance = await ds.getCashBalance() + await ds.getBankBalance();
    return (
      title: loc.notifDaySummaryTitle,
      body: loc.notifDaySummaryBody(
        AppNumberUtils.formatNumber(income),
        AppNumberUtils.formatNumber(expense),
        AppNumberUtils.formatNumber(balance),
      ),
    );
  }

  String _formatDate(DateTime date, String localeCode) {
    if (localeCode.startsWith('bn')) {
      return '${date.day} ${AppDateUtils.monthNameBn(date.month)} ${date.year}';
    }
    return DateFormat('dd MMM yyyy').format(date);
  }

  Future<String> _storedLocaleCode() async {
    try {
      final rows = await _dbHelper.query('settings',
          where: 'key = ?', whereArgs: ['locale'], limit: 1);
      if (rows.isEmpty) return 'bn';
      return rows.first['value'] as String? ?? 'bn';
    } catch (_) {
      return 'bn';
    }
  }

  AppLocalizations _localizations(String localeCode) {
    return lookupAppLocalizations(
      Locale(localeCode.startsWith('bn') ? 'bn' : 'en'),
    );
  }
}
