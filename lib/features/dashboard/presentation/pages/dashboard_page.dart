import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/config/theme/app_typography.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/quick_action_buttons.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/monthly_chart.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'নেক্সোরা খাতা',
              style: AppTypography.subtitle1.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'ড্যাশবোর্ড',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
        ],
      ),
      body: dashboardAsync.when(
        loading: () => const AppShimmerLoading(itemCount: 6),
        error: (err, stack) => AppErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(dashboardProvider),
        ),
        data: (data) => _DashboardContent(data: data),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final dynamic data;

  const _DashboardContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: AppSpacing.screenPadding.copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTodaySection(context),
          AppSpacing.boxHLG,
          _buildBalanceSection(context),
          AppSpacing.boxHXL,
          const QuickActionButtons(),
          AppSpacing.boxHXL,
          MonthlyChart(data: data.monthlyReport),
          AppSpacing.boxHXL,
          RecentTransactionsList(transactions: data.recentTransactions),
        ],
      ),
    );
  }

  Widget _buildTodaySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingHSm,
          child: Text(
            'আজকের হিসাব',
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppSpacing.boxHSM,
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: StatCardLarge(
                      title: 'আজকের আয়',
                      amount: data.todayIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.success,
                    ),
                  ),
                  AppSpacing.boxWMD,
                  Expanded(
                    child: StatCardLarge(
                      title: 'আজকের ব্যয়',
                      amount: data.todayExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.error,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                StatCardLarge(
                  title: 'আজকের আয়',
                  amount: data.todayIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.success,
                ),
                AppSpacing.boxHSM,
                StatCardLarge(
                  title: 'আজকের ব্যয়',
                  amount: data.todayExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.error,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBalanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingHSm,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ব্যালেন্স',
                style: AppTypography.subtitle2.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: data.totalBalance >= 0
                      ? AppColors.successLight
                      : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'মোট: ${data.totalBalance >= 0 ? '+' : ''}৳${data.totalBalance.toStringAsFixed(0)}',
                  style: AppTypography.caption.copyWith(
                    color: data.totalBalance >= 0
                        ? AppColors.success
                        : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        AppSpacing.boxHSM,
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            final cards = [
              StatCard(
                title: 'ক্যাশ ব্যালেন্স',
                amount: data.cashBalance,
                icon: Icons.money_rounded,
                color: AppColors.success,
              ),
              StatCard(
                title: 'ব্যাংক ব্যালেন্স',
                amount: data.bankBalance,
                icon: Icons.account_balance_rounded,
                color: AppColors.info,
              ),
              StatCard(
                title: 'মোট আয়',
                amount: data.totalIncome,
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
              ),
              StatCard(
                title: 'মোট ব্যয়',
                amount: data.totalExpense,
                icon: Icons.trending_down_rounded,
                color: AppColors.error,
              ),
            ];

            if (isWide) {
              return Row(
                children: cards.map((c) => Expanded(child: Padding(
                  padding: AppSpacing.paddingHSm,
                  child: c,
                ))).toList(),
              );
            }

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Padding(
                      padding: AppSpacing.paddingHSm,
                      child: cards[0],
                    )),
                    Expanded(child: Padding(
                      padding: AppSpacing.paddingHSm,
                      child: cards[1],
                    )),
                  ],
                ),
                AppSpacing.boxHSM,
                Row(
                  children: [
                    Expanded(child: Padding(
                      padding: AppSpacing.paddingHSm,
                      child: cards[2],
                    )),
                    Expanded(child: Padding(
                      padding: AppSpacing.paddingHSm,
                      child: cards[3],
                    )),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
