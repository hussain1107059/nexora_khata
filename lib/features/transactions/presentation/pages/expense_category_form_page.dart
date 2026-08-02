import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/categories/domain/entities/expense_category.dart';
import 'package:nexora_khata/features/categories/presentation/providers/expense_category_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_category_form_fields.dart';

class ExpenseCategoryFormPage extends ConsumerWidget {
  final ExpenseCategory? category;
  const ExpenseCategoryFormPage({super.key, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(category != null ? 'ক্যাটাগরি সম্পাদনা' : 'নতুন ক্যাটাগরি', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: TransactionCategoryFormFields(
        initialName: category?.name,
        initialDescription: category?.description,
        initialIcon: category?.icon,
        selectedColor: AppColors.error,
        selectedBackground: AppColors.errorLight,
        icons: const {
          'default': Icons.money_off_rounded,
          'utilities': Icons.bolt_rounded,
          'rent': Icons.home_rounded,
          'salary': Icons.work_rounded,
          'purchase': Icons.shopping_cart_rounded,
          'transport': Icons.local_shipping_rounded,
          'food': Icons.restaurant_rounded,
          'entertainment': Icons.movie_rounded,
          'health': Icons.health_and_safety_rounded,
          'education': Icons.school_rounded,
          'tax': Icons.receipt_long_rounded,
          'insurance': Icons.verified_rounded,
          'maintenance': Icons.build_rounded,
        },
        onSubmit: (data) async {
          final now = DateTime.now();
          final item = ExpenseCategory(
            id: category?.id ?? 0,
            businessId: 0,
            name: data.name,
            description: data.description,
            icon: data.icon,
            color: null,
            parentId: null,
            sortOrder: category?.sortOrder ?? 0,
            status: 'active',
            createdAt: category?.createdAt ?? now,
            updatedAt: now,
          );
          final editing = category != null;
          if (editing) {
            await ref.read(expenseCategoryFormProvider.notifier).update(item);
          } else {
            await ref.read(expenseCategoryFormProvider.notifier).create(item);
          }
          if (!context.mounted) return;
          final state = ref.read(expenseCategoryFormProvider);
          state.whenOrNull(
            error: (e, _) => AppSnackBar.error(context, e.toString()),
          );
          if (state is AsyncData) {
            AppSnackBar.success(context, editing ? 'ক্যাটাগরি আপডেট হয়েছে' : 'নতুন ক্যাটাগরি যোগ হয়েছে');
            context.pop(true);
          }
        },
      ),
    );
  }
}
