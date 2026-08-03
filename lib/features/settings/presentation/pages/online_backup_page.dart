import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/services/app_strings.dart';
import 'package:nexora_khata/core/widgets/app_dialog.dart';
import 'package:nexora_khata/core/widgets/app_snackbar.dart';
import 'package:nexora_khata/core/widgets/app_text.dart';
import 'package:nexora_khata/features/settings/data/services/google_drive_backup_service.dart';
import 'package:nexora_khata/features/settings/presentation/providers/drive_backup_provider.dart';

class OnlineBackupPage extends ConsumerStatefulWidget {
  const OnlineBackupPage({super.key});

  @override
  ConsumerState<OnlineBackupPage> createState() => _OnlineBackupPageState();
}

class _OnlineBackupPageState extends ConsumerState<OnlineBackupPage> {
  bool _signingIn = false;
  bool _backingUp = false;
  bool _restoring = false;

  GoogleDriveBackupService get _service =>
      ref.read(googleDriveBackupServiceProvider);

  String _errorText(DriveBackupError error) {
    final s = AppStrings.s;
    switch (error) {
      case DriveBackupError.noInternet:
        return s.obkErrorNoInternet;
      case DriveBackupError.notSignedIn:
        return s.obkErrorNotSignedIn;
      case DriveBackupError.signInCancelled:
        return s.obkErrorSignInCancelled;
      case DriveBackupError.signInFailed:
        return s.obkErrorSignInFailed;
      case DriveBackupError.permissionDenied:
        return s.obkErrorPermissionDenied;
      case DriveBackupError.tokenExpired:
        return s.obkErrorTokenExpired;
      case DriveBackupError.missingBackup:
        return s.obkErrorMissingBackup;
      case DriveBackupError.uploadFailed:
        return s.obkErrorUploadFailed;
      case DriveBackupError.downloadFailed:
        return s.obkErrorDownloadFailed;
      case DriveBackupError.restoreFailed:
        return s.obkErrorRestoreFailed;
      case DriveBackupError.unsupported:
        return s.obkErrorUnsupported;
      case DriveBackupError.unknown:
        return s.obkErrorUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(driveBackupStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: AppText(AppStrings.s.obkTitle, type: AppTextType.subtitle2),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _buildAccountCard(statusAsync),
          AppSpacing.boxLG,
          _buildStatusCard(statusAsync),
          AppSpacing.boxLG,
          _buildBackupCard(statusAsync),
          AppSpacing.boxLG,
          _buildRestoreCard(statusAsync),
          AppSpacing.boxHMassive,
        ],
      ),
    );
  }

  Widget _buildAccountCard(AsyncValue<DriveBackupStatus> statusAsync) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle_rounded, color: AppColors.primary, size: 20),
                AppSpacing.boxWSM,
                AppText(AppStrings.s.obkYourAccount, type: AppTextType.subtitle2),
              ],
            ),
            AppSpacing.boxMD,
            statusAsync.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
              error: (e, _) => AppText(
                AppStrings.s.setErrorPrefix('$e'),
                type: AppTextType.body2,
                color: AppColors.error,
              ),
              data: (status) {
                if (status.isSignedIn) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        AppStrings.s.obkSignedInAs(status.accountEmail ?? ''),
                        type: AppTextType.body2,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.boxSM,
                      AppText(
                        AppStrings.s.obkSignedInDesc,
                        type: AppTextType.caption,
                        color: AppColors.textSecondary,
                      ),
                      AppSpacing.boxLG,
                      SizedBox(
                        width: double.infinity, height: 44,
                        child: OutlinedButton.icon(
                          onPressed: _signingIn ? null : _signOut,
                          icon: const Icon(Icons.logout_rounded, size: 20),
                          label: Text(AppStrings.s.obkSignOut),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      AppStrings.s.obkSignedOutDesc,
                      type: AppTextType.body2,
                      color: AppColors.textSecondary,
                    ),
                    AppSpacing.boxLG,
                    SizedBox(
                      width: double.infinity, height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _signingIn ? null : _signIn,
                        icon: _signingIn
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : const Icon(Icons.login_rounded, size: 20, color: AppColors.white),
                        label: Text(AppStrings.s.obkSignIn, style: const TextStyle(color: AppColors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AsyncValue<DriveBackupStatus> statusAsync) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                AppSpacing.boxWSM,
                AppText(AppStrings.s.obkStatus, type: AppTextType.subtitle2),
              ],
            ),
            AppSpacing.boxMD,
            statusAsync.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
              error: (e, _) => AppText(
                AppStrings.s.setErrorPrefix('$e'),
                type: AppTextType.body2,
                color: AppColors.error,
              ),
              data: (status) => Column(
                children: [
                  _statusRow(AppStrings.s.obkLastBackup, _formatTime(status.lastBackupTime),
                    icon: Icons.update_rounded),
                  const Divider(height: 1),
                  _statusRow(AppStrings.s.obkBackupSize, status.formattedSize,
                    icon: Icons.storage_rounded),
                  const Divider(height: 1),
                  _statusRow(AppStrings.s.obkBackupDate, _formatDate(status.lastBackupTime),
                    icon: Icons.event_rounded),
                  const Divider(height: 1),
                  _statusRow(AppStrings.s.obkStatus,
                    status.isSignedIn
                        ? AppStrings.s.obkSignedInAs(status.accountEmail ?? AppStrings.s.obkNotSignedIn)
                        : AppStrings.s.obkNotSignedIn,
                      icon: Icons.check_circle_outline),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, String value, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          AppSpacing.boxWSM,
          Expanded(
            child: AppText(label, type: AppTextType.body2, color: AppColors.textSecondary),
          ),
          AppSpacing.boxWSM,
          Flexible(
            child: AppText(
              value,
              type: AppTextType.body2,
              color: AppColors.textPrimary,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard(AsyncValue<DriveBackupStatus> statusAsync) {
    final signedIn = statusAsync.valueOrNull?.isSignedIn ?? false;
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 20),
                AppSpacing.boxWSM,
                AppText(AppStrings.s.obkBackupNow, type: AppTextType.subtitle2),
              ],
            ),
            AppSpacing.boxLG,
            SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton.icon(
                onPressed: (!signedIn || _backingUp) ? null : _backupNow,
                icon: _backingUp
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.cloud_upload_outlined, size: 20, color: AppColors.white),
                label: Text(AppStrings.s.obkBackupNow, style: const TextStyle(color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreCard(AsyncValue<DriveBackupStatus> statusAsync) {
    final signedIn = statusAsync.valueOrNull?.isSignedIn ?? false;
    final hasBackup = statusAsync.valueOrNull?.hasBackup ?? false;
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restore_outlined, color: AppColors.warning, size: 20),
                AppSpacing.boxWSM,
                AppText(AppStrings.s.obkRestore, type: AppTextType.subtitle2),
              ],
            ),
            AppSpacing.boxMD,
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: AppText(
                AppStrings.s.obkRestoreWarning,
                type: AppTextType.body2,
                color: AppColors.warning,
              ),
            ),
            AppSpacing.boxLG,
            SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton.icon(
                onPressed: (!signedIn || !hasBackup || _restoring) ? null : _restore,
                icon: _restoring
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.restore_outlined, size: 20, color: AppColors.white),
                label: Text(AppStrings.s.obkRestore, style: const TextStyle(color: AppColors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() => _signingIn = true);
    try {
      await _service.signIn();
      ref.invalidate(driveBackupStatusProvider);
    } on DriveBackupException catch (e) {
      if (e.error != DriveBackupError.signInCancelled) {
        if (mounted) AppSnackBar.error(context, _errorText(e.error));
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, AppStrings.s.setErrorPrefix('$e'));
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _service.signOut();
    } finally {
      ref.invalidate(driveBackupStatusProvider);
    }
  }

  Future<void> _backupNow() async {
    setState(() => _backingUp = true);
    try {
      await _service.uploadBackup();
      ref.invalidate(driveBackupStatusProvider);
      if (mounted) AppSnackBar.success(context, AppStrings.s.obkUploadSuccess);
    } on DriveBackupException catch (e) {
      if (mounted) AppSnackBar.error(context, _errorText(e.error));
    } catch (e) {
      if (mounted) AppSnackBar.error(context, AppStrings.s.setErrorPrefix('$e'));
    } finally {
      if (mounted) setState(() => _backingUp = false);
    }
  }

  Future<void> _restore() async {
    final confirmed = await AppDialog.confirm(
      context,
      title: AppStrings.s.obkRestoreConfirmTitle,
      message: AppStrings.s.obkRestoreConfirmMsg,
      confirmLabel: AppStrings.s.commonConfirmLabel,
      icon: Icons.restore_rounded,
      iconColor: AppColors.warning,
      iconBackground: AppColors.warningLight,
    );
    if (confirmed != true) return;
    setState(() => _restoring = true);
    try {
      await _service.downloadAndRestore();
      ref.invalidate(driveBackupStatusProvider);
      if (mounted) AppSnackBar.success(context, AppStrings.s.obkRestoreSuccess);
    } on DriveBackupException catch (e) {
      if (mounted) AppSnackBar.error(context, _errorText(e.error));
    } catch (e) {
      if (mounted) AppSnackBar.error(context, AppStrings.s.setErrorPrefix('$e'));
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  String _formatTime(DateTime? date) {
    return date == null ? AppStrings.s.obkNever : DateFormat('hh:mm a').format(date);
  }

  String _formatDate(DateTime? date) {
    return date == null ? AppStrings.s.obkNever : DateFormat('dd/MM/yyyy').format(date);
  }
}