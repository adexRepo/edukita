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
    this.teacherName,
    this.rawScore,
  });

  final String date;
  final String type;
  final String comment;
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
