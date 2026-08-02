import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:nexora_khata/features/transactions/domain/entities/transfer.dart';
import 'package:nexora_khata/features/transactions/presentation/models/account_option.dart';
import 'package:nexora_khata/features/transactions/presentation/providers/transfer_provider.dart';

class TransferFormPage extends ConsumerStatefulWidget {
  const TransferFormPage({super.key});

  @override
  ConsumerState<TransferFormPage> createState() => _TransferFormPageState();
}

class _TransferFormPageState extends ConsumerState<TransferFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _selectedDate;
  String? _fromKey;
  String? _toKey;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
    _noteCtrl = TextEditingController();
    _selectedDate = DateTime.now();
    _updateDateText();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _dateCtrl.dispose();
    _noteCtrl.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final from = _fromKey;
    final to = _toKey;
    if (from == null || to == null) return;

    final fromType = from.split(':').first;
    final fromId = int.parse(from.split(':').last);
    final toType = to.split(':').first;
    final toId = int.parse(to.split(':').last);

    final now = DateTime.now();
    final transfer = Transfer(
      id: 0,
      businessId: 0,
      fromType: fromType,
      fromCashAccountId: fromType == 'cash' ? fromId : null,
      fromBankAccountId: fromType == 'bank' ? fromId : null,
      toType: toType,
      toCashAccountId: toType == 'cash' ? toId : null,
      toBankAccountId: toType == 'bank' ? toId : null,
      amount: amount,
      description: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      transferDate: _selectedDate,
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(transferFormProvider.notifier);
    final success = await notifier.create(transfer);

    if (!mounted) return;
    if (!success) {
      final state = ref.read(transferFormProvider);
      state.whenOrNull(
        error: (e, _) => AppSnackBar.error(context, e.toString()),
      );
      return;
    }
    AppSnackBar.success(context, 'টাকা ট্রান্সফার করা হয়েছে');
    ref.invalidate(transferListProvider);
    ref.invalidate(transferAccountOptionsProvider);
    ref.invalidate(transferRefreshProvider);
    ref.invalidate(dashboardProvider);
    ref.invalidate(dashboardRefreshProvider);
    context.pop(true);
  }

  Widget _buildAccountDropdown({
    required String label,
    required String? value,
    required List<AccountOption> accounts,
    required ValueChanged<String?> onChanged,
    bool exclude = false,
  }) {
    final options = exclude
        ? accounts.where((a) => a.key != value).toList()
        : accounts;
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodyText2.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      ),
      items: options.map((a) {
        final icon = a.isCash ? Icons.account_balance_wallet_rounded : Icons.account_balance_rounded;
        return DropdownMenuItem(
          value: a.key,
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${a.name} (৳ ${a.balance.toStringAsFixed(0)})',
                  style: AppTypography.bodyText2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? '$label নির্বাচন করুন' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(transferAccountOptionsProvider);
    final accounts = accountsAsync.valueOrNull ?? const <AccountOption>[];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('ট্রান্সফার', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz_rounded, color: AppColors.info),
                    AppSpacing.boxMD,
                    Expanded(
                      child: Text(
                        'নগদ বা ব্যাংক হিসাব থেকে টাকা স্থানান্তর করুন',
                        style: AppTypography.bodyText2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.boxXL,
              accountsAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAccountDropdown(
                          label: 'হিসাব থেকে',
                          value: _fromKey,
                          accounts: accounts,
                          onChanged: (v) {
                            setState(() {
                              _fromKey = v;
                              if (_toKey == v) _toKey = null;
                            });
                          },
                        ),
                        AppSpacing.boxLG,
                        _buildAccountDropdown(
                          label: 'হিসাবে',
                          value: _toKey,
                          accounts: accounts,
                          exclude: true,
                          onChanged: (v) => setState(() => _toKey = v),
                        ),
                      ],
                    ),
              AppSpacing.boxXL,
              AppTextField(
                label: 'পরিমাণ',
                hint: '০.০০',
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                prefix: Text(
                  '৳ ',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'পরিমাণ লিখুন';
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return 'সঠিক পরিমাণ লিখুন';
                  return null;
                },
              ),
              AppSpacing.boxLG,
              AppTextField(
                label: 'তারিখ',
                controller: _dateCtrl,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary,
                ),
              ),
              AppSpacing.boxLG,
              AppTextField(
                label: 'নোট',
                hint: 'কেন ট্রান্সফার হলো (ঐচ্ছিক)',
                controller: _noteCtrl,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              AppSpacing.boxHXL,
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(transferFormProvider);
                  return AppButton(
                    text: 'সংরক্ষণ করুন',
                    icon: Icons.check_rounded,
                    isLoading: state.isLoading,
                    onPressed: _save,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
