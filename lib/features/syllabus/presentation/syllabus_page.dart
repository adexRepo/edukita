import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/syllabus/presentation/subject_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SyllabusPage extends StatefulWidget {
  const SyllabusPage({super.key});

  @override
  State<SyllabusPage> createState() => _SyllabusPageState();
}

class _SyllabusPageState extends State<SyllabusPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<SubjectCubit>().loadCurriculum();
  }

  Future<void> _showCurriculumForm({Curriculum? existingCurriculum}) async {
    final cubit = context.read<SubjectCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => CurriculumFormDialog(
        curriculum: existingCurriculum,
        onSave: (curriculum) async {
          if (existingCurriculum == null) {
            await cubit.addCurriculum(curriculum);
          } else {
            await cubit.updateCurriculum(curriculum);
          }
        },
      ),
    );
  }

  Future<void> _showSyllabusForm(
    List<Curriculum> curriculums, {
    Syllabus? existingSyllabus,
  }) async {
    final cubit = context.read<SubjectCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => SyllabusFormDialog(
        syllabus: existingSyllabus,
        curriculums: curriculums,
        onSave: (syllabus) async {
          if (existingSyllabus == null) {
            await cubit.addSyllabus(syllabus);
          } else {
            await cubit.updateSyllabus(syllabus);
          }
        },
      ),
    );
  }

  Future<void> _showSubjectForm(
    List<Syllabus> syllabi, {
    Subject? existingSubject,
  }) async {
    final cubit = context.read<SubjectCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => SubjectFormDialog(
        subject: existingSubject,
        syllabi: syllabi,
        onSave: (subject) async {
          if (existingSubject == null) {
            await cubit.addSubject(subject);
          } else {
            await cubit.updateSubject(subject);
          }
        },
      ),
    );
  }

  Future<void> _showUnitForm(
    List<Subject> subjects, {
    Unit? existingUnit,
  }) async {
    final cubit = context.read<SubjectCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => UnitFormDialog(
        unit: existingUnit,
        subjects: subjects,
        onSave: (unit) async {
          if (existingUnit == null) {
            await cubit.addUnit(unit);
          } else {
            await cubit.updateUnit(unit);
          }
        },
      ),
    );
  }

  Future<void> _showCompetencyForm(
    List<Unit> units, {
    Competency? existingCompetency,
  }) async {
    final cubit = context.read<SubjectCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => CompetencyFormDialog(
        competency: existingCompetency,
        units: units,
        onSave: (competency) async {
          if (existingCompetency == null) {
            await cubit.addCompetency(competency);
          } else {
            await cubit.updateCompetency(competency);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete({
    required String title,
    required String subject,
    required Future<void> Function() onDelete,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: AppDialogTitle('Delete $title'),
          content: Text('Delete this $subject?'),
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
        );
      },
    );

    if (confirmed == true) {
      try {
        await onDelete();
        AppToast.showSubmissionSuccess(
          action: SubmissionAction.delete,
          subject: subject,
        );
      } catch (_) {
        AppToast.showSubmissionFailed(
          action: SubmissionAction.delete,
          subject: subject,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SubjectCubit, SubjectState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 12),
                _buildToolbar(state),
                const SizedBox(height: 12),
                Expanded(child: _buildContent(state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SubjectState state) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Curriculum Setup',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${state.curriculums.length} curriculums, ${state.syllabi.length} syllabus, ${state.subjects.length} subjects',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Refresh curriculum',
          onPressed: () => context.read<SubjectCubit>().loadCurriculum(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildToolbar(SubjectState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 720;
        final search = TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search curriculum',
          ),
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _showCurriculumForm(),
              icon: const Icon(Icons.add),
              label: const Text('Curriculum'),
            ),
            FilledButton.tonalIcon(
              onPressed: state.curriculums.isEmpty
                  ? null
                  : () => _showSyllabusForm(state.curriculums),
              icon: const Icon(Icons.menu_book),
              label: const Text('Syllabus'),
            ),
            FilledButton.tonalIcon(
              onPressed: state.syllabi.isEmpty
                  ? null
                  : () => _showSubjectForm(state.syllabi),
              icon: const Icon(Icons.library_books),
              label: const Text('Subject'),
            ),
            FilledButton.tonalIcon(
              onPressed: state.subjects.isEmpty
                  ? null
                  : () => _showUnitForm(state.subjects),
              icon: const Icon(Icons.view_agenda),
              label: const Text('Unit'),
            ),
            FilledButton.tonalIcon(
              onPressed: state.units.isEmpty
                  ? null
                  : () => _showCompetencyForm(state.units),
              icon: const Icon(Icons.checklist),
              label: const Text('Competency'),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [search, const SizedBox(height: 10), actions],
          );
        }

        return Row(
          children: [
            Expanded(child: search),
            const SizedBox(width: 12),
            actions,
          ],
        );
      },
    );
  }

  Widget _buildContent(SubjectState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    final query = _searchQuery.trim().toLowerCase();
    final curriculums = state.curriculums.where((curriculum) {
      if (query.isEmpty) return true;
      return curriculum.name.toLowerCase().contains(query) ||
          (curriculum.version ?? '').toLowerCase().contains(query) ||
          (curriculum.effectiveYear ?? '').toLowerCase().contains(query);
    }).toList();
    final syllabi = state.syllabi.where((syllabus) {
      if (query.isEmpty) return true;
      return syllabus.title.toLowerCase().contains(query) ||
          (syllabus.academicYear ?? '').toLowerCase().contains(query) ||
          (syllabus.level ?? '').toLowerCase().contains(query) ||
          (syllabus.semester ?? '').toLowerCase().contains(query);
    }).toList();
    final subjects = state.subjects.where((subject) {
      if (query.isEmpty) return true;
      return subject.name.toLowerCase().contains(query);
    }).toList();
    final units = state.units.where((unit) {
      if (query.isEmpty) return true;
      return unit.name.toLowerCase().contains(query);
    }).toList();
    final competencies = state.competencies.where((competency) {
      if (query.isEmpty) return true;
      return competency.description.toLowerCase().contains(query) ||
          (competency.code ?? '').toLowerCase().contains(query);
    }).toList();

    final sections = [
      _CurriculumSection(
        title: 'Curriculums',
        icon: Icons.account_tree,
        count: curriculums.length,
        emptyText: 'No curriculums yet.',
        child: ListView.separated(
          itemCount: curriculums.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final curriculum = curriculums[index];
            return _CurriculumTile(
              title: curriculum.name,
              subtitle: [
                if (curriculum.version?.trim().isNotEmpty == true)
                  'v${curriculum.version}',
                if (curriculum.effectiveYear?.trim().isNotEmpty == true)
                  curriculum.effectiveYear!,
                curriculum.status,
              ].join(' - '),
              description: curriculum.description,
              onEdit: () => _showCurriculumForm(existingCurriculum: curriculum),
              onDelete: () => _confirmDelete(
                title: 'Curriculum',
                subject: 'curriculum',
                onDelete: () => context.read<SubjectCubit>().deleteCurriculum(
                  curriculum.id,
                ),
              ),
            );
          },
        ),
      ),
      _CurriculumSection(
        title: 'Syllabus',
        icon: Icons.menu_book,
        count: syllabi.length,
        emptyText: 'No syllabus yet.',
        child: ListView.separated(
          itemCount: syllabi.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final syllabus = syllabi[index];
            final curriculum = _findCurriculum(
              state.curriculums,
              syllabus.curriculumId,
            );
            return _CurriculumTile(
              title: syllabus.title,
              subtitle: [
                curriculum?.name ?? '-',
                syllabus.academicYear ?? '-',
                if (syllabus.level?.trim().isNotEmpty == true)
                  'Level ${syllabus.level}',
                if (syllabus.semester?.trim().isNotEmpty == true)
                  'Semester ${syllabus.semester}',
                syllabus.status,
              ].join(' - '),
              description: syllabus.description,
              onEdit: () => _showSyllabusForm(
                state.curriculums,
                existingSyllabus: syllabus,
              ),
              onDelete: () => _confirmDelete(
                title: 'Syllabus',
                subject: 'syllabus',
                onDelete: () =>
                    context.read<SubjectCubit>().deleteSyllabus(syllabus.id),
              ),
            );
          },
        ),
      ),
      _CurriculumSection(
        title: 'Subjects',
        icon: Icons.library_books,
        count: subjects.length,
        emptyText: 'No subjects yet.',
        child: ListView.separated(
          itemCount: subjects.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final subject = subjects[index];
            final syllabus = _findSyllabus(state.syllabi, subject.syllabusId);
            return _CurriculumTile(
              title: subject.name,
              subtitle: '${syllabus?.title ?? '-'} - ${subject.status}',
              description: subject.description,
              onEdit: () =>
                  _showSubjectForm(state.syllabi, existingSubject: subject),
              onDelete: () => _confirmDelete(
                title: 'Subject',
                subject: 'subject',
                onDelete: () =>
                    context.read<SubjectCubit>().deleteSubject(subject.id),
              ),
            );
          },
        ),
      ),
      _CurriculumSection(
        title: 'Units',
        icon: Icons.view_agenda,
        count: units.length,
        emptyText: 'No units yet.',
        child: ListView.separated(
          itemCount: units.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final unit = units[index];
            final subject = _findSubject(state.subjects, unit.subjectId);
            return _CurriculumTile(
              title: _sequenceTitle(unit),
              subtitle: subject?.name ?? '-',
              description: unit.description,
              onEdit: () => _showUnitForm(state.subjects, existingUnit: unit),
              onDelete: () => _confirmDelete(
                title: 'Unit',
                subject: 'unit',
                onDelete: () =>
                    context.read<SubjectCubit>().deleteUnit(unit.id),
              ),
            );
          },
        ),
      ),
      _CurriculumSection(
        title: 'Competencies',
        icon: Icons.checklist,
        count: competencies.length,
        emptyText: 'No competencies yet.',
        child: ListView.separated(
          itemCount: competencies.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final competency = competencies[index];
            final unit = _findUnit(state.units, competency.unitId);
            return _CurriculumTile(
              title: competency.code?.trim().isNotEmpty == true
                  ? competency.code!
                  : 'Competency',
              subtitle: [
                unit?.name ?? '-',
                if (competency.level?.trim().isNotEmpty == true)
                  competency.level!,
              ].join(' - '),
              description: competency.description,
              onEdit: () => _showCompetencyForm(
                state.units,
                existingCompetency: competency,
              ),
              onDelete: () => _confirmDelete(
                title: 'Competency',
                subject: 'competency',
                onDelete: () => context.read<SubjectCubit>().deleteCompetency(
                  competency.id,
                ),
              ),
            );
          },
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 880) {
          return ListView.separated(
            itemCount: sections.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return SizedBox(height: 320, child: sections[index]);
            },
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              Expanded(child: sections[i]),
              if (i != sections.length - 1) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }

  Curriculum? _findCurriculum(List<Curriculum> curriculums, String? id) {
    for (final curriculum in curriculums) {
      if (curriculum.id == id) return curriculum;
    }
    return null;
  }

  Syllabus? _findSyllabus(List<Syllabus> syllabi, String? id) {
    for (final syllabus in syllabi) {
      if (syllabus.id == id) return syllabus;
    }
    return null;
  }

  Subject? _findSubject(List<Subject> subjects, String? id) {
    for (final subject in subjects) {
      if (subject.id == id) return subject;
    }
    return null;
  }

  Unit? _findUnit(List<Unit> units, String? id) {
    for (final unit in units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  String _sequenceTitle(Unit unit) {
    final sequence = unit.sequenceNo;
    if (sequence == null) return unit.name;
    return '$sequence. ${unit.name}';
  }
}

class _CurriculumSection extends StatelessWidget {
  const _CurriculumSection({
    required this.title,
    required this.icon,
    required this.count,
    required this.emptyText,
    required this.child,
  });

  final String title;
  final IconData icon;
  final int count;
  final String emptyText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: count == 0
                ? Center(
                    child: Text(
                      emptyText,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : child,
          ),
        ],
      ),
    );
  }
}

class _CurriculumTile extends StatelessWidget {
  const _CurriculumTile({
    required this.title,
    required this.subtitle,
    this.description,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final String? description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          subtitle,
          if (description?.trim().isNotEmpty == true) description!,
        ].join('\n'),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, height: 1.25),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit',
            onPressed: onEdit,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.edit, size: 16),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed: onDelete,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            padding: EdgeInsets.zero,
            color: AppColors.errorDark,
            icon: const Icon(Icons.delete_outline, size: 16),
          ),
        ],
      ),
    );
  }
}
