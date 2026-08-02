import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_search_field.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/all_transactions_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_card.dart';

class AllTransactionsPage extends ConsumerStatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  ConsumerState<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends ConsumerState<AllTransactionsPage> {
  @override
  Widget build(BuildContext context) {
    final txnsAsync = ref.watch(allTransactionsProvider);
    final selectedType = ref.watch(allTxTypeProvider);
    final selectedStatus = ref.watch(allTxStatusProvider);
    final hasFilter = selectedType != null || selectedStatus != null;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.s.txnAllTitle, style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(allTransactionsProvider),
            tooltip: AppStrings.s.commonRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          AppSpacing.boxSM,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    hintText: AppStrings.s.txnSearchHint,
                    onChanged: (v) =>
                        ref.read(allTxSearchProvider.notifier).state = v,
                  ),
                ),
                AppSpacing.boxMD,
                _FilterButton(
                  active: hasFilter,
                  onTap: () => _showFilterSheet(),
                ),
              ],
            ),
          ),
          AppSpacing.boxSM,
          Expanded(
            child: txnsAsync.when(
              loading: () => AppLoading(message: AppStrings.s.txnLoading),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(allTransactionsProvider),
              ),
              data: (txns) {
                if (txns.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: AppStrings.s.txnNoData,
                    subtitle: AppStrings.s.txnNoDataSubtitle,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allTransactionsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: AppSpacing.huge),
                    itemCount: txns.length,
                    itemBuilder: (context, index) {
                      final entry = txns[index];
                      return _buildCard(entry);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTxnSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(AppStrings.s.txnNew),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      barrierColor: AppColors.scrim,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
      ),
      builder: (ctx) => _FilterSheet(
        selectedType: ref.read(allTxTypeProvider),
        selectedStatus: ref.read(allTxStatusProvider),
        onTypeChanged: (v) {
          ref.read(allTxTypeProvider.notifier).state = v;
          ref.read(allTxRefreshProvider.notifier).state++;
          Navigator.pop(ctx);
        },
        onStatusChanged: (v) {
          ref.read(allTxStatusProvider.notifier).state = v;
          ref.read(allTxRefreshProvider.notifier).state++;
          Navigator.pop(ctx);
        },
        onClear: () {
          ref.read(allTxTypeProvider.notifier).state = null;
          ref.read(allTxStatusProvider.notifier).state = null;
          ref.read(allTxRefreshProvider.notifier).state++;
          Navigator.pop(ctx);
        },
      ),
    );
  }

  Widget _buildCard(TransactionEntry entry) {
    if (entry.isLoan) {
      final isRepay = entry.isLoanRepay;
      final isBorrow = entry.isLoanBorrow;
      final color = isRepay
          ? AppColors.info
          : (isBorrow ? AppColors.error : AppColors.success);
      final icon = isRepay
          ? Icons.autorenew_rounded
          : (isBorrow
              ? Icons.arrow_upward_rounded
              : Icons.arrow_downward_rounded);
      final title = isRepay
          ? AppStrings.s.txnRepay
          : (isBorrow ? AppStrings.s.loanBorrowLabel : AppStrings.s.loanLendLabel);
      return TransactionCard(
        description: entry.contactName ?? '',
        date: entry.date,
        categoryName: title,
        amount: entry.amount,
        status: entry.status,
        iconBackground: color.withValues(alpha: 0.1),
        iconColor: color,
        icon: icon,
        amountColor: color,
        completedStatusText: AppStrings.s.statusCompleted,
        onTap: () {
          final contactId = entry.contactId;
          if (contactId == null) return;
          context.push('${RouteNames.loanDetail}/$contactId');
        },
      );
    }
    final isIncome = entry.isIncome;
    final color = isIncome ? AppColors.success : AppColors.error;
    return TransactionCard(
      description: entry.description ?? '',
      date: entry.date,
      categoryName: entry.categoryName,
      amount: entry.amount,
      status: entry.status,
      iconBackground: color.withValues(alpha: 0.1),
      iconColor: color,
      icon: isIncome
          ? Icons.arrow_downward_rounded
          : Icons.arrow_upward_rounded,
      amountColor: color,
      completedStatusText: isIncome ? AppStrings.s.statusReceived : AppStrings.s.statusPaid,
      onTap: () {
        final route = isIncome
            ? '${RouteNames.incomeDetail}/${entry.id}'
            : '${RouteNames.expenseDetail}/${entry.id}';
        context.push(route);
      },
    );
  }

  void _showAddTxnSheet() {
    showModalBottomSheet<void>(
      context: context,
      barrierColor: AppColors.scrim,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXxl)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.s.txnAddPrompt,
                style: AppTypography.subtitle1.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.boxHMD,
              _SheetAction(
                icon: Icons.arrow_downward_rounded,
                color: AppColors.success,
                title: AppStrings.s.txnIncomeTitle,
                subtitle: AppStrings.s.txnIncomeSubtitle,
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await context.push<bool>(RouteNames.incomeAdd);
                  if (result == true) {
                    ref.invalidate(allTransactionsProvider);
                    ref.invalidate(allTxRefreshProvider);
                  }
                },
              ),
              AppSpacing.boxSM,
              _SheetAction(
                icon: Icons.arrow_upward_rounded,
                color: AppColors.error,
                title: AppStrings.s.txnExpenseTitle,
                subtitle: AppStrings.s.txnExpenseSubtitle,
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await context.push<bool>(RouteNames.expenseAdd);
                  if (result == true) {
                    ref.invalidate(allTransactionsProvider);
                    ref.invalidate(allTxRefreshProvider);
                  }
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
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _FilterButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: active ? AppColors.primary : AppColors.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: BorderSide(
              color: active ? AppColors.primary : AppColors.border,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.filter_alt_rounded,
                color: active ? AppColors.white : AppColors.textPrimary,
                size: 22,
              ),
            ),
          ),
        ),
        if (active)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.scaffoldBackground, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final String? selectedType;
  final String? selectedStatus;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.selectedType,
    required this.selectedStatus,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _type = widget.selectedType;
  late String? _status = widget.selectedStatus;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.s.commonFilter,
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_type != null || _status != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _type = null;
                        _status = null;
                      });
                      widget.onClear();
                    },
                    child: Text(AppStrings.s.txnClearAll),
                  ),
              ],
            ),
            AppSpacing.boxMD,
            Text(AppStrings.s.txnType, style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
            AppSpacing.boxSM,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildOption(label: AppStrings.s.txnAll, value: null, selected: _type, onSelected: (v) {
                  setState(() => _type = v);
                  widget.onTypeChanged(v);
                }),
                _buildOption(label: AppStrings.s.txnIncomeTitle, value: 'income', selected: _type, onSelected: (v) {
                  setState(() => _type = v);
                  widget.onTypeChanged(v);
                }),
                _buildOption(label: AppStrings.s.txnExpenseTitle, value: 'expense', selected: _type, onSelected: (v) {
                  setState(() => _type = v);
                  widget.onTypeChanged(v);
                }),
                _buildOption(label: AppStrings.s.txnLoan, value: 'loan', selected: _type, onSelected: (v) {
                  setState(() => _type = v);
                  widget.onTypeChanged(v);
                }),
              ],
            ),
            AppSpacing.boxMD,
            Text(AppStrings.s.txnStatusFilter, style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
            AppSpacing.boxSM,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _buildOption(label: AppStrings.s.txnAll, value: null, selected: _status, onSelected: (v) {
                  setState(() => _status = v);
                  widget.onStatusChanged(v);
                }),
                _buildOption(label: AppStrings.s.statusCompleted, value: 'completed', selected: _status, onSelected: (v) {
                  setState(() => _status = v);
                  widget.onStatusChanged(v);
                }),
                _buildOption(label: AppStrings.s.statusPending, value: 'pending', selected: _status, onSelected: (v) {
                  setState(() => _status = v);
                  widget.onStatusChanged(v);
                }),
                _buildOption(label: AppStrings.s.statusCancelled, value: 'cancelled', selected: _status, onSelected: (v) {
                  setState(() => _status = v);
                  widget.onStatusChanged(v);
                }),
              ],
            ),
            AppSpacing.boxLG,
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required String? value,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
