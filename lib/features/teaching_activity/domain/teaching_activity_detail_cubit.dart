import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_cubit.dart';
import 'package:edukita/features/teaching_activity/domain/teaching_activity_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeachingActivityDetailState {
  const TeachingActivityDetailState({
    this.detail,
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  final TeachingActivityDetailData? detail;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  TeachingActivityDetailState copyWith({
    TeachingActivityDetailData? detail,
    bool? isLoading,
    bool? isSaving,
    String? error,
    bool clearError = false,
  }) {
    return TeachingActivityDetailState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error,
    );
  }
}

class TeachingActivityDetailCubit extends Cubit<TeachingActivityDetailState> {
  TeachingActivityDetailCubit(
    this._repository,
    this._activityCacheService, {
    void Function()? onDataChanged,
  }) : _onDataChanged = onDataChanged,
       super(const TeachingActivityDetailState());

  final TeachingActivityRepository _repository;
  final TeachingActivityCacheService _activityCacheService;
  final void Function()? _onDataChanged;
  String? _activityId;
  bool _canEdit = false;
  bool _canReset = false;

  void configureAuthorization({required bool canEdit, required bool canReset}) {
    _canEdit = canEdit;
    _canReset = canReset;
  }

  void _requireEditAccess() {
    if (!_canEdit) {
      throw StateError('You do not have permission to edit this report.');
    }
  }

  void _requireResetAccess() {
    if (!_canReset) {
      throw StateError('You do not have permission to reset this report.');
    }
  }

  void _safeEmit(TeachingActivityDetailState nextState) {
    if (!isClosed) emit(nextState);
  }

  void _invalidateCaches() {
    _activityCacheService.clear();
    _onDataChanged?.call();
  }

  Future<void> loadDetail(String activityId) async {
    _activityId = activityId;
    _safeEmit(state.copyWith(isLoading: true, clearError: true));
    try {
      final detail = await _repository.getDetail(activityId);
      _safeEmit(state.copyWith(detail: detail, isLoading: false));
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  List<TeachingAttendanceRecord> markAllPresent() {
    final detail = state.detail;
    if (detail == null || detail.activity.activityId == null) return const [];
    return detail.students.map((student) {
      TeachingAttendanceRecord? existing;
      for (final item in detail.attendances) {
        if (item.studentId == student.id) {
          existing = item;
          break;
        }
      }
      return (existing ??
              TeachingAttendanceRecord(
                teachingActivityId: detail.activity.activityId!,
                studentId: student.id,
                status: TeachingAttendanceStatus.present,
              ))
          .copyWith(status: TeachingAttendanceStatus.present);
    }).toList();
  }

  Future<void> saveAttendance(List<TeachingAttendanceRecord> records) async {
    _requireEditAccess();
    if (state.isSaving) return;
    final activityId = _activityId;
    if (activityId == null) return;
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.saveAttendance(activityId, records);
      _invalidateCaches();
      _safeEmit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> saveSessionNotes({
    required int? lessonCompletionPercent,
    required String? materialCovered,
    required String? classCondition,
    required String? teachingChallenges,
    required String? followUpPlan,
    required String? sessionNotes,
    required String? assessmentType,
  }) async {
    _requireEditAccess();
    if (state.isSaving) return;
    final activityId = _activityId;
    if (activityId == null) return;
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.saveSessionNotes(
        activityId: activityId,
        lessonCompletionPercent: lessonCompletionPercent,
        materialCovered: materialCovered,
        classCondition: classCondition,
        teachingChallenges: teachingChallenges,
        followUpPlan: followUpPlan,
        sessionNotes: sessionNotes,
        assessmentType: assessmentType,
      );
      _invalidateCaches();
      _safeEmit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> saveStudentReportingData({
    required String assessmentType,
    required Set<String> studentIds,
    required List<TeachingAttendanceRecord> attendanceRecords,
    required List<TeachingAssessmentBulkInput> assessments,
    required List<StudentSessionNoteInput> notes,
  }) async {
    _requireEditAccess();
    if (state.isSaving) return;
    final activityId = _activityId;
    if (activityId == null) return;
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.saveStudentReportingData(
        activityId: activityId,
        assessmentType: assessmentType,
        studentIds: studentIds,
        attendanceRecords: attendanceRecords,
        assessments: assessments,
        notes: notes,
      );
      _invalidateCaches();
      _safeEmit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> resetReport() async {
    _requireResetAccess();
    if (state.isSaving) return;
    final activityId = _activityId;
    if (activityId == null) return;
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.resetReport(activityId);
      _invalidateCaches();
      _safeEmit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> addStudentNote({
    required String studentId,
    required String noteType,
    required String comment,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    required bool followUpNeeded,
    String? followUpNotes,
  }) async {
    _requireEditAccess();
    if (state.isSaving) return;
    final activityId = _activityId;
    if (activityId == null) return;
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.addStudentNote(
        activityId: activityId,
        studentId: studentId,
        noteType: noteType,
        comment: comment,
        scoreMode: scoreMode,
        rawScore: rawScore,
        normalizedScore: normalizedScore,
        followUpNeeded: followUpNeeded,
        followUpNotes: followUpNotes,
      );
      _invalidateCaches();
      _safeEmit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateStudentNote({
    required String id,
    required String studentId,
    required String noteType,
    required String comment,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    required bool followUpNeeded,
    String? followUpNotes,
  }) async {
    _requireEditAccess();
    if (state.isSaving) return;
    final activityId = _activityId;
    if (activityId == null) return;
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.updateStudentNote(
        id: id,
        studentId: studentId,
        noteType: noteType,
        comment: comment,
        scoreMode: scoreMode,
        rawScore: rawScore,
        normalizedScore: normalizedScore,
        followUpNeeded: followUpNeeded,
        followUpNotes: followUpNotes,
      );
      _invalidateCaches();
      _safeEmit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> completeActivityWithAttendance(
    List<TeachingAttendanceRecord> records,
  ) async {
    _requireEditAccess();
    if (state.isSaving) return;
    final activityId = _activityId;
    if (activityId == null) return;
    _safeEmit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.completeActivityWithAttendance(activityId, records);
      _invalidateCaches();
      _safeEmit(state.copyWith(isSaving: false));
    } catch (e) {
      _safeEmit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }
}
