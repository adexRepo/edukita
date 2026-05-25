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
  ClassCacheService({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _ClassCacheEntry> _items = {};

  ClassState? get(String key) {
    final entry = _items[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.cachedAt) > ttl) {
      _items.remove(key);
      return null;
    }
    return entry.state;
  }

  void put(String key, ClassState state) {
    _items[key] = _ClassCacheEntry(
      state: state.copyWith(isLoading: false),
      cachedAt: DateTime.now(),
    );
  }

  void clear() => _items.clear();
}

class _ClassCacheEntry {
  const _ClassCacheEntry({required this.state, required this.cachedAt});

  final ClassState state;
  final DateTime cachedAt;
}
