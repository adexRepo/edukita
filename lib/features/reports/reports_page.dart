import 'dart:io' as io;

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/report_definitions/data/report_definition_model.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _reportSearchQuery = '';
  String _rowSearchQuery = '';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReportDefinitionCubit>();
    if (cubit.state.definitions.isEmpty && !cubit.state.isLoading) {
      cubit.loadDefinitions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportDefinitionCubit, ReportDefinitionState>(
      builder: (context, state) {
        final selected = state.selectedDefinition;
        return Padding(
          padding: AppPageHeaderStyle.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: 'Reports',
                subtitle: selected == null
                    ? 'Choose a report definition to preview and export data.'
                    : '${selected.name} | ${state.resultRows.length} rows loaded',
                trailing: _buildHeaderActions(context, state),
              ),
              AppLoadingStrip(isLoading: state.isLoading || state.isRunning),
              const SizedBox(height: AppPageHeaderStyle.bottomGap),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 280, child: _buildReportList(context, state)),
                    const SizedBox(width: 14),
                    Expanded(child: _buildReportPreview(context, state)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderActions(
    BuildContext context,
    ReportDefinitionState state,
  ) {
    final selected = state.selectedDefinition;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        IconButton(
          tooltip: 'Refresh reports',
          onPressed: state.isLoading
              ? null
              : () => context.read<ReportDefinitionCubit>().loadDefinitions(
                    forceRefresh: true,
                  ),
          icon: const Icon(Icons.refresh),
        ),
        FilledButton.icon(
          onPressed: selected == null || state.isRunning
              ? null
              : () => _runReport(context),
          icon: const Icon(Icons.play_arrow_outlined, size: 17),
          label: const Text('Run'),
        ),
        OutlinedButton.icon(
          onPressed: state.resultRows.isEmpty
              ? null
              : () => _exportCsv(context, state),
          icon: const Icon(Icons.download_outlined, size: 17),
          label: const Text('Export CSV'),
        ),
      ],
    );
  }

  Widget _buildReportList(BuildContext context, ReportDefinitionState state) {
    final activeDefinitions = state.definitions
        .where((definition) => definition.isActive)
        .toList();
    final definitions = _filteredDefinitions(activeDefinitions);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              'Available Reports',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextField(
              onChanged: (value) => setState(() => _reportSearchQuery = value),
              decoration: const InputDecoration(
                isDense: true,
                prefixIcon: Icon(Icons.search, size: 18),
                hintText: 'Search code or name',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: activeDefinitions.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        'No active report settings. Add reports from Parameter > System > Reports.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  )
                : definitions.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: Text(
                            'No reports match your search.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ),
                      )
                : ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: definitions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final definition = definitions[index];
                      final selected =
                          state.selectedDefinition?.id == definition.id;
                      return _ReportListTile(
                        definition: definition,
                        selected: selected,
                        onTap: () {
                          setState(() => _rowSearchQuery = '');
                          context
                              .read<ReportDefinitionCubit>()
                              .selectDefinition(definition);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<ReportDefinition> _filteredDefinitions(
    List<ReportDefinition> definitions,
  ) {
    final query = _reportSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return definitions;
    return definitions.where((definition) {
      return definition.code.toLowerCase().contains(query) ||
          definition.name.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildReportPreview(
    BuildContext context,
    ReportDefinitionState state,
  ) {
    final selected = state.selectedDefinition;
    if (selected == null) {
      return _EmptyReportPanel(
        title: 'Select Report',
        message: 'Choose a report from the left panel to preview its data.',
      );
    }

    final rows = _filteredRows(state.resultRows);
    final columns = _visibleColumns(selected, state.resultRows);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selected.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        selected.description?.trim().isNotEmpty == true
                            ? selected.description!
                            : selected.code,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 260,
                  child: TextField(
                    onChanged: (value) =>
                        setState(() => _rowSearchQuery = value),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search, size: 18),
                      hintText: 'Search loaded rows',
                    ),
                  ),
                ),
              ],
            ),
            if (state.runError != null) ...[
              const SizedBox(height: 10),
              _ErrorBanner(error: state.runError!),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: state.resultRows.isEmpty
                  ? _EmptyReportPanel(
                      title: 'No Data Loaded',
                      message:
                          'Click Run to execute this report and show the preview.',
                      compact: true,
                    )
                  : AppTable<Map<String, Object?>>(
                      data: rows,
                      columns: columns,
                      emptyMessage: 'No rows match the current search',
                      pageable: Pageable(
                        page: 0,
                        size: rows.length,
                        totalPages: rows.isEmpty ? 0 : 1,
                        totalItems: rows.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runReport(BuildContext context) async {
    try {
      await context.read<ReportDefinitionCubit>().runSelectedReport();
    } catch (e) {
      if (!context.mounted) return;
      showErrorToastWithDetails(
        context,
        title: 'Failed to run report',
        error: e,
      );
    }
  }

  Future<void> _exportCsv(
    BuildContext context,
    ReportDefinitionState state,
  ) async {
    final selected = state.selectedDefinition;
    if (selected == null || state.resultRows.isEmpty) return;

    final columns = _exportColumns(selected, state.resultRows);
    final rows = _filteredRows(state.resultRows);
    final suggestedName = _safeFileName(selected.fileNamePattern);
    final location = await getSaveLocation(
      suggestedName: '$suggestedName.csv',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV file', extensions: ['csv']),
      ],
    );
    if (location == null) return;

    try {
      final buffer = StringBuffer();
      buffer.writeln(columns.map((column) => _csvCell(column.label)).join(','));
      for (final row in rows) {
        buffer.writeln(
          columns
              .map((column) => _csvCell(_formatValue(row[column.field])))
              .join(','),
        );
      }
      await io.File(location.path).writeAsString(buffer.toString(), flush: true);
      AppToast.showSuccess('Report exported.');
    } catch (e) {
      if (!context.mounted) return;
      showErrorToastWithDetails(
        context,
        title: 'Failed to export report',
        error: e,
      );
    }
  }

  List<Map<String, Object?>> _filteredRows(List<Map<String, Object?>> rows) {
    final query = _rowSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return rows;
    return rows.where((row) {
      return row.values.any(
        (value) => value?.toString().toLowerCase().contains(query) ?? false,
      );
    }).toList();
  }

  List<AppTableColumn<Map<String, Object?>>> _visibleColumns(
    ReportDefinition definition,
    List<Map<String, Object?>> rows,
  ) {
    final columns = _displayColumns(definition, rows);
    return columns.map((column) {
      return AppTableColumn<Map<String, Object?>>(
        title: column.label,
        flex: 1,
        minWidth: column.width,
        cell: (row) => Align(
          alignment: _alignmentFor(column.align),
          child: Text(
            _formatValue(row[column.field]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: _textAlignFor(column.align),
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
        ),
      );
    }).toList();
  }

  List<ReportColumnDefinition> _displayColumns(
    ReportDefinition definition,
    List<Map<String, Object?>> rows,
  ) {
    final configured = definition.columns
        .where((column) => column.visible && !column.missing)
        .toList();
    if (configured.isNotEmpty) return configured;
    if (rows.isEmpty) return const <ReportColumnDefinition>[];
    return rows.first.keys.map(ReportColumnDefinition.fromField).toList();
  }

  List<ReportColumnDefinition> _exportColumns(
    ReportDefinition definition,
    List<Map<String, Object?>> rows,
  ) {
    final configured = definition.columns
        .where((column) => column.export && !column.missing)
        .toList();
    if (configured.isNotEmpty) return configured;
    if (rows.isEmpty) return const <ReportColumnDefinition>[];
    return rows.first.keys.map(ReportColumnDefinition.fromField).toList();
  }

  Alignment _alignmentFor(String align) {
    return switch (align) {
      'right' => Alignment.centerRight,
      'center' => Alignment.center,
      _ => Alignment.centerLeft,
    };
  }

  TextAlign _textAlignFor(String align) {
    return switch (align) {
      'right' => TextAlign.right,
      'center' => TextAlign.center,
      _ => TextAlign.left,
    };
  }

  String _formatValue(Object? value) {
    if (value == null) return '-';
    final text = value.toString();
    return text.trim().isEmpty ? '-' : text;
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _safeFileName(String pattern) {
    final now = DateTime.now();
    final replaced = pattern
        .replaceAll('{year}', now.year.toString())
        .replaceAll('{month}', now.month.toString().padLeft(2, '0'))
        .replaceAll('{day}', now.day.toString().padLeft(2, '0'));
    final safe = replaced
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '-')
        .replaceAll(RegExp(r'\s+'), '-')
        .toLowerCase();
    return safe.trim().isEmpty ? 'report' : safe;
  }
}

class _ReportListTile extends StatelessWidget {
  const _ReportListTile({
    required this.definition,
    required this.selected,
    required this.onTap,
  });

  final ReportDefinition definition;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.24)
                : AppColors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.summarize_outlined,
              size: 18,
              color: selected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    definition.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    definition.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReportPanel extends StatelessWidget {
  const _EmptyReportPanel({
    required this.title,
    required this.message,
    this.compact = false,
  });

  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(compact ? 18 : 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bar_chart_outlined,
                size: compact ? 28 : 38,
                color: AppColors.primaryDark,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        border: Border.all(color: AppColors.errorAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.errorDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
