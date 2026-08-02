import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/app_dialog.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';

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
          title: Text('হিসাব', style: AppTypography.subtitle1),
        ),
        data: (contact) => AppBar(
          title: Text(
            contact?.name ?? 'হিসাব',
            style: AppTypography.subtitle1,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: 'সম্পাদনা',
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
              tooltip: 'মুছে ফেলুন',
              onPressed: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
      body: txnsAsync.when(
        loading: () => const AppLoading(message: 'লেনদেন লোড হচ্ছে...'),
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
          final balance = totalLend - totalBorrow;

          if (txns.isEmpty) {
            return const AppEmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'কোনো লেনদেন নেই',
              subtitle: 'নিচের বাটন দিয়ে টাকা নেওয়া বা দেওয়ার হিসাব যোগ করুন',
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
                  balance: balance,
                ),
                AppSpacing.boxHLG,
                Padding(
                  padding: AppSpacing.paddingHSm,
                  child: Text(
                    'লেনদেনের ইতিহাস',
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
        label: const Text('লেনদেন যোগ করুন'),
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
                  'কি করছেন?',
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
                  title: 'টাকা নিয়েছি',
                  subtitle: '$name থেকে টাকা নিয়েছি',
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
                  title: 'টাকা দিয়েছি',
                  subtitle: '$name কে টাকা দিয়েছি',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(
                      RouteNames.loanTxnAdd,
                      extra: {'contactId': contactId, 'name': name, 'type': 'lend'},
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
      title: 'হিসাব মুছে ফেলবেন?',
      message: 'এই ব্যক্তির সব লেনদেনের হিসাব মুছে যাবে',
      confirmLabel: 'মুছে ফেলুন',
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
      AppSnackBar.success(context, 'হিসাব মুছে ফেলা হয়েছে');
      ref.invalidate(loanDashboardProvider);
      context.pop();
    } else {
      final state = ref.read(loanContactFormProvider);
      state.whenOrNull(
        error: (e, _) => AppSnackBar.error(context, e.toString()),
      );
    }
  }

  Future<void> _confirmDeleteTxn(
    BuildContext context,
    WidgetRef ref,
    LoanTransaction txn,
  ) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'লেনদেন মুছে ফেলবেন?',
      message: 'এই লেনদেনটির হিসাব মুছে যাবে',
      confirmLabel: 'মুছে ফেলুন',
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
      AppSnackBar.success(context, 'লেনদেন মুছে ফেলা হয়েছে');
      ref.invalidate(loanTransactionsProvider(contactId));
      ref.invalidate(loanDashboardProvider);
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
  final double balance;

  const _BalanceCard({
    required this.totalBorrow,
    required this.totalLend,
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
            isSettled ? 'সম্পূর্ণ পরিশোধ' : (balance > 0 ? 'আমি পাবো' : 'আমাকে দিতে হবে'),
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
                  label: 'নিয়েছি',
                  amount: totalBorrow,
                  color: AppColors.error,
                ),
              ),
              Container(width: 1, height: 36, color: color.withValues(alpha: 0.3)),
              Expanded(
                child: _MiniStat(
                  label: 'দিয়েছি',
                  amount: totalLend,
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
  final VoidCallback onDelete;

  const _TransactionTile({required this.txn, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isBorrow = txn.isBorrow;
    final color = isBorrow ? AppColors.error : AppColors.success;
    final icon = isBorrow
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;

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
                    isBorrow ? 'নিয়েছি' : 'দিয়েছি',
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
