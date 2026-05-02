import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/management/guardian_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/domain/student_repository.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class StudentPageCubit extends Cubit<FeatureState<StudentPageData>> {
  final StudentRepository _repo;

  StudentFilter _filter = const StudentFilter();
  Pageable _pageable = const Pageable(page: 0, size: 20);

  StudentPageCubit(this._repo) : super(const FeatureState());

  Future<void> init() async {
    _filter = const StudentFilter();
    await _fetch();
  }

  Future<void> _fetch() async {
    emit(state.copyWith(loading: true, data: null));

    try {
      final result = await _repo.loadItems(_filter, _pageable);

      emit(state.copyWith(data: result, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, message: e.toString(), data: null));
    }
  }

  Future<void> applyFilter(StudentFilter filter) async {
    _filter = filter;
    _pageable = Pageable(page: 0, size: _pageable.size);
    await _fetch();
  }

  Future<List<SchoolClass>> loadAvailableClasses() {
    return _repo.loadAvailableClasses();
  }

  Future<List<School>> loadAvailableSchools() {
    return _repo.loadAvailableSchools();
  }

  Future<String> generateStudentNumber() {
    return _repo.generateStudentNumber();
  }

  Future<Student?> loadStudent(String id) {
    return _repo.findById(id);
  }

  Future<StudentGuardianFormData?> loadPrimaryGuardian(String studentId) {
    return _repo.loadPrimaryGuardian(studentId);
  }

  Future<List<StudentGuardianFormData>> loadGuardians(String studentId) {
    return _repo.loadGuardians(studentId);
  }

  Future<void> addStudent(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
  ]) async {
    final studentToSave = student.copyWith(
      id: student.id.isEmpty ? const Uuid().v4() : student.id,
    );

    await _repo.insertStudentWithSchool(studentToSave, schoolId, guardians);
    await _fetch();
  }

  Future<void> updateStudent(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
  ]) async {
    await _repo.updateStudentWithSchool(student, schoolId, guardians);
    await _fetch();
  }

  Future<void> deleteStudent(String id) async {
    await _repo.deleteStudent(id);
    await _fetch();
  }

  Future<void> goToPage(int pageInt) async {
    _pageable = Pageable(
      page: pageInt,
      size: _pageable.size,
      sorts: _pageable.sorts,
    );

    await _fetch();
  }

  Future<void> nextPage() async {
    _pageable = Pageable(
      page: _pageable.page + 1,
      size: _pageable.size,
      sorts: _pageable.sorts,
    );

    await _fetch();
  }
}
