import 'package:flutter/services.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_desktop_workspace.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/localization/localized_display.dart';
import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:edukita/features/students/persentation/quick_student_form_dialog.dart';
import 'package:edukita/features/students/persentation/student_form_dialog.dart';
import 'package:edukita/features/students/persentation/student_profile_cell.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:edukita/widgets/multi_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class StudentFilterButton extends StatefulWidget {
  const StudentFilterButton({
    super.key,
    required this.title,
    required this.fields,
    required this.onApply,
  });

  final String title;
  final List<FilterField> fields;
  final ValueChanged<List<MultiFilterItem>> onApply;

  @override
  State<StudentFilterButton> createState() => _StudentFilterButtonState();
}

class _StudentFilterButtonState extends State<StudentFilterButton> {
  List<MultiFilterItem> activeFilters = [];

  Future<void> _openFilter() async {
    final targetField = widget.fields.firstWhere(
      (field) => field.code == StudentFilterCodes.duafaStatus.name,
      orElse: () => widget.fields.first,
    );

    final result = await showGuardedDialog<List<MultiFilterItem>>(
      context: context,
      guardKey: 'student_filter_${widget.title}',
      builder: (_) => StudentFilterDialogV2(
        title: widget.title,
        field: targetField,
        fields: widget.fields,
        initialFilters: activeFilters,
      ),
    );

    if (mounted && result != null) {
      setState(() => activeFilters = result);
      widget.onApply(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _openFilter,
      icon: const Icon(Icons.filter_list),
      label: Text(
        activeFilters.isEmpty
            ? context.l10n.filterStudents
            : '${context.l10n.filterStudents} (${activeFilters.length})',
      ),
    );
  }
}

class StudentFilterDialog extends StatelessWidget {
  const StudentFilterDialog({
    super.key,
    required this.title,
    required this.field,
    required this.fields,
    this.initialFilters = const [],
  });
  final String title;
  final FilterField field;
  final List<FilterField> fields;
  final List<MultiFilterItem> initialFilters;
  @override
  Widget build(BuildContext context) => StudentFilterDialogV2(
    title: title,
    field: field,
    fields: fields,
    initialFilters: initialFilters,
  );
}

class StudentFilterDialogV2 extends StatefulWidget {
  const StudentFilterDialogV2({
    super.key,
    required this.title,
    required this.field,
    required this.fields,
    this.initialFilters = const [],
  });

  final String title;
  final FilterField field;
  final List<FilterField> fields;
  final List<MultiFilterItem> initialFilters;

  @override
  State<StudentFilterDialogV2> createState() => _StudentFilterDialogV2State();
}

class _StudentFilterDialogV2State extends State<StudentFilterDialogV2> {
  late FilterField selectedField;
  FilterOperator operator = FilterOperator.isEqual;
  String selectedValue = '';
  late final TextEditingController _valueController;
  late List<MultiFilterItem> draftFilters;

