import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:edukita/features/reports/assessment_model.dart';
import 'package:edukita/features/reports/assessment_repository.dart';

part 'assessment_state.dart';

class AssessmentCubit extends Cubit<AssessmentState> {
  final AssessmentRepository _repository;

  AssessmentCubit(this._repository) : super(const AssessmentState());

  Future<void> loadAssessmentModule() async {
    emit(state.copyWith(isLoading: true));
    try {
      final assessments = await _repository.getAllAssessments();
      final studentAssessments = await _repository.getAllStudentAssessments();
      final students = await _repository.getStudentOptions();
      final gradingScales = await _repository.getAllGradingScales();
      final evidenceCountsByResult =
          await _repository.getEvidenceCountsByResult();
      emit(
        state.copyWith(
          isLoading: false,
          assessments: assessments,
          studentAssessments: studentAssessments,
          students: students,
          gradingScales: gradingScales,
          evidenceCountsByResult: evidenceCountsByResult,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadAssessments() async {
    emit(state.copyWith(isLoading: true));
    try {
      final assessments = await _repository.getAllAssessments();
      emit(
        state.copyWith(isLoading: false, assessments: assessments, error: null),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addAssessment(Assessment assessment) async {
    try {
      await _repository.insertAssessment(assessment);
      await loadAssessmentModule();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateAssessment(Assessment assessment) async {
    try {
      await _repository.updateAssessment(assessment);
      await loadAssessmentModule();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteAssessment(String id) async {
    try {
      await _repository.deleteAssessment(id);
      await loadAssessmentModule();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> loadGradingScales() async {
    emit(state.copyWith(isLoading: true));
    try {
      final scales = await _repository.getAllGradingScales();
      emit(
        state.copyWith(isLoading: false, gradingScales: scales, error: null),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addGradingScale(GradingScale scale) async {
    try {
      await _repository.insertGradingScale(scale);
      await loadGradingScales();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> updateGradingScale(GradingScale scale) async {
    try {
      await _repository.updateGradingScale(scale);
      await loadGradingScales();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> recordStudentAssessment(
    StudentAssessment studentAssessment, {
    String? evidenceSourcePath,
    String? evidenceFileName,
    String? evidenceRemarks,
  }) async {
    try {
      await _repository.recordStudentAssessment(
        studentAssessment,
        evidenceSourcePath: evidenceSourcePath,
        evidenceFileName: evidenceFileName,
        evidenceRemarks: evidenceRemarks,
      );
      await loadAssessmentModule();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteStudentAssessment(String id) async {
    try {
      await _repository.deleteStudentAssessment(id);
      await loadAssessmentModule();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }
}
