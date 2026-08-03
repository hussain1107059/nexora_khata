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
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/all_transactions_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_detail_view.dart';

class ExpenseDetailPage extends ConsumerWidget {
  final int id;
  const ExpenseDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(expenseDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.s.expDetail, style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: () async {
              final expense = expenseAsync.valueOrNull;
              if (expense == null) return;
              final result = await context.push<bool>(
                '${RouteNames.expenseEdit}/${expense.id}',
                extra: expense,
              );
              if (result == true) {
                ref.invalidate(expenseDetailProvider(id));
                ref.invalidate(expenseFilteredListProvider);
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
      body: expenseAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (expense) {
          if (expense == null) {
            return Center(child: Text(AppStrings.s.expNotFound));
          }
          return TransactionDetailView(
            amount: expense.amount,
            amountLabel: AppStrings.s.expTotal,
            gradient: AppColors.primaryGradient,
            status: expense.status,
            completedStatusText: AppStrings.s.statusPaid,
            date: expense.expenseDate,
            categoryName: expense.catName,
            partnerLabel: AppStrings.s.expSupplier,
            partnerName: expense.supplierName,
            paymentMethod: expense.paymentMethod,
            reference: expense.reference,
            createdAt: expense.createdAt,
            description: expense.description,
            imagePath: expense.imagePath,
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
        content: Text(AppStrings.s.expDeleteConfirm, style: AppTypography.bodyText2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppStrings.s.commonCancel, style: AppTypography.button.copyWith(color: AppColors.textSecondary))),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(expenseFormProvider.notifier).delete(id);
            if (!context.mounted) return;
            AppSnackBar.success(context, AppStrings.s.expDeleted);
            ref.invalidate(expenseFilteredListProvider);
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