  @override
  void initState() {
    super.initState();
    selectedField = widget.field;
    selectedValue = selectedField.options?.firstOrNull ?? '';
    _valueController = TextEditingController(text: selectedValue);
    draftFilters = [...widget.initialFilters];
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _addFilter() {
    final value = selectedField.options?.isNotEmpty == true
        ? selectedValue
        : _valueController.text.trim();
    if (value.trim().isEmpty) return;

    setState(() {
      draftFilters.add(
        MultiFilterItem(
          fieldCode: selectedField.code,
          label: selectedField.label,
          operator: operator,
          value: value,
        ),
      );
      selectedValue = selectedField.options?.firstOrNull ?? '';
      _valueController.text = selectedValue;
    });
  }

  void _done() {
    Navigator.pop(context, draftFilters);
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputPanel(context),
              const SizedBox(height: AppSpacing.lg),
              _buildActiveFiltersPanel(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.buttonCancel),
        ),
        FilledButton(onPressed: _done, child: Text(context.l10n.done)),
      ],
    );
  }

  Widget _buildInputPanel(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Text(
          context.l10n.field,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: selectedField.code,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: widget.fields
              .map(
                (field) => DropdownMenuItem<String>(
                  value: field.code,
                  child: Text(field.label, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            final field = widget.fields.firstWhere(
              (entry) => entry.code == value,
              orElse: () => widget.field,
            );
            setState(() {
              selectedField = field;
              selectedValue = field.options?.firstOrNull ?? '';
              _valueController.text = selectedValue;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.filterOperator,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _operatorButton(
              '=',
              context.l10n.filterIsEqual,
              FilterOperator.isEqual,
            ),
            _operatorButton(
              '!=',
              context.l10n.filterIsNot,
              FilterOperator.isNot,
            ),
            _operatorButton(
              '~',
              context.l10n.filterContains,
              FilterOperator.contains,
            ),
            _operatorButton(
              '*',
              context.l10n.filterHasAnyValue,
              FilterOperator.hasAnyValue,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          context.l10n.value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (selectedField.options?.isNotEmpty == true)
          DropdownButtonFormField<String>(
            initialValue: selectedValue.isEmpty ? null : selectedValue,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: (selectedField.options ?? []).map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  _displayFilterValue(selectedField.code, option),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedValue = value ?? '';
                _valueController.text = value ?? '';
              });
            },
          )
        else
          TextFormField(
            controller: _valueController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addFilter,
            icon: const Icon(Icons.add),
            label: Text(context.l10n.addFilter),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFiltersPanel() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: AppSpacing.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.l10n.activeFilters,
            style: AppTypography.bodyStrongStyle,
          ),
          TextButton(
            onPressed: draftFilters.isEmpty
                ? null
                : () => setState(() => draftFilters.clear()),
            child: Text(context.l10n.clear),
          ),
        ],
      ),
      if (draftFilters.isEmpty)
        Text(context.l10n.noFiltersYet, style: AppTypography.secondaryStyle),
      for (final (index, filter) in draftFilters.indexed)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            '${filter.label} ${_operatorLabel(filter.operator)} ${_displayFilterValue(filter.fieldCode, filter.value)}',
          ),
          trailing: IconButton(
            tooltip: context.l10n.buttonRemove,
            onPressed: () => setState(() => draftFilters.removeAt(index)),
            icon: const Icon(Icons.close),
          ),
        ),
    ],
  );

  String _operatorLabel(FilterOperator operator) {
    return switch (operator) {
      FilterOperator.isEqual => '=',
      FilterOperator.isNot => '!=',
      FilterOperator.contains => '~',
      FilterOperator.hasAnyValue => '*',
    };
  }

  String _displayFilterValue(String fieldCode, String? value) {
    if (value == null || value.isEmpty) return '-';
    if (fieldCode == StudentFilterCodes.profileStatus.name) {
      return value == 'complete'
          ? context.l10n.profileComplete
          : context.l10n.profileIncomplete;
    }
    if (fieldCode == StudentFilterCodes.gender.name) {
      return translateGender(context, value);
    }
    if (fieldCode == StudentFilterCodes.status.name) {
      return translateStudentStatus(context, value);
    }
    return value;
  }

  Widget _operatorButton(
    String label,
    String description,
    FilterOperator value,
  ) {
    final selected = operator == value;
    return Tooltip(
      message: description,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          backgroundColor: selected ? AppColors.primary : null,
          foregroundColor: selected ? AppColors.white : null,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.greyMedium,
          ),
        ),
        onPressed: () => setState(() => operator = value),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

enum _StudentCreationMode { full, quick }

class _StudentCreationModeDialog extends StatelessWidget {
  const _StudentCreationModeDialog({required this.onSelected});

