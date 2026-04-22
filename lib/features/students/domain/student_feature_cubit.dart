import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/domain/student_repository.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentPageCubit extends Cubit<FeatureState<StudentPageData>> {
  final StudentRepository repo;

  StudentFilter _filter = const StudentFilter();
  Pageable _pageable = const Pageable(page: 0, size: 20);

  StudentPageCubit(this.repo) : super(const FeatureState()) {
    init();
  }
  Future<void> init() async {
    print("i init called");
    await _fetch();
  }

  Future<void> _fetch() async {
    emit(state.copyWith(loading: true, data: null));

    try {
      final result = await repo.loadItems(_filter, _pageable);

      emit(state.copyWith(data: result, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, message: e.toString(), data: null));
    }
  }

  Future<void> applyFilter(StudentFilter filter) async {
    print("i applyFilter called");

    _filter = filter;
    _pageable = Pageable(page: 0, size: _pageable.size);
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
