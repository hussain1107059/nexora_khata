import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/features/auth/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final success = await ref.read(authStateProvider.notifier).login(
          _usernameController.text,
          _passwordController.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      AppSnackBar.success(context, AppStrings.s.authLoginSuccess);
    } else {
      AppSnackBar.error(context, AppStrings.s.authLoginError);
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
                      AppStrings.s.authLoginTitle,
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.boxHSM,
                    Text(
                      AppStrings.s.authLoginSubtitle,
                      style: AppTypography.bodyText2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.boxHXXXL,
                    AppTextField(
                      label: AppStrings.s.authUsernameLabel,
                      hint: AppStrings.s.authUsernameHint,
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
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.textHint,
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? AppStrings.s.authRequiredField
                          : null,
                    ),
                    AppSpacing.boxHXXL,
                    AppButton(
                      text: AppStrings.s.authLoginButton,
                      icon: Icons.login_rounded,
                      isLoading: _submitting,
                      onPressed: _login,
                    ),
                    AppSpacing.boxHLG,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.s.authNoAccount,
                          style: AppTypography.bodyText2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go(RouteNames.signup),
                          child: Text(AppStrings.s.authSignupLink),
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
