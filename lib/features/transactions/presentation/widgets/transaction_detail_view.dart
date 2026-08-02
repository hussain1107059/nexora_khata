import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/utils/date_utils.dart';
import 'package:nexora_khata/core/utils/number_utils.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';

class TransactionDetailView extends StatelessWidget {
  final double amount;
  final String amountLabel;
  final Gradient gradient;
  final String status;
  final String completedStatusText;
  final DateTime date;
  final String? categoryName;
  final String? partnerLabel;
  final String? partnerName;
  final String? paymentMethod;
  final String? reference;
  final DateTime createdAt;
  final String? description;
  final String? imagePath;
  final VoidCallback onDelete;

  const TransactionDetailView({
    super.key,
    required this.amount,
    required this.amountLabel,
    required this.gradient,
    required this.status,
    required this.completedStatusText,
    required this.date,
    required this.categoryName,
    required this.partnerLabel,
    required this.partnerName,
    required this.paymentMethod,
    required this.reference,
    required this.createdAt,
    required this.description,
    required this.imagePath,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildAmountCard(),
        AppSpacing.boxLG,
        _buildInfoSection(),
        if (description != null && description!.isNotEmpty) ...[
          AppSpacing.boxLG,
          _buildSection('নোট', description!),
        ],
        if (imagePath != null) ...[
          AppSpacing.boxLG,
          _buildImageSection(imagePath!),
        ],
        AppSpacing.boxXXL,
        AppButton.danger(
          'মুছে ফেলুন',
          icon: Icons.delete_rounded,
          onPressed: onDelete,
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: AppSpacing.paddingXxl,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Text(amountLabel, style: AppTypography.bodyText2.copyWith(color: Colors.white70)),
          AppSpacing.boxSM,
          Text(AppNumberUtils.formatCurrency(amount),
            style: AppTypography.heading2.copyWith(color: AppColors.white, fontWeight: FontWeight.w700)),
          AppSpacing.boxSM,
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            ),
            child: Text(_statusText(), style: AppTypography.caption.copyWith(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          _infoRow(Icons.calendar_month_rounded, 'তারিখ', AppDateUtils.formatDate(date)),
          _infoRow(Icons.category_rounded, 'ক্যাটাগরি', categoryName ?? 'অনির্বাচিত'),
          if (partnerName != null && partnerLabel != null)
            _infoRow(Icons.person_rounded, partnerLabel!, partnerName!),
          _infoRow(Icons.payment_rounded, 'পেমেন্ট', _paymentText()),
          if (reference != null)
            _infoRow(Icons.receipt_rounded, 'রেফারেন্স', reference!),
          _infoRow(Icons.access_time_rounded, 'তৈরির তারিখ', AppDateUtils.formatDateTime(createdAt)),
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
          Text(label, style: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
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

  String _statusText() {
    switch (status) {
      case 'completed': return completedStatusText;
      case 'pending': return 'বকেয়া';
      case 'cancelled': return 'বাতিল';
      default: return status;
    }
  }

  String _paymentText() {
    switch (paymentMethod) {
      case 'cash': return 'নগদ';
      case 'bank': return 'ব্যাংক';
      case 'bkash': return 'বিকাশ';
      case 'nagad': return 'নগদ';
      case 'rocket': return 'রকেট';
      case 'card': return 'কার্ড';
      case 'check': return 'চেক';
      default: return paymentMethod ?? 'নগদ';
    }
  }
}
