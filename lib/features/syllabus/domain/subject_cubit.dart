import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';
import 'package:edukita/features/syllabus/domain/subject_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'subject_state.dart';

class SubjectCubit extends Cubit<SubjectState> {
  final SubjectRepository _repository;

  SubjectCubit(this._repository) : super(const SubjectState());

  Future<void> loadCurriculum() async {
    emit(state.copyWith(isLoading: true));
    try {
      final curriculums = await _repository.getAllCurriculums();
      final syllabi = await _repository.getAllSyllabi();
      final subjects = await _repository.getAllSubjects();
      final units = await _repository.getAllUnits();
      final competencies = await _repository.getAllCompetencies();
      emit(
        state.copyWith(
          isLoading: false,
          curriculums: curriculums,
          syllabi: syllabi,
          subjects: subjects,
          units: units,
          competencies: competencies,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadCurriculums() async {
    emit(state.copyWith(isLoading: true));
    try {
      final curriculums = await _repository.getAllCurriculums();
      emit(
        state.copyWith(isLoading: false, curriculums: curriculums, error: null),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addCurriculum(Curriculum curriculum) async {
    try {
      await _repository.insertCurriculum(curriculum);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateCurriculum(Curriculum curriculum) async {
    try {
      await _repository.updateCurriculum(curriculum);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteCurriculum(String id) async {
    try {
      await _repository.deleteCurriculum(id);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadSyllabi() async {
    emit(state.copyWith(isLoading: true));
    try {
      final syllabi = await _repository.getAllSyllabi();
      emit(state.copyWith(isLoading: false, syllabi: syllabi, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSyllabus(Syllabus syllabus) async {
    try {
      await _repository.insertSyllabus(syllabus);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSyllabus(Syllabus syllabus) async {
    try {
      await _repository.updateSyllabus(syllabus);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteSyllabus(String id) async {
    try {
      await _repository.deleteSyllabus(id);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

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
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      await _repository.updateSubject(subject);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _repository.deleteSubject(id);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<CurriculumDeleteImpact> getSubjectDeleteImpact(String id) {
    return _repository.getSubjectDeleteImpact(id);
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
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateUnit(Unit unit) async {
    try {
      await _repository.updateUnit(unit);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteUnit(String id) async {
    try {
      await _repository.deleteUnit(id);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<CurriculumDeleteImpact> getUnitDeleteImpact(String id) {
    return _repository.getUnitDeleteImpact(id);
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
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateCompetency(Competency competency) async {
    try {
      await _repository.updateCompetency(competency);
      await loadCurriculum();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteCompetency(String id) async {
    try {
      await _repository.deleteCompetency(id);
      await loadCurriculum();
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
