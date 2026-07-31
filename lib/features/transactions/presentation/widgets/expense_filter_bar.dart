import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/expense_provider.dart';

class ExpenseFilterBar extends ConsumerStatefulWidget {
  const ExpenseFilterBar({super.key});

  @override
  ConsumerState<ExpenseFilterBar> createState() => _ExpenseFilterBarState();
}

class _ExpenseFilterBarState extends ConsumerState<ExpenseFilterBar> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppSearchField(
            hintText: 'ব্যয় অনুসন্ধান করুন...',
            onChanged: (v) => ref.read(expenseSearchProvider.notifier).state = v,
          ),
        ),
        AppSpacing.boxSM,
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              _buildFilterChip('সব', null),
              AppSpacing.boxSM,
              _buildFilterChip('পরিশোধিত', 'completed'),
              AppSpacing.boxSM,
              _buildFilterChip('বকেয়া', 'pending'),
              AppSpacing.boxSM,
              _buildFilterChip('বাতিল', 'cancelled'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final selected = _selectedStatus == status;
    return FilterChip(
      label: Text(label, style: AppTypography.labelMedium.copyWith(
        color: selected ? AppColors.white : AppColors.textPrimary,
        fontSize: 12,
      )),
      selected: selected,
      onSelected: (_) {
        setState(() => _selectedStatus = selected ? null : status);
        ref.read(expenseStatusFilterProvider.notifier).state = _selectedStatus;
        ref.read(expenseRefreshProvider.notifier).state++;
      },
      selectedColor: AppColors.primary,
      checkmarkColor: AppColors.white,
      backgroundColor: AppColors.chipBackground,
      side: BorderSide.none,
      shape: StadiumBorder(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}

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
