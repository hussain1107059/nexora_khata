import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final int id;
  final int businessId;
  final String referenceType;
  final int referenceId;
  final String fileName;
  final String filePath;
  final int? fileSize;
  final String? mimeType;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Attachment({
    required this.id,
    required this.businessId,
    required this.referenceType,
    required this.referenceId,
    required this.fileName,
    required this.filePath,
    this.fileSize,
    this.mimeType,
    this.notes,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, businessId, referenceType, referenceId, fileName,
    filePath, fileSize, mimeType, notes, status, createdAt, updatedAt,
  ];
}
