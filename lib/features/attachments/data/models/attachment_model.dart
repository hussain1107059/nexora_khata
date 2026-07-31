import '../../domain/entities/attachment.dart';

class AttachmentModel extends Attachment {
  const AttachmentModel({
    required super.id, required super.businessId,
    required super.referenceType, required super.referenceId,
    required super.fileName, required super.filePath,
    super.fileSize, super.mimeType, super.notes, super.status,
    required super.createdAt, required super.updatedAt,
  });

  factory AttachmentModel.fromMap(Map<String, dynamic> m) => AttachmentModel(
    id: m['id'] as int,
    businessId: m['business_id'] as int,
    referenceType: m['reference_type'] as String,
    referenceId: m['reference_id'] as int,
    fileName: m['file_name'] as String,
    filePath: m['file_path'] as String,
    fileSize: m['file_size'] as int?,
    mimeType: m['mime_type'] as String?,
    notes: m['notes'] as String?,
    status: m['status'] as String? ?? 'active',
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId,
    'reference_type': referenceType, 'reference_id': referenceId,
    'file_name': fileName, 'file_path': filePath,
    'file_size': fileSize, 'mime_type': mimeType,
    'notes': notes, 'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
