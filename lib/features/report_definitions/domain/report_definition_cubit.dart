import 'package:edukita/core/cache/app_memory_cache.dart';
import 'package:edukita/features/report_definitions/data/report_definition_model.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'report_definition_state.dart';

class ReportDefinitionCubit extends Cubit<ReportDefinitionState> {
  ReportDefinitionCubit(this._repository, this._cacheService)
    : super(const ReportDefinitionState());

  final ReportDefinitionRepository _repository;
  final ReportDefinitionCacheService _cacheService;

  void _safeEmit(ReportDefinitionState nextState) {
    if (!isClosed) emit(nextState);
  }

  Future<void> loadDefinitions({bool forceRefresh = false}) async {
    final cacheKey = _definitionCacheKey();
    if (!forceRefresh) {
      final cachedState = _cacheService.getDefinitions(cacheKey);
      if (cachedState != null) {
        _safeEmit(cachedState.copyWith(isLoading: false, error: null));
        return;
      }
    }

    _safeEmit(state.copyWith(isLoading: true, error: null));
    try {
      final definitions = await _repository.getDefinitions(
        query: state.query,
        isActive: state.isActive,
      );
      final selected = _selectedAfterReload(definitions);
      final keepRows = selected != null && selected.id == state.selectedDefinition?.id;
      final nextState = state.copyWith(
        isLoading: false,
        definitions: definitions,
        selectedDefinition: selected,
        clearSelectedDefinition: selected == null,
        resultRows: keepRows ? state.resultRows : const [],
        runError: keepRows ? state.runError : null,
        error: null,
      );
      _cacheService.putDefinitions(cacheKey, nextState);
      _safeEmit(nextState);
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setSearch(String query) async {
    _safeEmit(state.copyWith(query: query));
    await loadDefinitions();
  }

  Future<void> setStatus(bool? isActive) async {
    _safeEmit(state.copyWith(isActive: isActive, clearStatus: isActive == null));
    await loadDefinitions();
  }

  Future<void> clearFilters() async {
    _safeEmit(state.copyWith(query: '', clearStatus: true));
    await loadDefinitions();
  }

  Future<void> saveDefinition(ReportDefinition definition) async {
    try {
      await _repository.saveDefinition(definition);
      _cacheService.clear();
      await loadDefinitions(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> setActive(ReportDefinition definition, bool isActive) async {
    try {
      await _repository.setActive(definition.id, isActive);
      _cacheService.clear();
      await loadDefinitions(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteDefinition(ReportDefinition definition) async {
    try {
      await _repository.deleteDefinition(definition.id);
      _cacheService.clear();
      await loadDefinitions(forceRefresh: true);
    } catch (e) {
      _safeEmit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  void selectDefinition(ReportDefinition definition) {
    _safeEmit(
      state.copyWith(
        selectedDefinition: definition,
        resultRows: const [],
        runError: null,
      ),
    );
  }

  Future<void> runSelectedReport() async {
    final definition = state.selectedDefinition;
    if (definition == null) return;
    final cacheKey = _resultCacheKey(definition);
    final cachedRows = _cacheService.getResultRows(cacheKey);
    if (cachedRows != null) {
      _safeEmit(
        state.copyWith(isRunning: false, resultRows: cachedRows, runError: null),
      );
      return;
    }

    _safeEmit(state.copyWith(isRunning: true, runError: null));
    try {
      final rows = await _repository.runReport(definition);
      _cacheService.putResultRows(cacheKey, rows);
      _safeEmit(
        state.copyWith(isRunning: false, resultRows: rows, runError: null),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isRunning: false,
          resultRows: const [],
          runError: e.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<ReportColumnSyncResult> syncColumns({
    required String querySql,
    required List<ReportColumnDefinition> existingColumns,
    bool useDatabasePreview = true,
  }) {
    return _repository.syncColumns(
      querySql: querySql,
      existingColumns: existingColumns,
      useDatabasePreview: useDatabasePreview,
    );
  }

  ReportDefinition? _selectedAfterReload(List<ReportDefinition> definitions) {
    if (definitions.isEmpty) return null;
    final selectedId = state.selectedDefinition?.id;
    if (selectedId == null) return definitions.first;
    return definitions.firstWhere(
      (definition) => definition.id == selectedId,
      orElse: () => definitions.first,
    );
  }

  String _definitionCacheKey() {
    return '${state.query.trim().toLowerCase()}|${state.isActive?.toString() ?? ''}';
  }

  String _resultCacheKey(ReportDefinition definition) {
    return [
      definition.id,
      definition.updatedAt,
      definition.querySql.hashCode.toString(),
    ].join('|');
  }
}

class ReportDefinitionCacheService {
  ReportDefinitionCacheService({
    Duration ttl = const Duration(seconds: 75),
    int maxDefinitionEntries = 3,
    int maxResultEntries = 1,
  }) : _definitionStates = AppMemoryCache<ReportDefinitionState>(
         ttl: ttl,
         maxEntries: maxDefinitionEntries,
       ),
       _resultRows = AppMemoryCache<List<Map<String, Object?>>>(
         ttl: ttl,
         maxEntries: maxResultEntries,
       );

  final AppMemoryCache<ReportDefinitionState> _definitionStates;
  final AppMemoryCache<List<Map<String, Object?>>> _resultRows;

  ReportDefinitionState? getDefinitions(String key) =>
      _definitionStates.get(key);

  void putDefinitions(String key, ReportDefinitionState state) {
    _definitionStates.put(
      key,
      state.copyWith(isLoading: false, isRunning: false, error: null),
    );
  }

  List<Map<String, Object?>>? getResultRows(String key) =>
      _resultRows.get(key);

  void putResultRows(String key, List<Map<String, Object?>> rows) {
    if (rows.length > 200) return;
    _resultRows.put(key, rows);
  }

  void clear() {
    _definitionStates.clear();
    _resultRows.clear();
  }
}
