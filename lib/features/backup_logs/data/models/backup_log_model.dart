import '../../domain/entities/backup_log.dart';

class BackupLogModel extends BackupLog {
  const BackupLogModel({
    required super.id, super.businessId, required super.fileName,
    super.filePath, super.fileSize, super.type, super.status,
    super.errorMessage, super.checksum, super.notes,
    required super.createdAt, required super.updatedAt,
  });

  factory BackupLogModel.fromMap(Map<String, dynamic> m) => BackupLogModel(
    id: m['id'] as int,
    businessId: m['business_id'] as int?,
    fileName: m['file_name'] as String,
    filePath: m['file_path'] as String?,
    fileSize: m['file_size'] as int?,
    type: m['type'] as String? ?? 'manual',
    status: m['status'] as String? ?? 'completed',
    errorMessage: m['error_message'] as String?,
    checksum: m['checksum'] as String?,
    notes: m['notes'] as String?,
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId, 'file_name': fileName,
    'file_path': filePath, 'file_size': fileSize,
    'type': type, 'status': status,
    'error_message': errorMessage, 'checksum': checksum,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
