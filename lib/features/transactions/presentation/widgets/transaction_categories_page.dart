import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_empty_state.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';

class TransactionCategoriesPage extends ConsumerWidget {
  final String title;
  final String addRoute;
  final String editRoute;
  final Color avatarBackground;
  final Color avatarColor;
  final IconData Function(String? icon) iconFor;
  final AsyncValue<List<dynamic>> categoriesAsync;
  final Future<void> Function(WidgetRef ref) refresh;
  final Future<void> Function(int id) delete;

  const TransactionCategoriesPage({
    super.key,
    required this.title,
    required this.addRoute,
    required this.editRoute,
    required this.avatarBackground,
    required this.avatarColor,
    required this.iconFor,
    required this.categoriesAsync,
    required this.refresh,
    required this.delete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(title, style: AppTypography.subtitle1),
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
                final result = await context.push<bool>(addRoute);
                if (result == true) await refresh(ref);
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
                    backgroundColor: avatarBackground,
                    child: Icon(iconFor(cat.icon as String?), color: avatarColor, size: 22),
                  ),
                  title: Text(cat.name as String, style: AppTypography.subtitle2),
                  subtitle: cat.description != null ? Text(cat.description as String, style: AppTypography.caption, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'edit') {
                        final result = await context.push<bool>('$editRoute/${cat.id}', extra: cat);
                        if (result == true) await refresh(ref);
                      } else if (v == 'delete') {
                        _confirmDelete(context, ref, cat.id as int, cat.name as String);
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
          final result = await context.push<bool>(addRoute);
          if (result == true) await refresh(ref);
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
            await delete(id);
            if (!context.mounted) return;
            AppSnackBar.success(context, 'ক্যাটাগরি মুছে ফেলা হয়েছে');
            await refresh(ref);
          }, child: Text('মুছুন', style: AppTypography.button.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }
}
