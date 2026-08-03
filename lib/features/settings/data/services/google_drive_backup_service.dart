import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as gdrive;
import 'package:nexora_khata/core/network/connectivity_service.dart';
import 'package:nexora_khata/core/services/database_helper.dart';
import 'package:nexora_khata/core/services/logger.dart';
import 'package:nexora_khata/features/settings/domain/repositories/settings_repository.dart';
import 'package:nexora_khata/features/settings/data/services/backup_service.dart';

/// Error kinds surfaced by [GoogleDriveBackupService] so the UI layer can
/// localise them without leaking Google/Dart exception types.
enum DriveBackupError {
  noInternet,
  notSignedIn,
  signInCancelled,
  signInFailed,
  permissionDenied,
  tokenExpired,
  missingBackup,
  uploadFailed,
  downloadFailed,
  restoreFailed,
  unsupported,
  unknown,
}

/// Thrown by [GoogleDriveBackupService] with a stable [error] category.
class DriveBackupException implements Exception {
  final DriveBackupError error;
  final String? detail;

  const DriveBackupException(this.error, [this.detail]);

  @override
  String toString() => 'DriveBackupException($error, $detail)';
}

/// Read-only snapshot of the online backup state used by the UI.
class DriveBackupStatus {
  final bool isSignedIn;
  final String? accountEmail;
  final String? fileId;
  final DateTime? lastBackupTime;
  final int? sizeBytes;

  const DriveBackupStatus({
    required this.isSignedIn,
    this.accountEmail,
    this.fileId,
    this.lastBackupTime,
    this.sizeBytes,
  });

  bool get hasBackup => fileId != null;

