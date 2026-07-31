import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/features/categories/domain/entities/expense_category.dart';
import 'package:nexora_khata/features/categories/presentation/providers/expense_category_provider.dart';

class ExpenseCategoryFormPage extends ConsumerStatefulWidget {
  final ExpenseCategory? category;
  const ExpenseCategoryFormPage({super.key, this.category});

  @override
  ConsumerState<ExpenseCategoryFormPage> createState() => _ExpenseCategoryFormPageState();
}

class _ExpenseCategoryFormPageState extends ConsumerState<ExpenseCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  String _selectedIcon = 'default';
  bool _isSubmitting = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    if (c != null) _selectedIcon = c.icon ?? 'default';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final category = ExpenseCategory(
      id: widget.category?.id ?? 0,
      businessId: 1,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      icon: _selectedIcon == 'default' ? null : _selectedIcon,
      color: null,
      parentId: null,
      sortOrder: widget.category?.sortOrder ?? 0,
      status: 'active',
      createdAt: widget.category?.createdAt ?? now,
      updatedAt: now,
    );

    setState(() => _isSubmitting = true);

    if (_isEditing) {
      await ref.read(expenseCategoryFormProvider.notifier).update(category);
    } else {
      await ref.read(expenseCategoryFormProvider.notifier).create(category);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final state = ref.read(expenseCategoryFormProvider);
    state.whenOrNull(
      error: (e, _) => AppSnackBar.error(context, e.toString()),
    );
    if (state is AsyncData) {
      AppSnackBar.success(context, _isEditing ? 'ক্যাটাগরি আপডেট হয়েছে' : 'নতুন ক্যাটাগরি যোগ হয়েছে');
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'ক্যাটাগরি সম্পাদনা' : 'নতুন ক্যাটাগরি', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.lg),
          children: [
            AppTextField(
              label: 'নাম',
              hint: 'ক্যাটাগরির নাম লিখুন',
              controller: _nameCtrl,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'নাম লিখুন' : null,
            ),
            AppSpacing.boxLG,
            AppTextField(
              label: 'বিবরণ',
              hint: 'ঐচ্ছিক',
              controller: _descCtrl,
              maxLines: 2,
            ),
            AppSpacing.boxLG,
            _buildIconSelector(),
            AppSpacing.boxXXL,
            AppButton.primary(
              _isEditing ? 'আপডেট করুন' : 'সংরক্ষণ করুন',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    const icons = {
      'default': Icons.money_off_rounded,
      'utilities': Icons.bolt_rounded,
      'rent': Icons.home_rounded,
      'salary': Icons.work_rounded,
      'purchase': Icons.shopping_cart_rounded,
      'transport': Icons.local_shipping_rounded,
      'food': Icons.restaurant_rounded,
      'entertainment': Icons.movie_rounded,
      'health': Icons.health_and_safety_rounded,
      'education': Icons.school_rounded,
      'tax': Icons.receipt_long_rounded,
      'insurance': Icons.verified_rounded,
      'maintenance': Icons.build_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('আইকন', style: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary)),
        AppSpacing.boxSM,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: icons.entries.map((e) {
            final selected = _selectedIcon == e.key;
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = e.key),
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: selected ? AppColors.errorLight : AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: selected ? Border.all(color: AppColors.error, width: 2) : null,
                ),
                child: Icon(e.value, color: selected ? AppColors.error : AppColors.textSecondary, size: 24),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
