import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/features/reports/domain/entities/report.dart';

class ReportSummaryCard extends StatelessWidget {
  final ReportSummary summary;

  const ReportSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary.period,
              style: AppTypography.subtitle2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.boxHLG,
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'মোট আয়',
                    amount: summary.totalIncome,
                    color: AppColors.success,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'মোট ব্যয়',
                    amount: summary.totalExpense,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            AppSpacing.boxHMD,
            const Divider(height: 1, color: AppColors.divider),
            AppSpacing.boxHMD,
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'নেট পরিমাণ',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      AppSpacing.boxHXS,
                      Text(
                        AppNumberUtils.formatCurrency(summary.netAmount),
                        style: AppTypography.subtitle1.copyWith(
                          color: summary.netAmount >= 0
                              ? AppColors.info
                              : AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'মোট লেনদেন',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.boxHXS,
                    Text(
                      '${summary.totalTransactions} টি',
                      style: AppTypography.subtitle1.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
