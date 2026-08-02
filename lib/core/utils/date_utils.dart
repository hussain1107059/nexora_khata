import 'package:intl/intl.dart';
import 'package:nexora_khata/core/services/app_strings.dart';

abstract final class AppDateUtils {
  AppDateUtils._();

  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'dd MMM yyyy';
  static const String displayDateFormatBn = 'dd MMMM yyyy';
  static const String displayTimeFormat = 'hh:mm a';
  static const String displayDateTimeFormat = 'dd MMM yyyy, hh:mm a';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String monthYearFormatBn = 'MMMM yyyy';
  static const String dayMonthFormat = 'dd MMM';
  static const String yearFormat = 'yyyy';

  static String formatDate(DateTime date, {String? format}) {
    return DateFormat(format ?? displayDateFormat).format(date);
  }

  static String formatDateTime(DateTime date, {String? format}) {
    return DateFormat(format ?? displayDateTimeFormat).format(date);
  }

  static String formatTime(DateTime date, {String? format}) {
    return DateFormat(format ?? displayTimeFormat).format(date);
  }

  static String formatToISO(DateTime date) {
    return DateFormat(dateTimeFormat).format(date);
  }

  static DateTime? parseDate(String dateStr, {String? format}) {
    try {
      return DateFormat(format ?? dateFormat).parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  static DateTime parseISO(String dateStr) {
    return DateFormat(dateTimeFormat).parse(dateStr);
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    final s = AppStrings.s;

    if (difference.inDays > 365) {
      return s.timeYearsAgo((difference.inDays / 365).floor());
    }
    if (difference.inDays > 30) {
      return s.timeMonthsAgo((difference.inDays / 30).floor());
    }
    if (difference.inDays > 7) {
      return s.timeWeeksAgo((difference.inDays / 7).floor());
    }
    if (difference.inDays > 0) {
      return s.timeDaysAgo(difference.inDays);
    }
    if (difference.inHours > 0) {
      return s.timeHoursAgo(difference.inHours);
    }
    if (difference.inMinutes > 0) {
      return s.timeMinutesAgo(difference.inMinutes);
    }
    return s.timeJustNow;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());

  static bool isYesterday(DateTime date) {
    return isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));
    return date.isAfter(weekStart) && date.isBefore(weekEnd);
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime date) {
    return date.year == DateTime.now().year;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59, 999);
  }

  /// Inclusive start of a month as an index-friendly `yyyy-MM-dd` string.
  static String monthStart(int year, int month) {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-01';
  }

  /// Exclusive end of a month as an index-friendly `yyyy-MM-dd` string.
  static String monthEndExclusive(int year, int month) {
    final next = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return formatDate(next, format: dateFormat);
  }

  /// Inclusive start of a year as an index-friendly `yyyy-MM-dd` string.
  static String yearStart(int year) => '$year-01-01';

  /// Exclusive end of a year as an index-friendly `yyyy-MM-dd` string.
  static String yearEndExclusive(int year) => '${year + 1}-01-01';

  static List<DateTime> getDaysInMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0);
    return List.generate(
      lastDay.day,
      (i) => DateTime(year, month, i + 1),
    );
  }

  static String monthNameBn(int month) {
    final s = AppStrings.s;
    switch (month) {
      case 1:
        return s.monthJanuary;
      case 2:
        return s.monthFebruary;
      case 3:
        return s.monthMarch;
      case 4:
        return s.monthApril;
      case 5:
        return s.monthMay;
      case 6:
        return s.monthJune;
      case 7:
        return s.monthJuly;
      case 8:
        return s.monthAugust;
      case 9:
        return s.monthSeptember;
      case 10:
        return s.monthOctober;
      case 11:
        return s.monthNovember;
      default:
        return s.monthDecember;
    }
  }

  static String dayNameBn(int weekday) {
    final s = AppStrings.s;
    switch (weekday) {
      case 1:
        return s.weekdayMon;
      case 2:
        return s.weekdayTue;
      case 3:
        return s.weekdayWed;
      case 4:
        return s.weekdayThu;
      case 5:
        return s.weekdayFri;
      case 6:
        return s.weekdaySat;
      default:
        return s.weekdaySun;
    }
  }
}
