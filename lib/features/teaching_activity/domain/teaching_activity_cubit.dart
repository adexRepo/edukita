import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeachingActivityState {
  const TeachingActivityState({
    this.activities = const [],
    this.date,
    this.teacherId,
    this.classId,
    this.status,
    this.isLoading = false,
    this.isSaving = false,
    this.openActivityId,
    this.error,
  });

  final List<TeachingActivityListItem> activities;
  final String? date;
  final String? teacherId;
  final String? classId;
  final String? status;
  final bool isLoading;
  final bool isSaving;
  final String? openActivityId;
  final String? error;

  TeachingActivityState copyWith({
    List<TeachingActivityListItem>? activities,
    String? date,
    String? teacherId,
    String? classId,
    String? status,
    bool? clearTeacherId,
    bool? clearClassId,
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
      date: date ?? this.date,
      teacherId: clearTeacherId == true ? null : teacherId ?? this.teacherId,
      classId: clearClassId == true ? null : classId ?? this.classId,
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
  TeachingActivityCubit(this._repository) : super(const TeachingActivityState());

  final TeachingActivityRepository _repository;

  Future<void> loadActivities({
    String? date,
    String? teacherId,
    String? classId,
    String? status,
    bool clearTeacherId = false,
    bool clearClassId = false,
    bool clearStatus = false,
  }) async {
    final effectiveDate = date ?? state.date ?? _dateOnly(DateTime.now());
    final effectiveTeacherId = clearTeacherId ? null : teacherId ?? state.teacherId;
    final effectiveClassId = clearClassId ? null : classId ?? state.classId;
    final effectiveStatus = clearStatus ? null : status ?? state.status;

    emit(
      state.copyWith(
        date: effectiveDate,
        teacherId: effectiveTeacherId,
        classId: effectiveClassId,
        status: effectiveStatus,
        clearTeacherId: clearTeacherId,
        clearClassId: clearClassId,
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
        status: effectiveStatus,
      );
      emit(state.copyWith(activities: activities, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> startClass(String scheduleId) async {
    emit(state.copyWith(isSaving: true, clearOpenActivityId: true, clearError: true));
    try {
      final activityId = await _repository.startClass(scheduleId);
      emit(state.copyWith(isSaving: false, openActivityId: activityId));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
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
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.cancelClass(
        scheduleId: scheduleId,
        activityId: activityId,
        reason: reason,
        notes: notes,
        replacementRequired: replacementRequired,
      );
      emit(state.copyWith(isSaving: false));
      await loadActivities();
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> completeActivity(String activityId) async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.completeActivity(activityId);
      emit(state.copyWith(isSaving: false));
      await loadActivities();
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  String _dateOnly(DateTime value) => value.toIso8601String().split('T').first;
}
