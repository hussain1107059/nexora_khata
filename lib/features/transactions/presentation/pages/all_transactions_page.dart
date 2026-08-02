import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/features/transactions/presentation/models/transaction_entry.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/all_transactions_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_filter_bar.dart';

class AllTransactionsPage extends ConsumerStatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  ConsumerState<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends ConsumerState<AllTransactionsPage> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    final txnsAsync = ref.watch(allTransactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('সব লেনদেন', style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(allTransactionsProvider),
            tooltip: 'রিফ্রেশ',
          ),
        ],
      ),
      body: Column(
        children: [
          AppSpacing.boxSM,
          TransactionFilterBar(
            searchHint: 'লেনদেন অনুসন্ধান করুন...',
            completedLabel: 'সম্পন্ন',
            searchProvider: allTxSearchProvider,
            statusProvider: allTxStatusProvider,
            refreshProvider: allTxRefreshProvider,
          ),
          AppSpacing.boxSM,
          _buildTypeFilter(),
          AppSpacing.boxSM,
          Expanded(
            child: txnsAsync.when(
              loading: () => const AppLoading(message: 'লেনদেন লোড হচ্ছে...'),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(allTransactionsProvider),
              ),
              data: (txns) {
                if (txns.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'কোনো লেনদেন নেই',
                    subtitle: 'নতুন লেনদেন যোগ করতে নিচের বাটনে ক্লিক করুন',
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
        label: const Text('নতুন লেনদেন'),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          _buildChip('সব', null),
          AppSpacing.boxSM,
          _buildChip('আয়', 'income'),
          AppSpacing.boxSM,
          _buildChip('ব্যয়', 'expense'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String? type) {
    final selected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedType = selected ? null : type);
        ref.read(allTxTypeProvider.notifier).state = _selectedType;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: selected ? AppColors.white : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(TransactionEntry entry) {
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
      completedStatusText: isIncome ? 'গৃহীত' : 'পরিশোধিত',
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
                'কি যোগ করবেন?',
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
                title: 'আয়',
                subtitle: 'টাকা পেয়েছি (বেতন, বিক্রয় ইত্যাদি)',
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
                title: 'ব্যয়',
                subtitle: 'টাকা খরচ হয়েছে (খাদ্য, ভাড়া ইত্যাদি)',
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
