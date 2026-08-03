import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
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
        title: Text(
          AppStrings.s.appTitle,
          style: AppTypography.subtitle1.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
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
            AppStrings.s.dashboardTodaySummary,
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
                      title: AppStrings.s.dashboardTodayIncome,
                      amount: data.todayIncome,
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.success,
                      gradient: AppColors.successGradient,
                    ),
                  ),
                  AppSpacing.boxWMD,
                  Expanded(
                    child: StatCardLarge(
                      title: AppStrings.s.dashboardTodayExpense,
                      amount: data.todayExpense,
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.error,
                      gradient: AppColors.errorGradient,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                StatCardLarge(
                  title: AppStrings.s.dashboardTodayIncome,
                  amount: data.todayIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.success,
                  gradient: AppColors.successGradient,
                ),
                AppSpacing.boxHSM,
                StatCardLarge(
                  title: AppStrings.s.dashboardTodayExpense,
                  amount: data.todayExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.error,
                  gradient: AppColors.errorGradient,
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
              Flexible(
                child: Text(
                  AppStrings.s.dashboardBalance,
                  style: AppTypography.subtitle2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                  '${AppStrings.s.dashboardTotalLabel}: ${data.totalBalance >= 0 ? '+' : ''}৳${data.totalBalance.toStringAsFixed(0)}',
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
                title: AppStrings.s.dashboardCashBalance,
                amount: data.cashBalance,
                icon: Icons.money_rounded,
                color: AppColors.success,
              ),
              StatCard(
                title: AppStrings.s.dashboardBankBalance,
                amount: data.bankBalance,
                icon: Icons.account_balance_rounded,
                color: AppColors.info,
              ),
              StatCard(
                title: AppStrings.s.dashboardTotalIncome,
                amount: data.totalIncome,
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
              ),
              StatCard(
                title: AppStrings.s.dashboardTotalExpense,
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
