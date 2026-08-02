import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/widgets/app_text.dart';
import 'package:nexora_khata/features/settings/presentation/providers/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppText('সেটিংস', type: AppTextType.heading4),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'পছন্দসমূহ'),
          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: const AppText('ডার্ক মোড', type: AppTextType.body2),
            value: isDarkMode,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          const _LanguageTile(),
          const Divider(height: 1),
          const _SectionHeader(title: 'ডেটাবেস'),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primary),
            title: const AppText('ব্যাকআপ', type: AppTextType.body2),
            subtitle: const AppText('ব্যাকআপ নিন', type: AppTextType.caption),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primary),
            title: const AppText('ব্যাকআপ ও পুনরুদ্ধার', type: AppTextType.body2),
            subtitle: const AppText('ব্যাকআপ, পুনরুদ্ধার, এক্সপোর্ট ও ইম্পোর্ট', type: AppTextType.caption),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/backup'),
          ),
          const Divider(height: 1),
          const _SectionHeader(title: 'অন্যান্য'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: const AppText('সম্পর্কে', type: AppTextType.body2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/about'),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
            title: const AppText('গোপনীয়তা নীতি', type: AppTextType.body2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined, color: AppColors.primary),
            title: const AppText('শর্তাবলী', type: AppTextType.body2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/terms'),
          ),
          const _AppVersionTile(),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: AppText(
        title,
        type: AppTextType.caption,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final langName = locale.languageCode == 'bn' ? 'বাংলা' : 'English';

    return ListTile(
      leading: const Icon(Icons.language, color: AppColors.primary),
      title: const AppText('ভাষা', type: AppTextType.body2),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            langName,
            type: AppTextType.body2,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
        ],
      ),
      onTap: () => _showLanguageDialog(context, ref),
    );
  }

  static Future<void> _showLanguageDialog(BuildContext context, WidgetRef ref) async {
    final currentLocale = ref.read(localeProvider);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const AppText('ভাষা নির্বাচন করুন', type: AppTextType.heading4),
        content: RadioGroup<Locale>(
          groupValue: currentLocale,
          onChanged: (locale) {
            if (locale != null) {
              ref.read(localeProvider.notifier).setLocale(locale);
              Navigator.pop(context);
            }
          },
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: AppText('বাংলা'),
                value: Locale('bn', 'BD'),
              ),
              RadioListTile<Locale>(
                title: AppText('English'),
                value: Locale('en', 'US'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppVersionTile extends ConsumerWidget {
  const _AppVersionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);

    return ListTile(
      leading: const Icon(Icons.info_outline, color: AppColors.primary),
      title: const AppText('অ্যাপ সংস্করণ', type: AppTextType.body2),
      trailing: packageInfo.when(
        data: (info) => AppText(
          '${info.version}+${info.buildNumber}',
          type: AppTextType.body2,
          color: AppColors.textSecondary,
        ),
        loading: () => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        error: (_, _) => const AppText(
          '1.0.0+1',
          type: AppTextType.body2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
