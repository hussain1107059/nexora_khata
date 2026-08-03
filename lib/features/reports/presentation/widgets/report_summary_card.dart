import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';

class ReportSummaryCard extends StatelessWidget {
  final ReportSummary summary;
  final String? periodText;

  const ReportSummaryCard({super.key, required this.summary, this.periodText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: AppSpacing.paddingLg,
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: Text(
              periodText ?? summary.period,
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: AppStrings.s.dashboardTotalIncome,
                    amount: summary.totalIncome,
                    color: AppColors.success,
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _SummaryItem(
                    label: AppStrings.s.dashboardTotalExpense,
                    amount: summary.totalExpense,
                    color: AppColors.error,
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _SummaryItem(
                    label: AppStrings.s.rptNetAmount,
                    amount: summary.netAmount,
                    color: summary.netAmount >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.boxHXS,
        Text(
          AppNumberUtils.formatCurrency(amount),
          style: AppTypography.subtitle1.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
