import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/features/categories/presentation/providers/income_category_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_categories_page.dart';

class IncomeCategoriesPage extends ConsumerWidget {
  const IncomeCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TransactionCategoriesPage(
      title: 'আয়ের ক্যাটাগরি',
      addRoute: RouteNames.incomeCategoryAdd,
      editRoute: RouteNames.incomeCategoryEdit,
      avatarBackground: AppColors.primaryLight,
      avatarColor: AppColors.primary,
      iconFor: _categoryIcon,
      categoriesAsync: ref.watch(incomeCategoryListProvider),
      refresh: (ref) async => ref.invalidate(incomeCategoryListProvider),
      delete: (id) async => ref.read(incomeCategoryFormProvider.notifier).delete(id),
    );
  }

  IconData _categoryIcon(String? icon) {
    switch (icon) {
      case 'salary': return Icons.work_rounded;
      case 'business': return Icons.store_rounded;
      case 'investment': return Icons.trending_up_rounded;
      case 'rent': return Icons.home_rounded;
      case 'freelance': return Icons.laptop_rounded;
      case 'gift': return Icons.card_giftcard_rounded;
      case 'refund': return Icons.replay_rounded;
      case 'interest': return Icons.account_balance_rounded;
      default: return Icons.attach_money_rounded;
    }
  }
}
