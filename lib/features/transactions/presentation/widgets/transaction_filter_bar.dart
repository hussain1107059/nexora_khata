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

  const TransactionFilterBar({
    super.key,
    required this.searchHint,
    required this.completedLabel,
    required this.searchProvider,
    required this.statusProvider,
    required this.refreshProvider,
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
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: AppSearchField(
            hintText: widget.searchHint,
            onChanged: (v) => ref.read(widget.searchProvider.notifier).state = v,
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
              _buildFilterChip(widget.completedLabel, 'completed'),
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
        ref.read(widget.statusProvider.notifier).state = _selectedStatus;
        ref.read(widget.refreshProvider.notifier).state++;
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
