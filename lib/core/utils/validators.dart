import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';

abstract final class AppValidators {
  AppValidators._();

  static String? required(String? value, [String fieldName = '']) {
    if (value == null || value.trim().isEmpty) {
      final name = fieldName.isEmpty ? AppStrings.s.valThisField : fieldName;
      return AppStrings.s.valRequired(name);
    }
    return null;
  }

  static String? minLength(String? value, int minLength,
      [String fieldName = '']) {
    if (value == null || value.trim().length < minLength) {
      final name = fieldName.isEmpty ? AppStrings.s.valValue : fieldName;
      return AppStrings.s.valMinLength(name, minLength);
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength,
      [String fieldName = '']) {
    if (value != null && value.trim().length > maxLength) {
      final name = fieldName.isEmpty ? AppStrings.s.valValue : fieldName;
      return AppStrings.s.valMaxLength(name, maxLength);
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return AppStrings.s.valEmail;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^01[3-9]\d{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return AppStrings.s.valPhone;
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.s.valAmountRequired;
    }
    final amount = AppNumberUtils.parseAmount(value);
    if (amount <= 0) {
      return AppStrings.s.valAmountInvalid;
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.s.valNumberRequired;
    }
    final number = AppNumberUtils.parseAmount(value);
    if (number < 0) {
      return AppStrings.s.valNumberPositive;
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final urlRegex = RegExp(
      r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return AppStrings.s.valUrl;
    }
    return null;
  }

  static String? match(String? value, String matchValue,
      [String fieldName = '']) {
    if (value != matchValue) {
      final name = fieldName.isEmpty ? AppStrings.s.valValue : fieldName;
      return AppStrings.s.valMismatch(name);
    }
    return null;
  }

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      DateTime.parse(value.trim());
      return null;
    } catch (_) {
      return AppStrings.s.valDate;
    }
  }
}
