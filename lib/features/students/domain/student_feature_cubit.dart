import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/domain/student_repository.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class StudentPageCubit extends Cubit<FeatureState<StudentPageData>> {
  final StudentRepository _repo;
  final StudentCacheService _cacheService;

  StudentFilter _filter = const StudentFilter();
  Pageable _pageable = const Pageable(page: 0, size: 20);

  StudentPageCubit(this._repo, this._cacheService)
    : super(const FeatureState());

  void _safeEmit(FeatureState<StudentPageData> nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> init() async {
    _filter = const StudentFilter();
    await _fetch();
  }

  Future<void> _fetch({bool forceRefresh = false}) async {
    final cacheKey = _cacheKey(_filter, _pageable);
    if (!forceRefresh) {
      final cachedData = _cacheService.getPage(cacheKey);
      if (cachedData != null) {
        _safeEmit(FeatureState<StudentPageData>(
          data: cachedData,
          loading: false,
        ));
        return;
      }
    }

    _safeEmit(state.copyWith(loading: true, data: null));

    try {
      final result = await _repo.loadItems(_filter, _pageable);
      _cacheService.putPage(cacheKey, result);

      _safeEmit(state.copyWith(data: result, loading: false));
    } catch (e) {
      _safeEmit(
        state.copyWith(loading: false, message: e.toString(), data: null),
      );
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

  Future<StudentAdvancedFormData> loadAdvancedFormData(String studentId) {
    return _repo.loadAdvancedFormData(studentId);
  }

  Future<StudentSiblingLookupResult?> lookupSiblingFamily(String lookup) {
    return _repo.lookupSiblingFamily(lookup);
  }

  Future<void> addStudent(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
    StudentAdvancedFormData advanced = const StudentAdvancedFormData(),
  ]) async {
    final studentToSave = student.copyWith(
      id: student.id.isEmpty ? const Uuid().v4() : student.id,
    );

    await _repo.insertStudentWithSchool(
      studentToSave,
      schoolId,
      guardians,
      advanced,
    );
    _cacheService.clear();
    await _fetch(forceRefresh: true);
  }

  Future<void> updateStudent(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
    StudentAdvancedFormData advanced = const StudentAdvancedFormData(),
  ]) async {
    await _repo.updateStudentWithSchool(student, schoolId, guardians, advanced);
    _cacheService.clear();
    await _fetch(forceRefresh: true);
  }

  Future<void> deleteStudent(String id) async {
    await _repo.deleteStudent(id);
    _cacheService.clear();
    await _fetch(forceRefresh: true);
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

  String _cacheKey(StudentFilter filter, Pageable pageable) {
    return [
      _listKey(filter.keyword),
      _listKey(filter.keywordNot),
      _listKey(filter.status),
      _listKey(filter.statusNot),
      _listKey(filter.classNames),
      _listKey(filter.classNamesNot),
      _listKey(filter.schoolNames),
      _listKey(filter.schoolNamesNot),
      _listKey(filter.joinAt),
      _listKey(filter.joinAtNot),
      _listKey(filter.scores.map((value) => value.toString())),
      _listKey(filter.scoresNot.map((value) => value.toString())),
      _listKey(filter.ages.map((value) => value.toString())),
      _listKey(filter.agesNot.map((value) => value.toString())),
      _listKey(filter.genders),
      _listKey(filter.gendersNot),
      pageable.page.toString(),
      pageable.size.toString(),
      pageable.sorts.map((sort) => sort.toSql()).join(','),
    ].join('|');
  }

  String _listKey(Iterable<String> values) => values.join(',');
}

class StudentCacheService {
  StudentCacheService({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _StudentPageCacheEntry> _pages = {};
  final Map<String, _StudentDetailCacheEntry> _details = {};

  StudentPageData? getPage(String key) {
    final entry = _pages[key];
    if (entry == null) return null;
    if (_isExpired(entry.cachedAt)) {
      _pages.remove(key);
      return null;
    }
    return entry.data;
  }

  void putPage(String key, StudentPageData data) {
    _pages[key] = _StudentPageCacheEntry(
      data: data,
      cachedAt: DateTime.now(),
    );
  }

  StudentDetailData? getDetail(String studentId) {
    final entry = _details[studentId];
    if (entry == null) return null;
    if (_isExpired(entry.cachedAt)) {
      _details.remove(studentId);
      return null;
    }
    return entry.data;
  }

  void putDetail(String studentId, StudentDetailData data) {
    _details[studentId] = _StudentDetailCacheEntry(
      data: data,
      cachedAt: DateTime.now(),
    );
  }

  void clear() {
    _pages.clear();
    _details.clear();
  }

  bool _isExpired(DateTime cachedAt) {
    return DateTime.now().difference(cachedAt) > ttl;
  }
}

class _StudentPageCacheEntry {
  const _StudentPageCacheEntry({required this.data, required this.cachedAt});

  final StudentPageData data;
  final DateTime cachedAt;
}

class _StudentDetailCacheEntry {
  const _StudentDetailCacheEntry({required this.data, required this.cachedAt});

  final StudentDetailData data;
  final DateTime cachedAt;
}
