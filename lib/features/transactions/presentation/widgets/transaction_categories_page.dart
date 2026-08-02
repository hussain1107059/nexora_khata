import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_dialog.dart';
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
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: avatarBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      iconFor(cat.icon as String?),
                      color: avatarColor,
                      size: 22,
                    ),
                  ),
                  title: Text(cat.name as String, style: AppTypography.subtitle2),
                  subtitle: cat.description != null
                      ? Text(
                          cat.description as String,
                          style: AppTypography.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
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
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                            AppSpacing.boxSM,
                            Text('সম্পাদনা'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_rounded, size: 18, color: AppColors.error),
                            AppSpacing.boxSM,
                            Text('মুছুন'),
                          ],
                        ),
                      ),
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
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id, String name) {
    AppDialog.confirm(
      context,
      title: 'ক্যাটাগরি মুছুন',
      message: '"$name" ক্যাটাগরি মুছে ফেলবেন?',
      confirmLabel: 'মুছুন',
      icon: Icons.delete_outline_rounded,
      iconColor: AppColors.error,
      iconBackground: AppColors.errorLight,
      destructive: true,
    ).then((confirmed) async {
      if (confirmed != true || !context.mounted) return;
      await delete(id);
      if (!context.mounted) return;
      AppSnackBar.success(context, 'ক্যাটাগরি মুছে ফেলা হয়েছে');
      await refresh(ref);
    });
  }
}
