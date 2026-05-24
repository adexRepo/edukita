part of 'report_definition_cubit.dart';

class ReportDefinitionState {
  const ReportDefinitionState({
    this.definitions = const [],
    this.selectedDefinition,
    this.resultRows = const [],
    this.isLoading = false,
    this.isRunning = false,
    this.error,
    this.runError,
    this.query = '',
    this.isActive,
  });

  final List<ReportDefinition> definitions;
  final ReportDefinition? selectedDefinition;
  final List<Map<String, Object?>> resultRows;
  final bool isLoading;
  final bool isRunning;
  final String? error;
  final String? runError;
  final String query;
  final bool? isActive;

  bool get hasFilters => query.trim().isNotEmpty || isActive != null;

  ReportDefinitionState copyWith({
    List<ReportDefinition>? definitions,
    ReportDefinition? selectedDefinition,
    bool clearSelectedDefinition = false,
    List<Map<String, Object?>>? resultRows,
    bool? isLoading,
    bool? isRunning,
    String? error,
    String? runError,
    String? query,
    bool? isActive,
    bool clearStatus = false,
  }) {
    return ReportDefinitionState(
      definitions: definitions ?? this.definitions,
      selectedDefinition: clearSelectedDefinition
          ? null
          : selectedDefinition ?? this.selectedDefinition,
      resultRows: resultRows ?? this.resultRows,
      isLoading: isLoading ?? this.isLoading,
      isRunning: isRunning ?? this.isRunning,
      error: error,
      runError: runError,
      query: query ?? this.query,
      isActive: clearStatus ? null : isActive ?? this.isActive,
    );
  }
}
