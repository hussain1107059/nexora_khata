import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_card.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_filter_bar.dart';

class ExpenseListPage extends ConsumerStatefulWidget {
  const ExpenseListPage({super.key});

  @override
  ConsumerState<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends ConsumerState<ExpenseListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseFilteredListProvider);
    final reportAsync = ref.watch(expenseMonthlyReportProvider(DateTime.now().year));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('ব্যয়ের তালিকা', style: AppTypography.subtitle1),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'দৈনিক'),
            Tab(text: 'মাসিক'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push(RouteNames.expenseMonthlyReport),
            tooltip: 'মাসিক রিপোর্ট',
          ),
          IconButton(
            icon: Icon(Icons.category_rounded),
            onPressed: () => context.push(RouteNames.expenseCategories),
            tooltip: 'ক্যাটাগরি',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(expensesAsync),
          _buildMonthlyTab(reportAsync),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>(RouteNames.expenseAdd);
          if (result == true) {
            ref.invalidate(expenseFilteredListProvider);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: Icon(Icons.add_rounded),
        label: Text('নতুন ব্যয়'),
      ),
    );
  }

  Widget _buildDailyTab(AsyncValue<List<Expense>> expensesAsync) {
    return Column(
      children: [
        AppSpacing.boxSM,
        TransactionFilterBar(
          searchHint: 'ব্যয় অনুসন্ধান করুন...',
          completedLabel: 'পরিশোধিত',
          searchProvider: expenseSearchProvider,
          statusProvider: expenseStatusFilterProvider,
          refreshProvider: expenseRefreshProvider,
        ),
        AppSpacing.boxSM,
        Expanded(
          child: expensesAsync.when(
            loading: () => AppLoading(message: 'ব্যয় লোড হচ্ছে...'),
            error: (e, _) => AppErrorWidget(
              message: e.toString(),
              onRetry: () => ref.invalidate(expenseFilteredListProvider),
            ),
            data: (expenses) {
              if (expenses.isEmpty) {
                return AppEmptyState(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'কোনো ব্যয় নেই',
                  subtitle: 'নতুন ব্যয় যোগ করতে নিচের বাটনে ক্লিক করুন',
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(expenseFilteredListProvider);
                },
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: AppSpacing.huge),
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return TransactionCard(
                      description: expense.description ?? '',
                      date: expense.expenseDate,
                      categoryName: expense.catName,
                      amount: expense.amount,
                      status: expense.status,
                      iconBackground: AppColors.errorLight,
                      iconColor: AppColors.error,
                      icon: Icons.arrow_upward_rounded,
                      amountColor: AppColors.error,
                      completedStatusText: 'পরিশোধিত',
                      onTap: () => context.push('${RouteNames.expenseDetail}/${expense.id}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlyTab(AsyncValue<List<Map<String, dynamic>>> reportAsync) {
    return reportAsync.when(
      loading: () => const AppLoading(),
      error: (e, _) => AppErrorWidget(message: e.toString()),
      data: (report) {
        if (report.isEmpty) {
          return AppEmptyState(
            icon: Icons.bar_chart_rounded,
            title: 'কোনো তথ্য নেই',
            subtitle: 'এই বছরের জন্য কোনো ব্যয় পাওয়া যায়নি',
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(AppSpacing.lg),
          itemCount: report.length,
          separatorBuilder: (_, _) => AppSpacing.boxSM,
          itemBuilder: (context, index) {
            final r = report[index];
            final month = int.tryParse(r['month']?.toString() ?? '0') ?? 0;
            final count = r['count'] as int? ?? 0;
            final total = (r['total'] as num?)?.toDouble() ?? 0;
            final monthName = _monthName(month);

            return Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 2, offset: const Offset(0, 1))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Center(
                      child: Text(month.toString().padLeft(2, '0'), style: AppTypography.subtitle1.copyWith(
                        color: AppColors.error, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  AppSpacing.boxMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(monthName, style: AppTypography.subtitle2),
                        Text('$count টি লেনদেন', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Flexible(
                    child: Text(AppNumberUtils.formatCurrency(total),
                      style: AppTypography.subtitle1.copyWith(
                        color: AppColors.error, fontWeight: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _monthName(int month) {
    const names = ['', 'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন', 'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর'];
    return month >= 1 && month <= 12 ? names[month] : '';
  }
}
