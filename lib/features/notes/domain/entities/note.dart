import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final int id;
  final int businessId;
  final String title;
  final String? content;
  final String? referenceType;
  final int? referenceId;
  final bool isPinned;
  final String? color;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.businessId,
    required this.title,
    this.content,
    this.referenceType,
    this.referenceId,
    this.isPinned = false,
    this.color,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    int? id, int? businessId, String? title, String? content,
    String? referenceType, int? referenceId, bool? isPinned,
    String? color, String? status, DateTime? createdAt, DateTime? updatedAt,
  }) => Note(
    id: id ?? this.id, businessId: businessId ?? this.businessId,
    title: title ?? this.title, content: content ?? this.content,
    referenceType: referenceType ?? this.referenceType,
    referenceId: referenceId ?? this.referenceId,
    isPinned: isPinned ?? this.isPinned, color: color ?? this.color,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    id, businessId, title, content, referenceType, referenceId,
    isPinned, color, status, createdAt, updatedAt,
  ];
}
