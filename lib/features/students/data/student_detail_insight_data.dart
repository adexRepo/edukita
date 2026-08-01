class StudentDetailInsights {
  const StudentDetailInsights({
    required this.attendance,
    required this.monthlyAttendance,
    required this.recentAttendance,
    required this.learning,
    required this.competencies,
    required this.recentTeacherNotes,
    required this.noteTypeCounts,
    required this.assistanceHistory,
  });

  final StudentAttendanceInsight attendance;
  final List<double?> monthlyAttendance;
  final List<StudentAttendanceRecordView> recentAttendance;
  final StudentLearningInsight learning;
  final List<StudentCompetencyInsight> competencies;
  final List<StudentTeacherNoteInsight> recentTeacherNotes;
  final List<StudentNoteTypeCount> noteTypeCounts;
  final List<StudentAssistanceHistoryInsight> assistanceHistory;
}

class StudentAttendanceInsight {
  const StudentAttendanceInsight({
    required this.totalRecords,
    required this.attendedRecords,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.sickCount,
    required this.permissionCount,
  });

  final int totalRecords;
  final int attendedRecords;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final int sickCount;
  final int permissionCount;

  double? get attendancePercentage {
    if (totalRecords == 0) return null;
    return (attendedRecords / totalRecords) * 100;
  }
}

class StudentAttendanceRecordView {
  const StudentAttendanceRecordView({
    required this.date,
    required this.session,
    required this.status,
    this.time,
    this.checkIn,
    this.note,
  });

  final String date;
  final String session;
  final String status;
  final String? time;
  final String? checkIn;
  final String? note;
}

class StudentLearningInsight {
  const StudentLearningInsight({
    required this.assessmentCount,
    this.averageScore,
    this.latestAssessmentDate,
  });

  final int assessmentCount;
  final double? averageScore;
  final String? latestAssessmentDate;
}

class StudentCompetencyInsight {
  const StudentCompetencyInsight({
    required this.label,
    required this.averageScore,
    required this.recordCount,
  });

  final String label;
  final double averageScore;
  final int recordCount;
}

class StudentTeacherNoteInsight {
  const StudentTeacherNoteInsight({
    required this.date,
    required this.type,
    required this.comment,
    this.source = 'session',
    this.teacherName,
    this.rawScore,
  });

  final String date;
  final String type;
  final String comment;
  final String source;
  final String? teacherName;
  final double? rawScore;
}

class StudentNoteTypeCount {
  const StudentNoteTypeCount({required this.type, required this.count});

  final String type;
  final int count;
}

class StudentAssistanceHistoryInsight {
  const StudentAssistanceHistoryInsight({
    required this.programName,
    required this.periodName,
    required this.status,
    this.ruleName,
    this.benefit,
    this.approvedAt,
  });

  final String programName;
  final String periodName;
  final String status;
  final String? ruleName;
  final String? benefit;
  final String? approvedAt;
}

class StudentSpecialNote {
  const StudentSpecialNote({
    required this.id,
    required this.studentId,
    required this.noteDate,
    required this.noteType,
    required this.note,
    this.followUpNeeded = false,
    this.followUpNote,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String studentId;
  final String noteDate;
  final String noteType;
  final String note;
  final bool followUpNeeded;
  final String? followUpNote;
  final String? createdBy;
  final String createdAt;
  final String updatedAt;

  factory StudentSpecialNote.fromMap(Map<String, Object?> map) {
    return StudentSpecialNote(
      id: map['id']?.toString() ?? '',
      studentId: map['student_id']?.toString() ?? '',
      noteDate: map['note_date']?.toString() ?? '',
      noteType: map['note_type']?.toString() ?? 'OTHER',
      note: map['note']?.toString() ?? '',
      followUpNeeded: ((map['follow_up_needed'] as num?)?.toInt() ?? 0) == 1,
      followUpNote: map['follow_up_note']?.toString(),
      createdBy: map['created_by']?.toString(),
      createdAt: map['created_at']?.toString() ?? '',
      updatedAt: map['updated_at']?.toString() ?? '',
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'note_date': noteDate,
      'note_type': noteType,
      'note': note,
      'follow_up_needed': followUpNeeded ? 1 : 0,
      'follow_up_note': followUpNote,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_active': 1,
    };
  }
}

class StudentSpecialNoteTypeOptions {
  StudentSpecialNoteTypeOptions._();

  static const interview = 'INTERVIEW';
  static const parentSurvey = 'PARENT_SURVEY';
  static const studentSurvey = 'STUDENT_SURVEY';
  static const homeVisit = 'HOME_VISIT';
  static const managementObservation = 'MANAGEMENT_OBSERVATION';
  static const other = 'OTHER';

  static const values = [
    interview,
    parentSurvey,
    studentSurvey,
    homeVisit,
    managementObservation,
    other,
  ];

  static String label(String value) {
    return switch (value) {
      interview => 'Interview',
      parentSurvey => 'Parent Survey',
      studentSurvey => 'Student Survey',
      homeVisit => 'Home Visit',
      managementObservation => 'Management Observation',
      _ => 'Other',
    };
  }
}
