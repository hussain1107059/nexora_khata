import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/config/theme/app_typography.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/dashboard_summary.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<RecentTransaction> transactions;

  const RecentTransactionsList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Padding(
        padding: AppSpacing.paddingLg,
        child: Center(
          child: Text(
            'কোনো লেনদেন নেই',
            style: AppTypography.bodyText2.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'সাম্প্রতিক লেনদেন',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'সব দেখুন',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...transactions.take(5).map((tx) => _TransactionTile(tx: tx)),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final RecentTransaction tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == 'income';
    final color = isIncome ? AppColors.success : AppColors.error;
    final icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final label = isIncome ? 'আয়' : 'ব্যয়';

    return Container(
      margin: AppSpacing.paddingHSm.copyWith(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () {},
          child: Padding(
            padding: AppSpacing.paddingHVXl.copyWith(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                AppSpacing.boxWMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description ?? tx.categoryName ?? label,
                        style: AppTypography.bodyText2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.boxHXS,
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              label,
                              style: AppTypography.overline.copyWith(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          AppSpacing.boxWSM,
                          Text(
                            AppDateUtils.timeAgo(tx.date),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  AppNumberUtils.formatCurrency(tx.amount),
                  style: AppTypography.bodyText2.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
