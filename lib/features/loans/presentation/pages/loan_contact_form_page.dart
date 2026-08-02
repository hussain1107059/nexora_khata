import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/features/loans/domain/entities/loan_contact.dart';
import 'package:nexora_khata/features/loans/presentation/providers/loan_provider.dart';

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
    AppSnackBar.success(context, _editing ? 'হিসাব আপডেট হয়েছে' : 'নতুন হিসাব যোগ হয়েছে');
    ref.invalidate(loanDashboardProvider);
    ref.invalidate(loanContactListProvider);
    ref.invalidate(loanRefreshProvider);
    context.pop(true);
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
