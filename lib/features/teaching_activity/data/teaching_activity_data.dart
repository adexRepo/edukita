class TeachingActivityStatus {
  TeachingActivityStatus._();

  static const scheduled = 'scheduled';
  static const inProgress = 'in_progress';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  static const values = [scheduled, inProgress, completed, cancelled];
}

class TeachingAttendanceStatus {
  TeachingAttendanceStatus._();

  static const present = 'present';
  static const absent = 'absent';
  static const late = 'late';
  static const sick = 'sick';
  static const permission = 'permission';

  static const values = [present, absent, late, sick, permission];
}

class TeachingAssessmentType {
  TeachingAssessmentType._();

  static const observation = 'observation';
  static const exercise = 'exercise';
  static const quiz = 'quiz';
  static const oral = 'oral';
  static const practical = 'practical';
  static const assignment = 'assignment';
  static const participation = 'participation';
  static const memorization = 'memorization';
  static const reading = 'reading';
  static const other = 'other';

  static const values = [
    quiz,
    observation,
    practical,
    exercise,
    assignment,
    oral,
    participation,
    memorization,
    reading,
    other,
  ];

  static bool usesNumericScore(String? value) => value == quiz;
}

class TeachingScoreMode {
  TeachingScoreMode._();

  static const numeric100 = 'numeric_100';
  static const star5 = 'star_5';
}

class TeachingAssessmentResult {
  TeachingAssessmentResult._();

  static const values = ['excellent', 'good', 'need_help', 'not_observed'];
}

class StudentSessionNoteType {
  StudentSessionNoteType._();

  static const values = [
    'learning_progress',
    'behavior',
    'attendance_concern',
    'needs_support',
    'achievement',
    'parent_follow_up',
    'other',
  ];
}

class CancellationReason {
  CancellationReason._();

  static const values = [
    'teacher_unavailable',
    'student_group_unavailable',
    'public_holiday',
    'room_unavailable',
    'weather_or_emergency',
    'schedule_mistake',
    'administrative_reason',
    'other',
  ];
}

class TeachingActivityListItem {
  const TeachingActivityListItem({
    required this.scheduleId,
    required this.activityDate,
    required this.status,
    this.activityId,
    this.teacherId,
    this.classId,
    this.unitId,
    this.strategyId,
    this.startAt,
    this.endAt,
    this.className,
    this.teacherName,
    this.subjectName,
    this.unitName,
    this.strategyName,
    this.title,
    this.description,
    this.startedAt,
    this.endedAt,
    this.lessonCompletionPercent,
    this.materialCovered,
    this.classCondition,
    this.teachingChallenges,
    this.followUpPlan,
    this.sessionNotes,
    this.assessmentType,
    this.cancelledAt,
    this.cancellationReason,
    this.cancellationNotes,
    this.replacementRequired = false,
  });

  final String? activityId;
  final String scheduleId;
  final String? teacherId;
  final String? classId;
  final String? unitId;
  final String? strategyId;
  final String activityDate;
  final String? startAt;
  final String? endAt;
  final String status;
  final String? className;
  final String? teacherName;
  final String? subjectName;
  final String? unitName;
  final String? strategyName;
  final String? title;
  final String? description;
  final String? startedAt;
  final String? endedAt;
  final int? lessonCompletionPercent;
  final String? materialCovered;
  final String? classCondition;
  final String? teachingChallenges;
  final String? followUpPlan;
  final String? sessionNotes;
  final String? assessmentType;
  final String? cancelledAt;
  final String? cancellationReason;
  final String? cancellationNotes;
  final bool replacementRequired;

  String get displayTime {
    final start = startAt?.trim();
    final end = endAt?.trim();
    if ((start == null || start.isEmpty) && (end == null || end.isEmpty)) {
      return '-';
    }
    if (end == null || end.isEmpty) return start ?? '-';
    return '${start ?? '-'} - $end';
  }

  bool get hasActivity => activityId != null && activityId!.isNotEmpty;

