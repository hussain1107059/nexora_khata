import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/config/theme/app_typography.dart';
import '../../../../core/router/route_names.dart';
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
            AppStrings.s.dashboardNoTransaction,
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
                AppStrings.s.dashboardRecentTransactions,
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => context.push(RouteNames.incomeList),
                child: Text(
                  AppStrings.s.dashboardViewAll,
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
    final isLoan = tx.type == 'loan';
    final isRepay = isLoan && tx.loanType == 'repay';
    final isBorrow = isLoan && tx.loanType == 'borrow';

    final Color color;
    final IconData icon;
    final String label;
    if (isLoan) {
      color = isRepay
          ? AppColors.info
          : (isBorrow ? AppColors.error : AppColors.success);
      icon = isRepay
          ? Icons.autorenew_rounded
          : (isBorrow
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded);
      label = isRepay
          ? AppStrings.s.txnRepay
          : (isBorrow ? AppStrings.s.loanBorrowLabel : AppStrings.s.loanLendLabel);
    } else {
      final isIncome = tx.type == 'income';
      color = isIncome ? AppColors.success : AppColors.error;
      icon = isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
      label = isIncome ? AppStrings.s.dashboardIncome : AppStrings.s.dashboardExpense;
    }

    return Container(
      margin: AppSpacing.paddingHSm.copyWith(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          onTap: () {
            if (isLoan) {
              final contactId = tx.contactId;
              if (contactId != null) {
                context.push('${RouteNames.loanDetail}/$contactId');
              }
            } else if (tx.type == 'income') {
              context.push('${RouteNames.incomeDetail}/${tx.id}');
            } else {
              context.push('${RouteNames.expenseDetail}/${tx.id}');
            }
          },
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
                        tx.description ?? tx.categoryName ?? tx.contactName ?? label,
                        style: AppTypography.bodyText2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.boxHXS,
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
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
                          Text(
                            AppDateUtils.timeAgo(tx.date),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textHint,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Text(
                    AppNumberUtils.formatCurrency(tx.amount),
                    style: AppTypography.bodyText2.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
