import 'package:intl/intl.dart';

abstract final class AppNumberUtils {
  AppNumberUtils._();

  static const String currencySymbol = '৳';
  static const String currencyCode = 'BDT';
  static const String localeBn = 'bn';
  static const String localeEn = 'en';

  static String formatCurrency(
    double amount, {
    int decimalDigits = 2,
    String symbol = currencySymbol,
  }) {
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
      locale: localeEn,
    );
    return formatter.format(amount);
  }

  static String formatNumber(
    double number, {
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat('#,###${decimalDigits > 0 ? '.${'0' * decimalDigits}' : ''}');
    return formatter.format(number);
  }

  static String formatCompact(double number) {
    if (number.abs() >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)}Cr';
    }
    if (number.abs() >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    }
    if (number.abs() >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(0);
  }

  static String formatCompactBn(double number) {
    if (number.abs() >= 10000000) {
      return '${(number / 10000000).toStringAsFixed(2)} কোটি';
    }
    if (number.abs() >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)} লাখ';
    }
    if (number.abs() >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)} হাজার';
    }
    return number.toStringAsFixed(0);
  }

  static String formatPercentage(
    double value, {
    int decimalDigits = 1,
  }) {
    return '${value.toStringAsFixed(decimalDigits)}%';
  }

  static String formatSign(double amount) {
    if (amount > 0) return '+${formatCurrency(amount)}';
    if (amount < 0) return formatCurrency(amount);
    return formatCurrency(0);
  }

  static String formatWithColor(double amount) {
    if (amount > 0) return '+${formatCurrency(amount)}';
    if (amount < 0) return formatCurrency(amount);
    return formatCurrency(0);
  }

  static String formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'নগদ';
      case 'bank':
        return 'ব্যাংক';
      case 'bKash':
      case 'bkash':
        return 'বিকাশ';
      case 'nagad':
        return 'নগদ';
      case 'rocket':
        return 'রকেট';
      case 'card':
        return 'কার্ড';
      case 'check':
      case 'cheque':
        return 'চেক';
      default:
        return method;
    }
  }

  static double parseAmount(String text) {
    return double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }
}
