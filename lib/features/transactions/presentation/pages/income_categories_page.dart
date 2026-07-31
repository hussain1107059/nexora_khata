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
import 'package:nexora_khata/features/categories/presentation/providers/income_category_provider.dart';

class IncomeCategoriesPage extends ConsumerWidget {
  const IncomeCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(incomeCategoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('আয়ের ক্যাটাগরি', style: AppTypography.subtitle1),
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
                final result = await context.push<bool>(RouteNames.incomeCategoryAdd);
                if (result == true) ref.invalidate(incomeCategoryListProvider);
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
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(_categoryIcon(cat.icon), color: AppColors.primary, size: 22),
                  ),
                  title: Text(cat.name, style: AppTypography.subtitle2),
                  subtitle: cat.description != null ? Text(cat.description!, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        final result = await context.push<bool>('${RouteNames.incomeCategoryEdit}/${cat.id}', extra: cat);
                        if (result == true) ref.invalidate(incomeCategoryListProvider);
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
          final result = await context.push<bool>(RouteNames.incomeCategoryAdd);
          if (result == true) ref.invalidate(incomeCategoryListProvider);
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
            await ref.read(incomeCategoryFormProvider.notifier).delete(id);
            if (!context.mounted) return;
            AppSnackBar.success(context, 'ক্যাটাগরি মুছে ফেলা হয়েছে');
            ref.invalidate(incomeCategoryListProvider);
          }, child: Text('মুছুন', style: AppTypography.button.copyWith(color: AppColors.error))),
        ],
      ),
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
