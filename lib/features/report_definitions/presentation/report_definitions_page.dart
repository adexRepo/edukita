import 'dart:async';

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/report_definitions/data/report_definition_model.dart';
import 'package:edukita/features/report_definitions/domain/report_definition_cubit.dart';
import 'package:edukita/features/report_definitions/presentation/report_definition_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportDefinitionsPage extends StatefulWidget {
  const ReportDefinitionsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ReportDefinitionsPage> createState() => _ReportDefinitionsPageState();
}

class _ReportDefinitionsPageState extends State<ReportDefinitionsPage> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReportDefinitionCubit>();
    _searchController = TextEditingController(text: cubit.state.query);
    if (cubit.state.definitions.isEmpty && !cubit.state.isLoading) {
      cubit.loadDefinitions();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<ReportDefinitionCubit, ReportDefinitionState>(
      builder: (context, state) {
        if (state.error != null && state.definitions.isEmpty) {
          return Center(child: Text('Error: ${state.error}'));
        }

        final pageContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, state),
            AppLoadingStrip(isLoading: state.isLoading, topPadding: 0),
            const SizedBox(height: AppPageHeaderStyle.bottomGap),
            Expanded(child: _buildTable(context, state)),
          ],
        );

        if (widget.embedded) return pageContent;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(padding: const EdgeInsets.all(12), child: pageContent),
        );
      },
    );

    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(title: const Text('Report Settings')),
      body: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }

  Widget _buildHeader(BuildContext context, ReportDefinitionState state) {
    final cubit = context.read<ReportDefinitionCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(
          title: 'Report Settings',
          subtitle:
              'Maintain dynamic report definitions, file names, SQL queries, and column display settings.',
          trailing: ElevatedButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add, size: 17),
            label: const Text('Add Report'),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _debouncedSearch(cubit, value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: state.query.trim().isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _searchController.clear();
                            _searchDebounce?.cancel();
                            cubit.setSearch('');
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                  hintText: 'Search report name, code, description',
                ),
              ),
            ),
            SizedBox(
              width: 145,
              child: CommonFormWidgets.dropdownFieldTyped<_StatusFilter>(
                label: 'Status',
                items: _StatusFilter.values,
                labelBuilder: (item) => item.label,
                valueBuilder: (item) => item.value,
                value: _StatusFilter.fromActive(state.isActive),
                isRequired: false,
                onChanged: (value) => cubit.setStatus(value?.isActive),
                onSaved: (_) {},
              ),
            ),
            if (state.hasFilters)
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _searchDebounce?.cancel();
                  cubit.clearFilters();
                },
                icon: const Icon(Icons.filter_alt_off_outlined, size: 17),
                label: const Text('Clear'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, ReportDefinitionState state) {
    final definitions = state.definitions;
    return AppTable<ReportDefinition>(
      data: definitions,
      emptyMessage: 'No report settings found',
      deferRowTap: false,
      pageable: Pageable(
        page: 0,
        size: definitions.length,
        totalPages: definitions.isEmpty ? 0 : 1,
        totalItems: definitions.length,
      ),
      onRowTap: (definition) => _openForm(context, definition: definition),
      columns: [
        AppTableColumn(
          title: 'Code\nReport Name',
          flex: 2,
          minWidth: 230,
          sortValue: (definition) => _sortValue(definition.code),
          cell: (definition) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                definition.code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                definition.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
        ),
        AppTableColumn(
          title: 'File Name',
          flex: 3,
          minWidth: 300,
          sortValue: (definition) => _sortValue(definition.fileNamePattern),
          cell: (definition) => Text(
            definition.fileNamePattern,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: 'Columns',
          flex: 2,
          minWidth: 120,
          sortValue: (definition) => definition.columns.length,
          cell: (definition) {
            final missing = definition.columns
                .where((column) => column.missing)
                .length;
            return Text(
              missing == 0
                  ? '${definition.columns.length} columns'
                  : '${definition.columns.length} columns, $missing missing',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: missing == 0 ? AppColors.textPrimary : AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        AppTableColumn(
          title: 'Status',
          flex: 1,
          minWidth: 110,
          sortValue: (definition) => definition.isActive ? 1 : 0,
          cell: (definition) => _pill(
            definition.isActive ? 'Active' : 'Inactive',
            muted: !definition.isActive,
          ),
        ),
        AppTableColumn(
          title: 'Actions',
          flex: 2,
          cell: (definition) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit report',
                onPressed: () => _openForm(context, definition: definition),
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, size: 16),
              ),
              IconButton(
                tooltip: definition.isActive ? 'Deactivate' : 'Activate',
                onPressed: () => _toggleActive(context, definition),
                constraints: const BoxConstraints.tightFor(
                  width: 28,
                  height: 28,
                ),
                padding: EdgeInsets.zero,
                icon: Icon(
                  definition.isActive
                      ? Icons.toggle_on_outlined
                      : Icons.toggle_off_outlined,
                  size: 18,
                  color: definition.isActive
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                ),
              ),
              if (!definition.isDefaultSeed)
                IconButton(
                  tooltip: 'Delete report setting',
                  onPressed: () => _confirmDelete(context, definition),
                  constraints: const BoxConstraints.tightFor(
                    width: 28,
                    height: 28,
                  ),
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(String label, {bool muted = false}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: muted
              ? AppColors.surfaceMuted
              : AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: muted ? AppColors.textSecondary : AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  void _debouncedSearch(ReportDefinitionCubit cubit, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      () => cubit.setSearch(value),
    );
  }

  Future<void> _openForm(
    BuildContext context, {
    ReportDefinition? definition,
  }) async {
    _searchDebounce?.cancel();
    final cubit = context.read<ReportDefinitionCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'report_definition_form_${definition?.id ?? 'new'}',
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ReportDefinitionFormDialog(
          definition: definition,
          onSave: cubit.saveDefinition,
        ),
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    ReportDefinition definition,
  ) async {
    final cubit = context.read<ReportDefinitionCubit>();
    try {
      await cubit.setActive(
        definition,
        !definition.isActive,
      );
      if (!context.mounted) return;
      AppToast.showSuccess(
        definition.isActive
            ? 'Report setting deactivated.'
            : 'Report setting activated.',
      );
    } catch (e) {
      if (!context.mounted) return;
      showErrorToastWithDetails(
        context,
        title: 'Failed to update report',
        error: e,
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    ReportDefinition definition,
  ) async {
    final cubit = context.read<ReportDefinitionCubit>();
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_report_definition_${definition.id}',
      builder: (context) => AlertDialog(
        title: const AppDialogTitle('Delete Report Setting'),
        content: Text(
          'Delete ${definition.name}? This removes the report from Parameter and the Reports menu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await cubit.deleteDefinition(definition);
      if (!context.mounted) return;
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.delete,
        subject: 'report setting',
      );
    } catch (e) {
      if (!context.mounted) return;
      showErrorToastWithDetails(
        context,
        title: 'Failed to delete report',
        error: e,
      );
    }
  }

  int _sortValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return 0;
    return normalized.codeUnitAt(0);
  }
}

class _StatusFilter {
  const _StatusFilter(this.label, this.value, this.isActive);

  final String label;
  final String value;
  final bool? isActive;

  static const values = [
    _StatusFilter('Active', 'active', true),
    _StatusFilter('Inactive', 'inactive', false),
  ];

  static _StatusFilter? fromActive(bool? isActive) {
    if (isActive == null) return null;
    return values.firstWhere((item) => item.isActive == isActive);
  }
}
