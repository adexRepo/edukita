part of 'attendance_cubit.dart';

class AttendanceState {
  final List<AttendanceSession> attendanceSessions;
  final List<StudentAttendance> studentAttendances;
  final bool isLoading;
  final String? error;

  const AttendanceState({
    this.attendanceSessions = const [],
    this.studentAttendances = const [],
    this.isLoading = false,
    this.error,
  });

  AttendanceState copyWith({
    List<AttendanceSession>? attendanceSessions,
    List<StudentAttendance>? studentAttendances,
    bool? isLoading,
    String? error,
  }) {
    return AttendanceState(
      attendanceSessions: attendanceSessions ?? this.attendanceSessions,
      studentAttendances: studentAttendances ?? this.studentAttendances,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
