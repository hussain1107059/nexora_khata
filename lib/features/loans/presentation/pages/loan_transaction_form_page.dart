import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_transaction.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';
import 'package:nexora_khata/features/transactions/data/datasources/transfer_datasource.dart';

class LoanTransactionFormPage extends ConsumerStatefulWidget {
  final int contactId;
  final String contactName;
  final String initialType;

  const LoanTransactionFormPage({
    super.key,
    required this.contactId,
    required this.contactName,
    this.initialType = 'borrow',
  });

  @override
  ConsumerState<LoanTransactionFormPage> createState() =>
      _LoanTransactionFormPageState();
}

class _LoanTransactionFormPageState extends ConsumerState<LoanTransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _selectedDate;
  late String _type;
  String? _repayType;
  String _paymentMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
    _noteCtrl = TextEditingController();
    _selectedDate = DateTime.now();
    _type = widget.initialType;
    _repayType = null;
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
    if (_type == 'repay' && _repayType == null) {
      AppSnackBar.error(context, AppStrings.s.loanTxnRepaySelectError);
      return;
    }
    final now = DateTime.now();
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
      contactId: widget.contactId,
      type: _type,
      repayType: _type == 'repay' ? _repayType : null,
      amount: amount,
      date: _selectedDate,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      paymentMethod: _paymentMethod,
      cashAccountId: cashId,
      bankAccountId: bankId,
      createdAt: now,
      updatedAt: now,
    );

    final notifier = ref.read(loanTransactionFormProvider.notifier);
    final success = await notifier.create(txn);

    if (!mounted) return;
    if (!success) {
      final state = ref.read(loanTransactionFormProvider);
      state.whenOrNull(
        error: (e, _) => AppSnackBar.error(context, e.toString()),
      );
      return;
    }
    final label = switch (_type) {
      'borrow' => AppStrings.s.loanTxnBorrowedMsg,
      'lend' => AppStrings.s.loanTxnLentMsg,
      _ => AppStrings.s.loanTxnRepaidMsg,
    };
    AppSnackBar.success(context, label);
    ref.invalidate(loanDashboardProvider);
    ref.invalidate(loanTransactionsProvider(widget.contactId));
    ref.invalidate(loanRefreshProvider);
    context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(AppStrings.s.loanTxnAddTitle, style: AppTypography.subtitle1),
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
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.info,
                        size: 22,
                      ),
                    ),
                    AppSpacing.boxMD,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.s.loanTxnAccount,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            widget.contactName,
                            style: AppTypography.subtitle2.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.boxXL,
              Text(
                AppStrings.s.loanTxnType,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.boxHSM,
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: AppStrings.s.loanBorrowLabel,
                      subtitle: AppStrings.s.loanTxnBorrowSub,
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.error,
                      selected: _type == 'borrow',
                      onTap: () => setState(() {
                        _type = 'borrow';
                        _repayType = null;
                      }),
                    ),
                  ),
                  AppSpacing.boxWMD,
                  Expanded(
                    child: _TypeButton(
                      label: AppStrings.s.loanLendLabel,
                      subtitle: AppStrings.s.loanTxnLendSub,
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.success,
                      selected: _type == 'lend',
                      onTap: () => setState(() {
                        _type = 'lend';
                        _repayType = null;
                      }),
                    ),
                  ),
                ],
              ),
              if (_type == 'repay') ...[
                AppSpacing.boxLG,
                Text(
                  AppStrings.s.loanTxnRepayWhich,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.boxHSM,
                Row(
                  children: [
                    Expanded(
                      child: _RepayDirectionButton(
                        label: AppStrings.s.loanTxnRepayBorrow,
                        subtitle: AppStrings.s.loanTxnRepayBorrowSub,
                        icon: Icons.south_west_rounded,
                        color: AppColors.error,
                        selected: _repayType == 'borrow',
                        onTap: () => setState(() => _repayType = 'borrow'),
                      ),
                    ),
                    AppSpacing.boxWMD,
                    Expanded(
                      child: _RepayDirectionButton(
                        label: AppStrings.s.loanTxnRepayLend,
                        subtitle: AppStrings.s.loanTxnRepayLendSub,
                        icon: Icons.north_east_rounded,
                        color: AppColors.success,
                        selected: _repayType == 'lend',
                        onTap: () => setState(() => _repayType = 'lend'),
                      ),
                    ),
                  ],
                ),
              ],
              AppSpacing.boxXL,
              AppTextField(
                label: AppStrings.s.formAmount,
                hint: AppStrings.s.formAmountHint,
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                prefix: Text(
                  '৳ ',
                  style: AppTypography.subtitle1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return AppStrings.s.valEnterAmount;
                  final n = double.tryParse(v);
                  if (n == null || n <= 0) return AppStrings.s.valEnterValidAmount;
                  return null;
                },
              ),
              AppSpacing.boxLG,
              DropdownButtonFormField<String>(
                initialValue: _paymentMethod,
                decoration: InputDecoration(
                  labelText: AppStrings.s.payMethod,
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
                items: [
                  DropdownMenuItem(value: 'cash', child: Text(AppStrings.s.payCash)),
                  DropdownMenuItem(value: 'bank', child: Text(AppStrings.s.payBank)),
                ],
                onChanged: (v) => setState(() => _paymentMethod = v!),
              ),
              AppSpacing.boxLG,
              AppTextField(
                label: AppStrings.s.formDate,
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
                label: AppStrings.s.formNote,
                hint: AppStrings.s.loanTxnNoteHint,
                controller: _noteCtrl,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              AppSpacing.boxHXL,
              Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(loanTransactionFormProvider);
                  return AppButton(
                    text: AppStrings.s.loanTxnSave,
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

class _RepayDirectionButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _RepayDirectionButton({
    required this.label,
    required this.subtitle,
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
            AppSpacing.boxXXS,
            Text(
              subtitle,
              style: AppTypography.overline.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.subtitle,
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
            Icon(icon, color: color, size: 26),
            AppSpacing.boxHSM,
            Text(
              label,
              style: AppTypography.subtitle2.copyWith(
                color: selected ? color : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            AppSpacing.boxXXS,
            Text(
              subtitle,
              style: AppTypography.overline.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
