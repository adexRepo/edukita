import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/data/student_exam_score_data.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/domain/student_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDetailCubit extends Cubit<FeatureState<StudentDetailData>> {
  final StudentRepository _repo;
  final StudentCacheService _cacheService;
  Future<StudentAdvancedFormData>? _advancedDataFuture;
  Future<List<StudentGuardianFormData>>? _guardiansFuture;
  Future<List<StudentRelationFormData>>? _relationsFuture;
  Future<List<StudentActivityFormData>>? _activitiesFuture;
  Future<StudentDetailInsights>? _insightsFuture;

  StudentDetailCubit(this._repo, this._cacheService)
    : super(const FeatureState());

  void _safeEmit(FeatureState<StudentDetailData> nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> init(String id) async {
    await _fetch(id);
  }

  Future<StudentGuardianFormData?> loadPrimaryGuardian(String studentId) {
    return _repo.loadPrimaryGuardian(studentId);
  }

  Future<List<StudentGuardianFormData>> loadGuardians(String studentId) async {
    final existing = _guardiansFuture;
    if (existing != null) return existing;
    final request = _repo.loadGuardians(studentId);
    _guardiansFuture = request;
    try {
      return await request;
    } catch (_) {
      _guardiansFuture = null;
      rethrow;
    }
  }

  Future<StudentAdvancedFormData> loadAdvancedFormData(String studentId) async {
    final existing = _advancedDataFuture;
    if (existing != null) return existing;
    final request = _repo.loadAdvancedFormData(studentId);
    _advancedDataFuture = request;
    try {
      return await request;
    } catch (_) {
      _advancedDataFuture = null;
      rethrow;
    }
  }

  Future<List<StudentRelationFormData>> loadRelations(String studentId) async {
    final existing = _relationsFuture;
    if (existing != null) return existing;
    final request = _repo.loadRelations(studentId);
    _relationsFuture = request;
    try {
      return await request;
    } catch (_) {
      _relationsFuture = null;
      rethrow;
    }
  }

  Future<List<StudentActivityFormData>> loadActivities(String studentId) async {
    final existing = _activitiesFuture;
    if (existing != null) return existing;
    final request = _repo.loadActivities(studentId);
    _activitiesFuture = request;
    try {
      return await request;
    } catch (_) {
      _activitiesFuture = null;
      rethrow;
    }
  }

  Future<StudentDetailInsights> loadDetailInsights(String studentId) async {
    final existing = _insightsFuture;
    if (existing != null) return existing;
    final request = _repo.loadDetailInsights(studentId);
    _insightsFuture = request;
    try {
      return await request;
    } catch (_) {
      _insightsFuture = null;
      rethrow;
    }
  }

  Future<StudentExamScoreOptions> loadExamScoreOptions(String studentId) {
    return _repo.loadExamScoreOptions(studentId);
  }

  Future<List<StudentExamScoreGroup>> loadStudentExamScores(String studentId) {
    return _repo.loadStudentExamScores(studentId);
  }

  Future<void> saveStudentExamScoreGroup(
    StudentExamScoreGroup group, {
    String? evidenceSourcePath,
    String? evidenceFileName,
  }) async {
    await _repo.saveStudentExamScoreGroup(
      group,
      evidenceSourcePath: evidenceSourcePath,
      evidenceFileName: evidenceFileName,
    );
    _insightsFuture = null;
    _cacheService.clear();
  }

  Future<void> deleteStudentExamScoreGroup(StudentExamScoreGroup group) async {
    await _repo.deleteStudentExamScoreGroup(group);
    _insightsFuture = null;
    _cacheService.clear();
  }

  Future<void> updateStudentExamScoreGroup(
    StudentExamScoreGroup group, {
    String? evidenceSourcePath,
    String? evidenceFileName,
  }) async {
    await _repo.updateStudentExamScoreGroup(
      group,
      evidenceSourcePath: evidenceSourcePath,
      evidenceFileName: evidenceFileName,
    );
    _insightsFuture = null;
    _cacheService.clear();
  }

  Future<void> _fetch(String id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedData = _cacheService.getDetail(id);
      if (cachedData != null) {
        _safeEmit(FeatureState<StudentDetailData>(
          data: cachedData,
          loading: false,
        ));
        return;
      }
    }

    _safeEmit(state.copyWith(loading: true, data: null));

    try {
      final result = await _repo.loadDetailItem(id);
      _cacheService.putDetail(id, result);

      _safeEmit(state.copyWith(data: result, loading: false));
    } catch (e) {
      _safeEmit(
        state.copyWith(loading: false, message: e.toString(), data: null),
      );
    }
  }
}
