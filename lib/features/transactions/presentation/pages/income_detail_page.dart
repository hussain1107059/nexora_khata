import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/all_transactions_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_detail_view.dart';

class IncomeDetailPage extends ConsumerWidget {
  final int id;
  const IncomeDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(incomeDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.s.incDetail, style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: () async {
              final income = incomeAsync.valueOrNull;
              if (income == null) return;
              final result = await context.push<bool>(
                '${RouteNames.incomeEdit}/${income.id}',
                extra: income,
              );
              if (result == true) {
                ref.invalidate(incomeDetailProvider(id));
                ref.invalidate(incomeFilteredListProvider);
                ref.invalidate(dashboardProvider);
                ref.invalidate(dashboardRefreshProvider);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: incomeAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (income) {
          if (income == null) {
            return Center(child: Text(AppStrings.s.incNotFound));
          }
          return TransactionDetailView(
            amount: income.amount,
            amountLabel: AppStrings.s.incTotal,
            gradient: AppColors.successGradient,
            status: income.status,
            completedStatusText: AppStrings.s.statusReceived,
            date: income.incomeDate,
            categoryName: income.catName,
            partnerLabel: null,
            partnerName: null,
            paymentMethod: income.paymentMethod,
            reference: income.reference,
            createdAt: income.createdAt,
            description: income.description,
            imagePath: income.imagePath,
            onDelete: () => _confirmDelete(context, ref),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.s.commonConfirm, style: AppTypography.subtitle1),
        content: Text(AppStrings.s.incDeleteConfirm, style: AppTypography.bodyText2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.s.commonCancel, style: AppTypography.button.copyWith(color: AppColors.textSecondary))),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(incomeFormProvider.notifier).delete(id);
            if (!context.mounted) return;
            AppSnackBar.success(context, AppStrings.s.incDeleted);
            ref.invalidate(incomeFilteredListProvider);
            ref.invalidate(dashboardProvider);
            ref.invalidate(dashboardRefreshProvider);
            ref.invalidate(allTransactionsProvider);
            ref.invalidate(allTxRefreshProvider);
            context.pop();
          }, child: Text(AppStrings.s.commonDelete, style: AppTypography.button.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }
}