  String get formattedSize {
    final size = sizeBytes;
    if (size == null) return '-';
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Handles Google sign-in and uploading/restoring a single SQLite backup file
/// owned by the user on their own Google Drive.
///
/// It deliberately reuses existing infrastructure instead of duplicating it:
/// * [ConnectivityService] for the no-internet check.
/// * [BackupService.restore] for the close -> copy -> reopen dance.
/// * [SettingsRepository] for persisting the last upload metadata.
class GoogleDriveBackupService {
  static const String _driveScope = 'https://www.googleapis.com/auth/drive.file';
  static const String _fileName = 'Nexora_Khata_Backup.db';
  static const String _fileMime = 'application/octet-stream';

  static const String _keyFileId = 'drive_backup_file_id';
  static const String _keyBackupTime = 'drive_backup_time';
  static const String _keyBackupSize = 'drive_backup_size';

  final DatabaseHelper _dbHelper;
  final BackupService _backupService;
  final ConnectivityService _connectivityService;
  final SettingsRepository _settingsRepository;

  final GoogleSignIn _signIn = GoogleSignIn.instance;
  bool _initialized = false;

  GoogleDriveBackupService(
    this._dbHelper,
    this._backupService,
    this._connectivityService,
    this._settingsRepository,
  );

  String get _databasePath => _dbHelper.db.path;

  Future<void> _initialize() async {
    if (_initialized) return;
    try {
      await _signIn.initialize();
      _initialized = true;
    } on GoogleSignInException catch (e) {
      throw DriveBackupException(DriveBackupError.signInFailed, e.description);
    }
  }

  Future<void> _requireOnline() async {
    final online = await _connectivityService.checkConnectivity();
    if (!online) {
      throw const DriveBackupException(DriveBackupError.noInternet);
    }
  }

  /// Interactive sign in. Returns true when the user completes sign-in.
  Future<bool> signIn() async {
    if (kIsWeb) {
      throw const DriveBackupException(DriveBackupError.unsupported);
    }
    await _initialize();
    try {
      await _signIn.authenticate(scopeHint: [_driveScope]);
      return true;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted ||
          e.code == GoogleSignInExceptionCode.uiUnavailable) {
        throw const DriveBackupException(DriveBackupError.signInCancelled);
      }
      throw DriveBackupException(DriveBackupError.signInFailed, e.description);
    }
  }

  Future<void> signOut() async {
    if (kIsWeb) return;
    await _initialize();
    try {
      await _signIn.signOut();
      await _signIn.disconnect();
    } catch (e) {
      log.w('Google sign out failed: $e');
    }
  }

  /// Current status without prompting the user for interaction.
  Future<DriveBackupStatus> getStatus() async {
    if (kIsWeb) {
      throw const DriveBackupException(DriveBackupError.unsupported);
    }
    await _initialize();
    GoogleSignInAccount? account;
    try {
      account = await _signIn.attemptLightweightAuthentication();
    } catch (e) {
      log.w('Silent sign-in restore failed: $e');
      account = null;
    }
    final time = await _getValue(_keyBackupTime);
    final size = await _getValue(_keyBackupSize);
    return DriveBackupStatus(
      isSignedIn: account != null,
      accountEmail: account?.email,
      fileId: await _readFileId(),
      lastBackupTime: time != null ? DateTime.tryParse(time) : null,
      sizeBytes: int.tryParse(size ?? ''),
    );
  }

  /// Uploads the current database to Google Drive, replacing the single
  /// [file] if it exists, or creating it if it does not.
  Future<DriveBackupStatus> uploadBackup() async {
    await _requireOnline();
    final session = await _buildDriveSession(interactive: true);
    try {
      final bytes = await File(_databasePath).readAsBytes();
      final media = commons.Media(Stream<List<int>>.value(bytes), bytes.length);

      String? fileId = await _readFileId();
      fileId ??= await _findFileId(session.drive);

      if (fileId == null) {
        final created = await session.drive.files.create(
          _metadata(),
          uploadMedia: media,
        );
        fileId = created.id;
      } else {
        try {
          await session.drive.files.update(
            _metadata(),
            fileId,
            uploadMedia: media,
          );
        } on commons.DetailedApiRequestError catch (e) {
          // The stored id points to a file that no longer exists: recreate it.
          if (e.status == 404) {
            final created = await session.drive.files.create(
              _metadata(),
              uploadMedia: media,
            );
            fileId = created.id;
          } else {
            rethrow;
          }
        }
      }

      final now = DateTime.now();
      await _setString(_keyFileId, fileId ?? '');
      await _setString(_keyBackupTime, now.toIso8601String());
      await _setString(_keyBackupSize, bytes.length.toString());
      return DriveBackupStatus(
        isSignedIn: true,
        accountEmail: session.userEmail,
        fileId: fileId,
        lastBackupTime: now,
        sizeBytes: bytes.length,
      );
    } on DriveBackupException {
      rethrow;
    } on SocketException {
      throw const DriveBackupException(DriveBackupError.noInternet);
    } on commons.DetailedApiRequestError catch (e) {
      throw _mapApiError(e, const DriveBackupException(DriveBackupError.uploadFailed));
    } catch (_) {
      throw const DriveBackupException(DriveBackupError.uploadFailed);
    } finally {
      session.client.close();
    }
  }

  /// Downloads the online backup and restores it into the local database.
  Future<DriveBackupStatus> downloadAndRestore() async {
    await _requireOnline();
    final session = await _buildDriveSession(interactive: true);
    try {
      String? fileId = await _readFileId();
      fileId ??= await _findFileId(session.drive);
      if (fileId == null) {
        throw const DriveBackupException(DriveBackupError.missingBackup);
      }

      final response = await session.drive.files.get(
        fileId,
        downloadOptions: commons.DownloadOptions.fullMedia,
      );
      final media = response as commons.Media;
      final buffer = BytesBuilder(copy: false);
      await for (final chunk in media.stream) {
        buffer.add(chunk);
      }
      final bytes = buffer.toBytes();

      final dir = await getTemporaryDirectory();
      final tmpFile = File(p.join(dir.path, 'nexora_online_restore.db'));
      await tmpFile.writeAsBytes(bytes, flush: true);

      final ok = await _backupService.restore(tmpFile.path);
      if (!ok) {
        throw const DriveBackupException(DriveBackupError.restoreFailed);
      }

      final storedTime = await _getValue(_keyBackupTime);
      await _setString(_keyBackupSize, bytes.length.toString());
      return DriveBackupStatus(
        isSignedIn: true,
        accountEmail: session.userEmail,
        fileId: fileId,
        lastBackupTime: storedTime != null ? DateTime.tryParse(storedTime) : null,
        sizeBytes: bytes.length,
      );
    } on DriveBackupException {
      rethrow;
    } on SocketException {
      throw const DriveBackupException(DriveBackupError.noInternet);
    } on commons.DetailedApiRequestError catch (e) {
      throw _mapApiError(e, const DriveBackupException(DriveBackupError.downloadFailed));
    } catch (_) {
      throw const DriveBackupException(DriveBackupError.downloadFailed);
    } finally {
      session.client.close();
    }
  }

  gdrive.File _metadata() => gdrive.File()
    ..name = _fileName
    ..mimeType = _fileMime;

  Future<String?> _findFileId(gdrive.DriveApi drive) async {
    final list = await drive.files.list(
      q: "name = '$_fileName' and trashed = false",
      $fields: 'files(id)',
      pageSize: 1,
    );
    final files = list.files;
    if (files == null || files.isEmpty) return null;
    return files.first.id;
  }

  Future<_DriveSession> _buildDriveSession({required bool interactive}) async {
    if (kIsWeb) {
      throw const DriveBackupException(DriveBackupError.unsupported);
    }
    await _initialize();
    GoogleSignInAccount? account;
    if (interactive) {
      try {
        account = await _signIn.authenticate(scopeHint: [_driveScope]);
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled ||
            e.code == GoogleSignInExceptionCode.interrupted ||
            e.code == GoogleSignInExceptionCode.uiUnavailable) {
          throw const DriveBackupException(DriveBackupError.signInCancelled);
        }
        throw DriveBackupException(DriveBackupError.signInFailed, e.description);
      }
    } else {
      account = await _signIn.attemptLightweightAuthentication();
    }
    if (account == null) {
      throw const DriveBackupException(DriveBackupError.notSignedIn);
    }
    final signedIn = account;
    final client = _AuthedHttpClient(
      http.Client(),
      () => signedIn.authorizationClient.authorizationHeaders(
        [_driveScope],
        promptIfNecessary: true,
      ),
    );
    return _DriveSession(signedIn, client, gdrive.DriveApi(client));
  }

