import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/features/categories/domain/entities/expense_category.dart';

class ExpenseCategoryChip extends StatelessWidget {
  final ExpenseCategory category;
  final bool selected;
  final VoidCallback? onTap;

  const ExpenseCategoryChip({
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
          color: selected ? AppColors.errorLight : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: selected ? Border.all(color: AppColors.error) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.money_off_rounded, size: 16, color: selected ? AppColors.error : AppColors.textSecondary),
            AppSpacing.boxXS,
            Text(category.name, style: AppTypography.labelMedium.copyWith(
              color: selected ? AppColors.error : AppColors.textPrimary,
            )),
          ],
        ),
      ),
    );
  }
}
