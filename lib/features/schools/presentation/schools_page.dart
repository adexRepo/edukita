import 'package:flutter/services.dart';
import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_inline_error.dart';
import 'package:edukita/widgets/app_desktop_workspace.dart';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/schools/presentation/class_form_dialog.dart';
import 'package:edukita/features/schools/presentation/school_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_dialog_skeleton.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef _SchoolCountsRead = ({Map<String, int>? data, Object? error});

typedef _SchoolClassesRead = ({List<SchoolClass>? data, Object? error});

class SchoolsPage extends StatefulWidget {
  const SchoolsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<SchoolsPage> createState() => _SchoolsPageState();
}

class _SchoolsPageState extends State<SchoolsPage> {
  String _schoolSearchQuery = '';
  final _searchFocus = FocusNode();
  final _searchController = TextEditingController();
  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  late Future<_SchoolCountsRead> _classCountsFuture;
  Map<String, int>? _lastClassCounts;
  int _countReadGeneration = 0;

  @override
  void initState() {
    super.initState();
    context.read<SchoolCubit>().loadSchools();
    _classCountsFuture = _loadClassCounts();
  }

  Future<_SchoolCountsRead> _loadClassCounts() async {
    final generation = ++_countReadGeneration;
    try {
      final allClasses = await context.read<ClassCubit>().getAllClasses();
      final counts = <String, int>{};
      for (final schoolClass in allClasses) {
        final schoolId = schoolClass.schoolId;
        if (schoolId == null || schoolId.isEmpty) continue;
        counts[schoolId] = (counts[schoolId] ?? 0) + 1;
      }
      if (mounted && generation == _countReadGeneration) {
        _lastClassCounts = counts;
      }
      return (data: counts, error: null);
    } catch (error) {
      return (data: _lastClassCounts, error: error);
    }
  }

  Future<void> _refreshClassCounts() async {
    if (!mounted) {
      return;
    }
    setState(() {
      _classCountsFuture = _loadClassCounts();
    });
  }

  Future<void> _showSchoolFormDialog({School? school}) async {
    await AppActionGuard.run(
      'school_form_load_${school?.id ?? 'new'}',
      () async {
        final schoolCubit = context.read<SchoolCubit>();
        final classCubit = context.read<ClassCubit>();
        final isEditing = school != null;
        final classes = isEditing
            ? await classCubit.getClassesBySchool(school.id)
            : <SchoolClass>[];

        if (!mounted) return;

        await showGuardedDialog<void>(
          context: context,
          guardKey: 'school_form_${school?.id ?? 'new'}',
          builder: (context) => SchoolFormDialog(
            school: school,
            initialClasses: classes,
            onSave: (school, classes) async {
              if (isEditing) {
                await schoolCubit.updateSchoolWithClasses(school, classes);
              } else {
                await schoolCubit.addSchoolWithClasses(school, classes);
              }
              await _refreshClassCounts();
            },
          ),
        );
      },
    );
  }

  Future<_SchoolClassesRead> _readClasses(
    ClassCubit cubit,
    String schoolId,
  ) async {
    try {
      return (data: await cubit.getClassesBySchool(schoolId), error: null);
    } catch (error) {
      return (data: null, error: error);
    }
  }

