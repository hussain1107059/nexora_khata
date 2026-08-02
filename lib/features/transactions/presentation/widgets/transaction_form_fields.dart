import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';

class CategoryOption {
  final int id;
  final String name;

  const CategoryOption(this.id, this.name);
}

class TransactionFormData {
  final double amount;
  final DateTime date;
  final int? categoryId;
  final String? description;
  final String? reference;
  final String? imagePath;
  final String paymentMethod;
  final String status;

  const TransactionFormData({
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.description,
    required this.reference,
    required this.imagePath,
    required this.paymentMethod,
    required this.status,
  });
}

class TransactionFormFields extends ConsumerStatefulWidget {
  final double? initialAmount;
  final DateTime initialDate;
  final int? initialCategoryId;
  final String? initialDescription;
  final String? initialReference;
  final String? initialImagePath;
  final String initialPaymentMethod;
  final String initialStatus;
  final String completedStatusLabel;
  final bool categoriesLoading;
  final List<CategoryOption> categories;
  final Future<int?> Function(String name)? onAddCategory;
  final Future<void> Function(TransactionFormData data) onSubmit;

  const TransactionFormFields({
    super.key,
    required this.initialAmount,
    required this.initialDate,
    required this.initialCategoryId,
    required this.initialDescription,
    required this.initialReference,
    required this.initialImagePath,
    required this.initialPaymentMethod,
    required this.initialStatus,
    required this.completedStatusLabel,
    required this.categoriesLoading,
    required this.categories,
    this.onAddCategory,
    required this.onSubmit,
  });

  @override
  ConsumerState<TransactionFormFields> createState() => _TransactionFormFieldsState();
}

