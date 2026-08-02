import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transfer_datasource.dart';

class LoanContactFormPage extends ConsumerStatefulWidget {
  final LoanContact? contact;

  const LoanContactFormPage({super.key, this.contact});

  @override
  ConsumerState<LoanContactFormPage> createState() => _LoanContactFormPageState();
}

class _LoanContactFormPageState extends ConsumerState<LoanContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _noteController;
  final _amountController = TextEditingController();
  String _txnType = 'borrow';
  String _paymentMethod = 'cash';

  bool get _editing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _noteController = TextEditingController(text: widget.contact?.note ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final contact = LoanContact(
      id: widget.contact?.id ?? 0,
      businessId: 0,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      createdAt: widget.contact?.createdAt ?? now,
      updatedAt: now,
    );

    final notifier = ref.read(loanContactFormProvider.notifier);
    final success = _editing
        ? await notifier.update(contact)
        : await notifier.create(contact);

    if (!mounted) return;
    if (!success) {
      final state = ref.read(loanContactFormProvider);
      state.whenOrNull(
        error: (e, _) => AppSnackBar.error(context, e.toString()),
      );
      return;
    }

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    if (!_editing && amount > 0) {
      final createdId = await _createdContactId(notifier);
      if (createdId != null) {
        await _createFirstTransaction(createdId, amount, now);
      }
    }

    if (!mounted) return;
    AppSnackBar.success(context, _editing ? 'হিসাব আপডেট হয়েছে' : 'নতুন হিসাব যোগ হয়েছে');
    ref.invalidate(loanDashboardProvider);
    ref.invalidate(loanContactListProvider);
    ref.invalidate(loanRefreshProvider);
    context.pop(true);
  }

  Future<int?> _createdContactId(LoanContactFormNotifier notifier) async {
    final repo = ref.read(loanRepositoryProvider);
    final result = await repo.getContacts();
    final contacts = result.fold((l) => throw l, (r) => r);
    final matching = contacts
        .where((c) => c.name == _nameController.text.trim())
        .toList()
      ..sort((a, b) => b.id.compareTo(a.id));
    if (matching.isEmpty) return null;
    return matching.first.id;
  }

  Future<void> _createFirstTransaction(
    int contactId,
    double amount,
    DateTime now,
  ) async {
    final accountDs = getIt<TransferDataSource>();
    int? cashId;
    int? bankId;
    if (_paymentMethod == 'cash') {
      cashId = await accountDs.getDefaultCashAccountId();
    } else {
      bankId = await accountDs.getDefaultBankAccountId();
    }
    final txn = LoanTransaction(
      id: 0,
      businessId: 0,
      contactId: contactId,
      type: _txnType,
      repayType: null,
      amount: amount,
      date: now,
      paymentMethod: _paymentMethod,
      cashAccountId: cashId,
      bankAccountId: bankId,
      createdAt: now,
      updatedAt: now,
    );
    await ref.read(loanTransactionFormProvider.notifier).create(txn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(_editing ? 'হিসাব সম্পাদনা' : 'নতুন হিসাব', style: AppTypography.subtitle1),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'নাম *',
                hint: 'যেমন: রাকিব, ফুপি, চাচা',
                controller: _nameController,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'নাম দিন' : null,
              ),
              AppSpacing.boxLG,
              AppTextField(
                label: 'ফোন',
                hint: 'ফোন নম্বর (ঐচ্ছিক)',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              AppSpacing.boxLG,
              AppTextField(
                label: 'নোট',
                hint: 'কোনো নোট (ঐচ্ছিক)',
                controller: _noteController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              if (!_editing) ...[
                AppSpacing.boxXXL,
                const Divider(height: 1),
                AppSpacing.boxLG,
                Text(
                  'প্রথম লেনদেন (ঐচ্ছিক)',
                  style: AppTypography.subtitle2.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.boxSM,
                Row(
                  children: [
                    Expanded(
                      child: _OptionButton(
                        label: 'নিয়েছি',
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.error,
                        selected: _txnType == 'borrow',
                        onTap: () => setState(() => _txnType = 'borrow'),
                      ),
                    ),
                    AppSpacing.boxWMD,
                    Expanded(
                      child: _OptionButton(
                        label: 'দিয়েছি',
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.success,
                        selected: _txnType == 'lend',
                        onTap: () => setState(() => _txnType = 'lend'),
                      ),
                    ),
                  ],
                ),
                AppSpacing.boxLG,
                AppTextField(
                  label: 'পরিমাণ',
                  hint: '০.০০',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  prefix: Text(
                    '৳ ',
                    style: AppTypography.subtitle1.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                AppSpacing.boxLG,
                DropdownButtonFormField<String>(
                  initialValue: _paymentMethod,
                  decoration: InputDecoration(
                    labelText: 'পেমেন্ট পদ্ধতি',
                    labelStyle: AppTypography.bodyText2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cash', child: Text('নগদ')),
                    DropdownMenuItem(value: 'bank', child: Text('ব্যাংক')),
                  ],
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
              ],
              AppSpacing.boxHXL,
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(loanContactFormProvider);
                  return AppButton(
                    text: _editing ? 'আপডেট করুন' : 'সেভ করুন',
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

class _OptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            AppSpacing.boxHSM,
            Text(
              label,
              style: AppTypography.subtitle2.copyWith(
                color: selected ? color : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
