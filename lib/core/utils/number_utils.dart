import 'package:intl/intl.dart';
import 'package:nexora_khata/core/services/app_strings.dart';

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
    final s = AppStrings.s;
    if (number.abs() >= 10000000) {
      return s.numCrore((number / 10000000).toStringAsFixed(2));
    }
    if (number.abs() >= 100000) {
      return s.numLakh((number / 100000).toStringAsFixed(1));
    }
    if (number.abs() >= 1000) {
      return s.numThousand((number / 1000).toStringAsFixed(1));
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
    final s = AppStrings.s;
    switch (method.toLowerCase()) {
      case 'cash':
        return s.payCash;
      case 'bank':
        return s.payBank;
      case 'bkash':
        return s.payBkash;
      case 'nagad':
        return s.payNagad;
      case 'rocket':
        return s.payRocket;
      case 'card':
        return s.payCard;
      case 'check':
      case 'cheque':
        return s.payCheck;
      default:
        return method;
    }
  }

  static double parseAmount(String text) {
    return double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
  }
}
