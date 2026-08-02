import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/features/loans/presentation/models/loan_summary.dart';

class LoanSummaryHeader extends StatelessWidget {
  final LoanDashboard dashboard;

  const LoanSummaryHeader({super.key, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: AppSpacing.paddingHSm,
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
              gradient: AppColors.infoGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.currency_exchange_rounded,
                    size: 18,
                    color: AppColors.white,
                  ),
                ),
                AppSpacing.boxWMD,
                Expanded(
                  child: Text(
                    AppStrings.s.loanSummary,
                    style: AppTypography.subtitle2.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: AppStrings.s.loanTotalReceivable,
                    amount: dashboard.totalLend,
                    color: AppColors.success,
                  ),
                ),
                Container(width: 1, height: 44, color: AppColors.divider),
                Expanded(
                  child: _SummaryItem(
                    label: AppStrings.s.loanTotalDebt,
                    amount: dashboard.totalBorrow,
                    color: AppColors.error,
                  ),
                ),
                Container(width: 1, height: 44, color: AppColors.divider),
                Expanded(
                  child: _SummaryItem(
                    label: AppStrings.s.loanNet,
                    amount: dashboard.netBalance,
                    color: dashboard.netBalance >= 0
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
          AppNumberUtils.formatCurrency(amount, decimalDigits: 0),
          style: AppTypography.subtitle1.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
