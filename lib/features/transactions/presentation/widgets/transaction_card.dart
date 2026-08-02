import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';

class TransactionCard extends StatelessWidget {
  final String description;
  final DateTime date;
  final String? categoryName;
  final double amount;
  final String status;
  final Color iconBackground;
  final Color iconColor;
  final IconData icon;
  final Color amountColor;
  final String completedStatusText;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionCard({
    super.key,
    required this.description,
    required this.date,
    required this.categoryName,
    required this.amount,
    required this.status,
    required this.iconBackground,
    required this.iconColor,
    required this.icon,
    required this.amountColor,
    required this.completedStatusText,
    this.onTap,
    this.onLongPress,
  });

  Color get _statusColor {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String get _statusText {
    switch (status) {
      case 'completed':
        return completedStatusText;
      case 'pending':
        return 'বকেয়া';
      case 'cancelled':
        return 'বাতিল';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: Icon(icon, color: iconColor, size: 22),
              ),
              AppSpacing.boxMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: AppTypography.subtitle2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    AppSpacing.boxXS,
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            AppDateUtils.formatDate(date),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (categoryName != null) ...[
                          AppSpacing.boxSM,
                          const Icon(Icons.circle, size: 4, color: AppColors.textHint),
                          AppSpacing.boxSM,
                          Flexible(
                            child: Text(
                              categoryName!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.boxMD,
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppNumberUtils.formatCurrency(amount),
                    style: AppTypography.subtitle1.copyWith(
                      color: amountColor,
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
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusText,
                      style: AppTypography.overline.copyWith(
                        color: _statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
