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
                onPressed: () => _showListViewSheet(context),
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

  void _showListViewSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      barrierColor: AppColors.scrim,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.s.txnLists,
                style: AppTypography.subtitle1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.boxHMD,
              _ListOptionTile(
                icon: Icons.arrow_downward_rounded,
                color: AppColors.success,
                title: AppStrings.s.incListTitle,
                subtitle: AppStrings.s.incListSubtitle,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.incomeList);
                },
              ),
              AppSpacing.boxSM,
              _ListOptionTile(
                icon: Icons.arrow_upward_rounded,
                color: AppColors.error,
                title: AppStrings.s.expListTitle,
                subtitle: AppStrings.s.expListSubtitle,
                onTap: () {
                  Navigator.pop(ctx);
                  context.push(RouteNames.expenseList);
                },
              ),
              AppSpacing.boxSM,
            ],
          ),
        ),
      ),
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
    final isTransfer = tx.type == 'transfer';

    final Color color;
    final IconData icon;
    final String label;
    if (isTransfer) {
      color = AppColors.primary;
      icon = Icons.swap_horiz_rounded;
      label = AppStrings.s.txnTransfer;
    } else if (isLoan) {
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
            if (isTransfer) {
              return;
            }
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

class _ListOptionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ListOptionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
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
                    title,
                    style: AppTypography.subtitle2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.boxXXS,
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
