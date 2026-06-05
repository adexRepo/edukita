import 'dart:async';

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/assistance/presentation/assistance_localized_display.dart';
import 'package:edukita/features/assistance/programs/data/assistance_program_model.dart';
import 'package:edukita/features/assistance/programs/domain/assistance_program_cubit.dart';
import 'package:edukita/features/assistance/programs/presentation/assistance_program_form_dialog.dart';
import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/presentation/authorization_helpers.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssistanceProgramsPage extends StatefulWidget {
  const AssistanceProgramsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<AssistanceProgramsPage> createState() => _AssistanceProgramsPageState();
}

class _AssistanceProgramsPageState extends State<AssistanceProgramsPage> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;

  bool get _canView =>
      _authScope.canView(AppMenuAccessRegistry.assistancePrograms.code);
  bool get _canCreate =>
      _authScope.canCreate(AppMenuAccessRegistry.assistancePrograms.code);
  bool get _canUpdate =>
      _authScope.canUpdate(AppMenuAccessRegistry.assistancePrograms.code);

  @override
  void initState() {
    super.initState();
    final state = context.read<AssistanceProgramCubit>().state;
    _searchController = TextEditingController(text: state.query);
    _loadAuthorizationAndPrograms();
  }

  Future<void> _loadAuthorizationAndPrograms() async {
    final scope = await loadCurrentAuthorizationScope();
    if (!mounted) return;
    setState(() {
      _authScope = scope;
      _authorizationLoaded = true;
    });
    if (!scope.canView(AppMenuAccessRegistry.assistancePrograms.code)) return;
    final state = context.read<AssistanceProgramCubit>().state;
    if (state.programs.isEmpty && !state.isLoading) {
      await context.read<AssistanceProgramCubit>().loadPrograms();
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
    if (!_authorizationLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_canView) {
      return AccessDeniedPanel(
        message: context.l10n.noPermissionViewAssistancePrograms,
      );
    }

    final content = BlocBuilder<AssistanceProgramCubit, AssistanceProgramState>(
      builder: (context, state) {
        if (state.error != null && state.programs.isEmpty) {
          return Center(
            child: Text(context.l10n.errorWithDetails(state.error!)),
          );
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: pageContent,
          ),
        );
      },
    );

    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.assistanceProgramsTitle)),
      body: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }

  Widget _buildHeader(BuildContext context, AssistanceProgramState state) {
    final cubit = context.read<AssistanceProgramCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(
          title: context.l10n.assistanceProgramsTitle,
          subtitle: context.l10n.assistanceProgramsSubtitle,
          trailing: _canCreate
              ? ElevatedButton.icon(
                  onPressed: () => _openForm(context),
                  icon: const Icon(Icons.add, size: 17),
                  label: Text(context.l10n.addProgram),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => _debouncedSearch(cubit, value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: state.query.trim().isEmpty
                      ? null
                        : IconButton(
                          tooltip: context.l10n.clearSearch,
                          onPressed: () {
                            _searchController.clear();
                            _searchDebounce?.cancel();
                            cubit.setSearch('');
                          },
                          icon: const Icon(Icons.close, size: 18),
                        ),
                  hintText: context.l10n.searchCodeNameDescription,
                ),
              ),
            ),
            SizedBox(
              width: 170,
              child: _filterDropdown<AssistanceProgramCategory>(
                label: context.l10n.category,
                value: state.category,
                values: AssistanceProgramCategory.values,
                labelBuilder: (item) =>
                    translateAssistanceCategory(context, item),
                valueBuilder: (item) => item.value,
                onChanged: cubit.setCategory,
              ),
            ),
            SizedBox(
              width: 170,
              child: _filterDropdown<AssistanceBenefitType>(
                label: context.l10n.benefit,
                value: state.benefitType,
                values: AssistanceBenefitType.values,
                labelBuilder: (item) =>
                    translateAssistanceBenefitType(context, item),
                valueBuilder: (item) => item.value,
                onChanged: cubit.setBenefitType,
              ),
            ),
            SizedBox(
              width: 170,
              child: _filterDropdown<AssistanceFrequency>(
                label: context.l10n.frequency,
                value: state.frequency,
                values: AssistanceFrequency.values,
                labelBuilder: (item) =>
                    translateAssistanceFrequency(context, item),
                valueBuilder: (item) => item.value,
                onChanged: cubit.setFrequency,
              ),
            ),
            SizedBox(
              width: 145,
              child: CommonFormWidgets.dropdownFieldTyped<_StatusFilter>(
                label: context.l10n.status,
                items: _StatusFilter.values,
                labelBuilder: (item) => item.isActive == true
                    ? context.l10n.statusActive
                    : context.l10n.statusInactive,
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
                label: Text(context.l10n.clearSearch),
              ),
          ],
        ),
      ],
    );
  }

  Widget _filterDropdown<T>({
    required String label,
    required T? value,
    required List<T> values,
    required String Function(T value) labelBuilder,
    required String Function(T value) valueBuilder,
    required ValueChanged<T?> onChanged,
  }) {
    return CommonFormWidgets.dropdownFieldTyped<T>(
      label: label,
      items: values,
      labelBuilder: labelBuilder,
      valueBuilder: valueBuilder,
      value: value,
      isRequired: false,
      onChanged: onChanged,
      onSaved: (_) {},
    );
  }

  Widget _buildTable(BuildContext context, AssistanceProgramState state) {
    final programs = state.programs;
    return AppTable<AssistanceProgram>(
      data: programs,
      emptyMessage: context.l10n.noAssistancePrograms,
      deferRowTap: false,
      pageable: Pageable(
        page: 0,
        size: programs.length,
        totalPages: programs.isEmpty ? 0 : 1,
        totalItems: programs.length,
      ),
      onRowTap: _canUpdate
          ? (program) => _openForm(context, program: program)
          : null,
      columns: [
        AppTableColumn(
          title: context.l10n.code,
          flex: 2,
          minWidth: 150,
          sortValue: (program) => _sortValue(program.code),
          cell: (program) => Text(
            program.code,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        AppTableColumn(
          title: context.l10n.name,
          flex: 3,
          minWidth: 180,
          sortValue: (program) => _sortValue(program.name),
          cell: (program) => Text(
            program.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        AppTableColumn(
          title: context.l10n.category,
          flex: 2,
          sortValue: (program) => _sortValue(program.category.label),
          cell: (program) =>
              _pill(translateAssistanceCategory(context, program.category)),
        ),
        AppTableColumn(
          title: context.l10n.benefit,
          flex: 2,
          sortValue: (program) => _sortValue(program.benefitType.label),
          cell: (program) => Text(
            translateAssistanceBenefitType(context, program.benefitType),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: context.l10n.frequency,
          flex: 2,
          sortValue: (program) => _sortValue(program.frequency.label),
          cell: (program) => Text(
            translateAssistanceFrequency(context, program.frequency),
            style: const TextStyle(fontSize: 12),
          ),
        ),
        AppTableColumn(
          title: context.l10n.defaultBenefit,
          flex: 3,
          minWidth: 200,
          sortValue: (program) => _sortValue(program.defaultBenefit),
          cell: (program) => Text(
            _benefitSummary(
              context,
              program,
              state.benefitsByProgramId[program.id] ?? const [],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
        ),
        AppTableColumn(
          title: context.l10n.status,
          flex: 1,
          minWidth: 110,
          sortValue: (program) => program.isActive ? 1 : 0,
          cell: (program) => _pill(
            program.isActive
                ? context.l10n.statusActive
                : context.l10n.statusInactive,
            muted: !program.isActive,
          ),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          flex: 2,
          minWidth: 120,
          cell: (program) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: context.l10n.editProgramTooltip,
                onPressed: _canUpdate
                    ? () => _openForm(context, program: program)
                    : null,
                constraints:
                    const BoxConstraints.tightFor(width: 28, height: 28),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.edit, size: 16),
              ),
              IconButton(
                tooltip: program.isActive
                    ? context.l10n.deactivate
                    : context.l10n.activate,
                onPressed: _canUpdate
                    ? () => _toggleActive(context, program)
                    : null,
                constraints:
                    const BoxConstraints.tightFor(width: 28, height: 28),
                padding: EdgeInsets.zero,
                icon: Icon(
                  program.isActive
                      ? Icons.toggle_on_outlined
                      : Icons.toggle_off_outlined,
                  size: 18,
                  color: program.isActive
                      ? AppColors.primaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _debouncedSearch(AssistanceProgramCubit cubit, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      () => cubit.setSearch(value),
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

  Future<void> _openForm(
    BuildContext context, {
    AssistanceProgram? program,
  }) async {
    if (program == null && !_canCreate) {
      AppToast.showFailed(
        context.l10n.noPermissionCreateAssistancePrograms,
      );
      return;
    }
    if (program != null && !_canUpdate) {
      AppToast.showFailed(
        context.l10n.noPermissionUpdateAssistancePrograms,
      );
      return;
    }
    _searchDebounce?.cancel();
    final cubit = context.read<AssistanceProgramCubit>();
    final benefits = program == null
        ? const <AssistanceProgramBenefit>[]
        : cubit.state.benefitsByProgramId[program.id] ??
              const <AssistanceProgramBenefit>[];
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'assistance_program_form_${program?.id ?? 'new'}',
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AssistanceProgramFormDialog(
          program: program,
          initialBenefits: benefits,
          onSave: (program, benefits) =>
              cubit.saveProgram(program, benefits: benefits),
        ),
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    AssistanceProgram program,
  ) async {
    if (!_canUpdate) {
      AppToast.showFailed(
        context.l10n.noPermissionUpdateAssistancePrograms,
      );
      return;
    }
    final cubit = context.read<AssistanceProgramCubit>();
    final successMessage = program.isActive
        ? context.l10n.assistanceProgramDeactivated
        : context.l10n.assistanceProgramActivated;
    final failedMessage = context.l10n.failedUpdateAssistanceProgramStatus;
    try {
      await cubit.setActive(program, !program.isActive);
      AppToast.showSuccess(successMessage);
    } catch (_) {
      AppToast.showFailed(failedMessage);
    }
  }

  int _sortValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return 0;
    return normalized.codeUnitAt(0);
  }

  String _benefitSummary(
    BuildContext context,
    AssistanceProgram program,
    List<AssistanceProgramBenefit> benefits,
  ) {
    final active = benefits.where((benefit) => benefit.isActive).toList();
    if (active.isEmpty) return program.defaultBenefit;
    return active
        .map(
          (benefit) =>
              '${translateAssistanceSchoolType(context, benefit.schoolType)}: '
              '${benefit.summary}',
        )
        .join('\n');
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
