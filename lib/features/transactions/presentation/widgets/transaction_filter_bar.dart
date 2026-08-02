import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_search_field.dart';

class TransactionFilterBar extends ConsumerStatefulWidget {
  final String searchHint;
  final String completedLabel;
  final StateProvider<String> searchProvider;
  final StateProvider<String?> statusProvider;
  final StateProvider<int> refreshProvider;
  final List<Widget>? extraChips;

  const TransactionFilterBar({
    super.key,
    required this.searchHint,
    required this.completedLabel,
    required this.searchProvider,
    required this.statusProvider,
    required this.refreshProvider,
    this.extraChips,
  });

  @override
  ConsumerState<TransactionFilterBar> createState() => _TransactionFilterBarState();
}

class _TransactionFilterBarState extends ConsumerState<TransactionFilterBar> {
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppSearchField(
            hintText: widget.searchHint,
            onChanged: (v) => ref.read(widget.searchProvider.notifier).state = v,
          ),
        ),
        AppSpacing.boxSM,
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            children: [
              _buildFilterChip('সব', null),
              AppSpacing.boxSM,
              _buildFilterChip(widget.completedLabel, 'completed'),
              AppSpacing.boxSM,
              _buildFilterChip('বকেয়া', 'pending'),
              AppSpacing.boxSM,
              _buildFilterChip('বাতিল', 'cancelled'),
              if (widget.extraChips != null && widget.extraChips!.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: SizedBox(
                    width: 1,
                    height: 24,
                    child: VerticalDivider(color: AppColors.divider),
                  ),
                ),
                ...widget.extraChips!,
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final selected = _selectedStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = selected ? null : status);
        ref.read(widget.statusProvider.notifier).state = _selectedStatus;
        ref.read(widget.refreshProvider.notifier).state++;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: selected ? AppColors.white : AppColors.textPrimary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
