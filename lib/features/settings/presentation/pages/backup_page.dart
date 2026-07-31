import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:nexora_khata/core/config/theme/app_colors.dart';
import 'package:nexora_khata/core/config/theme/app_spacing.dart';
import 'package:nexora_khata/core/widgets/app_text.dart';
import 'package:nexora_khata/features/settings/data/services/backup_service.dart';
import 'package:nexora_khata/features/settings/presentation/providers/backup_provider.dart';
import 'package:nexora_khata/features/settings/presentation/providers/settings_provider.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> with WidgetsBindingObserver {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final service = ref.read(backupServiceProvider);
    if (state == AppLifecycleState.paused) {
      service.pauseAutoBackup();
    } else if (state == AppLifecycleState.resumed) {
      service.resumeAutoBackup();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final autoEnabled = ref.watch(autoBackupEnabledProvider);
    final historyAsync = ref.watch(backupHistoryProvider);
    final countAsync = ref.watch(backupCountProvider);
    final sizeAsync = ref.watch(backupTotalSizeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppText('ব্যাকআপ ও পুনরুদ্ধার', type: AppTextType.subtitle2),
        centerTitle: true,
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _buildAutoBackupCard(autoEnabled),
          AppSpacing.boxLG,
          _buildManualBackupCard(),
          AppSpacing.boxLG,
          _buildRestoreCard(),
          AppSpacing.boxLG,
          _buildExportImportCard(),
          AppSpacing.boxLG,
          _buildHistorySection(historyAsync, countAsync, sizeAsync),
          AppSpacing.boxHMassive,
        ],
      ),
    );
  }

  Widget _buildAutoBackupCard(bool autoEnabled) {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule_rounded, color: AppColors.info, size: 20),
                AppSpacing.boxWSM,
                const AppText('স্বয়ংক্রিয় ব্যাকআপ', type: AppTextType.subtitle2),
                const Spacer(),
                Switch(
                  value: autoEnabled,
                  activeTrackColor: AppColors.info,
                  onChanged: (v) => ref.read(autoBackupEnabledProvider.notifier).toggle(v),
                ),
              ],
            ),
            if (autoEnabled) ...[
              AppSpacing.boxMD,
              const AppText('ব্যাকআপ ফ্রিকোয়েন্সি', type: AppTextType.caption, color: AppColors.textSecondary),
              AppSpacing.boxSM,
              _buildFrequencySelector(),
              AppSpacing.boxSM,
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 14, color: AppColors.info),
                    AppSpacing.boxWSM,
                    Expanded(child: AppText(
                      'অ্যাপ চালু থাকাকালীন স্বয়ংক্রিয় ব্যাকআপ নেওয়া হবে',
                      type: AppTextType.caption, color: AppColors.info,
                    )),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector() {
    final freq = ref.watch(autoBackupFrequencyProvider);
    return Row(
      children: [
        _freqChip('প্রতি ঘন্টা', 'hourly', freq),
        AppSpacing.boxWSM,
        _freqChip('দৈনিক', 'daily', freq),
        AppSpacing.boxWSM,
        _freqChip('সাপ্তাহিক', 'weekly', freq),
        AppSpacing.boxWSM,
        _freqChip('মাসিক', 'monthly', freq),
      ],
    );
  }

  Widget _freqChip(String label, String value, String current) {
    final selected = value == current;
    return GestureDetector(
      onTap: () => ref.read(autoBackupFrequencyProvider.notifier).setFrequency(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.info : AppColors.chipBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: selected ? AppColors.info : AppColors.border),
        ),
        child: AppText(label, type: AppTextType.caption,
          color: selected ? AppColors.white : AppColors.textPrimary),
      ),
    );
  }

  Widget _buildManualBackupCard() {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 20),
                AppSpacing.boxWSM,
                const AppText('ম্যানুয়াল ব্যাকআপ', type: AppTextType.subtitle2),
              ],
            ),
            AppSpacing.boxMD,
            const AppText('বর্তমান ডেটাবেসের একটি ব্যাকআপ কপি তৈরি করুন', type: AppTextType.body2, color: AppColors.textSecondary),
            AppSpacing.boxLG,
            SizedBox(
              width: double.infinity, height: 44,
              child: ElevatedButton.icon(
                onPressed: _isBackingUp ? null : _manualBackup,
                icon: _isBackingUp
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.download_rounded, size: 20),
                label: const AppText('ব্যাকআপ নিন', type: AppTextType.button, color: AppColors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestoreCard() {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restore_outlined, color: AppColors.warning, size: 20),
                AppSpacing.boxWSM,
                const AppText('পুনরুদ্ধার', type: AppTextType.subtitle2),
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
              child: const AppText(
                'পুনরুদ্ধার করলে বর্তমান ডেটা মুছে যাবে এবং ব্যাকআপ ফাইল থেকে প্রতিস্থাপিত হবে',
                type: AppTextType.body2, color: AppColors.warning,
              ),
            ),
            AppSpacing.boxLG,
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _isRestoring ? null : _restoreFromHistory,
                      icon: _isRestoring
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                          : const Icon(Icons.history_rounded, size: 20),
                      label: const AppText('ইতিহাস থেকে', type: AppTextType.button, color: AppColors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                    ),
                  ),
                ),
                AppSpacing.boxWSM,
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _isRestoring ? null : _restoreFromFile,
                      icon: _isRestoring
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.file_open_rounded, size: 20),
                      label: const AppText('ফাইল থেকে', type: AppTextType.button),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportImportCard() {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.share_outlined, color: AppColors.secondary, size: 20),
                AppSpacing.boxWSM,
                const AppText('এক্সপোর্ট / ইম্পোর্ট', type: AppTextType.subtitle2),
              ],
            ),
            AppSpacing.boxMD,
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _exportDb,
                      icon: _isExporting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                          : const Icon(Icons.share_rounded, size: 20),
                      label: const AppText('শেয়ার', type: AppTextType.button, color: AppColors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                    ),
                  ),
                ),
                AppSpacing.boxWSM,
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _importDb,
                      icon: const Icon(Icons.file_upload_outlined, size: 20),
                      label: const AppText('ইম্পোর্ট', type: AppTextType.button),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection(AsyncValue<List<BackupEntry>> historyAsync, AsyncValue<int> countAsync, AsyncValue<double> sizeAsync) {
    return Card(
      elevation: AppSpacing.elevationSm,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, color: AppColors.textPrimary, size: 20),
                AppSpacing.boxWSM,
                const AppText('ব্যাকআপ ইতিহাস', type: AppTextType.subtitle2),
                const Spacer(),
                countAsync.when(
                  data: (c) => sizeAsync.when(
                    data: (s) => AppText('$cটি | ${_fmtSize(s)}', type: AppTextType.caption, color: AppColors.textSecondary),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
            AppSpacing.boxMD,
            historyAsync.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 2),
              )),
              error: (e, _) => AppText('ত্রুটি: $e', type: AppTextType.body2, color: AppColors.error),
              data: (list) {
                if (list.isEmpty) {
                  return           Container(
                    padding: AppSpacing.paddingXl,
                    child: const Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 40, color: AppColors.textHint),
                        AppSpacing.boxSM,
                        AppText('কোনো ব্যাকআপ নেই', type: AppTextType.body2, color: AppColors.textSecondary),
                        AppText('প্রথম ব্যাকআপ নিন', type: AppTextType.caption, color: AppColors.textHint),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => _buildBackupTile(list[i]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackupTile(BackupEntry entry) {
    final typeIcon = entry.type == 'automatic' ? Icons.schedule_rounded : Icons.person_rounded;
    final typeColor = entry.type == 'automatic' ? AppColors.info : AppColors.primary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: typeColor.withValues(alpha: 0.15),
        child: Icon(typeIcon, size: 18, color: typeColor),
      ),
      title: AppText(entry.fileName, type: AppTextType.body2, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: AppText(
        '${_formatDate(entry.createdAt)} • ${entry.formattedSize}',
        type: AppTextType.caption, color: AppColors.textSecondary,
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textSecondary),
        onSelected: (v) => _handleBackupAction(v, entry),
        itemBuilder: (_) => [
          if (entry.filePath != null) ...[
            const PopupMenuItem(value: 'share', child: ListTile(
              leading: Icon(Icons.share_rounded, size: 18), title: AppText('শেয়ার', type: AppTextType.body2),
              dense: true, contentPadding: EdgeInsets.zero,
            )),
            const PopupMenuItem(value: 'restore', child: ListTile(
              leading: Icon(Icons.restore_outlined, size: 18, color: AppColors.warning),
              title: AppText('পুনরুদ্ধার', type: AppTextType.body2), dense: true, contentPadding: EdgeInsets.zero,
            )),
            const PopupMenuItem(value: 'share_file', child: ListTile(
              leading: Icon(Icons.file_present_rounded, size: 18), title: AppText('ফাইল শেয়ার', type: AppTextType.body2),
              dense: true, contentPadding: EdgeInsets.zero,
            )),
          ],
          const PopupMenuItem(value: 'delete', child: ListTile(
            leading: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
            title: AppText('মুছুন', type: AppTextType.body2), dense: true, contentPadding: EdgeInsets.zero,
          )),
        ],
      ),
    );
  }

  Future<void> _handleBackupAction(String action, BackupEntry entry) async {
    switch (action) {
      case 'share':
        if (entry.filePath != null) {
          final service = ref.read(backupServiceProvider);
          await service.shareBackup(entry.filePath!);
        }
      case 'restore':
        if (entry.filePath != null) {
          final confirmed = await _showConfirmDialog('পুনরুদ্ধার নিশ্চিত করুন',
            '${entry.fileName} থেকে ডেটা পুনরুদ্ধার করবেন?\nবর্তমান ডেটা মুছে যাবে।');
          if (confirmed == true && entry.filePath != null) {
            await _doRestore(entry.filePath!);
          }
        }
      case 'share_file':
        if (entry.filePath != null) {
          final service = ref.read(backupServiceProvider);
          await service.shareBackup(entry.filePath!);
        }
      case 'delete':
        if (mounted) {
          final confirmed = await _showConfirmDialog('ব্যাকআপ মুছুন',
            '${entry.fileName} ব্যাকআপটি মুছবেন?');
          if (confirmed == true) {
            final service = ref.read(backupServiceProvider);
            await service.deleteBackup(entry.id);
            ref.invalidate(backupHistoryProvider);
            ref.invalidate(backupCountProvider);
            ref.invalidate(backupTotalSizeProvider);
          }
        }
    }
  }

  Future<void> _manualBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.manualBackup();
      final repo = ref.read(settingsRepositoryProvider);
      await repo.setValue('last_backup_date', DateTime.now().toIso8601String());
      ref.invalidate(backupHistoryProvider);
      ref.invalidate(backupCountProvider);
      ref.invalidate(backupTotalSizeProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: AppText('ব্যাকআপ সফল: ${p.basename(file.path)}', color: AppColors.white),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'শেয়ার',
            textColor: AppColors.white,
            onPressed: () => service.shareBackup(file.path),
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: AppText('ব্যর্থ: $e', color: AppColors.white),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
    }
  }

  Future<void> _restoreFromHistory() async {
    final service = ref.read(backupServiceProvider);
    final history = await service.getBackupHistory(limit: 100);
    if (!mounted) return;
    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: AppText('কোনো ব্যাকআপ পাওয়া যায়নি', color: AppColors.white),
        backgroundColor: AppColors.warning,
      ));
      return;
    }
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) => Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 20, color: AppColors.warning),
                AppSpacing.boxWSM,
                AppText('ব্যাকআপ নির্বাচন করুন', type: AppTextType.subtitle2),
              ],
            ),
            AppSpacing.boxMD,
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                itemCount: history.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final e = history[i];
                  return ListTile(
                    title: AppText(e.fileName, type: AppTextType.body2, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: AppText('${_formatDate(e.createdAt)} • ${e.formattedSize}', type: AppTextType.caption, color: AppColors.textSecondary),
                    trailing: const Icon(Icons.restore_outlined, size: 20, color: AppColors.warning),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmAndRestore(e.filePath, e.fileName);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmAndRestore(String? filePath, String fileName) async {
    if (filePath == null) return;
    final confirmed = await _showConfirmDialog('পুনরুদ্ধার নিশ্চিত করুন',
      '$fileName থেকে পুনরুদ্ধার করবেন?\nবর্তমান সব ডেটা মুছে যাবে!');
    if (confirmed == true) {
      await _doRestore(filePath);
    }
  }

  Future<void> _restoreFromFile() async {
    final fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['db'],
    );
    if (fileResult == null || fileResult.files.single.path == null) return;
    final path = fileResult.files.single.path!;
    final name = fileResult.files.single.name;
    await _confirmAndRestore(path, name);
  }

  Future<void> _doRestore(String path) async {
    setState(() => _isRestoring = true);
    try {
      final service = ref.read(backupServiceProvider);
      final success = await service.restore(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: AppText(success ? 'পুনরুদ্ধার সফল! ${p.basename(path)}' : 'পুনরুদ্ধার ব্যর্থ', color: AppColors.white),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: AppText('ত্রুটি: $e', color: AppColors.white),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _exportDb() async {
    setState(() => _isExporting = true);
    try {
      final service = ref.read(backupServiceProvider);
      final file = await service.manualBackup();
      await service.shareBackup(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: AppText('ত্রুটি: $e', color: AppColors.white),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _importDb() async {
    final fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['db'],
    );
    if (fileResult == null || fileResult.files.single.path == null) return;
    final path = fileResult.files.single.path!;
    final confirmed = await _showConfirmDialog('ইম্পোর্ট নিশ্চিত করুন',
      '${fileResult.files.single.name} ইম্পোর্ট করবেন?\nবর্তমান ডেটা প্রতিস্থাপিত হবে!');
    if (confirmed == true) {
      final service = ref.read(backupServiceProvider);
      final success = await service.restore(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: AppText(success ? 'ইম্পোর্ট সফল' : 'ইম্পোর্ট ব্যর্থ', color: AppColors.white),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ));
      }
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: AppText(title, type: AppTextType.subtitle2),
        content: AppText(message, type: AppTextType.body2),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const AppText('বাতিল', type: AppTextType.button)),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const AppText('নিশ্চিত', type: AppTextType.button, color: AppColors.error)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => DateFormat('dd/MM/yyyy hh:mm a').format(dt);

  String _fmtSize(double bytes) {
    if (bytes < 1024) return '${bytes.toInt()} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

}
