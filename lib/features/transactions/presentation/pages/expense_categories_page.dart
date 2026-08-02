import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/features/categories/presentation/providers/expense_category_provider.dart';
import 'package:nexora_khata/features/transactions/presentation/widgets/transaction_categories_page.dart';

class ExpenseCategoriesPage extends ConsumerWidget {
  const ExpenseCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TransactionCategoriesPage(
      title: 'ব্যব্যের ক্যাটাগরি',
      addRoute: RouteNames.expenseCategoryAdd,
      editRoute: RouteNames.expenseCategoryEdit,
      avatarBackground: AppColors.errorLight,
      avatarColor: AppColors.error,
      iconFor: _categoryIcon,
      categoriesAsync: ref.watch(expenseCategoryListProvider),
      refresh: (ref) async => ref.invalidate(expenseCategoryListProvider),
      delete: (id) async => ref.read(expenseCategoryFormProvider.notifier).delete(id),
    );
  }

  IconData _categoryIcon(String? icon) {
    switch (icon) {
      case 'utilities': return Icons.bolt_rounded;
      case 'rent': return Icons.home_rounded;
      case 'salary': return Icons.work_rounded;
      case 'purchase': return Icons.shopping_cart_rounded;
      case 'transport': return Icons.local_shipping_rounded;
      case 'food': return Icons.restaurant_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'health': return Icons.health_and_safety_rounded;
      case 'education': return Icons.school_rounded;
      case 'tax': return Icons.receipt_long_rounded;
      case 'insurance': return Icons.verified_rounded;
      case 'maintenance': return Icons.build_rounded;
      default: return Icons.money_off_rounded;
    }
  }
}
