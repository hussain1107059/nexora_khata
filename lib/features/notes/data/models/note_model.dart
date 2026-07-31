import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id, required super.businessId, required super.title,
    super.content, super.referenceType, super.referenceId,
    super.isPinned, super.color, super.status,
    required super.createdAt, required super.updatedAt,
  });

  factory NoteModel.fromMap(Map<String, dynamic> m) => NoteModel(
    id: m['id'] as int,
    businessId: m['business_id'] as int,
    title: m['title'] as String,
    content: m['content'] as String?,
    referenceType: m['reference_type'] as String?,
    referenceId: m['reference_id'] as int?,
    isPinned: (m['is_pinned'] as int?) == 1,
    color: m['color'] as String?,
    status: m['status'] as String? ?? 'active',
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );

  Map<String, dynamic> toMap() => {
    if (id > 0) 'id': id,
    'business_id': businessId, 'title': title,
    'content': content, 'reference_type': referenceType,
    'reference_id': referenceId, 'is_pinned': isPinned ? 1 : 0,
    'color': color, 'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
