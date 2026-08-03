import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nexora_khata/core/network/connectivity_service.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/di/injection_container.dart';
import 'package:nexora_khata/features/settings/data/services/google_drive_backup_service.dart';
import 'package:nexora_khata/features/settings/presentation/providers/backup_provider.dart';
import 'package:nexora_khata/features/settings/presentation/providers/settings_provider.dart';

final googleDriveBackupServiceProvider =
    Provider<GoogleDriveBackupService>((ref) {
  final dbHelper = getIt<DatabaseHelper>();
  final connectivity = getIt<ConnectivityService>();
  final settingsRepo = ref.read(settingsRepositoryProvider);
  final backupService = ref.read(backupServiceProvider);
  return GoogleDriveBackupService(
    dbHelper,
    backupService,
    connectivity,
    settingsRepo,
  );
});

final driveBackupStatusProvider = FutureProvider<DriveBackupStatus>((ref) {
  return ref.read(googleDriveBackupServiceProvider).getStatus();
});