import 'package:flutter/material.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_spacing.dart';
import '../config/theme/app_typography.dart';

class AppSearchField extends StatelessWidget {
  final String? hintText;
  final ValueChanged<String>? onChanged;

  const AppSearchField({super.key, this.hintText, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText ?? 'অনুসন্ধান করুন...',
        hintStyle: AppTypography.bodyText2.copyWith(color: AppColors.textHint),
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textHint, size: 22),
        suffixIcon: Icon(Icons.tune_rounded, color: AppColors.textHint, size: 20),
        filled: true,
        fillColor: AppColors.chipBackground,
        contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
