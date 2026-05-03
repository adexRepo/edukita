import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/domain/class_repository.dart';

part 'class_state.dart';

class ClassCubit extends Cubit<ClassState> {
  final ClassRepository _repository;

  ClassCubit(this._repository) : super(const ClassState());

  Future<void> loadClasses() async {
    emit(state.copyWith(isLoading: true));
    try {
      final classes = await _repository.getAllClasses();
      emit(state.copyWith(isLoading: false, classes: classes, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addClass(SchoolClass schoolClass) async {
    try {
      await _repository.insertClass(schoolClass);
      await loadClasses();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateClass(SchoolClass schoolClass) async {
    try {
      await _repository.updateClass(schoolClass);
      await loadClasses();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await _repository.deleteClass(id);
      await loadClasses();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadClassesByLevel(int level) async {
    emit(state.copyWith(isLoading: true));
    try {
      final classes = await _repository.getClassesByLevel(level);
      emit(state.copyWith(isLoading: false, classes: classes, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadClassesBySchool(String schoolId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final classes = await _repository.getClassesBySchool(schoolId);
      emit(state.copyWith(isLoading: false, classes: classes, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<List<SchoolClass>> getClassesBySchool(String schoolId) {
    return _repository.getClassesBySchool(schoolId);
  }

  Future<List<SchoolClass>> getAllClasses() {
    return _repository.getAllClasses();
  }

  Future<void> loadClassesByYear(String year) async {
    emit(state.copyWith(isLoading: true));
    try {
      final classes = await _repository.getClassesByYear(year);
      emit(state.copyWith(isLoading: false, classes: classes, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