  DriveBackupException _mapApiError(
    commons.DetailedApiRequestError e,
    DriveBackupException fallback,
  ) {
    switch (e.status) {
      case 401:
        return const DriveBackupException(DriveBackupError.tokenExpired);
      case 403:
        return const DriveBackupException(DriveBackupError.permissionDenied);
      case 404:
        return const DriveBackupException(DriveBackupError.missingBackup);
      default:
        return fallback;
    }
  }

  Future<String?> _readFileId() async {
    final value = await _getValue(_keyFileId);
    return (value == null || value.isEmpty) ? null : value;
  }

  Future<String?> _getValue(String key) async {
    final result = await _settingsRepository.getValue(key);
    return result.fold((_) => null, (value) => value);
  }

  Future<void> _setString(String key, String value) async {
    await _settingsRepository.setValue(key, value);
  }
}

/// Minimal helper so both fields are resolvable together within a session.
class _DriveSession {
  final GoogleSignInAccount account;
  final http.Client client;
  final gdrive.DriveApi drive;

  _DriveSession(this.account, this.client, this.drive);

  String? get userEmail => account.email;
}

/// Wraps an [http.Client] and injects the Google OAuth2 headers on demand so
/// tokens are fetched/refreshed per request.
class _AuthedHttpClient extends http.BaseClient {
  final http.Client _inner;
  final Future<Map<String, String>?> Function() _headers;

  _AuthedHttpClient(this._inner, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final headers = await _headers();
    if (headers != null) {
      request.headers.addAll(headers);
    }
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}