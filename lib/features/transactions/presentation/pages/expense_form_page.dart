import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/categories/presentation/providers/expense_category_provider.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_form_fields.dart';

class ExpenseFormPage extends ConsumerWidget {
  final Expense? expense;
  const ExpenseFormPage({super.key, this.expense});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(expense != null ? 'ব্যয় সম্পাদনা' : 'নতুন ব্যয়', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: TransactionFormFields(
        initialAmount: expense?.amount,
        initialDate: expense?.expenseDate ?? DateTime.now(),
        initialCategoryId: expense?.categoryId,
        initialDescription: expense?.description,
        initialReference: expense?.reference,
        initialImagePath: expense?.imagePath,
        initialPaymentMethod: expense?.paymentMethod ?? 'cash',
        initialStatus: expense?.status ?? 'completed',
        completedStatusLabel: 'পরিশোধিত',
        categoriesLoading: categoriesAsync.isLoading,
        categories: categoriesAsync.valueOrNull
            ?.map((c) => CategoryOption(c.id, c.name))
            .toList() ??
            const [],
        onSubmit: (data) async {
          final now = DateTime.now();
          final item = Expense(
            id: expense?.id ?? 0,
            businessId: 1,
            supplierId: null,
            cashAccountId: null,
            bankAccountId: null,
            categoryId: data.categoryId!,
            amount: data.amount,
            description: data.description,
            reference: data.reference,
            imagePath: data.imagePath,
            expenseDate: data.date,
            paymentMethod: data.paymentMethod,
            isRecurring: false,
            status: data.status,
            createdAt: expense?.createdAt ?? now,
            updatedAt: now,
          );
          final editing = expense != null;
          if (editing) {
            await ref.read(expenseFormProvider.notifier).update(item);
          } else {
            await ref.read(expenseFormProvider.notifier).create(item);
          }
          if (!context.mounted) return;
          final state = ref.read(expenseFormProvider);
          state.whenOrNull(
            error: (e, _) => AppSnackBar.error(context, e.toString()),
          );
          if (state is AsyncData) {
            AppSnackBar.success(context, editing ? 'ব্যয় আপডেট হয়েছে' : 'নতুন ব্যয় যোগ হয়েছে');
            ref.invalidate(expenseFilteredListProvider);
            ref.invalidate(expenseRefreshProvider);
            context.pop(true);
          }
        },
      ),
    );
  }
}
