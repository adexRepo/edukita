import 'package:uuid/uuid.dart';

class Assessment {
  Assessment({
    String? id,
    required this.unitId,
    required this.name,
    this.type,
    this.maxScore,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String unitId;
  final String name;
  final String? type;
  final int? maxScore;

  Assessment copyWith({
    String? id,
    String? unitId,
    String? name,
    String? type,
    int? maxScore,
  }) {
    return Assessment(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      name: name ?? this.name,
      type: type ?? this.type,
      maxScore: maxScore ?? this.maxScore,
    );
  }

  factory Assessment.fromMap(Map<String, Object?> map) {
    return Assessment(
      id: map['id']?.toString(),
      unitId: map['unit_id'] as String,
      name: map['name'] as String,
      type: map['type'] as String?,
      maxScore: map['max_score'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'unit_id': unitId,
      'name': name,
      'type': type,
      'max_score': maxScore,
    };
  }

  @override
  String toString() =>
      'Assessment(id: $id, unitId: $unitId, name: $name, type: $type, maxScore: $maxScore)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Assessment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          unitId == other.unitId &&
          name == other.name &&
          type == other.type &&
          maxScore == other.maxScore;

  @override
  int get hashCode =>
      id.hashCode ^
      unitId.hashCode ^
      name.hashCode ^
      type.hashCode ^
      maxScore.hashCode;
}

class StudentAssessment {
  StudentAssessment({
    String? id,
    required this.studentId,
    required this.assessmentId,
    this.score,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String studentId;
  final String assessmentId;
  final double? score;

  StudentAssessment copyWith({
    String? id,
    String? studentId,
    String? assessmentId,
    double? score,
  }) {
    return StudentAssessment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      assessmentId: assessmentId ?? this.assessmentId,
      score: score ?? this.score,
    );
  }

  factory StudentAssessment.fromMap(Map<String, Object?> map) {
    return StudentAssessment(
      id: map['id']?.toString(),
      studentId: map['student_id'] as String,
      assessmentId: map['assessment_id'] as String,
      score: map['score'] == null ? null : (map['score'] as num).toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'assessment_id': assessmentId,
      'score': score,
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
          score == other.score;

  @override
  int get hashCode =>
      id.hashCode ^ studentId.hashCode ^ assessmentId.hashCode ^ score.hashCode;
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
