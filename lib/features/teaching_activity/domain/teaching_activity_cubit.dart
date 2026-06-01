import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeachingActivityState {
  const TeachingActivityState({
    this.activities = const [],
    this.sessionDateKeys = const <String>{},
    this.date,
    this.teacherId,
    this.classId,
    this.classLevel,
    this.status,
    this.isLoading = false,
    this.isSaving = false,
    this.openActivityId,
    this.error,
  });

  final List<TeachingActivityListItem> activities;
  final Set<String> sessionDateKeys;
  final String? date;
  final String? teacherId;
  final String? classId;
  final int? classLevel;
  final String? status;
  final bool isLoading;
  final bool isSaving;
  final String? openActivityId;
  final String? error;

  TeachingActivityState copyWith({
    List<TeachingActivityListItem>? activities,
    Set<String>? sessionDateKeys,
    String? date,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
    bool? clearTeacherId,
    bool? clearClassId,
    bool? clearClassLevel,
    bool? clearStatus,
    bool? isLoading,
    bool? isSaving,
    String? openActivityId,
    bool clearOpenActivityId = false,
    String? error,
    bool clearError = false,
  }) {
    return TeachingActivityState(
      activities: activities ?? this.activities,
      sessionDateKeys: sessionDateKeys ?? this.sessionDateKeys,
      date: date ?? this.date,
      teacherId: clearTeacherId == true ? null : teacherId ?? this.teacherId,
      classId: clearClassId == true ? null : classId ?? this.classId,
      classLevel:
          clearClassLevel == true ? null : classLevel ?? this.classLevel,
      status: clearStatus == true ? null : status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      openActivityId:
          clearOpenActivityId ? null : openActivityId ?? this.openActivityId,
      error: clearError ? null : error,
    );
  }
}

class TeachingActivityCubit extends Cubit<TeachingActivityState> {
  TeachingActivityCubit(this._repository, this._cacheService)
    : super(const TeachingActivityState());

  final TeachingActivityRepository _repository;
  final TeachingActivityCacheService _cacheService;

  void _safeEmit(TeachingActivityState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadActivities({
    String? date,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
    bool clearTeacherId = false,
    bool clearClassId = false,
    bool clearClassLevel = false,
    bool clearStatus = false,
    bool forceRefresh = false,
  }) async {
    final effectiveDate = date ?? state.date ?? _dateOnly(DateTime.now());
    final effectiveTeacherId = clearTeacherId
        ? null
        : teacherId ?? state.teacherId;
    final effectiveClassId = clearClassId ? null : classId ?? state.classId;
    final effectiveClassLevel =
        clearClassLevel ? null : classLevel ?? state.classLevel;
    final effectiveStatus = clearStatus ? null : status ?? state.status;
    final cacheKey = _cacheKey(
      date: effectiveDate,
      teacherId: effectiveTeacherId,
      classId: effectiveClassId,
      classLevel: effectiveClassLevel,
      status: effectiveStatus,
    );

    if (!forceRefresh) {
      final cachedState = _cacheService.get(cacheKey);
      if (cachedState != null) {
        _safeEmit(
          cachedState.copyWith(
            date: effectiveDate,
            teacherId: effectiveTeacherId,
            classId: effectiveClassId,
            classLevel: effectiveClassLevel,
            status: effectiveStatus,
            clearTeacherId: effectiveTeacherId == null,
            clearClassId: effectiveClassId == null,
            clearClassLevel: effectiveClassLevel == null,
            clearStatus: effectiveStatus == null,
            isLoading: false,
            clearOpenActivityId: true,
            clearError: true,
          ),
        );
        return;
      }
    }

    _safeEmit(
      state.copyWith(
        date: effectiveDate,
        teacherId: effectiveTeacherId,
        classId: effectiveClassId,
        classLevel: effectiveClassLevel,
        status: effectiveStatus,
        clearTeacherId: clearTeacherId,
        clearClassId: clearClassId,
        clearClassLevel: clearClassLevel,
        clearStatus: clearStatus,
        isLoading: true,
        clearOpenActivityId: true,
        clearError: true,
      ),
    );

    try {
      final activities = await _repository.getActivities(
        date: effectiveDate,
        teacherId: effectiveTeacherId,
        classId: effectiveClassId,
        classLevel: effectiveClassLevel,
        status: effectiveStatus,
      );
      final sessionDateKeys = await _repository.getSessionDateKeysForMonth(
        month: DateTime.tryParse(effectiveDate) ?? DateTime.now(),
        teacherId: effectiveTeacherId,
        classId: effectiveClassId,
        classLevel: effectiveClassLevel,
        status: effectiveStatus,
      );
      final nextState = state.copyWith(
        activities: activities,
        sessionDateKeys: sessionDateKeys,
        date: effectiveDate,
        teacherId: effectiveTeacherId,
        classId: effectiveClassId,
        classLevel: effectiveClassLevel,
        status: effectiveStatus,
        clearTeacherId: effectiveTeacherId == null,
        clearClassId: effectiveClassId == null,
        clearClassLevel: effectiveClassLevel == null,
        clearStatus: effectiveStatus == null,
        isLoading: false,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> startClass(String scheduleId) async {
    _safeEmit(
      state.copyWith(
        isSaving: true,
        clearOpenActivityId: true,
        clearError: true,
      ),
    );
    try {
      final activityId = await _repository.startClass(scheduleId);
      _cacheService.clear();
      _safeEmit(state.copyWith(isSaving: false, openActivityId: activityId));
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> cancelClass({
    String? scheduleId,
    String? activityId,
    required String reason,
    String? notes,
    required bool replacementRequired,
  }) async {
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.cancelClass(
        scheduleId: scheduleId,
        activityId: activityId,
        reason: reason,
        notes: notes,
        replacementRequired: replacementRequired,
      );
      _cacheService.clear();
      _safeEmit(state.copyWith(isSaving: false));
      await loadActivities(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> completeActivity(String activityId) async {
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.completeActivity(activityId);
      _cacheService.clear();
      _safeEmit(state.copyWith(isSaving: false));
      await loadActivities(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  String _cacheKey({
    required String date,
    String? teacherId,
    String? classId,
    int? classLevel,
    String? status,
  }) {
    return [
      date,
      teacherId ?? '',
      classId ?? '',
      classLevel?.toString() ?? '',
      status ?? '',
    ].join('|');
  }

  String _dateOnly(DateTime value) => value.toIso8601String().split('T').first;
}

class TeachingActivityCacheService {
  TeachingActivityCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxEntries = 4,
  }) : _items = AppMemoryCache<TeachingActivityState>(
         ttl: ttl,
         maxEntries: maxEntries,
       );

  final AppMemoryCache<TeachingActivityState> _items;
  int _revision = 0;

  int get revision => _revision;

  TeachingActivityState? get(String key) => _items.get(key);

  void put(String key, TeachingActivityState state) {
    _items.put(key, state.copyWith(isLoading: false, isSaving: false));
  }

  void clear() {
    _revision++;
    _items.clear();
  }
}
