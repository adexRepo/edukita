import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/schedule/schedule_model.dart';
import 'package:edukita/features/schedule/schedule_repository.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _repository;

  ScheduleCubit(this._repository) : super(const ScheduleState());

  Future<void> loadSchedules() async {
    emit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getAllSchedules();
      emit(state.copyWith(isLoading: false, schedules: schedules, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      await _repository.insertSchedule(schedule);
      await loadSchedules();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      await _repository.updateSchedule(schedule);
      await loadSchedules();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _repository.deleteSchedule(id);
      await loadSchedules();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadSchedulesByClass(String classId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesByClass(classId);
      emit(state.copyWith(isLoading: false, schedules: schedules, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesByTeacher(String teacherId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesByTeacher(teacherId);
      emit(state.copyWith(isLoading: false, schedules: schedules, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesByDate(String date) async {
    emit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesByDate(date);
      emit(state.copyWith(isLoading: false, schedules: schedules, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
