import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
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
        title: Text(AppStrings.s.expListTitle, style: AppTypography.subtitle1),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: AppStrings.s.expDailyTab),
            Tab(text: AppStrings.s.expMonthlyTab),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push(RouteNames.expenseMonthlyReport),
            tooltip: AppStrings.s.expMonthlyReportTooltip,
          ),
          IconButton(
            icon: Icon(Icons.category_rounded),
            onPressed: () => context.push(RouteNames.expenseCategories),
            tooltip: AppStrings.s.expCategoryTooltip,
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
        label: Text(AppStrings.s.expAdd),
      ),
    );
  }

  Widget _buildDailyTab(AsyncValue<List<Expense>> expensesAsync) {
    return Column(
      children: [
        AppSpacing.boxSM,
        TransactionFilterBar(
          searchHint: AppStrings.s.expSearchHint,
          completedLabel: AppStrings.s.statusPaid,
          searchProvider: expenseSearchProvider,
          statusProvider: expenseStatusFilterProvider,
          refreshProvider: expenseRefreshProvider,
        ),
        AppSpacing.boxSM,
        Expanded(
          child: expensesAsync.when(
            loading: () => AppLoading(message: AppStrings.s.expLoading),
            error: (e, _) => AppErrorWidget(
              message: e.toString(),
              onRetry: () => ref.invalidate(expenseFilteredListProvider),
            ),
            data: (expenses) {
              if (expenses.isEmpty) {
                return AppEmptyState(
                  icon: Icons.account_balance_wallet_rounded,
                  title: AppStrings.s.expEmpty,
                  subtitle: AppStrings.s.expEmptySubtitle,
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
                      completedStatusText: AppStrings.s.statusPaid,
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
            title: AppStrings.s.incNoData,
            subtitle: AppStrings.s.expEmptyDaySubtitle,
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
                        Text(AppStrings.s.expCount(count), style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
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
    final names = [
      '',
      AppStrings.s.monthJanuary,
      AppStrings.s.monthFebruary,
      AppStrings.s.monthMarch,
      AppStrings.s.monthApril,
      AppStrings.s.monthMay,
      AppStrings.s.monthJune,
      AppStrings.s.monthJuly,
      AppStrings.s.monthAugust,
      AppStrings.s.monthSeptember,
      AppStrings.s.monthOctober,
      AppStrings.s.monthNovember,
      AppStrings.s.monthDecember,
    ];
    return month >= 1 && month <= 12 ? names[month] : '';
  }
}
