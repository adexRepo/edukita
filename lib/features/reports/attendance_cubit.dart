import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/reports/attendance_model.dart';
import 'package:edukita/features/reports/attendance_repository.dart';

part 'attendance_state.dart';

class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceCubit(this._repository) : super(const AttendanceState());

  Future<void> loadAttendanceSessions() async {
    emit(state.copyWith(isLoading: true));
    try {
      final sessions = await _repository.getAllAttendanceSessions();
      emit(
        state.copyWith(
          isLoading: false,
          attendanceSessions: sessions,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addAttendanceSession(AttendanceSession session) async {
    try {
      await _repository.insertAttendanceSession(session);
      await loadAttendanceSessions();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateAttendanceSession(AttendanceSession session) async {
    try {
      await _repository.updateAttendanceSession(session);
      await loadAttendanceSessions();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadStudentAttendances() async {
    emit(state.copyWith(isLoading: true));
    try {
      final attendances = await _repository.getAllStudentAttendances();
      emit(
        state.copyWith(
          isLoading: false,
          studentAttendances: attendances,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addStudentAttendance(StudentAttendance attendance) async {
    try {
      await _repository.insertStudentAttendance(attendance);
      await loadStudentAttendances();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateStudentAttendance(StudentAttendance attendance) async {
    try {
      await _repository.updateStudentAttendance(attendance);
      await loadStudentAttendances();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadAttendanceByStudent(String studentId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final attendances = await _repository.getAttendanceByStudent(studentId);
      emit(
        state.copyWith(
          isLoading: false,
          studentAttendances: attendances,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
