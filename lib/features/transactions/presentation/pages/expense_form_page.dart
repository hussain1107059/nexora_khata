import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/categories/domain/entities/expense_category.dart';
import 'package:nexora_khata/features/categories/presentation/providers/expense_category_provider.dart';
import 'package:nexora_khata/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transfer_datasource.dart';
import 'package:nexora_khata/features/transactions/domain/entities/expense.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/all_transactions_provider.dart';
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
        title: Text(expense != null ? AppStrings.s.expEdit : AppStrings.s.expNew, style: AppTypography.subtitle1),
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
        completedStatusLabel: AppStrings.s.statusPaid,
        categoriesLoading: categoriesAsync.isLoading,
        categories: categoriesAsync.valueOrNull
            ?.map((c) => CategoryOption(c.id, c.name))
            .toList() ??
            const [],
        isEditing: expense != null,
        onAddCategory: (name) async {
          final now = DateTime.now();
          final cat = ExpenseCategory(
            id: 0,
            businessId: 0,
            name: name,
            sortOrder: 0,
            status: 'active',
            createdAt: now,
            updatedAt: now,
          );
          final repo = ref.read(expenseCategoryRepositoryProvider);
          final result = await repo.create(cat);
          final id = result.fold((l) => null, (r) => r.id);
          if (id != null) ref.invalidate(expenseCategoryListProvider);
          return id;
        },
        onSubmit: (data) async {
          final now = DateTime.now();
          final accountDs = getIt<TransferDataSource>();
          int? cashId;
          int? bankId;
          if (data.paymentMethod == 'cash') {
            cashId = await accountDs.getDefaultCashAccountId();
          } else {
            bankId = await accountDs.getDefaultBankAccountId();
          }
          final item = Expense(
            id: expense?.id ?? 0,
            businessId: 0,
            supplierId: null,
            cashAccountId: expense?.cashAccountId ?? cashId,
            bankAccountId: expense?.bankAccountId ?? bankId,
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
            AppSnackBar.success(context, editing ? AppStrings.s.expUpdated : AppStrings.s.expAdded);
            ref.invalidate(expenseFilteredListProvider);
            ref.invalidate(expenseRefreshProvider);
            ref.invalidate(dashboardProvider);
            ref.invalidate(dashboardRefreshProvider);
            ref.invalidate(allTransactionsProvider);
            ref.invalidate(allTxRefreshProvider);
            context.pop(true);
          }
        },
      ),
    );
  }
}
