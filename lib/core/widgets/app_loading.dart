import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';
import 'app_text.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const AppLoading({
    super.key,
    this.message,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size ?? 32,
            height: size ?? 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppColors.primary,
              ),
            ),
          ),
          if (message != null) ...[
            AppSpacing.boxHLG,
            AppText(
              message!,
              type: AppTextType.body2,
              color: AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.white.withValues(alpha: 0.7),
            child: AppLoading(message: message),
          ),
      ],
    );
  }
}

class AppShimmerLoading extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;

  const AppShimmerLoading({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding ?? AppSpacing.screenPadding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _buildShimmerItem(context),
        );
      },
    );
  }

  Widget _buildShimmerItem(BuildContext context) {
    return Container(
      height: itemHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Row(
        children: [
          AppSpacing.boxWLG,
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.disabled.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          AppSpacing.boxWMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.disabled.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                AppSpacing.boxHSM,
                Container(
                  width: 100,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.disabled.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.boxWLG,
          Container(
            width: 60,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.disabled.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          AppSpacing.boxWLG,
        ],
      ),
    );
  }
}
