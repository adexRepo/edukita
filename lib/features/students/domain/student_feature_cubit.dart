import 'package:edukita/core/cache/app_memory_cache.dart';
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
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class StudentPageCubit extends Cubit<FeatureState<StudentPageData>> {
  final StudentRepository _repo;
  final StudentCacheService _cacheService;

  StudentFilter _filter = const StudentFilter();
  Pageable _pageable = const Pageable(page: 0, size: 20);
  int _requestRevision = 0;

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
    final requestRevision = ++_requestRevision;
    final filter = _filter;
    final pageable = _pageable;
    final cacheKey = _cacheKey(filter, pageable);
    if (!forceRefresh) {
      final cachedData = _cacheService.getPage(cacheKey);
      if (cachedData != null) {
        if (requestRevision != _requestRevision) return;
        _safeEmit(FeatureState<StudentPageData>(
          data: cachedData,
          loading: false,
        ));
        return;
      }
    }

    _safeEmit(state.copyWith(loading: true, data: null));

    try {
      final result = await _repo.loadItems(filter, pageable);
      _cacheService.putPage(cacheKey, result);
      if (requestRevision != _requestRevision) return;

      _safeEmit(state.copyWith(data: result, loading: false));
    } catch (e) {
      if (requestRevision != _requestRevision) return;
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

  Future<List<TeachingLocation>> loadAvailableTeachingLocations() {
    return _repo.loadAvailableTeachingLocations();
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

  Future<void> addQuickStudent(Student student, String schoolId) async {
    final studentToSave = student.copyWith(
      id: student.id.isEmpty ? const Uuid().v4() : student.id,
      profileStatus: 'quick_registered',
    );

    await _repo.insertQuickStudentWithSchool(studentToSave, schoolId);
    _cacheService.clear();
    await _fetch(forceRefresh: true);
  }

  Future<void> updateStudent(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
    StudentAdvancedFormData advanced = const StudentAdvancedFormData(),
  ]) async {
    await _repo.updateStudentWithSchool(
      student.copyWith(profileStatus: 'complete'),
      schoolId,
      guardians,
      advanced,
    );
    _cacheService.clear();
    await _fetch(forceRefresh: true);
  }

  Future<void> setStudentActiveStatus(String id, bool active) async {
    await _repo.setStudentActiveStatus(id, active);
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
      _listKey(filter.namesEqual),
      _listKey(filter.namesContains),
      _listKey(filter.namesNot),
      _listKey(filter.studentIdsEqual),
      _listKey(filter.studentIdsContains),
      _listKey(filter.studentIdsNot),
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
      _listKey(filter.duafaStatuses),
      _listKey(filter.duafaStatusesNot),
      _listKey(filter.teachingLocations),
      _listKey(filter.teachingLocationsNot),
      _listKey(filter.profileStatuses),
      _listKey(filter.profileStatusesNot),
      pageable.page.toString(),
      pageable.size.toString(),
      pageable.sorts.map((sort) => sort.toSql()).join(','),
    ].join('|');
  }

  String _listKey(Iterable<String> values) => values.join(',');
}

class StudentCacheService {
  StudentCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxPageEntries = 4,
    int maxDetailEntries = 3,
  }) : _pages = AppMemoryCache<StudentPageData>(
         ttl: ttl,
         maxEntries: maxPageEntries,
       ),
       _details = AppMemoryCache<StudentDetailData>(
         ttl: ttl,
         maxEntries: maxDetailEntries,
       );

  final AppMemoryCache<StudentPageData> _pages;
  final AppMemoryCache<StudentDetailData> _details;

  StudentPageData? getPage(String key) => _pages.get(key);

  void putPage(String key, StudentPageData data) => _pages.put(key, data);

  StudentDetailData? getDetail(String studentId) => _details.get(studentId);

  void putDetail(String studentId, StudentDetailData data) {
    _details.put(studentId, data);
  }

  void clear() {
    _pages.clear();
    _details.clear();
  }
}
