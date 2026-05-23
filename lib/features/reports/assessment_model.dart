import 'package:uuid/uuid.dart';

class Assessment {
  Assessment({
    String? id,
    required this.unitId,
    this.competencyId,
    required this.name,
    this.type,
    this.assessmentType,
    this.assessmentSource,
    this.scoreType,
    this.isEvidenceRequired = false,
    this.evidenceLabel,
    this.maxScore,
    this.description,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String unitId;
  final String? competencyId;
  final String name;
  final String? type;
  final String? assessmentType;
  final String? assessmentSource;
  final String? scoreType;
  final bool isEvidenceRequired;
  final String? evidenceLabel;
  final double? maxScore;
  final String? description;

  String get displayType => assessmentType ?? type ?? '-';

  Assessment copyWith({
    String? id,
    String? unitId,
    String? competencyId,
    String? name,
    String? type,
    String? assessmentType,
    String? assessmentSource,
    String? scoreType,
    bool? isEvidenceRequired,
    String? evidenceLabel,
    double? maxScore,
    String? description,
  }) {
    return Assessment(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      competencyId: competencyId ?? this.competencyId,
      name: name ?? this.name,
      type: type ?? this.type,
      assessmentType: assessmentType ?? this.assessmentType,
      assessmentSource: assessmentSource ?? this.assessmentSource,
      scoreType: scoreType ?? this.scoreType,
      isEvidenceRequired: isEvidenceRequired ?? this.isEvidenceRequired,
      evidenceLabel: evidenceLabel ?? this.evidenceLabel,
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
      assessmentType: map['assessment_type']?.toString(),
      assessmentSource: map['assessment_source']?.toString(),
      scoreType: map['score_type']?.toString(),
      isEvidenceRequired:
          ((map['is_evidence_required'] as num?)?.toInt() ?? 0) == 1,
      evidenceLabel: map['evidence_label']?.toString(),
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
      'assessment_type': assessmentType,
      'assessment_source': assessmentSource,
      'score_type': scoreType,
      'is_evidence_required': isEvidenceRequired ? 1 : 0,
      'evidence_label': evidenceLabel,
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
          assessmentType == other.assessmentType &&
          assessmentSource == other.assessmentSource &&
          scoreType == other.scoreType &&
          isEvidenceRequired == other.isEvidenceRequired &&
          evidenceLabel == other.evidenceLabel &&
          maxScore == other.maxScore &&
          description == other.description;

  @override
  int get hashCode =>
      id.hashCode ^
      unitId.hashCode ^
      competencyId.hashCode ^
      name.hashCode ^
      type.hashCode ^
      assessmentType.hashCode ^
      assessmentSource.hashCode ^
      scoreType.hashCode ^
      isEvidenceRequired.hashCode ^
      evidenceLabel.hashCode ^
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

class AssessmentEvidence {
  AssessmentEvidence({
    String? id,
    required this.assessmentId,
    required this.studentAssessmentId,
    required this.studentId,
    required this.fileName,
    required this.filePath,
    this.fileType,
    this.uploadedBy,
    required this.uploadedAt,
    this.remarks,
    String? createdAt,
    String? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  final String id;
  final String assessmentId;
  final String studentAssessmentId;
  final String studentId;
  final String fileName;
  final String filePath;
  final String? fileType;
  final String? uploadedBy;
  final String uploadedAt;
  final String? remarks;
  final String createdAt;
  final String updatedAt;

  factory AssessmentEvidence.fromMap(Map<String, Object?> map) {
    return AssessmentEvidence(
      id: map['id']?.toString(),
      assessmentId: map['assessment_id']?.toString() ?? '',
      studentAssessmentId: map['student_assessment_id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      fileName: map['file_name']?.toString() ?? '',
      filePath: map['file_path']?.toString() ?? '',
      fileType: map['file_type']?.toString(),
      uploadedBy: map['uploaded_by']?.toString(),
      uploadedAt: map['uploaded_at']?.toString() ?? '',
      remarks: map['remarks']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'assessment_id': assessmentId,
      'student_assessment_id': studentAssessmentId,
      'student_id': studentId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      'uploaded_at': uploadedAt,
      'remarks': remarks,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
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
