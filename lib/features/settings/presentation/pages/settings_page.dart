import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/config/theme/app_typography.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_text.dart';
import 'package:nexora_khata/features/auth/presentation/providers/auth_provider.dart';
import 'package:nexora_khata/features/settings/presentation/providers/settings_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStrings.dependOnLocale(context);
    final isDarkMode = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppText(AppStrings.s.setTitle, type: AppTextType.heading4),
      ),
      body: ListView(
        children: [
          const _ProfileSection(),
          _SectionHeader(title: AppStrings.s.setPreferences),
          SwitchListTile(
            secondary: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: AppText(AppStrings.s.setDarkMode, type: AppTextType.body2),
            value: isDarkMode,
            onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
          ),
          const _LanguageTile(),
          const Divider(height: 1),
          _SectionHeader(title: AppStrings.s.setDatabase),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primary),
            title: AppText(AppStrings.s.setBackup, type: AppTextType.body2),
            subtitle: AppText(AppStrings.s.setBackupTake, type: AppTextType.caption),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/backup'),
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.primary),
            title: AppText(AppStrings.s.setBackupRestore, type: AppTextType.body2),
            subtitle: AppText(AppStrings.s.setBackupRestoreSub, type: AppTextType.caption),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/backup'),
          ),
          const Divider(height: 1),
          _SectionHeader(title: AppStrings.s.setOther),
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppColors.primary),
            title: AppText(AppStrings.s.setAbout, type: AppTextType.body2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/about'),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
            title: AppText(AppStrings.s.setPrivacy, type: AppTextType.body2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.article_outlined, color: AppColors.primary),
            title: AppText(AppStrings.s.setTerms, type: AppTextType.body2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/terms'),
          ),
          const _AppVersionTile(),
          const _LogoutTile(),
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
      title: AppText(AppStrings.s.setLanguage, type: AppTextType.body2),
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
        title: AppText(AppStrings.s.setSelectLanguage, type: AppTextType.heading4),
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
    AppStrings.dependOnLocale(context);
    final packageInfo = ref.watch(packageInfoProvider);

    return ListTile(
      leading: const Icon(Icons.info_outline, color: AppColors.primary),
      title: AppText(AppStrings.s.setAppVersion, type: AppTextType.body2),
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

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStrings.dependOnLocale(context);
    final user = ref.watch(authStateProvider).value;
    final name = user?.name ?? '';
    final subtitle = user?.username ?? user?.email;

    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              name.isEmpty ? '?' : name.characters.first.toUpperCase(),
              style: AppTypography.heading5.copyWith(color: AppColors.primary),
            ),
          ),
          AppSpacing.boxWMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  name.isEmpty ? AppStrings.s.appTitle : name,
                  type: AppTextType.subtitle1,
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  AppText(
                    subtitle,
                    type: AppTextType.caption,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutTile extends ConsumerWidget {
  const _LogoutTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AppStrings.dependOnLocale(context);
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.error),
      title: AppText(
        AppStrings.s.setLogout,
        type: AppTextType.body2,
        color: AppColors.error,
      ),
      onTap: () => _confirmLogout(context, ref),
    );
  }

  static Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(AppStrings.s.logoutConfirmTitle, type: AppTextType.heading4),
        content: AppText(AppStrings.s.logoutConfirmMsg, type: AppTextType.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(AppStrings.s.logoutConfirmNo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: AppText(
              AppStrings.s.logoutConfirmYes,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}
