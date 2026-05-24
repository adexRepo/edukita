import 'package:edukita/features/report_definitions/data/report_definition_model.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'report_definition_state.dart';

class ReportDefinitionCubit extends Cubit<ReportDefinitionState> {
  ReportDefinitionCubit(this._repository) : super(const ReportDefinitionState());

  final ReportDefinitionRepository _repository;

  Future<void> loadDefinitions() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final definitions = await _repository.getDefinitions(
        query: state.query,
        isActive: state.isActive,
      );
      final selected = _selectedAfterReload(definitions);
      final keepRows = selected != null && selected.id == state.selectedDefinition?.id;
      emit(
        state.copyWith(
          isLoading: false,
          definitions: definitions,
          selectedDefinition: selected,
          clearSelectedDefinition: selected == null,
          resultRows: keepRows ? state.resultRows : const [],
          runError: keepRows ? state.runError : null,
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setSearch(String query) async {
    emit(state.copyWith(query: query));
    await loadDefinitions();
  }

  Future<void> setStatus(bool? isActive) async {
    emit(state.copyWith(isActive: isActive, clearStatus: isActive == null));
    await loadDefinitions();
  }

  Future<void> clearFilters() async {
    emit(state.copyWith(query: '', clearStatus: true));
    await loadDefinitions();
  }

  Future<void> saveDefinition(ReportDefinition definition) async {
    try {
      await _repository.saveDefinition(definition);
      await loadDefinitions();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> setActive(ReportDefinition definition, bool isActive) async {
    try {
      await _repository.setActive(definition.id, isActive);
      await loadDefinitions();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteDefinition(ReportDefinition definition) async {
    try {
      await _repository.deleteDefinition(definition.id);
      await loadDefinitions();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      rethrow;
    }
  }

  void selectDefinition(ReportDefinition definition) {
    emit(
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

    emit(state.copyWith(isRunning: true, runError: null));
    try {
      final rows = await _repository.runReport(definition);
      emit(state.copyWith(isRunning: false, resultRows: rows, runError: null));
    } catch (e) {
      emit(
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
}
