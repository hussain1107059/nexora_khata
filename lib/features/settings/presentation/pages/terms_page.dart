import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/services/app_strings.dart';
import '../../../../core/widgets/app_text.dart';

class TermsPage extends ConsumerWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(AppStrings.s.termsTitle, type: AppTextType.subtitle2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              AppStrings.s.termsIntro,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.termsServiceTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.termsService1 +
                  AppStrings.s.termsService2 +
                  AppStrings.s.termsService3,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.termsUserTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.termsUser1 +
                  AppStrings.s.termsUser2 +
                  AppStrings.s.termsUser3 +
                  AppStrings.s.termsUser4,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.termsAccountTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.termsAccount1 +
                  AppStrings.s.termsAccount2 +
                  AppStrings.s.termsAccount3,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.termsDisclaimerTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.termsDisclaimer1 +
                  AppStrings.s.termsDisclaimer2 +
                  AppStrings.s.termsDisclaimer3,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.termsLimitsTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.termsLimits1 +
                  AppStrings.s.termsLimits2 +
                  AppStrings.s.termsLimits3,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.termsContactTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.termsContactMsg + 'badhonbytebd@gmail.com',
              type: AppTextType.body2,
            ),
            AppSpacing.boxXXL,
          ],
        ),
      ),
    );
  }
}