  factory TeachingActivityListItem.fromMap(Map<String, Object?> map) {
    final status = map['activity_status']?.toString();
    return TeachingActivityListItem(
      activityId: map['activity_id']?.toString(),
      scheduleId: map['schedule_id'].toString(),
      teacherId: map['teacher_id']?.toString(),
      classId: map['class_id']?.toString(),
      unitId: map['unit_id']?.toString(),
      strategyId: map['strategy_id']?.toString(),
      activityDate:
          map['activity_date']?.toString() ?? map['schedule_date']?.toString() ?? '',
      startAt: map['start_at']?.toString(),
      endAt: map['end_at']?.toString(),
      status: status == null || status.isEmpty
          ? TeachingActivityStatus.scheduled
          : status,
      className: map['class_name']?.toString(),
      teacherName: map['teacher_name']?.toString(),
      subjectName: map['subject_name']?.toString(),
      unitName: map['unit_name']?.toString(),
      strategyName: map['strategy_name']?.toString(),
      title: map['title']?.toString(),
      description: map['description']?.toString(),
      startedAt: map['started_at']?.toString(),
      endedAt: map['ended_at']?.toString(),
      lessonCompletionPercent:
          (map['lesson_completion_percent'] as num?)?.toInt(),
      materialCovered: map['material_covered']?.toString(),
      classCondition: map['class_condition']?.toString(),
      teachingChallenges: map['teaching_challenges']?.toString(),
      followUpPlan: map['follow_up_plan']?.toString(),
      sessionNotes: map['session_notes']?.toString(),
      assessmentType: map['assessment_type']?.toString(),
      cancelledAt: map['cancelled_at']?.toString(),
      cancellationReason: map['cancellation_reason']?.toString(),
      cancellationNotes: map['cancellation_notes']?.toString(),
      replacementRequired:
          ((map['replacement_required'] as num?)?.toInt() ?? 0) == 1,
    );
  }
}

class TeachingActivityDetailData {
  const TeachingActivityDetailData({
    required this.activity,
    required this.students,
    required this.attendances,
    required this.assessments,
    required this.studentNotes,
    required this.competencies,
  });

  final TeachingActivityListItem activity;
  final List<ClassStudentOption> students;
  final List<TeachingAttendanceRecord> attendances;
  final List<TeachingAssessmentRecord> assessments;
  final List<StudentSessionNoteRecord> studentNotes;
  final List<CompetencyOption> competencies;
}

class ClassStudentOption {
  const ClassStudentOption({
    required this.id,
    required this.studentNo,
    required this.fullName,
    this.nickName,
  });

  final String id;
  final String studentNo;
  final String fullName;
  final String? nickName;

  String get displayName => nickName == null || nickName!.isEmpty
      ? fullName
      : '$fullName (${nickName!})';

  factory ClassStudentOption.fromMap(Map<String, Object?> map) {
    return ClassStudentOption(
      id: map['id'].toString(),
      studentNo: map['student_no']?.toString() ?? '-',
      fullName: map['full_name']?.toString() ?? '-',
      nickName: map['nick_name']?.toString(),
    );
  }
}

