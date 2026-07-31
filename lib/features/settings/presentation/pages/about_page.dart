import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_spacing.dart';
import '../../../../core/widgets/app_text.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('সম্পর্কে', type: AppTextType.subtitle2),
        centerTitle: true,
      ),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final version = snapshot.data?.version ?? '--';
          final buildNumber = snapshot.data?.buildNumber ?? '--';
          final versionStr = '$version+$buildNumber';

          return SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                AppSpacing.boxHHuge,
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: AppColors.primary,
                ),
                AppSpacing.boxLG,
                const AppText(
                  'নেক্সোরা খাতা',
                  type: AppTextType.heading3,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.boxSM,
                const AppText(
                  'একটি আধুনিক হিসাব সংরক্ষণ অ্যাপ্লিকেশন',
                  type: AppTextType.body2,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                AppSpacing.boxXXL,
                const Divider(),
                AppSpacing.boxLG,
                _InfoRow(label: 'অ্যাপ সংস্করণ', value: versionStr),
                _InfoRow(label: 'ডেভেলপার', value: 'BadhonByte'),
                _InfoRow(label: 'ইমেইল', value: 'badhonbyte@email.com'),
                _InfoRow(label: 'ওয়েবসাইট', value: 'https://badhonbyte.com'),
                AppSpacing.boxXXL,
                const Divider(),
                AppSpacing.boxLG,
                const AppText(
                  '© 2026 BadhonByte. সর্বস্বত্ব সংরক্ষিত।',
                  type: AppTextType.caption,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: AppText(
              label,
              type: AppTextType.body2,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: AppText(
              value,
              type: AppTextType.body2,
            ),
          ),
        ],
      ),
    );
  }
}
