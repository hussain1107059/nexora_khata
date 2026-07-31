abstract final class AppValidators {
  AppValidators._();

  static String? required(String? value, [String fieldName = 'এই ক্ষেত্রটি']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName আবশ্যক';
    }
    return null;
  }

  static String? minLength(String? value, int minLength,
      [String fieldName = 'মান']) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName কমপক্ষে $minLength অক্ষর হতে হবে';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength,
      [String fieldName = 'মান']) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName সর্বোচ্চ $maxLength অক্ষর হতে পারে';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'বৈধ ইমেইল ঠিকানা দিন';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final phoneRegex = RegExp(r'^01[3-9]\d{8}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'বৈধ মোবাইল নম্বর দিন (যেমন: 01XXXXXXXXX)';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'পরিমাণ আবশ্যক';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'বৈধ পরিমাণ দিন (০-এর বেশি)';
    }
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'সংখ্যা আবশ্যক';
    }
    final number = double.tryParse(value.trim());
    if (number == null || number < 0) {
      return 'বৈধ ধনাত্মক সংখ্যা দিন';
    }
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final urlRegex = RegExp(
      r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
    );
    if (!urlRegex.hasMatch(value.trim())) {
      return 'বৈধ URL দিন';
    }
    return null;
  }

  static String? match(String? value, String matchValue,
      [String fieldName = 'মান']) {
    if (value != matchValue) {
      return '$fieldName মেলে না';
    }
    return null;
  }

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      DateTime.parse(value.trim());
      return null;
    } catch (_) {
      return 'বৈধ তারিখ দিন';
    }
  }
}