  final ValueChanged<_StudentCreationMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Text(context.l10n.addStudent),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                minVerticalPadding: AppSpacing.sm,
                leading: const Icon(Icons.person_add_alt_1_outlined),
                title: Text(context.l10n.addFullStudent),
                subtitle: Text(context.l10n.fullStudentDescription),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onSelected(_StudentCreationMode.full),
              ),
              const Divider(),
              ListTile(
                minVerticalPadding: AppSpacing.sm,
                leading: const Icon(Icons.flash_on_outlined),
                title: Text(context.l10n.quickRegisterStudent),
                subtitle: Text(context.l10n.quickRegisterStudentDescription),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onSelected(_StudentCreationMode.quick),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          autofocus: true,
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.buttonCancel),
        ),
      ],
    );
  }
}

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String? sortColumn;
  StudentFilter _filter = const StudentFilter();
  List<MultiFilterItem> _activeFilters = [];
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<TeachingLocation> _teachingLocations = const [];
  bool isAscending = true;
  int? _observedCacheRevision;
  bool _externalRefreshScheduled = false;
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;

  bool get _canViewStudents =>
      _authScope.canView(AppMenuAccessRegistry.students.code);
  bool get _canCreateStudents =>
      _authScope.canCreate(AppMenuAccessRegistry.students.code);
  bool get _canUpdateStudents =>
      _authScope.canUpdate(AppMenuAccessRegistry.students.code);
  bool get _canDeleteStudents =>
      _authScope.canDelete(AppMenuAccessRegistry.students.code);

  @override
  void initState() {
    super.initState();
    _loadAuthorizationAndStudents();
  }

  Future<void> _loadAuthorizationAndStudents() async {
    final session = await AuthSessionCache.instance.read();
    AppAuthorizationScope scope;
    if (session == null || session.isAdmin) {
      scope = AppAuthorizationScope(
        role: AppUserRole.admin,
        permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
          AppUserRole.admin,
        ),
      );
    } else {
      scope = await getIt<UserManagementRepository>()
          .getAuthorizationScopeForUser(session.userId);
    }
    if (!mounted) return;
    setState(() {
      _authScope = scope;
      _authorizationLoaded = true;
    });
    if (!scope.canView(AppMenuAccessRegistry.students.code)) return;
    final cubit = context.read<StudentPageCubit>();
    await cubit.init();
    _observedCacheRevision = cubit.cacheRevision;
    final teachingLocations = await cubit.loadAvailableTeachingLocations();
    if (!mounted) return;
    setState(() => _teachingLocations = teachingLocations);
  }

  void _refreshIfStudentCacheChanged() {
    if (!_authorizationLoaded ||
        !_canViewStudents ||
        _externalRefreshScheduled) {
      return;
    }
    final cubit = context.read<StudentPageCubit>();
    final revision = cubit.cacheRevision;
    if (_observedCacheRevision == null) {
      _observedCacheRevision = revision;
      return;
    }
    if (_observedCacheRevision == revision) return;

    _externalRefreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await cubit.refreshAfterExternalChange();
      if (!mounted) return;
      setState(() {
        _observedCacheRevision = cubit.cacheRevision;
        _externalRefreshScheduled = false;
      });
    });
  }

  void _inquiry() {
    if (!_canViewStudents) return;
    _filter = buildStudentFilter([
      ..._activeFilters,
      if (_searchController.text.trim().isNotEmpty)
        MultiFilterItem(
          fieldCode: StudentFilterCodes.name.name,
          label: context.l10n.name,
          operator: FilterOperator.contains,
          value: _searchController.text.trim(),
        ),
    ]);
    context.read<StudentPageCubit>().applyFilter(_filter);
  }

  Future<void> _showAddStudentDialog() async {
    if (!_canCreateStudents) {
      AppToast.showFailed(context.l10n.studentCreateDenied);
      return;
    }
    final mode = await showGuardedDialog<_StudentCreationMode>(
      context: context,
      guardKey: 'student_creation_mode',
      builder: (dialogContext) => _StudentCreationModeDialog(
        onSelected: (mode) => Navigator.of(dialogContext).pop(mode),
      ),
    );

    if (!mounted || mode == null) return;
    if (mode == _StudentCreationMode.quick) {
      await _showQuickStudentDialog();
      return;
    }
    await _showFullStudentDialog();
  }

  Future<void> _showFullStudentDialog() async {
    await AppActionGuard.run('student_form_load_new', () async {
      final cubit = context.read<StudentPageCubit>();
      final schools = await cubit.loadAvailableSchools();
      final classes = await cubit.loadAvailableClasses();
      final teachingLocations = await cubit.loadAvailableTeachingLocations();
      final studentNo = await cubit.generateStudentNumber();

      if (!mounted) return;

      if (schools.isEmpty) {
        AppToast.showFailed(context.l10n.createSchoolBeforeAddingStudents);
        return;
      }

      if (classes.isEmpty) {
        AppToast.showFailed(context.l10n.createClassBeforeAddingStudents);
        return;
      }

      if (teachingLocations.isEmpty) {
        AppToast.showFailed(context.l10n.createTeachingLocationBeforeStudents);
        return;
      }

      await showGuardedDialog<void>(
        context: context,
        guardKey: 'student_form_new',
        builder: (dialogContext) => StudentFormDialog(
          availableSchools: schools,
          availableClasses: classes,
          availableTeachingLocations: teachingLocations,
          generatedStudentNo: studentNo,
          onSiblingLookup: cubit.lookupSiblingFamily,
          onSubmit: (student, schoolId, guardians, advanced) async {
            await cubit.addStudent(student, schoolId, guardians, advanced);
          },
        ),
      );
    });
  }

  Future<void> _showQuickStudentDialog() async {
    await AppActionGuard.run('student_quick_form_load_new', () async {
      final cubit = context.read<StudentPageCubit>();
      final classes = await cubit.loadQuickRegisterClasses();
      final teachingLocations = await cubit.loadAvailableTeachingLocations();
      final studentNo = await cubit.generateStudentNumber();

      if (!mounted) return;

      if (classes.isEmpty) {
        AppToast.showFailed(context.l10n.createClassBeforeAddingStudents);
        return;
      }

      if (teachingLocations.isEmpty) {
        AppToast.showFailed(context.l10n.createTeachingLocationBeforeStudents);
        return;
      }

      await showGuardedDialog<void>(
        context: context,
        guardKey: 'student_quick_form_new',
        builder: (dialogContext) => QuickStudentFormDialog(
          availableClasses: classes,
          availableTeachingLocations: teachingLocations,
          generatedStudentNo: studentNo,
          onSubmit: (student, schoolId) async {
            await cubit.addQuickStudent(student, schoolId);
          },
        ),
      );
    });
  }

  Future<void> _showEditStudentDialog(StudentTable row) async {
    if (!_canUpdateStudents) {
      AppToast.showFailed(context.l10n.studentUpdateDenied);
      return;
    }
    await AppActionGuard.run('student_form_load_${row.id}', () async {
      final cubit = context.read<StudentPageCubit>();
      final schools = await cubit.loadAvailableSchools();
      final classes = await cubit.loadAvailableClasses();
      final teachingLocations = await cubit.loadAvailableTeachingLocations();
      final student = await cubit.loadStudent(row.id);
      final guardians = await cubit.loadGuardians(row.id);
      final advancedData = await cubit.loadAdvancedFormData(row.id);

      if (!mounted || student == null) return;

      await showGuardedDialog<void>(
        context: context,
        guardKey: 'student_form_${row.id}',
        builder: (dialogContext) => StudentFormDialog(
          availableSchools: schools,
          availableClasses: classes,
          availableTeachingLocations: teachingLocations,
          generatedStudentNo: student.studentId,
          initialStudent: student,
          initialGuardians: guardians,
          initialAdvancedData: advancedData,
          onSiblingLookup: cubit.lookupSiblingFamily,
          onSubmit: (updatedStudent, schoolId, guardians, advanced) async {
            await cubit.updateStudent(
              updatedStudent,
              schoolId,
              guardians,
              advanced,
            );
          },
        ),
      );
    });
  }

  Future<void> _confirmToggleStudentStatus(StudentTable student) async {
    if (!_canDeleteStudents) {
      AppToast.showFailed(context.l10n.studentDeleteDenied);
      return;
    }
    final activate = student.status == StudentStatus.inactive;
    final actionLabel = activate
        ? context.l10n.activate
        : context.l10n.deactivate;
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'toggle_student_status_${student.id}',
      builder: (dialogContext) => AlertDialog(
        title: AppDialogTitle(actionLabel),
        content: Text(
          context.l10n.confirmActionForSubject(actionLabel, student.fullName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<StudentPageCubit>().setStudentActiveStatus(
          student.id,
          activate,
        );
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.update,
          subject: 'student',
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.update,
          subject: 'student',
        );
      }
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    _refreshIfStudentCacheChanged();
    if (!_authorizationLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_canViewStudents) {
      return Scaffold(
        body: Center(
          child: Text(
            context.l10n.studentAccessDenied,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: BlocBuilder<StudentPageCubit, FeatureState<StudentPageData>>(
        builder: (context, state) {
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.keyF, control: true):
                  _searchFocus.requestFocus,
            },
            child: Focus(
              autofocus: true,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: AppDesktopWorkspace(
                  header: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppPageHeader(title: context.l10n.menuStudents),
                      AppLoadingStrip(isLoading: state.loading),
                      const SizedBox(height: AppSpacing.sm),
                      _buildStatsFromState(
                        state.data ?? StudentPageData.empty(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildHeader(),
                      if (state.message != null) _studentError(state),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                  content: _buildTableSection(state),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _studentError(FeatureState<StudentPageData> state) => Wrap(
    spacing: AppSpacing.xs,
    runSpacing: AppSpacing.xs,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        context.l10n.studentsLoadFailed,
        style: AppTypography.bodyStrongStyle,
      ),
      TextButton(
        onPressed: state.loading ? null : _inquiry,
        child: Text(context.l10n.retry),
      ),
      TextButton(
        onPressed: () => showErrorDetailDialog(
          context,
          title: context.l10n.menuStudents,
          error: state.message!,
        ),
        child: Text(context.l10n.detail),
      ),
    ],
  );

  Widget _buildCard(String title, String value) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.panel),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: AppColors.primaryForeground,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: AppTypography.sectionTitle,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _buildStatsFromState(StudentPageData state) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
      final values = [
        (context.l10n.total, state.totalStudents),
        (context.l10n.genderMale, state.maleStudents),
        (context.l10n.genderFemale, state.femaleStudents),
        (context.l10n.statusActive, state.activeStudents),
      ];
      if (constraints.maxWidth / scale < 720) {
        return ExpansionTile(
          title: Text(
            '${context.l10n.total}: ${state.totalStudents}',
            style: AppTypography.bodyStrongStyle,
          ),
          children: [
            for (final item in values) _buildCard(item.$1, item.$2.toString()),
          ],
        );
      }
      final count = (constraints.maxWidth / (220 * scale)).floor().clamp(1, 4);
      final width =
          (constraints.maxWidth - (count - 1) * AppSpacing.sm) / count;
      return Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final item in values)
            SizedBox(
              width: width,
              child: _buildCard(item.$1, item.$2.toString()),
            ),
        ],
      );
    },
  );

  Widget _buildHeader() => LayoutBuilder(
    builder: (context, constraints) {
      final search = TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        onSubmitted: (_) => _inquiry(),
        decoration: InputDecoration(
          labelText: context.l10n.studentsSearchNameHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            tooltip: context.l10n.clear,
            onPressed: () {
              _searchController.clear();
              _inquiry();
            },
            icon: const Icon(Icons.close),
          ),
        ),
      );
      final actions = Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          StudentFilterButton(
            title: context.l10n.filterStudents,
            fields: _studentFilterFields(),
            onApply: (filters) {
              _activeFilters = filters;
              _inquiry();
            },
          ),
          OutlinedButton(
            onPressed: _inquiry,
            child: Text(context.l10n.buttonSearch),
          ),
          if (_canCreateStudents)
            FilledButton.icon(
              onPressed: _showAddStudentDialog,
              icon: const Icon(Icons.add),
              label: Text(context.l10n.addStudent),
            ),
        ],
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: AppSpacing.xs),
          Align(alignment: Alignment.centerRight, child: actions),
        ],
      );
    },
  );

  Widget _buildTableSection(FeatureState<StudentPageData> state) {
    final rows = state.data?.students ?? const <StudentTable>[];
    final byName = [...rows]
      ..sort(
        (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      );
    final byClass = [...rows]
      ..sort(
        (a, b) =>
            a.className.toLowerCase().compareTo(b.className.toLowerCase()),
      );
    final names = {for (final (index, row) in byName.indexed) row.id: index};
    final classes = {for (final (index, row) in byClass.indexed) row.id: index};
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadii.panel),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: AppTable<StudentTable>(
        data: state.data?.students ?? [],
        pageable: state.data?.pageable,
        onRowTap: (item) {
          context.push('/students/${item.id}');
        },
        onPageChanged: (page) =>
            context.read<StudentPageCubit>().goToPage(page),
        columns: [
          AppTableColumn(
            title: context.l10n.studentProfile,
            minWidth: 280,
            flex: 5,
            sortValue: (data) => names[data.id] ?? 0,
            cell: (s) => StudentProfileCell(student: s),
          ),
          AppTableColumn(
            title: context.l10n.classSchool,
            flex: 3,
            sortValue: (data) => classes[data.id] ?? 0,
            cell: (s) => Text(
              '${s.className}\n${s.schoolName}',
              style: const TextStyle(fontSize: 12, height: 1.2),
            ),
          ),
          AppTableColumn(
            title: context.l10n.ageGender,
            flex: 2,
            sortValue: (data) => data.age,
            cell: (s) => Text(
              '${s.age} ${context.l10n.years}\n${translateGender(context, s.gender.name)}',
              style: const TextStyle(fontSize: 12, height: 1.2),
            ),
          ),
          AppTableColumn(
            title:
                '${context.l10n.duafaStatus}\n${context.l10n.studentLocation}',
            flex: 3,
            sortValue: (data) => switch (data.duafaStatus) {
              'Yatim Piatu' => 0,
              'Yatim' => 1,
              'Piatu' => 2,
              _ => 3,
            },
            cell: (s) => Text(
              '${s.duafaStatus}\n${s.teachingLocationName}',
              style: const TextStyle(fontSize: 12, height: 1.2),
            ),
          ),
          AppTableColumn(
            title: context.l10n.profileStatus,
            flex: 2,
            sortValue: (data) => data.profileStatus == 'complete' ? 0 : 1,
            cell: (s) => _profileStatusPill(s.profileStatus),
          ),
          AppTableColumn(
            title: context.l10n.scoreStatus,
            alignment: Alignment.centerRight,
            headerTextAlign: TextAlign.right,
            flex: 2,
            sortValue: (data) => data.averageScore?.round() ?? -1,
            cell: (s) => Text(
              '${s.averageScore?.toStringAsFixed(0) ?? '-'}/100\n${translateStudentStatus(context, s.status.name)}',
              style: const TextStyle(fontSize: 12, height: 1.2),
            ),
          ),
          AppTableColumn(
            title: context.l10n.joinDate,
            flex: 2,
            sortValue: (data) =>
                DateTime.tryParse(data.joinAt)?.millisecondsSinceEpoch ?? 0,
            cell: (s) => Text(s.joinAt, style: const TextStyle(fontSize: 12)),
          ),
          AppTableColumn(
            title: context.l10n.actions,
            minWidth: 128,
            flex: 2,
            cell: (s) => Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: context.l10n.editStudentTooltip,
                    onPressed: _canUpdateStudents
                        ? () => _showEditStudentDialog(s)
                        : null,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit, size: 16),
                  ),
                  IconButton(
                    tooltip: s.status == StudentStatus.inactive
                        ? context.l10n.activate
                        : context.l10n.deactivate,
                    onPressed: _canDeleteStudents
                        ? () => _confirmToggleStudentStatus(s)
                        : null,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      s.status == StudentStatus.inactive
                          ? Icons.person_add_alt_outlined
                          : Icons.person_off_outlined,
                      size: 16,
                      color: s.status == StudentStatus.inactive
                          ? AppColors.primary
                          : AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileStatusPill(String status) {
    final complete = status == 'complete';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: complete
              ? AppColors.success.withValues(alpha: 0.10)
              : AppColors.warning.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: complete
                ? AppColors.success.withValues(alpha: 0.40)
                : AppColors.warning.withValues(alpha: 0.45),
          ),
        ),
        child: Text(
          complete
              ? context.l10n.profileComplete
              : context.l10n.profileIncomplete,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  List<FilterField> _studentFilterFields() {
    final locationNames =
        _teachingLocations
            .map((location) => location.name.trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return [
      FilterField(
        code: StudentFilterCodes.name.name,
        label: context.l10n.name,
        inputType: FilterInputType.text,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return context.l10n.fieldRequiredMessage(context.l10n.name);
          }
          if (value.length < 2) return context.l10n.fullNameMinimumThree;
          return null;
        },
      ),
      FilterField(
        code: StudentFilterCodes.studentId.name,
        label: context.l10n.studentNo,
        inputType: FilterInputType.text,
      ),
      FilterField(
        code: StudentFilterCodes.className.name,
        label: context.l10n.className,
        inputType: FilterInputType.text,
      ),
      FilterField(
        code: StudentFilterCodes.schoolName.name,
        label: context.l10n.school,
        inputType: FilterInputType.text,
      ),
      FilterField(
        code: StudentFilterCodes.age.name,
        label: context.l10n.age,
        inputType: FilterInputType.number,
      ),
      FilterField(
        code: StudentFilterCodes.gender.name,
        label: context.l10n.gender,
        inputType: FilterInputType.dropdown,
        options: [Gender.male.name, Gender.female.name],
      ),
      FilterField(
        code: StudentFilterCodes.score.name,
        label: context.l10n.score,
        inputType: FilterInputType.number,
      ),
      FilterField(
        code: StudentFilterCodes.status.name,
        label: context.l10n.status,
        inputType: FilterInputType.dropdown,
        options: [
          StudentStatus.active.name,
          StudentStatus.warning.name,
          StudentStatus.inactive.name,
        ],
      ),
      FilterField(
        code: StudentFilterCodes.duafaStatus.name,
        label: context.l10n.duafaStatus,
        inputType: FilterInputType.dropdown,
        options: const ['Dhuafa', 'Yatim', 'Piatu', 'Yatim Piatu'],
      ),
      FilterField(
        code: StudentFilterCodes.teachingLocation.name,
        label: context.l10n.studentLocation,
        inputType: locationNames.isEmpty
            ? FilterInputType.text
            : FilterInputType.dropdown,
        options: locationNames.isEmpty ? null : locationNames,
      ),
      FilterField(
        code: StudentFilterCodes.profileStatus.name,
        label: context.l10n.profileStatus,
        inputType: FilterInputType.dropdown,
        options: const ['complete', 'quick_registered'],
      ),
      FilterField(
        code: StudentFilterCodes.joinDate.name,
        label: context.l10n.joinDate,
        inputType: FilterInputType.date,
      ),
    ];
  }
}
