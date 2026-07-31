import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ExpenseCard({super.key, required this.expense, this.onTap, this.onLongPress});

  Color get _statusColor {
    switch (expense.status) {
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
    switch (expense.status) {
      case 'completed':
        return 'পরিশোধিত';
      case 'pending':
        return 'বকেয়া';
      case 'cancelled':
        return 'বাতিল';
      default:
        return expense.status;
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
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(Icons.arrow_upward_rounded, color: AppColors.error, size: 22),
              ),
              AppSpacing.boxMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (expense.description != null && expense.description!.isNotEmpty)
                      Text(expense.description!, style: AppTypography.subtitle2, maxLines: 1, overflow: TextOverflow.ellipsis),
                    AppSpacing.boxXS,
                    Row(
                      children: [
                        Text(AppDateUtils.formatDate(expense.expenseDate), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        if (expense.catName != null) ...[
                          AppSpacing.boxSM,
                          Icon(Icons.circle, size: 4, color: AppColors.textHint),
                          AppSpacing.boxSM,
                          Text(expense.catName!, style: AppTypography.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
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
                  Text(AppNumberUtils.formatCurrency(expense.amount), style: AppTypography.subtitle1.copyWith(color: AppColors.error, fontWeight: FontWeight.w700)),
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
