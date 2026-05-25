import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/schools/domain/class_cubit.dart';
import 'package:edukita/features/schools/domain/school_cubit.dart';
import 'package:edukita/features/schools/presentation/class_form_dialog.dart';
import 'package:edukita/features/schools/presentation/school_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchoolsPage extends StatefulWidget {
  const SchoolsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<SchoolsPage> createState() => _SchoolsPageState();
}

class _SchoolsPageState extends State<SchoolsPage> {
  String _schoolSearchQuery = '';
  late Future<Map<String, int>> _classCountsFuture;

  @override
  void initState() {
    super.initState();
    context.read<SchoolCubit>().loadSchools();
    _classCountsFuture = _loadClassCounts();
  }

  Future<Map<String, int>> _loadClassCounts() async {
    final allClasses = await context.read<ClassCubit>().getAllClasses();
    final counts = <String, int>{};
    for (final schoolClass in allClasses) {
      final schoolId = schoolClass.schoolId;
      if (schoolId == null || schoolId.isEmpty) continue;
      counts[schoolId] = (counts[schoolId] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> _refreshClassCounts() async {
    setState(() {
      _classCountsFuture = _loadClassCounts();
    });
  }

  Future<void> _showSchoolFormDialog({School? school}) async {
    final schoolCubit = context.read<SchoolCubit>();
    final classCubit = context.read<ClassCubit>();
    final isEditing = school != null;
    final classes = isEditing
        ? await classCubit.getClassesBySchool(school.id)
        : <SchoolClass>[];

    if (!mounted) return;

    await showDialog<void>(
      context: context,
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
  }

  Future<void> _showClassDialog(School school) async {
    final classCubit = context.read<ClassCubit>();
    final classes = await classCubit.getClassesBySchool(school.id);

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _SchoolClassesDialog(
        school: school,
        classes: classes,
        onAdd: () async {
          await _showClassFormDialog(school: school);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          await _showClassDialog(school);
        },
        onEdit: (schoolClass) async {
          await _showClassFormDialog(school: school, schoolClass: schoolClass);
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          await _showClassDialog(school);
        },
        onDelete: (schoolClass) async {
          final deleted = await _confirmDeleteClass(schoolClass);
          if (!deleted) return;
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
          await _showClassDialog(school);
        },
      ),
    );
  }

  Future<void> _showClassFormDialog({
    required School school,
    SchoolClass? schoolClass,
  }) async {
    final classCubit = context.read<ClassCubit>();

    await showDialog<void>(
      context: context,
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppDialogTitle('Delete Class'),
        content: Text('Delete ${schoolClass.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const AppDialogTitle('Delete School'),
        content: Text('Delete ${school.name ?? 'this school'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
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
      child: const AppPageHeader(
        title: 'Schools',
        subtitle: 'Manage school profiles and their class structures.',
      ),
    );
  }

  Widget _buildContent(SchoolState state) {
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    final normalizedQuery = _schoolSearchQuery.trim().toLowerCase();
    final schools = normalizedQuery.isEmpty
        ? state.schools
        : state.schools.where((school) {
            return (school.name ?? '').toLowerCase().contains(normalizedQuery);
          }).toList();

    return Column(
      children: [
        _buildTableHeader(),
        if (widget.embedded)
          AppLoadingStrip(isLoading: state.isLoading, topPadding: 0),
        const SizedBox(height: AppPageHeaderStyle.bottomGap),
        Expanded(
          child: FutureBuilder<Map<String, int>>(
            future: _classCountsFuture,
            builder: (context, snapshot) {
              final classCounts = snapshot.data ?? const <String, int>{};
              if (schools.isEmpty) {
                return Center(
                  child: Text(
                    state.schools.isEmpty
                        ? 'No schools yet.'
                        : 'No schools match your search.',
                  ),
                );
              }

              return AppTable<School>(
                data: schools,
                pageable: Pageable(
                  page: 0,
                  size: schools.length,
                  totalPages: 1,
                  totalItems: schools.length,
                ),
                onRowTap: _showClassDialog,
                columns: [
                  AppTableColumn(
                    title: 'School',
                    flex: 4,
                    sortValue: (school) {
                      final name = school.name ?? '';
                      return name.isEmpty ? 0 : name.codeUnitAt(0);
                    },
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
                    title: 'Type',
                    flex: 2,
                    sortValue: (school) => school.type?.index ?? 0,
                    cell: (school) => Text(
                      school.type?.label ?? '-',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  AppTableColumn(
                    title: 'Address',
                    flex: 4,
                    sortValue: (school) {
                      final address = school.address ?? '';
                      return address.isEmpty ? 0 : address.codeUnitAt(0);
                    },
                    cell: (school) => Text(
                      school.address ?? '-',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  AppTableColumn(
                    title: 'Classes',
                    flex: 2,
                    sortValue: (school) => classCounts[school.id] ?? 0,
                    cell: (school) => Text(
                      '${classCounts[school.id] ?? 0}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  AppTableColumn(
                    title: 'Actions',
                    flex: 2,
                    cell: (school) => Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Edit school',
                            onPressed: () =>
                                _showSchoolFormDialog(school: school),
                            constraints: const BoxConstraints.tightFor(
                              width: 28,
                              height: 28,
                            ),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.edit, size: 16),
                          ),
                          IconButton(
                            tooltip: 'Delete school',
                            onPressed: () => _confirmDeleteSchool(school),
                            constraints: const BoxConstraints.tightFor(
                              width: 28,
                              height: 28,
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
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final search = TextField(
          onChanged: (value) {
            setState(() {
              _schoolSearchQuery = value;
            });
          },
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search school name',
          ),
        );
        final addButton = FilledButton.icon(
          onPressed: () => _showSchoolFormDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Add School'),
        );

        if (widget.embedded) {
          final title = AppPageHeader(
            title: 'Schools',
            subtitle: 'Manage school profiles and their class structures.',
          );
          final refresh = IconButton(
            tooltip: 'Refresh schools',
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
                const SizedBox(height: 10),
                search,
                const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
    return AlertDialog(
      title: AppDialogTitle('Classes - ${school.name ?? '-'}'),
      content: SizedBox(
        width: 720,
        height: 420,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: () => onAdd(),
                icon: const Icon(Icons.add),
                label: const Text('Add Class'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: classes.isEmpty
                  ? const Center(child: Text('No classes for this school.'))
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
                          title: 'Class',
                          flex: 3,
                          sortValue: (schoolClass) =>
                              schoolClass.name.codeUnitAt(0),
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
                          title: 'Level',
                          flex: 2,
                          sortValue: (schoolClass) => schoolClass.level,
                          cell: (schoolClass) => Text(
                            '${schoolClass.level}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        AppTableColumn(
                          title: 'Section',
                          flex: 2,
                          sortValue: (schoolClass) =>
                              schoolClass.section?.codeUnitAt(0) ?? 0,
                          cell: (schoolClass) => Text(
                            schoolClass.section ?? '-',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        AppTableColumn(
                          title: 'Year',
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
                          title: 'Actions',
                          flex: 2,
                          cell: (schoolClass) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Edit class',
                                onPressed: () => onEdit(schoolClass),
                                constraints: const BoxConstraints.tightFor(
                                  width: 28,
                                  height: 28,
                                ),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit, size: 16),
                              ),
                              IconButton(
                                tooltip: 'Delete class',
                                onPressed: () => onDelete(schoolClass),
                                constraints: const BoxConstraints.tightFor(
                                  width: 28,
                                  height: 28,
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
          child: const Text('Close'),
        ),
      ],
    );
  }
}
