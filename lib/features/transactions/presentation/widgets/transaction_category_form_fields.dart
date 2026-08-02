import 'package:flutter/material.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';

class CategoryFormData {
  final String name;
  final String? description;
  final String? icon;

  const CategoryFormData({
    required this.name,
    required this.description,
    required this.icon,
  });
}

class TransactionCategoryFormFields extends StatefulWidget {
  final String? initialName;
  final String? initialDescription;
  final String? initialIcon;
  final Map<String, IconData> icons;
  final Color selectedColor;
  final Color selectedBackground;
  final Future<void> Function(CategoryFormData data) onSubmit;

  const TransactionCategoryFormFields({
    super.key,
    required this.initialName,
    required this.initialDescription,
    required this.initialIcon,
    required this.icons,
    required this.selectedColor,
    required this.selectedBackground,
    required this.onSubmit,
  });

  @override
  State<TransactionCategoryFormFields> createState() => _TransactionCategoryFormFieldsState();
}

class _TransactionCategoryFormFieldsState extends State<TransactionCategoryFormFields> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late String _selectedIcon;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _descCtrl = TextEditingController(text: widget.initialDescription ?? '');
    _selectedIcon = widget.initialIcon ?? 'default';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await widget.onSubmit(
      CategoryFormData(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        icon: _selectedIcon == 'default' ? null : _selectedIcon,
      ),
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          AppTextField(
            label: AppStrings.s.catName,
            hint: AppStrings.s.catNameHint,
            controller: _nameCtrl,
            validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.s.valEnterNameHint : null,
          ),
          AppSpacing.boxLG,
          AppTextField(
            label: AppStrings.s.catDesc,
            hint: AppStrings.s.catOptional,
            controller: _descCtrl,
            maxLines: 2,
          ),
          AppSpacing.boxLG,
          _buildIconSelector(),
          AppSpacing.boxXXL,
          AppButton.primary(
            _isSubmitting ? AppStrings.s.commonLoading : AppStrings.s.commonSaveLabel,
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.s.catIcon, style: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary)),
        AppSpacing.boxSM,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: widget.icons.entries.map((e) {
            final selected = _selectedIcon == e.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = e.key),
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: selected ? widget.selectedBackground : AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: selected ? Border.all(color: widget.selectedColor, width: 2) : null,
                ),
                child: Icon(e.value, color: selected ? widget.selectedColor : AppColors.textSecondary, size: 24),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
