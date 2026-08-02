import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/features/auth/presentation/providers/auth_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final success = await ref.read(authStateProvider.notifier).signup(
          name: _nameController.text,
          username: _usernameController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      AppSnackBar.success(context, AppStrings.s.authSignupSuccess);
    } else {
      final error = ref.read(authStateProvider).asError?.error;
      AppSnackBar.error(
        context,
        error is ValidationFailure
            ? AppStrings.s.authUsernameTaken
            : error is Failure
                ? error.message
                : AppStrings.s.authRequiredField,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppStrings.dependOnLocale(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      child: Image.asset(
                        'assets/images/NexoraKhata.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    ),
                    AppSpacing.boxHXL,
                    Text(
                      AppStrings.s.authSignupTitle,
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.boxHSM,
                    Text(
                      AppStrings.s.authSignupSubtitle,
                      style: AppTypography.bodyText2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.boxHXXXL,
                    AppTextField(
                      label: AppStrings.s.authFullNameLabel,
                      hint: AppStrings.s.authFullNameHint,
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                        color: AppColors.textHint,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppStrings.s.authRequiredField
                          : null,
                    ),
                    AppSpacing.boxHLG,
                    AppTextField(
                      label: AppStrings.s.authNewUsernameLabel,
                      hint: AppStrings.s.authNewUsernameHint,
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.textHint,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? AppStrings.s.authRequiredField
                          : null,
                    ),
                    AppSpacing.boxHLG,
                    AppTextField(
                      label: AppStrings.s.authPasswordLabel,
                      hint: AppStrings.s.authPasswordHint,
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textHint,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return AppStrings.s.authRequiredField;
                        }
                        if (v.length < 4) {
                          return AppStrings.s.authPasswordMin;
                        }
                        return null;
                      },
                    ),
                    AppSpacing.boxHLG,
                    AppTextField(
                      label: AppStrings.s.authConfirmPasswordLabel,
                      hint: AppStrings.s.authConfirmPasswordHint,
                      controller: _confirmController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textHint,
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return AppStrings.s.authRequiredField;
                        }
                        if (v != _passwordController.text) {
                          return AppStrings.s.authPasswordsMismatch;
                        }
                        return null;
                      },
                    ),
                    AppSpacing.boxHXXL,
                    AppButton(
                      text: AppStrings.s.authSignupButton,
                      icon: Icons.person_add_alt_1_rounded,
                      isLoading: _submitting,
                      onPressed: _signup,
                    ),
                    AppSpacing.boxHLG,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.s.authHaveAccount,
                          style: AppTypography.bodyText2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(RouteNames.login),
                          child: Text(AppStrings.s.authLoginLink),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
