import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/categories/domain/entities/income_category.dart';
import 'package:nexora_khata/features/categories/presentation/providers/income_category_provider.dart';
import 'package:nexora_khata/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transfer_datasource.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_form_fields.dart';

class IncomeFormPage extends ConsumerWidget {
  final Income? income;
  const IncomeFormPage({super.key, this.income});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(incomeCategoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(income != null ? 'আয় সম্পাদনা' : 'নতুন আয়', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: TransactionFormFields(
        initialAmount: income?.amount,
        initialDate: income?.incomeDate ?? DateTime.now(),
        initialCategoryId: income?.categoryId,
        initialDescription: income?.description,
        initialReference: income?.reference,
        initialImagePath: income?.imagePath,
        initialPaymentMethod: income?.paymentMethod ?? 'cash',
        initialStatus: income?.status ?? 'completed',
        completedStatusLabel: 'গৃহীত',
        categoriesLoading: categoriesAsync.isLoading,
        categories: categoriesAsync.valueOrNull
            ?.map((c) => CategoryOption(c.id, c.name))
            .toList() ??
            const [],
        onAddCategory: (name) async {
          final now = DateTime.now();
          final cat = IncomeCategory(
            id: 0,
            businessId: 0,
            name: name,
            sortOrder: 0,
            status: 'active',
            createdAt: now,
            updatedAt: now,
          );
          final repo = ref.read(incomeCategoryRepositoryProvider);
          final result = await repo.create(cat);
          final id = result.fold((l) => null, (r) => r.id);
          if (id != null) ref.invalidate(incomeCategoryListProvider);
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
          final item = Income(
            id: income?.id ?? 0,
            businessId: 0,
            customerId: null,
            cashAccountId: income?.cashAccountId ?? cashId,
            bankAccountId: income?.bankAccountId ?? bankId,
            categoryId: data.categoryId!,
            amount: data.amount,
            description: data.description,
            reference: data.reference,
            imagePath: data.imagePath,
            incomeDate: data.date,
            paymentMethod: data.paymentMethod,
            isRecurring: false,
            status: data.status,
            createdAt: income?.createdAt ?? now,
            updatedAt: now,
          );
          final editing = income != null;
          if (editing) {
            await ref.read(incomeFormProvider.notifier).update(item);
          } else {
            await ref.read(incomeFormProvider.notifier).create(item);
          }
          if (!context.mounted) return;
          final state = ref.read(incomeFormProvider);
          state.whenOrNull(
            error: (e, _) => AppSnackBar.error(context, e.toString()),
          );
          if (state is AsyncData) {
            AppSnackBar.success(context, editing ? 'আয় আপডেট হয়েছে' : 'নতুন আয় যোগ হয়েছে');
            ref.invalidate(incomeFilteredListProvider);
            ref.invalidate(incomeRefreshProvider);
            ref.invalidate(dashboardProvider);
            ref.invalidate(dashboardRefreshProvider);
            context.pop(true);
          }
        },
      ),
    );
  }
}
