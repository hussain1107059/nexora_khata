import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _buildAmountCard(),
        AppSpacing.boxLG,
        _buildInfoSection(),
        if (description != null && description!.isNotEmpty) ...[
          AppSpacing.boxLG,
          _buildSection(AppStrings.s.detNote, description!),
        ],
        if (imagePath != null) ...[
          AppSpacing.boxLG,
          _buildImageSection(imagePath!),
        ],
        AppSpacing.boxHXXXL,
        AppButton.danger(
          AppStrings.s.detDelete,
          icon: Icons.delete_rounded,
          onPressed: onDelete,
        ),
      ],
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        boxShadow: [
          BoxShadow(
            color: gradient is LinearGradient
                ? (gradient as LinearGradient).colors.first.withValues(alpha: 0.3)
                : AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            amountLabel,
            style: AppTypography.bodyText2.copyWith(color: Colors.white70),
          ),
          AppSpacing.boxSM,
          Text(
            AppNumberUtils.formatCurrency(amount),
            style: AppTypography.heading3.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          AppSpacing.boxMD,
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusText(),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          children: [
            _infoRow(Icons.calendar_month_rounded, AppStrings.s.detDate, AppDateUtils.formatDate(date)),
            AppSpacing.boxSM,
            _infoRow(Icons.category_rounded, AppStrings.s.detCategory, categoryName ?? AppStrings.s.statusUnselected),
            if (partnerName != null && partnerLabel != null) ...[
              AppSpacing.boxSM,
              _infoRow(Icons.person_rounded, partnerLabel!, partnerName!),
            ],
            AppSpacing.boxSM,
            _infoRow(Icons.payment_rounded, AppStrings.s.payPayment, _paymentText()),
            if (reference != null) ...[
              AppSpacing.boxSM,
              _infoRow(Icons.receipt_rounded, AppStrings.s.detReference, reference!),
            ],
            AppSpacing.boxSM,
            _infoRow(Icons.access_time_rounded, AppStrings.s.detCreatedAt, AppDateUtils.formatDateTime(createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
        AppSpacing.boxWMD,
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyText2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            style: AppTypography.subtitle2.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AppSpacing.boxSM,
            Text(content, style: AppTypography.bodyText2),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: kIsWeb
            ? _webImagePlaceholder()
            : Image.file(
                File(imagePath),
                width: double.infinity,
                height: 240,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _webImagePlaceholder(),
              ),
      ),
    );
  }

  Widget _webImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 240,
      color: AppColors.chipBackground,
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          size: 48,
          color: AppColors.textHint,
        ),
      ),
    );
  }

  String _statusText() {
    switch (status) {
      case 'completed':
        return completedStatusText;
      case 'pending':
        return AppStrings.s.statusPending;
      case 'cancelled':
        return AppStrings.s.statusCancelled;
      default:
        return status;
    }
  }

  String _paymentText() {
    return AppNumberUtils.formatPaymentMethod(paymentMethod ?? 'cash');
  }
}
