import 'package:uuid/uuid.dart';

class StudentStory {
  StudentStory({
    String? id,
    required this.studentId,
    required this.story,
    required this.createdBy,
    this.createdAt,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String studentId;
  final String story;
  final String createdBy;
  final String? createdAt;

  StudentStory copyWith({
    String? id,
    String? studentId,
    String? story,
    String? createdBy,
    String? createdAt,
  }) {
    return StudentStory(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      story: story ?? this.story,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory StudentStory.fromMap(Map<String, Object?> map) {
    return StudentStory(
      id: map['id']?.toString(),
      studentId: map['student_id'] as String,
      story: map['story'] as String,
      createdBy: map['create_by'] as String,
      createdAt: map['create_at'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'story': story,
      'create_by': createdBy,
      'create_at': createdAt,
    };
  }

  @override
  String toString() =>
      'StudentStory(id: $id, studentId: $studentId, story: $story, createdBy: $createdBy, createdAt: $createdAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentStory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          story == other.story &&
          createdBy == other.createdBy &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      studentId.hashCode ^
      story.hashCode ^
      createdBy.hashCode ^
      createdAt.hashCode;
}
