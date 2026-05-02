import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';

part 'teacher_state.dart';

class TeacherCubit extends Cubit<TeacherState> {
  final TeacherRepository _repository;

  TeacherCubit(this._repository) : super(const TeacherState());

  Future<void> loadTeachers() async {
    emit(state.copyWith(isLoading: true));
    try {
      final teachers = await _repository.getAllTeachers();
      emit(state.copyWith(isLoading: false, teachers: teachers, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    try {
      await _repository.insertTeacher(teacher);
      await loadTeachers();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateTeacher(Teacher teacher) async {
    try {
      await _repository.updateTeacher(teacher);
      await loadTeachers();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      await _repository.deleteTeacher(id);
      await loadTeachers();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> loadTeachersByGender(String gender) async {
    emit(state.copyWith(isLoading: true));
    try {
      final teachers = await _repository.getTeachersByGender(gender);
      emit(state.copyWith(isLoading: false, teachers: teachers, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
