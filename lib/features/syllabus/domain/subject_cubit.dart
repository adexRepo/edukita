import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';
import 'package:edukita/features/syllabus/domain/subject_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'subject_state.dart';

class SubjectCubit extends Cubit<SubjectState> {
  final SubjectRepository _repository;
  final SubjectCacheService _cacheService;

  SubjectCubit(this._repository, this._cacheService)
    : super(const SubjectState());

  void _safeEmit(SubjectState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadCurriculum({bool forceRefresh = false}) async {
    const cacheKey = 'curriculum:all';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false, error: null));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final curriculums = await _repository.getAllCurriculums();
      final syllabi = await _repository.getAllSyllabi();
      final subjects = await _repository.getAllSubjects();
      final units = await _repository.getAllUnits();
      final competencies = await _repository.getAllCompetencies();
      final nextState = state.copyWith(
        isLoading: false,
        curriculums: curriculums,
        syllabi: syllabi,
        subjects: subjects,
        units: units,
        competencies: competencies,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadCurriculums({bool forceRefresh = false}) async {
    const cacheKey = 'curriculums';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false, error: null));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final curriculums = await _repository.getAllCurriculums();
      final nextState = state.copyWith(
        isLoading: false,
        curriculums: curriculums,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addCurriculum(Curriculum curriculum) async {
    try {
      await _repository.insertCurriculum(curriculum);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateCurriculum(Curriculum curriculum) async {
    try {
      await _repository.updateCurriculum(curriculum);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteCurriculum(String id) async {
    try {
      await _repository.deleteCurriculum(id);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadSyllabi({bool forceRefresh = false}) async {
    const cacheKey = 'syllabi';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false, error: null));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final syllabi = await _repository.getAllSyllabi();
      final nextState = state.copyWith(
        isLoading: false,
        syllabi: syllabi,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSyllabus(Syllabus syllabus) async {
    try {
      await _repository.insertSyllabus(syllabus);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSyllabus(Syllabus syllabus) async {
    try {
      await _repository.updateSyllabus(syllabus);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteSyllabus(String id) async {
    try {
      await _repository.deleteSyllabus(id);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadSubjects({bool forceRefresh = false}) async {
    const cacheKey = 'subjects';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false, error: null));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final subjects = await _repository.getAllSubjects();
      final nextState = state.copyWith(
        isLoading: false,
        subjects: subjects,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSubject(Subject subject) async {
    try {
      await _repository.insertSubject(subject);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSubject(Subject subject) async {
    try {
      await _repository.updateSubject(subject);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      await _repository.deleteSubject(id);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<CurriculumDeleteImpact> getSubjectDeleteImpact(String id) {
    return _repository.getSubjectDeleteImpact(id);
  }

  Future<void> loadUnits({bool forceRefresh = false}) async {
    const cacheKey = 'units';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false, error: null));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final units = await _repository.getAllUnits();
      final nextState = state.copyWith(
        isLoading: false,
        units: units,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addUnit(Unit unit) async {
    try {
      await _repository.insertUnit(unit);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateUnit(Unit unit) async {
    try {
      await _repository.updateUnit(unit);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteUnit(String id) async {
    try {
      await _repository.deleteUnit(id);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<CurriculumDeleteImpact> getUnitDeleteImpact(String id) {
    return _repository.getUnitDeleteImpact(id);
  }

  Future<void> loadUnitsBySubject(
    String subjectId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'units:subject:$subjectId';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false, error: null));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final units = await _repository.getUnitsBySubject(subjectId);
      final nextState = state.copyWith(
        isLoading: false,
        units: units,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadCompetencies({bool forceRefresh = false}) async {
    const cacheKey = 'competencies';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false, error: null));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final competencies = await _repository.getAllCompetencies();
      final nextState = state.copyWith(
        isLoading: false,
        competencies: competencies,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addCompetency(Competency competency) async {
    try {
      await _repository.insertCompetency(competency);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateCompetency(Competency competency) async {
    try {
      await _repository.updateCompetency(competency);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteCompetency(String id) async {
    try {
      await _repository.deleteCompetency(id);
      _cacheService.clear();
      await loadCurriculum(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadCompetenciesByUnit(
    String unitId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'competencies:unit:$unitId';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false, error: null));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final competencies = await _repository.getCompetenciesByUnit(unitId);
      final nextState = state.copyWith(
        isLoading: false,
        competencies: competencies,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

class SubjectCacheService {
  SubjectCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxEntries = 4,
  }) : _items = AppMemoryCache<SubjectState>(
         ttl: ttl,
         maxEntries: maxEntries,
       );

  final AppMemoryCache<SubjectState> _items;

  SubjectState? get(String key) => _items.get(key);

  void put(String key, SubjectState state) {
    _items.put(key, state.copyWith(isLoading: false, error: null));
  }

  void clear() => _items.clear();
}
