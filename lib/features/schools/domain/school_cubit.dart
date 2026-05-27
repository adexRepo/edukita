import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/schools/domain/school_repository.dart';

part 'school_state.dart';

class SchoolCubit extends Cubit<SchoolState> {
  final SchoolRepository _repository;
  final SchoolCacheService _cacheService;

  SchoolCubit(this._repository, this._cacheService) : super(const SchoolState());

  void _safeEmit(SchoolState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadSchools({bool forceRefresh = false}) async {
    const cacheKey = 'all';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schools = await _repository.getAllSchools();
      final nextState = state.copyWith(
        isLoading: false,
        schools: schools,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSchool(School school) async {
    try {
      await _repository.insertSchool(school);
      _cacheService.clear();
      await loadSchools(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> addSchoolWithClasses(
    School school,
    List<SchoolClass> classes,
  ) async {
    try {
      await _repository.insertSchoolWithClasses(school, classes);
      _cacheService.clear();
      await loadSchools(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSchool(School school) async {
    try {
      await _repository.updateSchool(school);
      _cacheService.clear();
      await loadSchools(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSchoolWithClasses(
    School school,
    List<SchoolClass> classes,
  ) async {
    try {
      await _repository.updateSchoolWithClasses(school, classes);
      _cacheService.clear();
      await loadSchools(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteSchool(String id) async {
    try {
      await _repository.deleteSchool(id);
      _cacheService.clear();
      await loadSchools(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadSchoolsByType(String type, {bool forceRefresh = false}) async {
    final cacheKey = 'type:$type';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schools = await _repository.getSchoolsByType(type);
      final nextState = state.copyWith(
        isLoading: false,
        schools: schools,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadStudentSchools(
    String studentId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'student:$studentId';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schools = await _repository.getSchoolsByStudent(studentId);
      final nextState = state.copyWith(
        isLoading: false,
        schools: schools,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> linkSchool(StudentSchool studentSchool) async {
    try {
      await _repository.linkStudentSchool(studentSchool);
      _cacheService.clear();
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> unlinkSchool(String studentSchoolId) async {
    try {
      await _repository.unlinkStudentSchool(studentSchoolId);
      _cacheService.clear();
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }
}

class SchoolCacheService {
  SchoolCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxEntries = 3,
  }) : _items = AppMemoryCache<SchoolState>(
         ttl: ttl,
         maxEntries: maxEntries,
       );

  final AppMemoryCache<SchoolState> _items;

  SchoolState? get(String key) => _items.get(key);

  void put(String key, SchoolState state) {
    _items.put(key, state.copyWith(isLoading: false));
  }

  void clear() => _items.clear();
}
