import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';import 'package:nexora_khata/core/widgets/app_dialog.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/all_transactions_provider.dart';

class LoanDetailPage extends ConsumerWidget {
  final int contactId;

  const LoanDetailPage({super.key, required this.contactId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(loanContactDetailProvider(contactId));
    final txnsAsync = ref.watch(loanTransactionsProvider(contactId));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: contactAsync.when(
        loading: () => AppBar(title: const Text('...')),
        error: (_, _) => AppBar(
          title: Text(AppStrings.s.loanDetailTitle, style: AppTypography.subtitle1),
        ),
        data: (contact) => AppBar(
          title: Text(
            contact?.name ?? AppStrings.s.loanDetailTitle,
            style: AppTypography.subtitle1,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: AppStrings.s.loanEdit,
              onPressed: () async {
                if (contact == null) return;
                final result = await context.push<bool>(
                  RouteNames.loanContactEdit,
                  extra: contact,
                );
                if (result == true) {
                  ref.invalidate(loanContactDetailProvider(contactId));
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_rounded),
              tooltip: AppStrings.s.loanDelete,
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
      body: txnsAsync.when(
        loading: () => AppLoading(message: AppStrings.s.loanTxnLoading),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(loanTransactionsProvider(contactId)),
        ),
        data: (txns) {
          final totalBorrow = txns
              .where((t) => t.isBorrow)
              .fold<double>(0, (s, t) => s + t.amount);
          final totalLend = txns
              .where((t) => t.isLend)
              .fold<double>(0, (s, t) => s + t.amount);
          final repaidBorrow = txns
              .where((t) => t.repaysBorrow)
              .fold<double>(0, (s, t) => s + t.amount);
          final repaidLend = txns
              .where((t) => t.repaysLend)
              .fold<double>(0, (s, t) => s + t.amount);
          final remainingBorrow = totalBorrow - repaidBorrow;
          final remainingLend = totalLend - repaidLend;
          final balance = remainingLend - remainingBorrow;

          if (txns.isEmpty) {
            return AppEmptyState(
              icon: Icons.receipt_long_rounded,
              title: AppStrings.s.loanTxnEmpty,
              subtitle: AppStrings.s.loanTxnEmptySubtitle,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(loanTransactionsProvider(contactId));
              ref.invalidate(loanDashboardProvider);
            },
            child: ListView(
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.huge,
              ),
              children: [
                _BalanceCard(
                  totalBorrow: totalBorrow,
                  totalLend: totalLend,
                  repaidBorrow: repaidBorrow,
                  repaidLend: repaidLend,
                  balance: balance,
                ),
                AppSpacing.boxHLG,
                Padding(
                  padding: AppSpacing.paddingHSm,
                  child: Text(
                    AppStrings.s.loanHistory,
                    style: AppTypography.subtitle2.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AppSpacing.boxHSM,
                for (final txn in txns)
                  _TransactionTile(
                    txn: txn,
                    onEdit: () => _editTxn(context, ref, txn),
                    onDelete: () => _confirmDeleteTxn(context, ref, txn),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTxnSheet(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppStrings.s.loanAddTxn),
      ),
    );
  }

  void _showAddTxnSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      barrierColor: AppColors.scrim,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
      ),
      builder: (ctx) {
        final name = ref
                .read(loanContactDetailProvider(contactId))
                .valueOrNull
                ?.name ??
            '';
        return SafeArea(
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.s.loanActionPrompt,
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.boxHMD,
                _SheetAction(
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.error,
                  title: AppStrings.s.loanBorrow,
                  subtitle: AppStrings.s.loanBorrowSubtitle(name),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(
                      RouteNames.loanTxnAdd,
                      extra: {'contactId': contactId, 'name': name, 'type': 'borrow'},
                    );
                  },
                ),
                AppSpacing.boxSM,
                _SheetAction(
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.success,
                  title: AppStrings.s.loanLend,
                  subtitle: AppStrings.s.loanLendSubtitle(name),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(
                      RouteNames.loanTxnAdd,
                      extra: {'contactId': contactId, 'name': name, 'type': 'lend'},
                    );
                  },
                ),
                AppSpacing.boxSM,
                _SheetAction(
                  icon: Icons.autorenew_rounded,
                  color: AppColors.info,
                  title: AppStrings.s.loanRepay,
                  subtitle: AppStrings.s.loanRepaySubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(
                      RouteNames.loanTxnAdd,
                      extra: {'contactId': contactId, 'name': name, 'type': 'repay'},
                    );
                  },
                ),
                AppSpacing.boxSM,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.s.loanDeleteTitle,
      message: AppStrings.s.loanDeleteMsg,
      confirmLabel: AppStrings.s.loanDelete,
      destructive: true,
      icon: Icons.delete_rounded,
      iconColor: AppColors.error,
      iconBackground: AppColors.errorLight,
    );
    if (confirmed != true || !context.mounted) return;
    final notifier = ref.read(loanContactFormProvider.notifier);
    final success = await notifier.delete(contactId);
    if (!context.mounted) return;
    if (success) {
      AppSnackBar.success(context, AppStrings.s.loanDeleted);
      ref.invalidate(loanDashboardProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(dashboardRefreshProvider);
      ref.invalidate(allTransactionsProvider);
      ref.invalidate(allTxRefreshProvider);
      context.pop();
    } else {
      final state = ref.read(loanContactFormProvider);
      state.whenOrNull(
        error: (e, _) => AppSnackBar.error(context, e.toString()),
      );
    }
  }

  Future<void> _editTxn(
    BuildContext context,
    WidgetRef ref,
    LoanTransaction txn,
  ) async {
    final name =
        ref.read(loanContactDetailProvider(contactId)).valueOrNull?.name ?? '';
    final result = await context.push<bool>(
      RouteNames.loanTxnEdit,
      extra: {'transaction': txn, 'name': name},
    );
    if (result == true) {
      ref.invalidate(loanTransactionsProvider(contactId));
      ref.invalidate(loanDashboardProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(dashboardRefreshProvider);
      ref.invalidate(allTransactionsProvider);
      ref.invalidate(allTxRefreshProvider);
    }
  }

  Future<void> _confirmDeleteTxn(
    BuildContext context,
    WidgetRef ref,
    LoanTransaction txn,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.s.loanTxnDeleteTitle,
      message: AppStrings.s.loanTxnDeleteMsg,
      confirmLabel: AppStrings.s.loanDelete,
      destructive: true,
      icon: Icons.delete_rounded,
      iconColor: AppColors.error,
      iconBackground: AppColors.errorLight,
    );
    if (confirmed != true || !context.mounted) return;
    final notifier = ref.read(loanTransactionFormProvider.notifier);
    final success = await notifier.delete(txn.id);
    if (!context.mounted) return;
    if (success) {
      AppSnackBar.success(context, AppStrings.s.loanTxnDeleted);
      ref.invalidate(loanTransactionsProvider(contactId));
      ref.invalidate(loanDashboardProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(dashboardRefreshProvider);
      ref.invalidate(allTransactionsProvider);
      ref.invalidate(allTxRefreshProvider);
    } else {
      final state = ref.read(loanTransactionFormProvider);
      state.whenOrNull(
        error: (e, _) => AppSnackBar.error(context, e.toString()),
      );
    }
  }
}

class _BalanceCard extends StatelessWidget {
  final double totalBorrow;
  final double totalLend;
  final double repaidBorrow;
  final double repaidLend;
  final double balance;

  const _BalanceCard({
    required this.totalBorrow,
    required this.totalLend,
    required this.repaidBorrow,
    required this.repaidLend,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final isSettled = balance == 0;
    final color = isSettled ? AppColors.textSecondary : (balance > 0 ? AppColors.success : AppColors.error);

    return Container(
      margin: AppSpacing.paddingHSm,
      padding: AppSpacing.paddingXl,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isSettled
                ? AppStrings.s.loanFullSettled
                : (balance > 0 ? AppStrings.s.loanYouReceive : AppStrings.s.loanYouOwe),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.boxHSM,
          Text(
            AppNumberUtils.formatCurrency(balance.abs()),
            style: AppTypography.heading4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.boxHMD,
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: AppStrings.s.loanBorrowLabel,
                  amount: totalBorrow,
                  color: AppColors.error,
                ),
              ),
              Container(width: 1, height: 36, color: color.withValues(alpha: 0.3)),
              Expanded(
                child: _MiniStat(
                  label: AppStrings.s.loanLendLabel,
                  amount: totalLend,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          AppSpacing.boxSM,
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: AppStrings.s.loanRepayBorrow,
                  amount: repaidBorrow,
                  color: AppColors.error,
                ),
              ),
              Container(width: 1, height: 36, color: color.withValues(alpha: 0.3)),
              Expanded(
                child: _MiniStat(
                  label: AppStrings.s.loanRepayLend,
                  amount: repaidLend,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _MiniStat({
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
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        AppSpacing.boxHXS,
        Text(
          AppNumberUtils.formatCurrency(amount),
          style: AppTypography.subtitle2.copyWith(
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

class _TransactionTile extends StatelessWidget {
  final LoanTransaction txn;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionTile({
    required this.txn,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBorrow = txn.isBorrow;
    final isRepay = txn.isRepay;
    final color = isRepay
        ? AppColors.info
        : (isBorrow ? AppColors.error : AppColors.success);
    final icon = isRepay
        ? Icons.autorenew_rounded
        : (isBorrow
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded);
    final title = isRepay
        ? (txn.repaysBorrow ? AppStrings.s.loanRepayBorrowed : AppStrings.s.loanRepayLent)
        : (isBorrow ? AppStrings.s.loanBorrowLabel : AppStrings.s.loanLendLabel);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.boxXXS,
                  Text(
                    AppDateUtils.formatDate(txn.date),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (txn.paymentMethod != null &&
                      txn.paymentMethod!.isNotEmpty) ...[
                    AppSpacing.boxXXS,
                    Text(
                      AppNumberUtils.formatPaymentMethod(txn.paymentMethod!),
                      style: AppTypography.caption.copyWith(
                        color: txn.isCash ? AppColors.primary : AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (txn.note != null && txn.note!.isNotEmpty) ...[
                    AppSpacing.boxXXS,
                    Text(
                      txn.note!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.boxMD,
            Text(
              AppNumberUtils.formatCurrency(txn.amount),
              style: AppTypography.subtitle1.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.boxSM,
            GestureDetector(
              onTap: onEdit,
              child: const Icon(
                Icons.edit_rounded,
                size: 20,
                color: AppColors.textHint,
              ),
            ),
            AppSpacing.boxXS,
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetAction({
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
          ],
        ),
      ),
    );
  }
}