class _TransactionFormFieldsState extends ConsumerState<TransactionFormFields> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _referenceCtrl;
  late final TextEditingController _dateCtrl;
  late DateTime _selectedDate;
  int? _categoryId;
  late String _paymentMethod;
  late String _status;
  String? _imagePath;
  bool _isSubmitting = false;
  final List<CategoryOption> _localCategories = [];

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.initialAmount != null ? widget.initialAmount.toString() : '',
    );
    _descriptionCtrl = TextEditingController(text: widget.initialDescription ?? '');
    _referenceCtrl = TextEditingController(text: widget.initialReference ?? '');
    _dateCtrl = TextEditingController();
    _selectedDate = widget.initialDate;
    _updateDateText();
    _categoryId = widget.initialCategoryId;
    _paymentMethod = widget.initialPaymentMethod;
    _status = widget.initialStatus;
    _imagePath = widget.initialImagePath;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _referenceCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _updateDateText() {
    _dateCtrl.text = '${_selectedDate.year}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('bn', 'BD'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _updateDateText();
      });
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      AppSnackBar.warning(context, 'ওয়েব সংস্করণে ছবি সংযুক্তি সমর্থিত নয়');
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      AppSnackBar.warning(context, 'ক্যাটাগরি নির্বাচন করুন');
      return;
    }
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    setState(() => _isSubmitting = true);
    await widget.onSubmit(
      TransactionFormData(
        amount: amount,
        date: _selectedDate,
        categoryId: _categoryId,
        description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
        reference: _referenceCtrl.text.isEmpty ? null : _referenceCtrl.text,
        imagePath: _imagePath,
        paymentMethod: _paymentMethod,
        status: _status,
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
            label: 'পরিমাণ',
            hint: '০.০০',
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            prefix: Text('৳ ', style: AppTypography.subtitle1.copyWith(color: AppColors.textSecondary)),
            validator: (v) {
              if (v == null || v.isEmpty) return 'পরিমাণ লিখুন';
              final n = double.tryParse(v);
              if (n == null || n <= 0) return 'সঠিক পরিমাণ লিখুন';
              return null;
            },
          ),
          AppSpacing.boxLG,
          _buildCategorySection(),
          AppSpacing.boxLG,
          AppTextField(
            label: 'তারিখ',
            controller: _dateCtrl,
            readOnly: true,
            onTap: _pickDate,
            suffixIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primary),
          ),
          AppSpacing.boxLG,
          AppTextField(
            label: 'নোট',
            hint: 'বিবরণ লিখুন...',
            controller: _descriptionCtrl,
            maxLines: 3,
          ),
          AppSpacing.boxLG,
          AppTextField(
            label: 'রেফারেন্স',
            hint: 'ইনভয়েস নম্বর ইত্যাদি',
            controller: _referenceCtrl,
          ),
          AppSpacing.boxLG,
          _buildPaymentMethodDropdown(),
          AppSpacing.boxLG,
          _buildStatusDropdown(),
          AppSpacing.boxLG,
          _buildImagePicker(),
          AppSpacing.boxXXL,
          AppButton.primary(
            _isSubmitting ? 'লোড হচ্ছে...' : 'সংরক্ষণ করুন',
            isLoading: _isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    if (widget.categoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final allCategories = _allCategories;
    const newCategoryValue = -1;

    return DropdownButtonFormField<int>(
      initialValue: _categoryId,
      decoration: InputDecoration(
        labelText: 'ক্যাটাগরি',
        labelStyle: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      items: [
        for (final c in allCategories)
          DropdownMenuItem(
            value: c.id,
            child: Text(c.name, style: AppTypography.bodyText2),
          ),
        if (widget.onAddCategory != null)
          DropdownMenuItem(
            value: newCategoryValue,
            child: Row(
              children: [
                const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text('নতুন ক্যাটাগরি', style: AppTypography.bodyText2),
              ],
            ),
          ),
      ],
      onChanged: (v) {
        if (v == newCategoryValue) {
          _showAddCategoryDialog();
        } else {
          setState(() => _categoryId = v);
        }
      },
      validator: (v) => v == null ? 'ক্যাটাগরি নির্বাচন করুন' : null,
    );
  }

  List<CategoryOption> get _allCategories {
    final existing = widget.categories;
    final local = _localCategories
        .where((c) => !existing.any((w) => w.id == c.id))
        .toList();
    return [...existing, ...local];
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      barrierColor: AppColors.scrim,
      builder: (ctx) => AlertDialog(
        title: const Text('নতুন ক্যাটাগরি'),
        content: AppTextField(
          label: 'ক্যাটাগরির নাম',
          hint: 'যেমন: কাপড়, বিল, চিকিৎসা',
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('যোগ করুন'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name == null || name.isEmpty || widget.onAddCategory == null) return;
    final id = await widget.onAddCategory!(name);
    if (!mounted) return;
    if (id == null) {
      AppSnackBar.error(context, 'ক্যাটাগরি যোগ করা যায়নি');
      return;
    }
    setState(() {
      _localCategories.add(CategoryOption(id, name));
      _categoryId = id;
    });
  }

  Widget _buildPaymentMethodDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _paymentMethod,
      decoration: InputDecoration(
        labelText: 'পেমেন্ট পদ্ধতি',
        labelStyle: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      items: const [
        DropdownMenuItem(value: 'cash', child: Text('নগদ')),
        DropdownMenuItem(value: 'bank', child: Text('ব্যাংক')),
        DropdownMenuItem(value: 'bkash', child: Text('বিকাশ')),
        DropdownMenuItem(value: 'nagad', child: Text('নগদ (Nagad)')),
        DropdownMenuItem(value: 'rocket', child: Text('রকেট')),
        DropdownMenuItem(value: 'card', child: Text('কার্ড')),
        DropdownMenuItem(value: 'check', child: Text('চেক')),
      ],
      onChanged: (v) => setState(() => _paymentMethod = v!),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _status,
      decoration: InputDecoration(
        labelText: 'স্ট্যাটাস',
        labelStyle: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      items: [
        DropdownMenuItem(value: 'completed', child: Text(widget.completedStatusLabel)),
        const DropdownMenuItem(value: 'pending', child: Text('বকেয়া')),
        const DropdownMenuItem(value: 'cancelled', child: Text('বাতিল')),
      ],
      onChanged: (v) => setState(() => _status = v!),
    );
  }

  Widget _buildImagePicker() {
    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(
              _imagePath != null ? Icons.image_rounded : Icons.add_photo_alternate_rounded,
              color: AppColors.primary, size: 28,
            ),
            AppSpacing.boxMD,
            Expanded(
              child: Text(
                _imagePath != null ? 'ছবি সংযুক্ত হয়েছে' : 'ছবি যোগ করুন',
                style: AppTypography.bodyText2.copyWith(
                  color: _imagePath != null ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            if (_imagePath != null)
              GestureDetector(
                onTap: () => setState(() => _imagePath = null),
                child: Icon(Icons.close_rounded, color: AppColors.error, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
