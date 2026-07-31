import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_loading.dart';
import 'package:nexora_khata/core/widgets/app_error_widget.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';

class IncomeDetailPage extends ConsumerWidget {
  final int id;
  const IncomeDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(incomeDetailProvider(id));

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('আয়ের বিবরণ', style: AppTypography.subtitle1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_rounded, color: AppColors.primary),
            onPressed: () async {
              final income = incomeAsync.valueOrNull;
              if (income == null) return;
              final result = await context.push<bool>(
                '${RouteNames.incomeEdit}/${income.id}',
                extra: income,
              );
              if (result == true) {
                ref.invalidate(incomeDetailProvider(id));
                ref.invalidate(incomeFilteredListProvider);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_rounded, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: incomeAsync.when(
        loading: () => const AppLoading(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (income) {
          if (income == null) {
            return const Center(child: Text('আয় পাওয়া যায়নি'));
          }

          return ListView(
            padding: EdgeInsets.all(AppSpacing.lg),
            children: [
              _buildAmountCard(income),
              AppSpacing.boxLG,
              _buildInfoSection(income),
              if (income.description != null && income.description!.isNotEmpty) ...[
                AppSpacing.boxLG,
                _buildSection('নোট', income.description!),
              ],
              if (income.imagePath != null) ...[
                AppSpacing.boxLG,
                _buildImageSection(income.imagePath!),
              ],
              AppSpacing.boxXXL,
              AppButton.danger(
                'মুছে ফেলুন',
                icon: Icons.delete_rounded,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAmountCard(Income income) {
    return Container(
      padding: AppSpacing.paddingXxl,
      decoration: BoxDecoration(
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Text('মোট আয়', style: AppTypography.bodyText2.copyWith(color: Colors.white70)),
          AppSpacing.boxSM,
          Text(AppNumberUtils.formatCurrency(income.amount),
            style: AppTypography.heading2.copyWith(color: AppColors.white, fontWeight: FontWeight.w700)),
          AppSpacing.boxSM,
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Text(_statusText(income.status), style: AppTypography.caption.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(Income income) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _infoRow(Icons.calendar_month_rounded, 'তারিখ', AppDateUtils.formatDate(income.incomeDate)),
          _infoRow(Icons.category_rounded, 'ক্যাটাগরি', income.catName ?? 'অনির্বাচিত'),
          _infoRow(Icons.payment_rounded, 'পেমেন্ট', _paymentText(income.paymentMethod)),
          if (income.reference != null)
            _infoRow(Icons.receipt_rounded, 'রেফারেন্স', income.reference!),
          _infoRow(Icons.access_time_rounded, 'তৈরির তারিখ', AppDateUtils.formatDateTime(income.createdAt)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          AppSpacing.boxMD,
          Text(label, style: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary),),
          Spacer(),
          Text(value, style: AppTypography.subtitle2.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          AppSpacing.boxSM,
          Text(content, style: AppTypography.bodyText2),
        ],
      ),
    );
  }

  Widget _buildImageSection(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Image.file(File(imagePath), width: double.infinity, height: 240, fit: BoxFit.cover, errorBuilder: (_, _, _) => Container(
          height: 240,
          color: AppColors.chipBackground,
          child: Center(child: Icon(Icons.broken_image_rounded, size: 48, color: AppColors.textHint)),
        )),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('নিশ্চিত করুন', style: AppTypography.subtitle1),
        content: Text('আপনি কি এই আয়টি মুছে ফেলতে চান?', style: AppTypography.bodyText2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('বাতিল', style: AppTypography.button.copyWith(color: AppColors.textSecondary))),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            await ref.read(incomeFormProvider.notifier).delete(id);
            if (!context.mounted) return;
            AppSnackBar.success(context, 'আয় মুছে ফেলা হয়েছে');
            ref.invalidate(incomeFilteredListProvider);
            context.pop();
          }, child: Text('মুছুন', style: AppTypography.button.copyWith(color: AppColors.error))),
        ],
      ),
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'completed': return 'গৃহীত';
      case 'pending': return 'বকেয়া';
      case 'cancelled': return 'বাতিল';
      default: return status;
    }
  }

  String _paymentText(String? method) {
    switch (method) {
      case 'cash': return 'নগদ';
      case 'bank': return 'ব্যাংক';
      case 'bkash': return 'বিকাশ';
      case 'nagad': return 'নগদ';
      case 'rocket': return 'রকেট';
      case 'card': return 'কার্ড';
      case 'check': return 'চেক';
      default: return method ?? 'নগদ';
    }
  }
}
