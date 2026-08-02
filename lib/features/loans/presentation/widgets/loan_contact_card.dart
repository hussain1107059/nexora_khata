import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/features/loans/presentation/models/loan_summary.dart';

class LoanContactCard extends StatelessWidget {
  final LoanContactSummary summary;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const LoanContactCard({
    super.key,
    required this.summary,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final contact = summary.contact;
    final isReceivable = summary.isReceivable;
    final color = summary.isSettled ? AppColors.textSecondary : (isReceivable ? AppColors.success : AppColors.error);
    final iconBackground = summary.isSettled
        ? AppColors.chipBackground
        : (isReceivable ? AppColors.successLight : AppColors.errorLight);
    final icon = summary.isSettled
        ? Icons.check_circle_rounded
        : (isReceivable ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded);
    final tag = summary.isSettled
        ? 'পরিশোধিত'
        : (isReceivable ? 'পাওনা' : 'দেনা');
    final balanceText = summary.isSettled
        ? AppNumberUtils.formatCurrency(0, decimalDigits: 0)
        : AppNumberUtils.formatCurrency(summary.balance.abs(), decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              AppSpacing.boxMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: AppTypography.subtitle2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.boxXS,
                    Row(
                      children: [
                        if (contact.phone != null && contact.phone!.isNotEmpty) ...[
                          Text(
                            contact.phone!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSpacing.boxSM,
                          const Icon(
                            Icons.circle,
                            size: 4,
                            color: AppColors.textHint,
                          ),
                          AppSpacing.boxSM,
                        ],
                        Text(
                          summary.isSettled
                              ? 'সম্পূর্ণ পরিশোধ'
                              : 'আমি ${isReceivable ? "পাবো" : "দেবো"}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.boxMD,
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balanceText,
                      style: AppTypography.subtitle1.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.boxXS,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.overline.copyWith(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
