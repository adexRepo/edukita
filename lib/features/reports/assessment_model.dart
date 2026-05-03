import 'package:uuid/uuid.dart';

class Assessment {
  Assessment({
    String? id,
    required this.unitId,
    this.competencyId,
    required this.name,
    this.type,
    this.maxScore,
    this.description,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String unitId;
  final String? competencyId;
  final String name;
  final String? type;
  final double? maxScore;
  final String? description;

  Assessment copyWith({
    String? id,
    String? unitId,
    String? competencyId,
    String? name,
    String? type,
    double? maxScore,
    String? description,
  }) {
    return Assessment(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      competencyId: competencyId ?? this.competencyId,
      name: name ?? this.name,
      type: type ?? this.type,
      maxScore: maxScore ?? this.maxScore,
      description: description ?? this.description,
    );
  }

  factory Assessment.fromMap(Map<String, Object?> map) {
    return Assessment(
      id: map['id']?.toString(),
      unitId: map['unit_id'] as String,
      competencyId: map['competency_id']?.toString(),
      name: map['name'] as String,
      type: map['type'] as String?,
      maxScore: map['max_score'] == null
          ? null
          : (map['max_score'] as num).toDouble(),
      description: map['description'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'unit_id': unitId,
      'competency_id': competencyId,
      'name': name,
      'type': type,
      'max_score': maxScore,
      'description': description,
    };
  }

  @override
  String toString() =>
      'Assessment(id: $id, unitId: $unitId, competencyId: $competencyId, name: $name, type: $type, maxScore: $maxScore)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Assessment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          unitId == other.unitId &&
          competencyId == other.competencyId &&
          name == other.name &&
          type == other.type &&
          maxScore == other.maxScore &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      unitId.hashCode ^
      competencyId.hashCode ^
      name.hashCode ^
      type.hashCode ^
      maxScore.hashCode ^
      description.hashCode;
}

class StudentAssessment {
  StudentAssessment({
    String? id,
    required this.studentId,
    required this.assessmentId,
    this.score,
    this.note,
    this.assessedAt,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String studentId;
  final String assessmentId;
  final double? score;
  final String? note;
  final String? assessedAt;

  StudentAssessment copyWith({
    String? id,
    String? studentId,
    String? assessmentId,
    double? score,
    String? note,
    String? assessedAt,
  }) {
    return StudentAssessment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      assessmentId: assessmentId ?? this.assessmentId,
      score: score ?? this.score,
      note: note ?? this.note,
      assessedAt: assessedAt ?? this.assessedAt,
    );
  }

  factory StudentAssessment.fromMap(Map<String, Object?> map) {
    return StudentAssessment(
      id: map['id']?.toString(),
      studentId: map['student_id'] as String,
      assessmentId: map['assessment_id'] as String,
      score: map['score'] == null ? null : (map['score'] as num).toDouble(),
      note: map['note'] as String?,
      assessedAt: map['assessed_at'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'assessment_id': assessmentId,
      'score': score,
      'note': note,
      'assessed_at': assessedAt,
    };
  }

  @override
  String toString() =>
      'StudentAssessment(id: $id, studentId: $studentId, assessmentId: $assessmentId, score: $score)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAssessment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          studentId == other.studentId &&
          assessmentId == other.assessmentId &&
          score == other.score &&
          note == other.note &&
          assessedAt == other.assessedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      studentId.hashCode ^
      assessmentId.hashCode ^
      score.hashCode ^
      note.hashCode ^
      assessedAt.hashCode;
}

class GradingScale {
  GradingScale({
    String? id,
    required this.minPercent,
    required this.maxPercent,
    required this.grade,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final int minPercent;
  final int maxPercent;
  final String grade;

  GradingScale copyWith({
    String? id,
    int? minPercent,
    int? maxPercent,
    String? grade,
  }) {
    return GradingScale(
      id: id ?? this.id,
      minPercent: minPercent ?? this.minPercent,
      maxPercent: maxPercent ?? this.maxPercent,
      grade: grade ?? this.grade,
    );
  }

  factory GradingScale.fromMap(Map<String, Object?> map) {
    return GradingScale(
      id: map['id']?.toString(),
      minPercent: map['min_percent'] as int,
      maxPercent: map['max_percent'] as int,
      grade: map['grade'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'min_percent': minPercent,
      'max_percent': maxPercent,
      'grade': grade,
    };
  }

  @override
  String toString() =>
      'GradingScale(id: $id, minPercent: $minPercent, maxPercent: $maxPercent, grade: $grade)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradingScale &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          minPercent == other.minPercent &&
          maxPercent == other.maxPercent &&
          grade == other.grade;

  @override
  int get hashCode =>
      id.hashCode ^ minPercent.hashCode ^ maxPercent.hashCode ^ grade.hashCode;
}

class AssessmentStudentOption {
  const AssessmentStudentOption({
    required this.id,
    required this.fullName,
    required this.className,
  });

  final String id;
  final String fullName;
  final String className;

  factory AssessmentStudentOption.fromMap(Map<String, Object?> map) {
    return AssessmentStudentOption(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '-',
      className: map['class_name']?.toString() ?? '-',
    );
  }
}
