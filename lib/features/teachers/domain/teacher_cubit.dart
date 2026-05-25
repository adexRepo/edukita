import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';

part 'teacher_state.dart';

class TeacherCubit extends Cubit<TeacherState> {
  final TeacherRepository _repository;
  final TeacherCacheService _cacheService;

  TeacherCubit(this._repository, this._cacheService)
    : super(const TeacherState());

  void _safeEmit(TeacherState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadTeachers({bool forceRefresh = false}) async {
    const cacheKey = 'all';
    if (!forceRefresh) {
      final cachedState = _cacheService.get(cacheKey);
      if (cachedState != null) {
        _safeEmit(cachedState.copyWith(isLoading: false));
        return;
      }
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final teachers = await _repository.getAllTeachers();
      final nextState = state.copyWith(
        isLoading: false,
        teachers: teachers,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addTeacher(Teacher teacher) async {
    try {
      await _repository.insertTeacher(teacher);
      _cacheService.clear();
      await loadTeachers(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateTeacher(Teacher teacher) async {
    try {
      await _repository.updateTeacher(teacher);
      _cacheService.clear();
      await loadTeachers(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      await _repository.deleteTeacher(id);
      _cacheService.clear();
      await loadTeachers(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadTeachersByGender(
    String gender, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'gender:$gender';
    if (!forceRefresh) {
      final cachedState = _cacheService.get(cacheKey);
      if (cachedState != null) {
        _safeEmit(cachedState.copyWith(isLoading: false));
        return;
      }
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final teachers = await _repository.getTeachersByGender(gender);
      final nextState = state.copyWith(
        isLoading: false,
        teachers: teachers,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

class TeacherCacheService {
  TeacherCacheService({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _TeacherCacheEntry> _items = {};

  TeacherState? get(String key) {
    final entry = _items[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.cachedAt) > ttl) {
      _items.remove(key);
      return null;
    }
    return entry.state;
  }

  void put(String key, TeacherState state) {
    _items[key] = _TeacherCacheEntry(
      state: state.copyWith(isLoading: false),
      cachedAt: DateTime.now(),
    );
  }

  void clear() => _items.clear();
}

class _TeacherCacheEntry {
  const _TeacherCacheEntry({required this.state, required this.cachedAt});

  final TeacherState state;
  final DateTime cachedAt;
}
