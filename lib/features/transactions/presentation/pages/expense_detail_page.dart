import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
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
        title: Text('ব্যয়ের বিবরণ', style: AppTypography.subtitle1),
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
            return const Center(child: Text('ব্যয় পাওয়া যায়নি'));
          }
          return TransactionDetailView(
            amount: expense.amount,
            amountLabel: 'মোট ব্যয়',
            gradient: AppColors.primaryGradient,
            status: expense.status,
            completedStatusText: 'পরিশোধিত',
            date: expense.expenseDate,
            categoryName: expense.catName,
            partnerLabel: 'সাপ্লায়ার',
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
        title: Text('নিশ্চিত করুন', style: AppTypography.subtitle1),
        content: Text('আপনি কি এই ব্যয়টি মুছে ফেলতে চান?', style: AppTypography.bodyText2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('বাতিল', style: AppTypography.button.copyWith(color: AppColors.textSecondary))),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(expenseFormProvider.notifier).delete(id);
            if (!context.mounted) return;
            AppSnackBar.success(context, 'ব্যয় মুছে ফেলা হয়েছে');
            ref.invalidate(expenseFilteredListProvider);
            context.pop();
          }, child: Text('মুছুন', style: AppTypography.button.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }
}
