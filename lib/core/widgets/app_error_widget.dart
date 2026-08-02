import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';
import 'app_text.dart';
import 'app_button.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.error, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.error,
              ),
            ),
            AppSpacing.boxHXL,
            AppText(
              title ?? 'কিছু ভুল হয়েছে',
              type: AppTextType.subtitle1,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            AppSpacing.boxHSM,
            AppText(
              message,
              type: AppTextType.body2,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              AppSpacing.boxHXL,
              AppButton(
                text: 'পুনরায় চেষ্টা করুন',
                onPressed: onRetry,
                icon: Icons.refresh_rounded,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.96, 0.96), end: const Offset(1, 1), curve: Curves.easeOut);
  }
}
