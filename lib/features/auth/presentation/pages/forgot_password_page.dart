import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/errors/failures.dart';
import 'package:nexora_khata/core/router/route_names.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/utils/validators.dart';
import 'package:nexora_khata/core/widgets/app_button.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text_field.dart';
import 'package:nexora_khata/features/auth/presentation/providers/auth_provider.dart';

enum _ResetStep { email, question, newPassword }

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _ResetStep _step = _ResetStep.email;
  String _email = '';
  String _question = '';
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _answerController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _errorMessage(Object? error, String fallback) {
    return error is Failure ? error.message : fallback;
  }

  Future<void> _loadQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getSecurityQuestion(_emailController.text);
    if (!mounted) return;
    result.fold(
      (l) {
        setState(() => _busy = false);
        AppSnackBar.error(
            context, _errorMessage(l, AppStrings.s.authForgotEmailNotFound));
      },
      (question) {
        setState(() {
          _busy = false;
          if (question == null || question.isEmpty) {
            AppSnackBar.error(context, AppStrings.s.authForgotEmailNotFound);
          } else {
            _email = _emailController.text.trim();
            _question = question;
            _step = _ResetStep.question;
          }
        });
      },
    );
  }

  Future<void> _verifyAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      AppSnackBar.error(context, AppStrings.s.authRequiredField);
      return;
    }
    setState(() => _busy = true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.verifySecurityAnswer(_email, _answerController.text);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (l) => AppSnackBar.error(
          context, _errorMessage(l, AppStrings.s.authForgotWrongAnswer)),
      (ok) {
        if (ok) {
          _step = _ResetStep.newPassword;
        } else {
          AppSnackBar.error(context, AppStrings.s.authForgotWrongAnswer);
        }
      },
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.resetPassword(
      email: _email,
      newPassword: _newPasswordController.text,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      (l) => AppSnackBar.error(
          context, _errorMessage(l, AppStrings.s.authRequiredField)),
      (_) {
        AppSnackBar.success(context, AppStrings.s.authForgotResetSuccess);
        context.go(RouteNames.login);
      },
    );
  }

  String _getStepTitle() {
    switch (_step) {
      case _ResetStep.email:
        return AppStrings.s.authForgotTitle;
      case _ResetStep.question:
        return AppStrings.s.authForgotQuestionTitle;
      case _ResetStep.newPassword:
        return AppStrings.s.authForgotNewPasswordTitle;
    }
  }

  String _getStepSubtitle() {
    switch (_step) {
      case _ResetStep.email:
        return AppStrings.s.authForgotSubtitle;
      case _ResetStep.question:
        return AppStrings.s.authForgotQuestionSubtitle;
      case _ResetStep.newPassword:
        return AppStrings.s.authForgotNewPasswordSubtitle;
    }
  }

  void _goBack() {
    if (_step == _ResetStep.email) {
      context.go(RouteNames.login);
    } else if (_step == _ResetStep.question) {
      setState(() => _step = _ResetStep.email);
    } else {
      setState(() => _step = _ResetStep.question);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppStrings.dependOnLocale(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        title: Text(
          AppStrings.s.authForgotTitle,
          style: AppTypography.subtitle1,
        ),
        centerTitle: true,
      ),
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
                    Image.asset(
                      'assets/images/NexoraKhata.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    AppSpacing.boxHXL,
                    Text(
                      _getStepTitle(),
                      style: AppTypography.heading2,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.boxHSM,
                    Text(
                      _getStepSubtitle(),
                      style: AppTypography.bodyText2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.boxHXXXL,
                    ..._buildStepFields(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStepFields() {
    switch (_step) {
      case _ResetStep.email:
        return [
          AppTextField(
            label: AppStrings.s.authEmailLabel,
            hint: AppStrings.s.authForgotEmailHint,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: AppColors.textHint,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return AppStrings.s.authRequiredField;
              }
              return AppValidators.email(v);
            },
          ),
          AppSpacing.boxHXXL,
          AppButton(
            text: AppStrings.s.authForgotContinue,
            icon: Icons.arrow_forward_rounded,
            isLoading: _busy,
            onPressed: _loadQuestion,
          ),
        ];
      case _ResetStep.question:
        return [
          Text(
            _question,
            style: AppTypography.subtitle1,
            textAlign: TextAlign.center,
          ),
          AppSpacing.boxHLG,
          AppTextField(
            controller: _answerController,
            hint: AppStrings.s.authForgotQuestionHint,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.textHint,
            ),
            obscureText: true,
          ),
          AppSpacing.boxHXXL,
          AppButton(
            text: AppStrings.s.authForgotVerify,
            icon: Icons.verified_rounded,
            isLoading: _busy,
            onPressed: _verifyAnswer,
          ),
          AppSpacing.boxHSM,
          TextButton(
            onPressed: _goBack,
            child: Text(AppStrings.s.authForgotContinue),
          ),
        ];
      case _ResetStep.newPassword:
        return [
          AppTextField(
            label: AppStrings.s.authForgotNewPasswordLabel,
            hint: AppStrings.s.authForgotNewPasswordHint,
            controller: _newPasswordController,
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
            label: AppStrings.s.authForgotConfirmPasswordLabel,
            hint: AppStrings.s.authForgotConfirmPasswordHint,
            controller: _confirmPasswordController,
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
              if (v != _newPasswordController.text) {
                return AppStrings.s.authPasswordsMismatch;
              }
              return null;
            },
          ),
          AppSpacing.boxHXXL,
          AppButton(
            text: AppStrings.s.authForgotResetButton,
            icon: Icons.password_rounded,
            isLoading: _busy,
            onPressed: _resetPassword,
          ),
          AppSpacing.boxHXL,
          TextButton(
            onPressed: _goBack,
            child: Text(AppStrings.s.authForgotBack),
          ),
        ];
    }
  }
}