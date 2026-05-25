import 'package:edukita/features/schedule/data/schedule_model.dart';
import 'package:edukita/features/schedule/domain/schedule_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final ScheduleRepository _repository;
  final ScheduleCacheService _cacheService;

  ScheduleCubit(this._repository, this._cacheService)
    : super(const ScheduleState());

  void _safeEmit(ScheduleState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadSchedules({bool forceRefresh = false}) async {
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
        schedules: schedules,
        events: events,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    try {
      await _repository.insertSchedule(schedule);
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    try {
      await _repository.updateSchedule(schedule);
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteSchedule(String id) async {
    try {
      await _repository.deleteSchedule(id);
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> addEvent(ScheduleEvent event) async {
    try {
      await _repository.insertEvent(event);
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateEvent(ScheduleEvent event) async {
    try {
      await _repository.updateEvent(event);
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _repository.deleteEvent(id);
      _cacheService.clear();
      await loadSchedules(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadSchedulesByClass(
    String classId, {
    bool forceRefresh = false,
  }) async {
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
        schedules: schedules,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesByLevel(
    int level, {
    bool forceRefresh = false,
  }) async {
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
        schedules: schedules,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesByTeacher(
    String teacherId, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'teacher:$teacherId';
    final cachedState = forceRefresh ? null : _cacheService.get(cacheKey);
    if (cachedState != null) {
      _safeEmit(cachedState.copyWith(isLoading: false));
      return;
    }

    _safeEmit(state.copyWith(isLoading: true));
    try {
      final schedules = await _repository.getSchedulesByTeacher(teacherId);
      final nextState = state.copyWith(
        isLoading: false,
        schedules: schedules,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesByDate(
    String date, {
    bool forceRefresh = false,
  }) async {
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
        schedules: schedules,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadSchedulesBySubject(
    String subjectId, {
    bool forceRefresh = false,
  }) async {
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
        schedules: schedules,
        error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

class ScheduleCacheService {
  ScheduleCacheService({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _ScheduleCacheEntry> _items = {};

  ScheduleState? get(String key) {
    final entry = _items[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.cachedAt) > ttl) {
      _items.remove(key);
      return null;
    }
    return entry.state;
  }

  void put(String key, ScheduleState state) {
    _items[key] = _ScheduleCacheEntry(
      state: state.copyWith(isLoading: false),
      cachedAt: DateTime.now(),
    );
  }

  void clear() => _items.clear();
}

class _ScheduleCacheEntry {
  const _ScheduleCacheEntry({required this.state, required this.cachedAt});

  final ScheduleState state;
  final DateTime cachedAt;
}
