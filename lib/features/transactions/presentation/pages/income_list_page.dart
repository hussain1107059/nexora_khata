import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/income_card.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/income_filter_bar.dart';

class IncomeListPage extends ConsumerWidget {
  const IncomeListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(incomeFilteredListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('আয়ের তালিকা', style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_rounded),
            onPressed: () => context.push(RouteNames.incomeMonthlyReport),
            tooltip: 'মাসিক রিপোর্ট',
          ),
          IconButton(
            icon: Icon(Icons.category_rounded),
            onPressed: () => context.push(RouteNames.incomeCategories),
            tooltip: 'ক্যাটাগরি',
          ),
        ],
      ),
      body: Column(
        children: [
          AppSpacing.boxSM,
          IncomeFilterBar(),
          AppSpacing.boxSM,
          Expanded(
            child: incomesAsync.when(
              loading: () => AppLoading(message: 'আয় লোড হচ্ছে...'),
              error: (e, _) => AppErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(incomeFilteredListProvider),
              ),
              data: (incomes) {
                if (incomes.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'কোনো আয় নেই',
                    subtitle: 'নতুন আয় যোগ করতে নিচের বাটনে ক্লিক করুন',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(incomeFilteredListProvider);
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: AppSpacing.huge),
                    itemCount: incomes.length,
                    itemBuilder: (context, index) {
                      final income = incomes[index];
                      return IncomeCard(
                        income: income,
                        onTap: () => context.push('${RouteNames.incomeDetail}/${income.id}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>(RouteNames.incomeAdd);
          if (result == true) {
            ref.invalidate(incomeFilteredListProvider);
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: Icon(Icons.add_rounded),
        label: Text('নতুন আয়'),
      ),
    );
  }
}