  Future<void> _showClassDialog(School school) async {
    await AppActionGuard.run('school_classes_flow_${school.id}', () async {
      var viewRevision = 0;
      while (true) {
        if (!mounted) return;
        final classCubit = context.read<ClassCubit>();
        final classesFuture = _readClasses(classCubit, school.id);
        final action = await showGuardedDialog<_SchoolClassAction>(
          context: context,
          guardKey: 'school_classes_${school.id}_${viewRevision++}',
          builder: (dialogContext) => FutureBuilder<_SchoolClassesRead>(
            future: classesFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError || snapshot.data?.error != null) {
                return AppDialog(
                  title: AppDialogTitle(
                    context.l10n.classesForSchool(school.name ?? '-'),
                  ),
                  content: SizedBox(
                    width: 720,
                    child: AppInlineError(
                      message: context.l10n.operationFailedTryAgain,
                      onRetry: () => Navigator.of(
                        dialogContext,
                      ).pop(const _SchoolClassAction('retry')),
                      onDetails: () => showErrorDetailDialog(
                        context,
                        title: context.l10n.operationFailedTryAgain,
                        error:
                            snapshot.data?.error ??
                            snapshot.error ??
                            context.l10n.operationFailedTryAgain,
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(context.l10n.close),
                    ),
                  ],
                );
              }
              if (!snapshot.hasData) {
                return AppDialog(
                  title: AppDialogTitle(
                    context.l10n.classesForSchool(school.name ?? '-'),
                  ),
                  content: SizedBox(
                    width: 720,
                    height: _schoolClassesViewportHeight(context),
                    child: const AppDialogSkeleton(rows: 6),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(context.l10n.close),
                    ),
                  ],
                );
              }
              return _SchoolClassesDialog(
                school: school,
                classes: snapshot.data!.data!,
                onAdd: () async {
                  Navigator.of(
                    dialogContext,
                  ).pop(const _SchoolClassAction('add'));
                },
                onEdit: (value) async {
                  Navigator.of(
                    dialogContext,
                  ).pop(_SchoolClassAction('edit', value));
                },
                onDelete: (value) async {
                  Navigator.of(
                    dialogContext,
                  ).pop(_SchoolClassAction('delete', value));
                },
              );
            },
          ),
        );
        if (action == null || !mounted) return;
        switch (action.kind) {
          case 'add':
            await _showClassFormDialog(school: school);
          case 'edit':
            await _showClassFormDialog(
              school: school,
              schoolClass: action.schoolClass,
            );
          case 'delete':
            await _confirmDeleteClass(action.schoolClass!);
        }
      }
    });
  }

  Future<void> _showClassFormDialog({
    required School school,
    SchoolClass? schoolClass,
  }) async {
    final classCubit = context.read<ClassCubit>();

    await showGuardedDialog<void>(
      context: context,
      guardKey: 'class_form_${schoolClass?.id ?? 'new_${school.id}'}',
      builder: (context) => ClassFormDialog(
        schoolClass: schoolClass,
        schoolType: school.type,
        onSave: (value) async {
          final classWithSchool = value.copyWith(schoolId: school.id);
          if (schoolClass == null) {
            await classCubit.addClass(classWithSchool);
          } else {
            await classCubit.updateClass(classWithSchool);
          }
          await _refreshClassCounts();
        },
      ),
    );
  }

  Future<bool> _confirmDeleteClass(SchoolClass schoolClass) async {
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_class_${schoolClass.id}',
      builder: (dialogContext) => AppDialog(
        title: AppDialogTitle(context.l10n.deleteClass),
        content: Text(context.l10n.deleteNamedItem(schoolClass.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorDark,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return false;
    try {
      await context.read<ClassCubit>().deleteClass(schoolClass.id);
      await _refreshClassCounts();
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.delete,
        subject: 'class',
      );
      return true;
    } catch (_) {
      AppToast.showSubmissionFailed(
        action: SubmissionAction.delete,
        subject: 'class',
      );
      return false;
    }
  }

  Future<void> _confirmDeleteSchool(School school) async {
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_school_${school.id}',
      builder: (dialogContext) => AppDialog(
        title: AppDialogTitle(context.l10n.deleteSchool),
        content: Text(
          context.l10n.deleteNamedItem(school.name ?? context.l10n.school),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorDark,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await context.read<SchoolCubit>().deleteSchool(school.id);
      await _refreshClassCounts();
      AppToast.showSubmissionSuccess(
        action: SubmissionAction.delete,
        subject: 'school',
      );
    } catch (_) {
      AppToast.showSubmissionFailed(
        action: SubmissionAction.delete,
        subject: 'school',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<SchoolCubit, SchoolState>(
      builder: (context, state) {
        return Column(
          children: [
            if (!widget.embedded) _buildTopBar(),
            if (!widget.embedded) AppLoadingStrip(isLoading: state.isLoading),
            Expanded(
              child: Padding(
                padding: widget.embedded
                    ? EdgeInsets.zero
                    : const EdgeInsets.all(12),
                child: _buildContent(state),
              ),
            ),
          ],
        );
      },
    );
    if (widget.embedded) return content;
    return Scaffold(body: content);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: AppPageHeaderStyle.pagePadding,
      child: AppPageHeader(
        title: context.l10n.schools,
        subtitle: context.l10n.schoolsSubtitle,
      ),
    );
  }

  Widget _buildContent(SchoolState state) {
    final normalizedQuery = _schoolSearchQuery.trim().toLowerCase();
    final schools = normalizedQuery.isEmpty
        ? state.schools
        : state.schools.where((school) {
            return (school.name ?? '').toLowerCase().contains(normalizedQuery);
          }).toList();

    Map<String, int> ranks(String Function(School) value) {
      final ordered = [...schools]
        ..sort(
          (a, b) => value(a).toLowerCase().compareTo(value(b).toLowerCase()),
        );
      return {for (var i = 0; i < ordered.length; i++) ordered[i].id: i};
    }

    final nameRanks = ranks((value) => value.name ?? ''),
        addressRanks = ranks((value) => value.address ?? '');
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyF, control: true): () =>
            _searchFocus.requestFocus(),
      },
      child: Focus(
        autofocus: true,
        child: AppDesktopWorkspace(
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTableHeader(),
              if (state.error != null)
                AppInlineError(
                  message: context.l10n.operationFailedTryAgain,
                  onRetry: () => context.read<SchoolCubit>().loadSchools(
                    forceRefresh: true,
                  ),
                  onDetails: () => showErrorDetailDialog(
                    context,
                    title: context.l10n.operationFailedTryAgain,
                    error: state.error!,
                  ),
                ),
              if (widget.embedded)
                AppLoadingStrip(isLoading: state.isLoading, topPadding: 0),
              const SizedBox(height: AppPageHeaderStyle.bottomGap),
            ],
          ),
          content: FutureBuilder<_SchoolCountsRead>(
            future: _classCountsFuture,
            builder: (context, snapshot) {
              final classCounts =
                  snapshot.data?.data ??
                  _lastClassCounts ??
                  const <String, int>{};
              return Column(
                children: [
                  if (snapshot.hasError || snapshot.data?.error != null)
                    AppInlineError(
                      message: context.l10n.operationFailedTryAgain,
                      onRetry: _refreshClassCounts,
                      onDetails: () => showErrorDetailDialog(
                        context,
                        title: context.l10n.operationFailedTryAgain,
                        error:
                            snapshot.data?.error ??
                            snapshot.error ??
                            context.l10n.operationFailedTryAgain,
                      ),
                    ),
                  Expanded(
                    child: AppTable<School>(
                      data: schools,
                      pageable: Pageable(
                        page: 0,
                        size: schools.length,
                        totalPages: 1,
                        totalItems: schools.length,
                      ),
                      emptyMessage: state.schools.isEmpty
                          ? context.l10n.noSchoolsYet
                          : context.l10n.noSchoolsMatch,
                      onRowTap: _showClassDialog,
                      columns: [
                        AppTableColumn(
                          title: context.l10n.school,
                          flex: 4,
                          sortValue: (school) => nameRanks[school.id] ?? 0,
                          cell: (school) => Text(
                            school.name ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.type,
                          flex: 2,
                          sortValue: (school) => school.type?.index ?? 0,
                          cell: (school) => Text(
                            school.type?.label ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.address,
                          flex: 4,
                          sortValue: (school) => addressRanks[school.id] ?? 0,
                          cell: (school) => Text(
                            school.address ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.classes,
                          alignment: Alignment.centerRight,
                          headerTextAlign: TextAlign.right,
                          flex: 2,
                          sortValue: (school) => classCounts[school.id] ?? 0,
                          cell: (school) => Text(
                            snapshot.data?.data != null ||
                                    _lastClassCounts != null
                                ? '${classCounts[school.id] ?? 0}'
                                : '-',
                            style: AppTypography.numericStyle,
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.actions,
                          minWidth: 144,
                          flex: 2,
                          cell: (school) => Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: context.l10n.edit,
                                  onPressed: () =>
                                      _showSchoolFormDialog(school: school),
                                  constraints: const BoxConstraints.tightFor(
                                    width: 40,
                                    height: 40,
                                  ),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.edit, size: 16),
                                ),
                                IconButton(
                                  tooltip: context.l10n.delete,
                                  onPressed: () => _confirmDeleteSchool(school),
                                  constraints: const BoxConstraints.tightFor(
                                    width: 40,
                                    height: 40,
                                  ),
                                  padding: EdgeInsets.zero,
                                  color: AppColors.errorDark,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth /
                (MediaQuery.textScalerOf(context).scale(12) / 12) <
            1000;
        final search = TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: (value) {
            setState(() {
              _schoolSearchQuery = value;
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: context.l10n.searchSchoolName,
          ),
        );
        final addButton = FilledButton.icon(
          onPressed: () => _showSchoolFormDialog(),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.addSchool),
        );

        if (widget.embedded) {
          final title = AppPageHeader(
            title: context.l10n.schools,
            subtitle: context.l10n.schoolsSubtitle,
          );
          final refresh = IconButton(
            tooltip: context.l10n.refresh,
            onPressed: () {
              context.read<SchoolCubit>().loadSchools(forceRefresh: true);
              _refreshClassCounts();
            },
            icon: const Icon(Icons.refresh),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: title),
                    refresh,
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                search,
                const SizedBox(height: AppSpacing.sm),
                Align(alignment: Alignment.centerLeft, child: addButton),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: title),
              SizedBox(width: 320, child: search),
              const SizedBox(width: 8),
              addButton,
              refresh,
            ],
          );
        }

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: AppSpacing.sm),
              Align(alignment: Alignment.centerRight, child: addButton),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            addButton,
          ],
        );
      },
    );
  }
}

class _SchoolClassesDialog extends StatelessWidget {
  const _SchoolClassesDialog({
    required this.school,
    required this.classes,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final School school;
  final List<SchoolClass> classes;
  final Future<void> Function() onAdd;
  final Future<void> Function(SchoolClass schoolClass) onEdit;
  final Future<void> Function(SchoolClass schoolClass) onDelete;

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: AppDialogTitle(context.l10n.classesForSchool(school.name ?? '-')),
      content: SizedBox(
        width: 720,
        height: _schoolClassesViewportHeight(context),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => onAdd(),
                icon: const Icon(Icons.add),
                label: Text(context.l10n.addClass),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: classes.isEmpty
                  ? Center(child: Text(context.l10n.noClassesForSchool))
                  : AppTable<SchoolClass>(
                      data: classes,
                      pageable: Pageable(
                        page: 0,
                        size: classes.length,
                        totalPages: 1,
                        totalItems: classes.length,
                      ),
                      columns: [
                        AppTableColumn(
                          title: context.l10n.className,
                          flex: 3,
                          sortValue: (schoolClass) => schoolClass.name.isEmpty
                              ? 0
                              : schoolClass.name.codeUnitAt(0),
                          cell: (schoolClass) => Text(
                            schoolClass.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.level,
                          flex: 2,
                          sortValue: (schoolClass) => schoolClass.level,
                          cell: (schoolClass) => Text(
                            '${schoolClass.level}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.section,
                          flex: 2,
                          sortValue: (schoolClass) =>
                              SchoolClass.normalizeSection(
                                schoolClass.section,
                              )?.codeUnitAt(0) ??
                              0,
                          cell: (schoolClass) => Text(
                            SchoolClass.normalizeSection(schoolClass.section) ??
                                '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.year,
                          flex: 2,
                          sortValue: (schoolClass) =>
                              int.tryParse(schoolClass.year) ?? 0,
                          cell: (schoolClass) => Text(
                            schoolClass.year,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        AppTableColumn(
                          title: context.l10n.actions,
                          minWidth: 144,
                          flex: 2,
                          cell: (schoolClass) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: context.l10n.edit,
                                onPressed: () => onEdit(schoolClass),
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit, size: 16),
                              ),
                              IconButton(
                                tooltip: context.l10n.delete,
                                onPressed: () => onDelete(schoolClass),
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
                                padding: EdgeInsets.zero,
                                color: AppColors.errorDark,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.close),
        ),
      ],
    );
  }
}

class _SchoolClassAction {
  const _SchoolClassAction(this.kind, [this.schoolClass]);
  final String kind;
  final SchoolClass? schoolClass;
}

double _schoolClassesViewportHeight(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.7).clamp(320.0, 600.0);
