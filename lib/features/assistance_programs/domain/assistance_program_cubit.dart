import 'package:edukita/features/assistance_programs/data/assistance_program_model.dart';
import 'package:edukita/features/assistance_programs/domain/assistance_program_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'assistance_program_state.dart';

class AssistanceProgramCubit extends Cubit<AssistanceProgramState> {
  AssistanceProgramCubit(this._repository, this._cacheService)
      : super(const AssistanceProgramState());

  final AssistanceProgramRepository _repository;
  final AssistanceProgramCacheService _cacheService;

  void _safeEmit(AssistanceProgramState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadPrograms({bool forceRefresh = false}) async {
    final cacheKey = _cacheKey(state);
    if (!forceRefresh) {
      final cachedState = _cacheService.get(cacheKey);
      if (cachedState != null) {
        _safeEmit(cachedState.copyWith(isLoading: false, error: null));
        return;
      }
    }

    _safeEmit(state.copyWith(isLoading: true, error: null));
    try {
      final programs = await _repository.getPrograms(
        query: state.query,
        category: state.category,
        benefitType: state.benefitType,
        frequency: state.frequency,
        isActive: state.isActive,
      );
      final benefitsByProgramId = await _repository.getBenefitsForPrograms(
        programs.map((program) => program.id),
      );
      final nextState = state.copyWith(
          isLoading: false,
          programs: programs,
          benefitsByProgramId: benefitsByProgramId,
          error: null,
      );
      _cacheService.put(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setSearch(String query) async {
    _safeEmit(state.copyWith(query: query));
    await loadPrograms();
  }

  Future<void> setCategory(AssistanceProgramCategory? category) async {
    _safeEmit(
      state.copyWith(category: category, clearCategory: category == null),
    );
    await loadPrograms();
  }

  Future<void> setBenefitType(AssistanceBenefitType? benefitType) async {
    _safeEmit(
      state.copyWith(
        benefitType: benefitType,
        clearBenefitType: benefitType == null,
      ),
    );
    await loadPrograms();
  }

  Future<void> setFrequency(AssistanceFrequency? frequency) async {
    _safeEmit(
      state.copyWith(
        frequency: frequency,
        clearFrequency: frequency == null,
      ),
    );
    await loadPrograms();
  }

  Future<void> setStatus(bool? isActive) async {
    _safeEmit(
      state.copyWith(isActive: isActive, clearStatus: isActive == null),
    );
    await loadPrograms();
  }

  Future<void> clearFilters() async {
    _safeEmit(
      state.copyWith(
        query: '',
        clearCategory: true,
        clearBenefitType: true,
        clearFrequency: true,
        clearStatus: true,
      ),
    );
    await loadPrograms();
  }

  Future<void> saveProgram(
    AssistanceProgram program, {
    List<AssistanceProgramBenefit>? benefits,
  }) async {
    try {
      await _repository.saveProgram(program, benefits: benefits);
      _cacheService.clear();
      await loadPrograms(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> setActive(AssistanceProgram program, bool isActive) async {
    try {
      await _repository.setActive(program.id, isActive);
      _cacheService.clear();
      await loadPrograms(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  String _cacheKey(AssistanceProgramState state) {
    return [
      state.query.trim().toLowerCase(),
      state.category?.value ?? '',
      state.benefitType?.value ?? '',
      state.frequency?.value ?? '',
      state.isActive?.toString() ?? '',
    ].join('|');
  }
}

class AssistanceProgramCacheService {
  AssistanceProgramCacheService({this.ttl = const Duration(minutes: 2)});

  final Duration ttl;
  final Map<String, _AssistanceProgramCacheEntry> _items = {};

  AssistanceProgramState? get(String key) {
    final entry = _items[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.cachedAt) > ttl) {
      _items.remove(key);
      return null;
    }
    return entry.state;
  }

  void put(String key, AssistanceProgramState state) {
    _items[key] = _AssistanceProgramCacheEntry(
      state: state.copyWith(isLoading: false, error: null),
      cachedAt: DateTime.now(),
    );
  }

  void clear() => _items.clear();
}

class _AssistanceProgramCacheEntry {
  const _AssistanceProgramCacheEntry({
    required this.state,
    required this.cachedAt,
  });

  final AssistanceProgramState state;
  final DateTime cachedAt;
}
