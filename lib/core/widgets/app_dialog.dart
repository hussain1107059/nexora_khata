import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';

abstract final class AppDialog {
  AppDialog._();

  /// Premium confirmation dialog. Returns `true` when the user confirms.
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'নিশ্চিত করুন',
    String cancelLabel = 'বাতিল',
    IconData icon = Icons.help_outline_rounded,
    Color iconColor = AppColors.info,
    Color iconBackground = AppColors.infoLight,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (ctx) => AlertDialog(
        icon: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 28, color: iconColor),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel),
          ),
          AppSpacing.boxWSM,
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: destructive
                ? FilledButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}
