import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/domain/class_repository.dart';

part 'class_state.dart';

class ClassCubit extends Cubit<ClassState> {
  final ClassRepository _repository;
  final ClassCacheService _cacheService;

  ClassCubit(this._repository, this._cacheService) : super(const ClassState());

  void _safeEmit(ClassState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadClasses({bool forceRefresh = false}) async {
    const cacheKey = 'all';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final classes = await _repository.getAllClasses();
      final nextState = state.copyWith(
        isLoading: false,
        classes: classes,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addClass(SchoolClass schoolClass) async {
    try {
      await _repository.insertClass(schoolClass);
      _cacheService.clear();
      await loadClasses(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateClass(SchoolClass schoolClass) async {
    try {
      await _repository.updateClass(schoolClass);
      _cacheService.clear();
      await loadClasses(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await _repository.deleteClass(id);
      _cacheService.clear();
      await loadClasses(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadClassesByLevel(int level, {bool forceRefresh = false}) async {
    final cacheKey = 'level:$level';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final classes = await _repository.getClassesByLevel(level);
      final nextState = state.copyWith(
        isLoading: false,
        classes: classes,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadClassesBySchool(
    String schoolId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'school:$schoolId';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final classes = await _repository.getClassesBySchool(schoolId);
      final nextState = state.copyWith(
        isLoading: false,
        classes: classes,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<List<SchoolClass>> getClassesBySchool(String schoolId) {
    return _repository.getClassesBySchool(schoolId);
  }

  Future<List<SchoolClass>> getAllClasses() {
    return _repository.getAllClasses();
  }

  Future<void> loadClassesByYear(String year, {bool forceRefresh = false}) async {
    final cacheKey = 'year:$year';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final classes = await _repository.getClassesByYear(year);
      final nextState = state.copyWith(
        isLoading: false,
        classes: classes,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

class ClassCacheService {
  ClassCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxEntries = 3,
  }) : _items = AppMemoryCache<ClassState>(
         ttl: ttl,
         maxEntries: maxEntries,
       );

  final AppMemoryCache<ClassState> _items;

  ClassState? get(String key) => _items.get(key);

  void put(String key, ClassState state) {
    _items.put(key, state.copyWith(isLoading: false));
  }

  void clear() => _items.clear();
}
