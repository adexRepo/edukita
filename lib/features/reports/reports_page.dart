import 'dart:io' as io;

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/report_definitions/data/report_definition_model.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_cubit.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/presentation/authorization_helpers.dart';
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
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;

  bool get _canViewReports =>
      _authScope.canView(AppMenuAccessRegistry.reports.code);
  bool get _canExportReports =>
      _authScope.can(AppMenuAccessRegistry.reports.code, AppPermissionAction.export);

  @override
  void initState() {
    super.initState();
    _loadAuthorizationAndReports();
  }

  Future<void> _loadAuthorizationAndReports() async {
    final scope = await loadCurrentAuthorizationScope();
    if (!mounted) return;
    setState(() {
      _authScope = scope;
      _authorizationLoaded = true;
    });
    if (!scope.canView(AppMenuAccessRegistry.reports.code)) return;
    final cubit = context.read<ReportDefinitionCubit>();
    if (cubit.state.definitions.isEmpty && !cubit.state.isLoading) {
      await cubit.loadDefinitions();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authorizationLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_canViewReports) {
      return AccessDeniedPanel(
        message: context.l10n.noPermissionViewReports,
      );
    }

    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BlocBuilder<ReportDefinitionCubit, ReportDefinitionState>(
            buildWhen: (previous, current) {
              return previous.selectedDefinition?.id !=
                      current.selectedDefinition?.id ||
                  previous.resultRows.length != current.resultRows.length ||
                  previous.isLoading != current.isLoading ||
                  previous.isRunning != current.isRunning;
            },
            builder: (context, state) {
              final selected = state.selectedDefinition;
              return AppPageHeader(
                title: context.l10n.menuReports,
                subtitle: selected == null
                    ? context.l10n.reportsChooseDefinition
                    : context.l10n.reportRowsLoaded(
                        selected.name,
                        state.resultRows.length,
                      ),
                trailing: _buildHeaderActions(context, state),
              );
            },
          ),
          BlocSelector<ReportDefinitionCubit, ReportDefinitionState, bool>(
            selector: (state) => state.isLoading,
            builder: (context, isLoading) {
              return AppLoadingStrip(isLoading: isLoading);
            },
          ),
          const SizedBox(height: AppPageHeaderStyle.bottomGap),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 280,
                  child:
                      BlocBuilder<
                        ReportDefinitionCubit,
                        ReportDefinitionState
                      >(
                        buildWhen: (previous, current) {
                          return previous.definitions != current.definitions ||
                              previous.selectedDefinition?.id !=
                                  current.selectedDefinition?.id ||
                              previous.isLoading != current.isLoading;
                        },
                        builder: _buildReportList,
                      ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child:
                      BlocBuilder<
                        ReportDefinitionCubit,
                        ReportDefinitionState
                      >(
                        buildWhen: (previous, current) {
                          return previous.selectedDefinition?.id !=
                                  current.selectedDefinition?.id ||
                              previous.resultRows != current.resultRows ||
                              previous.isRunning != current.isRunning ||
                              previous.runError != current.runError;
                        },
                        builder: _buildReportPreview,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          tooltip: context.l10n.refreshReports,
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
          label: Text(context.l10n.run),
        ),
        OutlinedButton.icon(
          onPressed: state.resultRows.isEmpty || !_canExportReports
              ? null
              : () => _exportExcel(context, state),
          icon: const Icon(Icons.download_outlined, size: 17),
          label: Text(context.l10n.exportExcel),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Text(
              context.l10n.availableReports,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: TextField(
              onChanged: (value) => setState(() => _reportSearchQuery = value),
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
                hintText: context.l10n.searchCodeOrName,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: activeDefinitions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        context.l10n.noActiveReportSettings,
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
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Text(
                            context.l10n.noReportsMatchSearch,
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
        title: context.l10n.selectReport,
        message: context.l10n.selectReportMessage,
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
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, size: 18),
                      hintText: context.l10n.searchLoadedRows,
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
              child: Stack(
                children: [
                  Positioned.fill(
                    child: state.resultRows.isEmpty
                        ? _EmptyReportPanel(
                            title: context.l10n.noDataLoaded,
                            message: context.l10n.clickRunReportPreview,
                            compact: true,
                          )
                        : AppTable<Map<String, Object?>>(
                            data: rows,
                            columns: columns,
                            emptyMessage: context.l10n.noRowsMatchSearch,
                            pageable: Pageable(
                              page: 0,
                              size: rows.length,
                              totalPages: rows.isEmpty ? 0 : 1,
                              totalItems: rows.length,
                            ),
                          ),
                  ),
                  if (state.isRunning)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _runReport(BuildContext context) async {
    final cubit = context.read<ReportDefinitionCubit>();
    final failedTitle = context.l10n.failedRunReport;
    try {
      await cubit.runSelectedReport();
    } catch (e) {
      if (!context.mounted) return;
      showErrorToastWithDetails(
        context,
        title: failedTitle,
        error: e,
      );
    }
  }

  Future<void> _exportExcel(
    BuildContext context,
    ReportDefinitionState state,
  ) async {
    if (!_canExportReports) {
      AppToast.showFailed(context.l10n.noPermissionExportReports);
      return;
    }
    final selected = state.selectedDefinition;
    if (selected == null || state.resultRows.isEmpty) return;

    final columns = _exportColumns(selected, state.resultRows);
    final rows = _filteredRows(state.resultRows);
    final suggestedName = _safeFileName(selected.fileNamePattern);
    final successMessage = context.l10n.reportExported;
    final failedTitle = context.l10n.failedExportReport;
    final excelHtml = _excelHtml(
      selected,
      columns,
      rows,
      reportCodeLabel: context.l10n.reportCode,
      descriptionLabel: context.l10n.description,
      exportedAtLabel: context.l10n.exportedAt,
      totalRowsLabel: context.l10n.totalRows,
    );
    final location = await getSaveLocation(
      suggestedName: generatedFileName('$suggestedName.xls'),
      acceptedTypeGroups: const [
        XTypeGroup(label: 'Excel file', extensions: ['xls']),
      ],
    );
    if (location == null) return;

    try {
      await io.File(location.path).writeAsString(
        excelHtml,
        flush: true,
      );
      AppToast.showSuccess(successMessage);
    } catch (e) {
      if (!context.mounted) return;
      showErrorToastWithDetails(
        context,
        title: failedTitle,
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

  String _excelHtml(
    ReportDefinition definition,
    List<ReportColumnDefinition> columns,
    List<Map<String, Object?>> rows,
    {
    required String reportCodeLabel,
    required String descriptionLabel,
    required String exportedAtLabel,
    required String totalRowsLabel,
  }) {
    final exportedAt = _formatDateTime(DateTime.now());
    final description = definition.description?.trim();
    final buffer = StringBuffer()
      ..writeln('<html>')
      ..writeln('<head>')
      ..writeln('<meta charset="utf-8">')
      ..writeln('<style>')
      ..writeln('body{font-family:Calibri,Arial,sans-serif;color:#1F2937;}')
      ..writeln('table{border-collapse:collapse;width:100%;}')
      ..writeln(
        '.title{font-size:20px;font-weight:700;color:#1F2937;text-align:left;}',
      )
      ..writeln('.meta-label{font-weight:700;color:#6B7280;width:140px;}')
      ..writeln('.meta-value{color:#1F2937;}')
      ..writeln(
        'th{background:#48CFCB;color:#FFFFFF;font-weight:700;border:1px solid #2BA7A3;padding:8px;text-align:left;}',
      )
      ..writeln(
        'td{border:1px solid #E5E7EB;padding:7px;vertical-align:top;mso-number-format:"\\@";}',
      )
      ..writeln('tr.alt td{background:#F8FAFB;}')
      ..writeln('.right{text-align:right;}')
      ..writeln('.center{text-align:center;}')
      ..writeln('</style>')
      ..writeln('</head>')
      ..writeln('<body>')
      ..writeln('<table>')
      ..writeln(
        '<tr><td class="title" colspan="${columns.length.clamp(1, 99)}">${_html(definition.name)}</td></tr>',
      )
      ..writeln(
        '<tr><td class="meta-label">${_html(reportCodeLabel)}</td><td class="meta-value" colspan="${(columns.length - 1).clamp(1, 98)}">${_html(definition.code)}</td></tr>',
      );

    if (description != null && description.isNotEmpty) {
      buffer.writeln(
        '<tr><td class="meta-label">${_html(descriptionLabel)}</td><td class="meta-value" colspan="${(columns.length - 1).clamp(1, 98)}">${_html(description)}</td></tr>',
      );
    }

    buffer
      ..writeln(
        '<tr><td class="meta-label">${_html(exportedAtLabel)}</td><td class="meta-value" colspan="${(columns.length - 1).clamp(1, 98)}">${_html(exportedAt)}</td></tr>',
      )
      ..writeln(
        '<tr><td class="meta-label">${_html(totalRowsLabel)}</td><td class="meta-value" colspan="${(columns.length - 1).clamp(1, 98)}">${rows.length}</td></tr>',
      )
      ..writeln('<tr></tr>')
      ..writeln('<tr>');

    for (final column in columns) {
      buffer.writeln(
        '<th style="width:${column.width}px">${_html(column.label)}</th>',
      );
    }
    buffer.writeln('</tr>');

    for (var index = 0; index < rows.length; index++) {
      final row = rows[index];
      buffer.writeln('<tr${index.isOdd ? ' class="alt"' : ''}>');
      for (final column in columns) {
        final alignClass = switch (column.align) {
          'right' => ' class="right"',
          'center' => ' class="center"',
          _ => '',
        };
        buffer.writeln(
          '<td$alignClass>${_html(_formatValue(row[column.field]))}</td>',
        );
      }
      buffer.writeln('</tr>');
    }

    buffer
      ..writeln('</table>')
      ..writeln('</body>')
      ..writeln('</html>');

    return buffer.toString();
  }

  String _html(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .replaceAll('\n', '<br>');
  }

  String _formatDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
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
