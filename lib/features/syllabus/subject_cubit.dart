import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/syllabus/subject_model.dart';
import 'package:edukita/features/syllabus/subject_repository.dart';

part 'subject_state.dart';

class SubjectCubit extends Cubit<SubjectState> {
  final SubjectRepository _repository;

  SubjectCubit(this._repository) : super(const SubjectState());

  Future<void> loadSubjects() async {
    emit(state.copyWith(isLoading: true));
    try {
      final subjects = await _repository.getAllSubjects();
      emit(state.copyWith(isLoading: false, subjects: subjects, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      await _repository.insertSubject(subject);
      await loadSubjects();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      await _repository.updateSubject(subject);
      await loadSubjects();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _repository.deleteSubject(id);
      await loadSubjects();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadUnits() async {
    emit(state.copyWith(isLoading: true));
    try {
      final units = await _repository.getAllUnits();
      emit(state.copyWith(isLoading: false, units: units, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addUnit(Unit unit) async {
    try {
      await _repository.insertUnit(unit);
      await loadUnits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateUnit(Unit unit) async {
    try {
      await _repository.updateUnit(unit);
      await loadUnits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteUnit(String id) async {
    try {
      await _repository.deleteUnit(id);
      await loadUnits();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadUnitsBySubject(String subjectId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final units = await _repository.getUnitsBySubject(subjectId);
      emit(state.copyWith(isLoading: false, units: units, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadCompetencies() async {
    emit(state.copyWith(isLoading: true));
    try {
      final competencies = await _repository.getAllCompetencies();
      emit(
        state.copyWith(
          isLoading: false,
          competencies: competencies,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addCompetency(Competency competency) async {
    try {
      await _repository.insertCompetency(competency);
      await loadCompetencies();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateCompetency(Competency competency) async {
    try {
      await _repository.updateCompetency(competency);
      await loadCompetencies();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteCompetency(String id) async {
    try {
      await _repository.deleteCompetency(id);
      await loadCompetencies();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadCompetenciesByUnit(String unitId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final competencies = await _repository.getCompetenciesByUnit(unitId);
      emit(
        state.copyWith(
          isLoading: false,
          competencies: competencies,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
