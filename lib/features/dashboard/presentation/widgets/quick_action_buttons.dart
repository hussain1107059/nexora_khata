import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/config/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';

class QuickActionButtons extends StatelessWidget {
  const QuickActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: Text(
            'দ্রুত অ্যাকশন',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.boxHSM,
        Padding(
          padding: AppSpacing.paddingHSm,
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ActionBtn(
                icon: Icons.add_circle_rounded,
                label: 'আয় যোগ করুন',
                color: AppColors.success,
                onTap: () => context.push(RouteNames.incomeAdd),
              ),
              _ActionBtn(
                icon: Icons.remove_circle_rounded,
                label: 'ব্যয় যোগ করুন',
                color: AppColors.error,
                onTap: () => context.push(RouteNames.expenseAdd),
              ),
              _ActionBtn(
                icon: Icons.swap_horiz_rounded,
                label: 'ট্রান্সফার',
                color: AppColors.info,
                onTap: () => context.push(RouteNames.transferAdd),
              ),
              _ActionBtn(
                icon: Icons.currency_exchange_rounded,
                label: 'ঋণ',
                color: AppColors.warning,
                onTap: () => context.push(RouteNames.loanList),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          constraints: const BoxConstraints(minWidth: 100),
          padding: AppSpacing.paddingHVXl.copyWith(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.divider),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              AppSpacing.boxWSM,
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
