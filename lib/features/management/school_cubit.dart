import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/management/school_model.dart';
import 'package:edukita/features/management/school_repository.dart';

part 'school_state.dart';

class SchoolCubit extends Cubit<SchoolState> {
  final SchoolRepository _repository;

  SchoolCubit(this._repository) : super(const SchoolState());

  Future<void> loadSchools() async {
    emit(state.copyWith(isLoading: true));
    try {
      final schools = await _repository.getAllSchools();
      emit(state.copyWith(isLoading: false, schools: schools, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSchool(School school) async {
    try {
      await _repository.insertSchool(school);
      await loadSchools();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateSchool(School school) async {
    try {
      await _repository.updateSchool(school);
      await loadSchools();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteSchool(String id) async {
    try {
      await _repository.deleteSchool(id);
      await loadSchools();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> loadSchoolsByType(String type) async {
    emit(state.copyWith(isLoading: true));
    try {
      final schools = await _repository.getSchoolsByType(type);
      emit(state.copyWith(isLoading: false, schools: schools, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadStudentSchools(String studentId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final schools = await _repository.getSchoolsByStudent(studentId);
      emit(state.copyWith(isLoading: false, schools: schools, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> linkSchool(StudentSchool studentSchool) async {
    try {
      await _repository.linkStudentSchool(studentSchool);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> unlinkSchool(String studentSchoolId) async {
    try {
      await _repository.unlinkStudentSchool(studentSchoolId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
