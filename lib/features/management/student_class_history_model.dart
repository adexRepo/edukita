import 'package:uuid/uuid.dart';

class StudentClassHistory {
  StudentClassHistory({
    String? id,
    required this.studentId,
    this.fromClassId,
    this.toClassId,
    this.changedAt,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String studentId;
  final String? fromClassId;
  final String? toClassId;
  final String? changedAt;

  StudentClassHistory copyWith({
    String? id,
    String? studentId,
    String? fromClassId,
    String? toClassId,
    String? changedAt,
  }) {
    return StudentClassHistory(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fromClassId: fromClassId ?? this.fromClassId,
      toClassId: toClassId ?? this.toClassId,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  factory StudentClassHistory.fromMap(Map<String, Object?> map) {
    return StudentClassHistory(
      id: map['id']?.toString(),
      studentId: map['student_id'] as String,
      fromClassId: map['from_class_id'] as String?,
      toClassId: map['to_class_id'] as String?,
      changedAt: map['changed_at'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'from_class_id': fromClassId,
      'to_class_id': toClassId,
      'changed_at': changedAt,
    };
  }

  @override
  String toString() =>
      'StudentClassHistory(id: $id, studentId: $studentId, fromClassId: $fromClassId, toClassId: $toClassId, changedAt: $changedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentClassHistory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          fromClassId == other.fromClassId &&
          toClassId == other.toClassId &&
          changedAt == other.changedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      studentId.hashCode ^
      fromClassId.hashCode ^
      toClassId.hashCode ^
      changedAt.hashCode;
}
