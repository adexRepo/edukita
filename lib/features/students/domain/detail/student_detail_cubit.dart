import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/student_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDetailCubit extends Cubit<FeatureState<StudentDetailData>> {
  final StudentRepository _repo;

  StudentDetailCubit(this._repo) : super(const FeatureState());

  Future<void> init(String id) async {
    await _fetch(id);
  }

  Future<StudentGuardianFormData?> loadPrimaryGuardian(String studentId) {
    return _repo.loadPrimaryGuardian(studentId);
  }

  Future<List<StudentGuardianFormData>> loadGuardians(String studentId) {
    return _repo.loadGuardians(studentId);
  }

  Future<StudentAdvancedFormData> loadAdvancedFormData(String studentId) {
    return _repo.loadAdvancedFormData(studentId);
  }

  Future<List<StudentRelationFormData>> loadRelations(String studentId) {
    return _repo.loadRelations(studentId);
  }

  Future<List<StudentActivityFormData>> loadActivities(String studentId) {
    return _repo.loadActivities(studentId);
  }

  Future<void> _fetch(String id) async {
    emit(state.copyWith(loading: true, data: null));

    try {
      final result = await _repo.loadDetailItem(id);

      emit(state.copyWith(data: result, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, message: e.toString(), data: null));
    }
  }
}
