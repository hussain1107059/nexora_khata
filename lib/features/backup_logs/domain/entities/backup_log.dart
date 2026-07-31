import 'package:equatable/equatable.dart';

class BackupLog extends Equatable {
  final int id;
  final int? businessId;
  final String fileName;
  final String? filePath;
  final int? fileSize;
  final String type;
  final String status;
  final String? errorMessage;
  final String? checksum;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BackupLog({
    required this.id,
    this.businessId,
    required this.fileName,
    this.filePath,
    this.fileSize,
    this.type = 'manual',
    this.status = 'completed',
    this.errorMessage,
    this.checksum,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id, businessId, fileName, filePath, fileSize,
    type, status, errorMessage, checksum, notes, createdAt, updatedAt,
  ];
}
