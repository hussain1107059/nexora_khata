import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';

class TransactionCategoryChip extends StatelessWidget {
  final String categoryName;
  final bool selected;
  final IconData icon;
  final Color selectedColor;
  final Color selectedBackground;
  final VoidCallback? onTap;

  const TransactionCategoryChip({
    super.key,
    required this.categoryName,
    required this.icon,
    required this.selectedColor,
    required this.selectedBackground,
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
          color: selected ? selectedBackground : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: selected ? Border.all(color: selectedColor) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? selectedColor : AppColors.textSecondary),
            AppSpacing.boxXS,
            Text(categoryName, style: AppTypography.labelMedium.copyWith(
              color: selected ? selectedColor : AppColors.textPrimary,
            )),
          ],
        ),
      ),
    );
  }
}
