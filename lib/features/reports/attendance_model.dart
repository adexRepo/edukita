import 'package:uuid/uuid.dart';

class AttendanceSession {
  AttendanceSession({
    String? id,
    required this.scheduleId,
    this.date,
    this.startTime,
    this.endTime,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String scheduleId;
  final String? date;
  final String? startTime;
  final String? endTime;

  AttendanceSession copyWith({
    String? id,
    String? scheduleId,
    String? date,
    String? startTime,
    String? endTime,
  }) {
    return AttendanceSession(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  factory AttendanceSession.fromMap(Map<String, Object?> map) {
    return AttendanceSession(
      id: map['id']?.toString(),
      scheduleId: map['schedule_id'] as String,
      date: map['date'] as String?,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };
  }

  @override
  String toString() =>
      'AttendanceSession(id: $id, scheduleId: $scheduleId, date: $date, startTime: $startTime, endTime: $endTime)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          scheduleId == other.scheduleId &&
          date == other.date &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode =>
      id.hashCode ^
      scheduleId.hashCode ^
      date.hashCode ^
      startTime.hashCode ^
      endTime.hashCode;
}

class StudentAttendance {
  StudentAttendance({
    String? id,
    required this.attendanceSessionId,
    required this.studentId,
    this.status,
    this.checkInTime,
    this.note,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String attendanceSessionId;
  final String studentId;
  final String? status;
  final String? checkInTime;
  final String? note;

  StudentAttendance copyWith({
    String? id,
    String? attendanceSessionId,
    String? studentId,
    String? status,
    String? checkInTime,
    String? note,
  }) {
    return StudentAttendance(
      id: id ?? this.id,
      attendanceSessionId: attendanceSessionId ?? this.attendanceSessionId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      note: note ?? this.note,
    );
  }

  factory StudentAttendance.fromMap(Map<String, Object?> map) {
    return StudentAttendance(
      id: map['id']?.toString(),
      attendanceSessionId: map['attendance_session_id'] as String,
      studentId: map['student_id'] as String,
      status: map['status'] as String?,
      checkInTime: map['check_in_time'] as String?,
      note: map['note'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'attendance_session_id': attendanceSessionId,
      'student_id': studentId,
      'status': status,
      'check_in_time': checkInTime,
      'note': note,
    };
  }

  @override
  String toString() =>
      'StudentAttendance(id: $id, attendanceSessionId: $attendanceSessionId, studentId: $studentId, status: $status, checkInTime: $checkInTime, note: $note)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentAttendance &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          attendanceSessionId == other.attendanceSessionId &&
          studentId == other.studentId &&
          status == other.status &&
          checkInTime == other.checkInTime &&
          note == other.note;

  @override
  int get hashCode =>
      id.hashCode ^
      attendanceSessionId.hashCode ^
      studentId.hashCode ^
      status.hashCode ^
      checkInTime.hashCode ^
      note.hashCode;
}

class StudentActivity {
  StudentActivity({
    required this.studentId,
    required this.sessionId,
    this.questionsAsked,
    this.answersGiven,
  });

  final String studentId;
  final String sessionId;
  final int? questionsAsked;
  final int? answersGiven;

  StudentActivity copyWith({
    String? studentId,
    String? sessionId,
    int? questionsAsked,
    int? answersGiven,
  }) {
    return StudentActivity(
      studentId: studentId ?? this.studentId,
      sessionId: sessionId ?? this.sessionId,
      questionsAsked: questionsAsked ?? this.questionsAsked,
      answersGiven: answersGiven ?? this.answersGiven,
    );
  }

  factory StudentActivity.fromMap(Map<String, Object?> map) {
    return StudentActivity(
      studentId: map['student_id'] as String,
      sessionId: map['session_id'] as String,
      questionsAsked: map['questions_asked'] as int?,
      answersGiven: map['answers_given'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'student_id': studentId,
      'session_id': sessionId,
      'questions_asked': questionsAsked,
      'answers_given': answersGiven,
    };
  }

  @override
  String toString() =>
      'StudentActivity(studentId: $studentId, sessionId: $sessionId, questionsAsked: $questionsAsked, answersGiven: $answersGiven)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentActivity &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          sessionId == other.sessionId &&
          questionsAsked == other.questionsAsked &&
          answersGiven == other.answersGiven;

  @override
  int get hashCode =>
      studentId.hashCode ^
      sessionId.hashCode ^
      questionsAsked.hashCode ^
      answersGiven.hashCode;
}
