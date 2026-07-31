import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/features/categories/domain/entities/income_category.dart';
import 'package:nexora_khata/features/categories/presentation/providers/income_category_provider.dart';
import 'package:nexora_khata/features/transactions/domain/entities/income.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/income_provider.dart';

class IncomeFormPage extends ConsumerStatefulWidget {
  final Income? income;
  const IncomeFormPage({super.key, this.income});

  @override
  ConsumerState<IncomeFormPage> createState() => _IncomeFormPageState();
}

class _IncomeFormPageState extends ConsumerState<IncomeFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _referenceCtrl;
  DateTime _selectedDate = DateTime.now();
  int? _categoryId;
  String _paymentMethod = 'cash';
  String _status = 'completed';
  String? _imagePath;
  bool _isSubmitting = false;

  bool get _isEditing => widget.income != null;

  @override
  void initState() {
    super.initState();
    final i = widget.income;
    _amountCtrl = TextEditingController(text: i != null ? i.amount.toString() : '');
    _descriptionCtrl = TextEditingController(text: i?.description ?? '');
    _referenceCtrl = TextEditingController(text: i?.reference ?? '');
    if (i != null) {
      _selectedDate = i.incomeDate;
      _categoryId = i.categoryId;
      _paymentMethod = i.paymentMethod ?? 'cash';
      _status = i.status;
      _imagePath = i.imagePath;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descriptionCtrl.dispose();
    _referenceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('bn', 'BD'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      AppSnackBar.warning(context, 'ক্যাটাগরি নির্বাচন করুন');
      return;
    }

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final now = DateTime.now();
    final income = Income(
      id: widget.income?.id ?? 0,
      businessId: 1,
      customerId: null,
      cashAccountId: null,
      bankAccountId: null,
      categoryId: _categoryId!,
      amount: amount,
      description: _descriptionCtrl.text.isEmpty ? null : _descriptionCtrl.text,
      reference: _referenceCtrl.text.isEmpty ? null : _referenceCtrl.text,
      imagePath: _imagePath,
      incomeDate: _selectedDate,
      paymentMethod: _paymentMethod,
      isRecurring: false,
      status: _status,
      createdAt: widget.income?.createdAt ?? now,
      updatedAt: now,
    );

    setState(() => _isSubmitting = true);

    if (_isEditing) {
      await ref.read(incomeFormProvider.notifier).update(income);
    } else {
      await ref.read(incomeFormProvider.notifier).create(income);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final state = ref.read(incomeFormProvider);
    state.whenOrNull(
      error: (e, _) => AppSnackBar.error(context, e.toString()),
    );
    if (state is AsyncData) {
      AppSnackBar.success(context, _isEditing ? 'আয় আপডেট হয়েছে' : 'নতুন আয় যোগ হয়েছে');
      ref.invalidate(incomeFilteredListProvider);
      ref.invalidate(incomeRefreshProvider);
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(incomeCategoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'আয় সম্পাদনা' : 'নতুন আয়', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: Form(
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
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('ক্যাটাগরি লোড করতে সমস্যা', style: AppTypography.caption.copyWith(color: AppColors.error)),
              data: (categories) => _buildCategoryDropdown(categories),
            ),
            AppSpacing.boxLG,
            AppTextField(
              label: 'তারিখ',
              controller: TextEditingController(
                text: '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
              ),
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
              hint: 'ইনভয়েস নম্বর ইত্যাদি',
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
              _isEditing ? 'আপডেট করুন' : 'সংরক্ষণ করুন',
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<IncomeCategory> categories) {
    return DropdownButtonFormField<int>(
      initialValue: _categoryId,
      decoration: InputDecoration(
        labelText: 'ক্যাটাগরি',
        labelStyle: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      items: categories.map((c) => DropdownMenuItem(
        value: c.id,
        child: Text(c.name, style: AppTypography.bodyText2),
      )).toList(),
      onChanged: (v) => setState(() => _categoryId = v),
      validator: (v) => v == null ? 'ক্যাটাগরি নির্বাচন করুন' : null,
    );
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
        DropdownMenuItem(value: 'nagad', child: Text('নগদ')),
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
      items: const [
        DropdownMenuItem(value: 'completed', child: Text('গৃহীত')),
        DropdownMenuItem(value: 'pending', child: Text('বকেয়া')),
        DropdownMenuItem(value: 'cancelled', child: Text('বাতিল')),
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
                _imagePath != null ? 'ছবি সংযুক্ত হয়েছে' : 'ছবি যোগ করুন',
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
