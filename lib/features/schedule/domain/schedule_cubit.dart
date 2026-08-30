import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:edukita/features/schedule/data/schedule_model.dart';
import 'package:edukita/features/schedule/domain/schedule_repository.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _repository;
  final ScheduleCacheService _cacheService;
  final TeachingActivityCacheService _teachingActivityCacheService;
  int _loadGeneration = 0;

  ScheduleCubit(
    this._repository,
    this._cacheService,
    this._teachingActivityCacheService,
  ) : super(const ScheduleState());

  void _safeEmit(ScheduleState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadSchedules({bool forceRefresh = false}) async {
    final loadGeneration = ++_loadGeneration;
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
      final schedules = await _repository.getAllSchedules();
      final events = await _repository.getAllEvents();
      final nextState = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        schedules: schedules,
        events: events,
        error: null,
      );
      if (loadGeneration != _loadGeneration || isClosed) return;
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      if (loadGeneration != _loadGeneration || isClosed) return;
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSchedule(Schedule schedule, {String? teacherScopeId}) async {
    try {
      await _repository.insertSchedule(schedule);
      _safeEmit(
        state.copyWith(schedules: [...state.schedules, schedule], error: null),
      );
      _clearScheduleRelatedCaches();
      await _reloadAfterMutation(teacherScopeId: teacherScopeId);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateSchedule(
    Schedule schedule, {
    String? teacherScopeId,
  }) async {
    try {
      await _repository.updateSchedule(schedule);
      _safeEmit(
        state.copyWith(
          schedules: state.schedules
              .map((item) => item.id == schedule.id ? schedule : item)
              .toList(),
          error: null,
        ),
      );
      _clearScheduleRelatedCaches();
      await _reloadAfterMutation(teacherScopeId: teacherScopeId);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteSchedule(String id, {String? teacherScopeId}) async {
    try {
      await _repository.deleteSchedule(id);
      _safeEmit(
        state.copyWith(
          schedules: state.schedules.where((item) => item.id != id).toList(),
          error: null,
        ),
      );
      _clearScheduleRelatedCaches();
      await _reloadAfterMutation(teacherScopeId: teacherScopeId);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> addEvent(ScheduleEvent event) async {
    try {
      await _repository.insertEvent(event);
      _safeEmit(state.copyWith(events: [...state.events, event], error: null));
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateEvent(ScheduleEvent event) async {
    try {
      await _repository.updateEvent(event);
      _safeEmit(
        state.copyWith(
          events: state.events
              .map((item) => item.id == event.id ? event : item)
              .toList(),
          error: null,
        ),
      );
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
      _safeEmit(
        state.copyWith(
          events: state.events.where((item) => item.id != id).toList(),
          error: null,
        ),
      );
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (_) {
      rethrow;
    }
  }

  Future<void> loadSchedulesByClass(
    String classId, {
    bool forceRefresh = false,
  }) async {
    final loadGeneration = ++_loadGeneration;
    final cacheKey = 'class:$classId';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesByClass(classId);
      final nextState = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        schedules: schedules,
        error: null,
      );
      if (loadGeneration != _loadGeneration || isClosed) return;
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      if (loadGeneration != _loadGeneration || isClosed) return;
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesByLevel(
    int level, {
    bool forceRefresh = false,
  }) async {
    final loadGeneration = ++_loadGeneration;
    final cacheKey = 'level:$level';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesByLevel(level);
      final nextState = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        schedules: schedules,
        error: null,
      );
      if (loadGeneration != _loadGeneration || isClosed) return;
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      if (loadGeneration != _loadGeneration || isClosed) return;
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesByTeacher(
    String teacherId, {
    bool forceRefresh = false,
  }) async {
    final loadGeneration = ++_loadGeneration;
    final cacheKey = 'teacher:$teacherId';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesByTeacher(teacherId);
      final events = await _repository.getAllEvents();
      final nextState = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        schedules: schedules,
        events: events,
        error: null,
      );
      if (loadGeneration != _loadGeneration || isClosed) return;
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      if (loadGeneration != _loadGeneration || isClosed) return;
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesByDate(
    String date, {
    bool forceRefresh = false,
  }) async {
    final loadGeneration = ++_loadGeneration;
    final cacheKey = 'date:$date';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesByDate(date);
      final nextState = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        schedules: schedules,
        error: null,
      );
      if (loadGeneration != _loadGeneration || isClosed) return;
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      if (loadGeneration != _loadGeneration || isClosed) return;
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesBySubject(
    String subjectId, {
    bool forceRefresh = false,
  }) async {
    final loadGeneration = ++_loadGeneration;
    final cacheKey = 'subject:$subjectId';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesBySubject(subjectId);
      final nextState = state.copyWith(
        isLoading: false,
        hasLoaded: true,
        schedules: schedules,
        error: null,
      );
      if (loadGeneration != _loadGeneration || isClosed) return;
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      if (loadGeneration != _loadGeneration || isClosed) return;
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _clearScheduleRelatedCaches() {
    _cacheService.clear();
    _teachingActivityCacheService.clear();
  }

  Future<void> _reloadAfterMutation({String? teacherScopeId}) {
    if (teacherScopeId != null && teacherScopeId.trim().isNotEmpty) {
      return loadSchedulesByTeacher(teacherScopeId, forceRefresh: true);
    }
    return loadSchedules(forceRefresh: true);
  }
}

class ScheduleCacheService {
  ScheduleCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxEntries = 4,
  }) : _items = AppMemoryCache<ScheduleState>(ttl: ttl, maxEntries: maxEntries);

  final AppMemoryCache<ScheduleState> _items;
  int _revision = 0;

  int get revision => _revision;

  ScheduleState? get(String key) => _items.get(key);

  void put(String key, ScheduleState state) {
    _items.put(key, state.copyWith(isLoading: false));
  }

  void clear() {
    _revision++;
    _items.clear();
  }
}
