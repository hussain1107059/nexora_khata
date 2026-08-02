import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/categories/domain/entities/income_category.dart';
import 'package:nexora_khata/features/categories/presentation/providers/income_category_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_category_form_fields.dart';

class IncomeCategoryFormPage extends ConsumerWidget {
  final IncomeCategory? category;
  const IncomeCategoryFormPage({super.key, this.category});

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
        selectedColor: AppColors.primary,
        selectedBackground: AppColors.primaryLight,
        icons: const {
          'default': Icons.attach_money_rounded,
          'salary': Icons.work_rounded,
          'business': Icons.store_rounded,
          'investment': Icons.trending_up_rounded,
          'rent': Icons.home_rounded,
          'freelance': Icons.laptop_rounded,
          'gift': Icons.card_giftcard_rounded,
          'refund': Icons.replay_rounded,
          'interest': Icons.account_balance_rounded,
        },
        onSubmit: (data) async {
          final now = DateTime.now();
          final item = IncomeCategory(
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
            await ref.read(incomeCategoryFormProvider.notifier).update(item);
          } else {
            await ref.read(incomeCategoryFormProvider.notifier).create(item);
          }
          if (!context.mounted) return;
          final state = ref.read(incomeCategoryFormProvider);
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
