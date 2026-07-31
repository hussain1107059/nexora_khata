import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';

class IncomeCard extends StatelessWidget {
  final Income income;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const IncomeCard({super.key, required this.income, this.onTap, this.onLongPress});

  Color get _statusColor {
    switch (income.status) {
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
    switch (income.status) {
      case 'completed':
        return 'গৃহীত';
      case 'pending':
        return 'বকেয়া';
      case 'cancelled':
        return 'বাতিল';
      default:
        return income.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.arrow_downward_rounded, color: AppColors.success, size: 22),
              ),
              AppSpacing.boxMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (income.description != null && income.description!.isNotEmpty)
                      Text(income.description!, style: AppTypography.subtitle2, maxLines: 1, overflow: TextOverflow.ellipsis),
                    AppSpacing.boxXS,
                    Row(
                      children: [
                        Text(AppDateUtils.formatDate(income.incomeDate), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        if (income.catName != null) ...[
                          AppSpacing.boxSM,
                          Icon(Icons.circle, size: 4, color: AppColors.textHint),
                          AppSpacing.boxSM,
                          Text(income.catName!, style: AppTypography.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.boxMD,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(AppNumberUtils.formatCurrency(income.amount), style: AppTypography.subtitle1.copyWith(color: AppColors.success, fontWeight: FontWeight.w700)),
                  AppSpacing.boxXS,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                    ),
                    child: Text(_statusText, style: AppTypography.caption.copyWith(color: _statusColor, fontSize: 10)),
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
