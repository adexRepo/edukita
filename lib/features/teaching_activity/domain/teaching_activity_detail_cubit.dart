import 'package:edukita/features/teaching_activity/data/teaching_activity_data.dart';
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

class TeachingActivityDetailCubit
    extends Cubit<TeachingActivityDetailState> {
  TeachingActivityDetailCubit(this._repository)
      : super(const TeachingActivityDetailState());

  final TeachingActivityRepository _repository;
  String? _activityId;

  Future<void> loadDetail(String activityId) async {
    _activityId = activityId;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final detail = await _repository.getDetail(activityId);
      emit(state.copyWith(detail: detail, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
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
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.saveAttendance(activityId, records);
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
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
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
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
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> addAssessment({
    required String studentId,
    String? competencyId,
    required String assessmentType,
    required String result,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    double? score,
    String? notes,
  }) async {
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.addAssessment(
        activityId: activityId,
        studentId: studentId,
        competencyId: competencyId,
        assessmentType: assessmentType,
        result: result,
        scoreMode: scoreMode,
        rawScore: rawScore,
        normalizedScore: normalizedScore,
        score: score,
        notes: notes,
      );
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateAssessment({
    required String id,
    required String studentId,
    String? competencyId,
    required String assessmentType,
    required String result,
    required String scoreMode,
    double? rawScore,
    double? normalizedScore,
    double? score,
    String? notes,
  }) async {
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.updateAssessment(
        id: id,
        studentId: studentId,
        competencyId: competencyId,
        assessmentType: assessmentType,
        result: result,
        scoreMode: scoreMode,
        rawScore: rawScore,
        normalizedScore: normalizedScore,
        score: score,
        notes: notes,
      );
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> saveBulkAssessments({
    String? competencyId,
    required String assessmentType,
    required List<TeachingAssessmentBulkInput> records,
  }) async {
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.saveBulkAssessments(
        activityId: activityId,
        competencyId: competencyId,
        assessmentType: assessmentType,
        records: records,
      );
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteAssessment(String id) async {
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.deleteAssessment(id);
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
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
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
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
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
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
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
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
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteStudentNote(String id) async {
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.deleteStudentNote(id);
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }

  Future<void> completeActivity() async {
    final activityId = _activityId;
    if (activityId == null) return;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _repository.completeActivity(activityId);
      emit(state.copyWith(isSaving: false));
      await loadDetail(activityId);
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
      rethrow;
    }
  }
}
