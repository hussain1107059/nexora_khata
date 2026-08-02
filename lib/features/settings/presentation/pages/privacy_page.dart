import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/services/app_strings.dart';
import '../../../../core/widgets/app_text.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(AppStrings.s.privacyTitle, type: AppTextType.subtitle2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              AppStrings.s.privacyIntro,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.privacyCollectTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.privacyCollect1 +
                  AppStrings.s.privacyCollect2 +
                  AppStrings.s.privacyCollect3,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.privacyUseTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.privacyUse1 +
                  AppStrings.s.privacyUse2 +
                  AppStrings.s.privacyUse3,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.privacySecurityTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.privacySecurity1 +
                  AppStrings.s.privacySecurity2 +
                  AppStrings.s.privacySecurity3,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.privacyRightsTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.privacyRights1 +
                  AppStrings.s.privacyRights2 +
                  AppStrings.s.privacyRights3,
              type: AppTextType.body2,
            ),
            AppSpacing.boxLG,
            AppText(AppStrings.s.privacyContactTitle, type: AppTextType.subtitle2),
            AppSpacing.boxSM,
            AppText(
              AppStrings.s.privacyContactMsg + 'badhonbytebd@gmail.com',
              type: AppTextType.body2,
            ),
            AppSpacing.boxXXL,
          ],
        ),
      ),
    );
  }
}
