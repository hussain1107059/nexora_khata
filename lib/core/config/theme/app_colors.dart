import 'package:flutter/material.dart';

abstract final class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFFE53935);
  static const Color primaryLight = Color(0xFFFFEBEE);
  static const Color primaryDark = Color(0xFFC62828);

  static const Color secondary = Color(0xFF1E88E5);
  static const Color secondaryLight = Color(0xFFE3F2FD);

  // Semantic
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF3F4F6);

  static const Color textPrimary = Color(0xFF1B1F24);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEEF0F3);
  static const Color disabled = Color(0xFFC5CAD1);
  static const Color shadow = Color(0x14000000);
  static const Color scrim = Color(0x66000000);

  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color chipBackground = Color(0xFFF1F2F4);
  static const Color surfaceMuted = Color(0xFFF7F8FA);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF05A50), Color(0xFFE53935), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF43A047), Color(0xFF2E7D32)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFFA726), Color(0xFFFB8C00), Color(0xFFEF6C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [Color(0xFFE57373), Color(0xFFEF5350), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient infoGradient = LinearGradient(
    colors: [Color(0xFF29B6F6), Color(0xFF039BE5), Color(0xFF0277BD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
