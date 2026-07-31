import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/categories/presentation/providers/expense_category_provider.dart';

class ExpenseCategoriesPage extends ConsumerWidget {
  const ExpenseCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('ব্যয়ের ক্যাটাগরি', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: categoriesAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (categories) {
          if (categories.isEmpty) {
            return AppEmptyState(
              icon: Icons.category_rounded,
              title: 'কোনো ক্যাটাগরি নেই',
              subtitle: 'নতুন ক্যাটাগরি যোগ করুন',
              actionLabel: 'ক্যাটাগরি যোগ করুন',
              onAction: () async {
                final result = await context.push<bool>(RouteNames.expenseCategoryAdd);
                if (result == true) ref.invalidate(expenseCategoryListProvider);
              },
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.lg),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                margin: EdgeInsets.only(bottom: AppSpacing.sm),
                elevation: AppSpacing.elevationSm,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.errorLight,
                    child: Icon(_categoryIcon(cat.icon), color: AppColors.error, size: 22),
                  ),
                  title: Text(cat.name, style: AppTypography.subtitle2),
                  subtitle: cat.description != null ? Text(cat.description!, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        final result = await context.push<bool>('${RouteNames.expenseCategoryEdit}/${cat.id}', extra: cat);
                        if (result == true) ref.invalidate(expenseCategoryListProvider);
                      } else if (v == 'delete') {
                        _confirmDelete(context, ref, cat.id, cat.name);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18, color: AppColors.primary), AppSpacing.boxSM, Text('সম্পাদনা')])),
                      PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, size: 18, color: AppColors.error), AppSpacing.boxSM, Text('মুছুন')])),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push<bool>(RouteNames.expenseCategoryAdd);
          if (result == true) ref.invalidate(expenseCategoryListProvider);
        },
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: Icon(Icons.add_rounded),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('নিশ্চিত করুন', style: AppTypography.subtitle1),
        content: Text('"$name" ক্যাটাগরি মুছে ফেলবেন?', style: AppTypography.bodyText2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('বাতিল', style: AppTypography.button.copyWith(color: AppColors.textSecondary))),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(expenseCategoryFormProvider.notifier).delete(id);
            if (!context.mounted) return;
            AppSnackBar.success(context, 'ক্যাটাগরি মুছে ফেলা হয়েছে');
            ref.invalidate(expenseCategoryListProvider);
          }, child: Text('মুছুন', style: AppTypography.button.copyWith(color: AppColors.error))),
        ],
      ),
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
