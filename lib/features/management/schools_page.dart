import 'package:edukita/features/management/class_cubit.dart';
import 'package:edukita/features/management/class_model.dart';
import 'package:edukita/features/management/school_cubit.dart';
import 'package:edukita/features/management/school_form_dialog.dart';
import 'package:edukita/features/management/school_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/clay_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SchoolsPage extends StatefulWidget {
  const SchoolsPage({super.key});

  @override
  State<SchoolsPage> createState() => _SchoolsPageState();
}

class _SchoolsPageState extends State<SchoolsPage> {
  School? _selectedSchool;

  @override
  void initState() {
    super.initState();
    context.read<SchoolCubit>().loadSchools();
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
          await classCubit.loadClassesBySchool(school.id);
          setState(() => _selectedSchool = school);
        },
      ),
    );
  }

  void _selectSchool(School school) {
    setState(() => _selectedSchool = school);
    context.read<ClassCubit>().loadClassesBySchool(school.id);
  }

  Future<void> _confirmDeleteSchool(School school) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete School'),
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

    await context.read<SchoolCubit>().deleteSchool(school.id);
    if (!mounted) return;

    if (_selectedSchool?.id == school.id) {
      setState(() => _selectedSchool = null);
      context.read<ClassCubit>().loadClassesBySchool('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'School',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _showSchoolFormDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add School'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _SchoolTable(
                      selected: _selectedSchool,
                      onSelect: _selectSchool,
                      onEdit: (school) => _showSchoolFormDialog(school: school),
                      onDelete: _confirmDeleteSchool,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: _ClassTable(selectedSchool: _selectedSchool)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SchoolTable extends StatelessWidget {
  const _SchoolTable({
    required this.selected,
    required this.onSelect,
    required this.onEdit,
    required this.onDelete,
  });

  final School? selected;
  final ValueChanged<School> onSelect;
  final ValueChanged<School> onEdit;
  final ValueChanged<School> onDelete;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      child: BlocBuilder<SchoolCubit, SchoolState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }
          if (state.schools.isEmpty) {
            return const Center(child: Text('No schools yet.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schools',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: state.schools.length,
                  itemBuilder: (context, index) {
                    final school = state.schools[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SchoolRow(
                        school: school,
                        selected: selected?.id == school.id,
                        onTap: () => onSelect(school),
                        onEdit: () => onEdit(school),
                        onDelete: () => onDelete(school),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SchoolRow extends StatelessWidget {
  const _SchoolRow({
    required this.school,
    required this.selected,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final School school;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;

    return Material(
      color: selected
          ? selectedColor.withValues(alpha: 0.08)
          : AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? selectedColor : AppColors.border,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: selected ? 5 : 0,
                color: selectedColor,
              ),
              Expanded(
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: selected
                        ? selectedColor
                        : AppColors.surfaceMuted,
                    child: Icon(
                      selected ? Icons.check : Icons.apartment,
                      size: 17,
                      color: selected
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                  title: Text(
                    school.name ?? '-',
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${school.type?.label ?? '-'} - ${school.address ?? '-'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit school',
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                      ),
                      IconButton(
                        tooltip: 'Delete school',
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                      ),
                      if (selected)
                        Icon(Icons.chevron_right, color: selectedColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassTable extends StatelessWidget {
  const _ClassTable({required this.selectedSchool});

  final School? selectedSchool;

  @override
  Widget build(BuildContext context) {
    return ClayCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedSchool == null
                ? 'Classes'
                : 'Classes - ${selectedSchool!.name ?? '-'}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: selectedSchool == null
                ? const Center(child: Text('Select a school to view classes.'))
                : BlocBuilder<ClassCubit, ClassState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state.error != null) {
                        return Center(child: Text('Error: ${state.error}'));
                      }
                      if (state.classes.isEmpty) {
                        return const Center(
                          child: Text('No classes for this school.'),
                        );
                      }
                      return _ClassList(classes: state.classes);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ClassList extends StatelessWidget {
  const _ClassList({required this.classes});

  final List<SchoolClass> classes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: classes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final schoolClass = classes[index];
        return ListTile(
          title: Text(schoolClass.name),
          subtitle: Text(
            'Level ${schoolClass.level} - Section ${schoolClass.section ?? '-'} - Year ${schoolClass.year}',
          ),
        );
      },
    );
  }
}
