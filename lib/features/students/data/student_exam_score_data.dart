import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:uuid/uuid.dart';

class StudentExamScoreGroup {
  StudentExamScoreGroup({
    String? id,
    required this.studentId,
    required this.scope,
    required this.examType,
    this.source,
    this.academicYear,
    this.semester,
    required this.examDate,
    this.evidenceRequired = false,
    this.evidenceFileName,
    this.evidenceFilePath,
    this.evidenceFileType,
    this.note,
    this.items = const <StudentExamScoreItem>[],
    String? createdAt,
    String? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String studentId;
  final String scope;
  final String examType;
  final String? source;
  final String? academicYear;
  final String? semester;
  final String examDate;
  final bool evidenceRequired;
  final String? evidenceFileName;
  final String? evidenceFilePath;
  final String? evidenceFileType;
  final String? note;
  final List<StudentExamScoreItem> items;
  final String createdAt;
  final String updatedAt;

  bool get isSchool => scope == 'school';
  bool get hasEvidence => evidenceFilePath?.trim().isNotEmpty == true;

  double? get averagePercent {
    final values = items
        .where((item) => item.maxScore != null && item.maxScore! > 0)
        .map((item) => (item.score / item.maxScore!) * 100)
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  factory StudentExamScoreGroup.fromMap(
    Map<String, Object?> map, {
    List<StudentExamScoreItem> items = const <StudentExamScoreItem>[],
  }) {
    return StudentExamScoreGroup(
      id: map['id']?.toString(),
      studentId: map['student_id']?.toString() ?? '',
      scope: map['scope']?.toString() ?? 'school',
      examType: map['exam_type']?.toString() ?? '-',
      source: map['source']?.toString(),
      academicYear: map['academic_year']?.toString(),
      semester: map['semester']?.toString(),
      examDate: map['exam_date']?.toString() ?? '',
      evidenceRequired:
          ((map['evidence_required'] as num?)?.toInt() ?? 0) == 1,
      evidenceFileName: map['evidence_file_name']?.toString(),
      evidenceFilePath: map['evidence_file_path']?.toString(),
      evidenceFileType: map['evidence_file_type']?.toString(),
      note: map['note']?.toString(),
      items: items,
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'scope': scope,
      'exam_type': examType,
      'source': source,
      'academic_year': academicYear,
      'semester': semester,
      'exam_date': examDate,
      'evidence_required': evidenceRequired ? 1 : 0,
      'evidence_file_name': evidenceFileName,
      'evidence_file_path': evidenceFilePath,
      'evidence_file_type': evidenceFileType,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class StudentExamScoreItem {
  StudentExamScoreItem({
    String? id,
    required this.groupId,
    this.subjectId,
    this.subjectName,
    this.unitId,
    this.unitName,
    required this.score,
    this.maxScore,
    this.note,
    String? createdAt,
    String? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String groupId;
  final String? subjectId;
  final String? subjectName;
  final String? unitId;
  final String? unitName;
  final double score;
  final double? maxScore;
  final String? note;
  final String createdAt;
  final String updatedAt;

  factory StudentExamScoreItem.fromMap(Map<String, Object?> map) {
    return StudentExamScoreItem(
      id: map['id']?.toString(),
      groupId: map['group_id']?.toString() ?? '',
      subjectId: map['subject_id']?.toString(),
      subjectName: map['subject_name']?.toString(),
      unitId: map['unit_id']?.toString(),
      unitName: map['unit_name']?.toString(),
      score: (map['score'] as num?)?.toDouble() ?? 0,
      maxScore: (map['max_score'] as num?)?.toDouble(),
      note: map['note']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'subject_id': subjectId,
      'unit_id': unitId,
      'score': score,
      'max_score': maxScore,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class StudentExamScoreOptions {
  const StudentExamScoreOptions({
    required this.subjects,
    required this.units,
  });

  final List<Subject> subjects;
  final List<Unit> units;
}