class CompetencyOption {
  const CompetencyOption({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  factory CompetencyOption.fromMap(Map<String, Object?> map) {
    final code = map['code']?.toString();
    final description = map['description']?.toString() ?? '-';
    return CompetencyOption(
      id: map['id'].toString(),
      label: code == null || code.isEmpty ? description : '$code - $description',
    );
  }
}

class TeachingAttendanceRecord {
  const TeachingAttendanceRecord({
    this.id,
    required this.teachingActivityId,
    required this.studentId,
    required this.status,
    this.checkInTime,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String teachingActivityId;
  final String studentId;
  final String status;
  final String? checkInTime;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  TeachingAttendanceRecord copyWith({
    String? id,
    String? teachingActivityId,
    String? studentId,
    String? status,
    String? checkInTime,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return TeachingAttendanceRecord(
      id: id ?? this.id,
      teachingActivityId: teachingActivityId ?? this.teachingActivityId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory TeachingAttendanceRecord.fromMap(Map<String, Object?> map) {
    return TeachingAttendanceRecord(
      id: map['id']?.toString(),
      teachingActivityId: map['teaching_activity_id'].toString(),
      studentId: map['student_id'].toString(),
      status: map['status']?.toString() ?? TeachingAttendanceStatus.present,
      checkInTime: map['check_in_time']?.toString(),
      notes: map['notes']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'teaching_activity_id': teachingActivityId,
      'student_id': studentId,
      'status': status,
      'check_in_time': checkInTime,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class TeachingAssessmentRecord {
  const TeachingAssessmentRecord({
    this.id,
    required this.teachingActivityId,
    required this.studentId,
    this.studentName,
    this.competencyId,
    this.competencyLabel,
    required this.assessmentType,
    required this.result,
    this.scoreMode,
    this.rawScore,
    this.normalizedScore,
    this.score,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String teachingActivityId;
  final String studentId;
  final String? studentName;
  final String? competencyId;
  final String? competencyLabel;
  final String assessmentType;
  final String result;
  final String? scoreMode;
  final double? rawScore;
  final double? normalizedScore;
  final double? score;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  factory TeachingAssessmentRecord.fromMap(Map<String, Object?> map) {
    final score = map['score'];
    final rawScore = map['raw_score'];
    final normalizedScore = map['normalized_score'];
    return TeachingAssessmentRecord(
      id: map['id']?.toString(),
      teachingActivityId: map['teaching_activity_id'].toString(),
      studentId: map['student_id'].toString(),
      studentName: map['student_name']?.toString(),
      competencyId: map['competency_id']?.toString(),
      competencyLabel: map['competency_label']?.toString(),
      assessmentType:
          map['assessment_type']?.toString() ?? TeachingAssessmentType.values.first,
      result: map['result']?.toString() ?? TeachingAssessmentResult.values.first,
      scoreMode: map['score_mode']?.toString(),
      rawScore: rawScore is num
          ? rawScore.toDouble()
          : double.tryParse('$rawScore'),
      normalizedScore: normalizedScore is num
          ? normalizedScore.toDouble()
          : double.tryParse('$normalizedScore'),
      score: score is num ? score.toDouble() : double.tryParse('$score'),
      notes: map['notes']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }
}

class TeachingAssessmentBulkInput {
  const TeachingAssessmentBulkInput({
    required this.studentId,
    required this.result,
    required this.scoreMode,
    this.rawScore,
    this.normalizedScore,
    this.score,
    this.notes,
  });

  final String studentId;
  final String result;
  final String scoreMode;
  final double? rawScore;
  final double? normalizedScore;
  final double? score;
  final String? notes;
}

class StudentSessionNoteRecord {
  const StudentSessionNoteRecord({
    this.id,
    required this.teachingActivityId,
    required this.studentId,
    this.studentName,
    required this.noteType,
    required this.comment,
    required this.followUpNeeded,
    this.scoreMode,
    this.rawScore,
    this.normalizedScore,
    this.followUpNotes,
    this.createdAt,
    this.updatedAt,
  });

  final String? id;
  final String teachingActivityId;
  final String studentId;
  final String? studentName;
  final String noteType;
  final String comment;
  final bool followUpNeeded;
  final String? scoreMode;
  final double? rawScore;
  final double? normalizedScore;
  final String? followUpNotes;
  final String? createdAt;
  final String? updatedAt;

  factory StudentSessionNoteRecord.fromMap(Map<String, Object?> map) {
    return StudentSessionNoteRecord(
      id: map['id']?.toString(),
      teachingActivityId: map['teaching_activity_id'].toString(),
      studentId: map['student_id'].toString(),
      studentName: map['student_name']?.toString(),
      noteType: map['note_type']?.toString() ?? StudentSessionNoteType.values.first,
      comment: map['comment']?.toString() ?? '',
      followUpNeeded: ((map['follow_up_needed'] as num?)?.toInt() ?? 0) == 1,
      scoreMode: map['score_mode']?.toString(),
      rawScore: (map['raw_score'] as num?)?.toDouble(),
      normalizedScore: (map['normalized_score'] as num?)?.toDouble(),
      followUpNotes: map['follow_up_notes']?.toString(),
      createdAt: map['created_at']?.toString(),
      updatedAt: map['updated_at']?.toString(),
    );
  }
}
