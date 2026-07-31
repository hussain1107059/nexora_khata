import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';
import '../config/theme/app_typography.dart';

enum SnackBarType { success, error, warning, info }

extension SnackBarTypeX on SnackBarType {
  Color get color => switch (this) {
        SnackBarType.success => AppColors.success,
        SnackBarType.error => AppColors.error,
        SnackBarType.warning => AppColors.warning,
        SnackBarType.info => AppColors.info,
      };

  IconData get icon => switch (this) {
        SnackBarType.success => Icons.check_circle_rounded,
        SnackBarType.error => Icons.error_rounded,
        SnackBarType.warning => Icons.warning_rounded,
        SnackBarType.info => Icons.info_rounded,
      };
}

abstract final class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context,
    String message, {
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(type.icon, color: AppColors.white, size: 20),
            AppSpacing.boxWMD,
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyText2.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: type.color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.white,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message, type: SnackBarType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message, type: SnackBarType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message, type: SnackBarType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message, type: SnackBarType.info);
  }
}
