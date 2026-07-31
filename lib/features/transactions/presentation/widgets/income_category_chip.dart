import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/features/categories/domain/entities/income_category.dart';

class IncomeCategoryChip extends StatelessWidget {
  final IncomeCategory category;
  final bool selected;
  final VoidCallback? onTap;

  const IncomeCategoryChip({
    super.key,
    required this.category,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: selected ? Border.all(color: AppColors.primary) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.attach_money_rounded, size: 16, color: selected ? AppColors.primary : AppColors.textSecondary),
            AppSpacing.boxXS,
            Text(category.name, style: AppTypography.labelMedium.copyWith(
              color: selected ? AppColors.primary : AppColors.textPrimary,
            )),
          ],
        ),
      ),
    );
  }
}
