import 'dart:io' as io;

import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/data/syllabus_model.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/features/syllabus/domain/subject_repository.dart';
import 'package:edukita/features/syllabus/presentation/subject_form_dialog.dart';
import 'package:edukita/features/strategy/data/strategy_model.dart';
import 'package:edukita/features/strategy/domain/strategy_cubit.dart';
import 'package:edukita/features/strategy/presentation/strategy_form_dialog.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_action_guard.dart';
import 'package:edukita/widgets/app_dialog.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class SyllabusPage extends StatefulWidget {
  const SyllabusPage({super.key, this.parameterMenu, this.embedded = false});

  final String? parameterMenu;
  final bool embedded;

  @override
  State<SyllabusPage> createState() => _SyllabusPageState();
}

class _SyllabusPageState extends State<SyllabusPage> {
  static const _allowedStrategySampleExtensions = [
    'xls',
    'xlsx',
    'doc',
    'docx',
    'txt',
    'md',
    'pdf',
  ];

  String _searchQuery = '';
  _CurriculumView _selectedView = _CurriculumView.curriculums;
  double _navigatorWidth = 232;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedView = _viewForParameterMenu(widget.parameterMenu);
    context.read<SubjectCubit>().loadCurriculum();
    context.read<StrategyCubit>().loadStrategies();
  }

  @override
  void didUpdateWidget(covariant SyllabusPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parameterMenu == widget.parameterMenu) return;
    final nextView = _viewForParameterMenu(widget.parameterMenu);
    if (nextView == _selectedView) return;
    setState(() {
      _selectedView = nextView;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showCurriculumForm({Curriculum? existingCurriculum}) async {
    final cubit = context.read<SubjectCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'curriculum_form_${existingCurriculum?.id ?? 'new'}',
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
    required List<Subject> subjects,
    Syllabus? existingSyllabus,
  }) async {
    final cubit = context.read<SubjectCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'syllabus_form_${existingSyllabus?.id ?? 'new'}',
      builder: (_) => SyllabusFormDialog(
        syllabus: existingSyllabus,
        curriculums: curriculums,
        subjects: subjects,
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

  Future<void> _showSubjectForm({Subject? existingSubject}) async {
    final cubit = context.read<SubjectCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'subject_form_${existingSubject?.id ?? 'new'}',
      builder: (_) => SubjectFormDialog(
        subject: existingSubject,
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
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'unit_form_${existingUnit?.id ?? 'new'}',
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
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'competency_form_${existingCompetency?.id ?? 'new'}',
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

  Future<void> _showStrategyForm({Strategy? existingStrategy}) async {
    final cubit = context.read<StrategyCubit>();
    await showGuardedDialog<void>(
      context: context,
      guardKey: 'strategy_form_${existingStrategy?.id ?? 'new'}',
      builder: (_) => StrategyFormDialog(
        strategy: existingStrategy,
        onSave: (strategy) async {
          if (existingStrategy == null) {
            await cubit.addStrategy(strategy);
          } else {
            await cubit.updateStrategy(strategy);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete({
    required String title,
    required String subject,
    required Future<void> Function() onDelete,
    Future<CurriculumDeleteImpact> Function()? impactLoader,
  }) async {
    final impact = impactLoader == null ? null : await impactLoader();
    if (!mounted) return;

    final hasImpact = impact?.hasImpact ?? false;
    final confirmed = await showGuardedDialog<bool>(
      context: context,
      guardKey: 'delete_parameter_${title}_$subject',
      builder: (context) {
        return AppDialog(
          title: AppDialogTitle(context.l10n.deleteItemTitle(title)),
          content: _DeleteImpactContent(subject: subject, impact: impact),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.buttonCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.errorDark,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                hasImpact ? context.l10n.deleteAnyway : context.l10n.delete,
              ),
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

  Future<void> _downloadStrategySample(Strategy strategy) async {
    final sampleFileLabel = context.l10n.sampleImplementationFile;
    final notAttachedMessage = context.l10n.sampleFileNotAttached;
    final notFoundMessage = context.l10n.sampleFileNotFound;
    final downloadedMessage = context.l10n.sampleFileDownloaded;
    final failedMessage = context.l10n.sampleFileDownloadFailed;
    final sourcePath = strategy.sampleFilePath?.trim();
    if (sourcePath == null || sourcePath.isEmpty) {
      AppToast.showFailed(notAttachedMessage);
      return;
    }

    final sourceFile = io.File(sourcePath);
    if (!await sourceFile.exists()) {
      AppToast.showFailed(notFoundMessage);
      return;
    }

    final fileName = strategy.sampleFileName ?? p.basename(sourcePath);
    final location = await getSaveLocation(
      suggestedName: generatedFileName(fileName),
      acceptedTypeGroups: [
        XTypeGroup(
          label: sampleFileLabel,
          extensions: _allowedStrategySampleExtensions,
        ),
      ],
    );
    if (location == null) return;

    try {
      if (p.normalize(sourceFile.path) != p.normalize(location.path)) {
        await sourceFile.copy(location.path);
      }
      AppToast.showSuccess(downloadedMessage);
    } catch (_) {
      AppToast.showFailed(failedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocBuilder<SubjectCubit, SubjectState>(
      builder: (context, state) {
        final strategyState = context.watch<StrategyCubit>().state;
        return _buildShell(state, strategyState);
      },
    );
    if (widget.embedded) return content;
    return Scaffold(body: content);
  }

  Widget _buildShell(SubjectState state, StrategyState strategyState) {
    if (widget.embedded) {
      return _buildContent(state, strategyState);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 760) {
          return Padding(
            padding: AppPageHeaderStyle.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CurriculumCompactNavigator(
                  selectedView: _selectedView,
                  countForView: (view) =>
                      _countForView(view, state, strategyState),
                  onSelect: (view) {
                    setState(() {
                      _selectedView = view;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
                const SizedBox(height: 12),
                Expanded(child: _buildContent(state, strategyState)),
              ],
            ),
          );
        }

        return Row(
          children: [
            _CurriculumNavigator(
              width: _navigatorWidth,
              selectedView: _selectedView,
              countForView: (view) => _countForView(view, state, strategyState),
              onSelect: (view) {
                setState(() {
                  _selectedView = view;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
              onResize: (delta) {
                setState(() {
                  _navigatorWidth = (_navigatorWidth + delta)
                      .clamp(188, 292)
                      .toDouble();
                });
              },
            ),
            Expanded(
              child: Padding(
                padding: AppPageHeaderStyle.pagePadding,
                child: _buildContent(state, strategyState),
              ),
            ),
          ],
        );
      },
    );
  }

  _CurriculumView _viewForParameterMenu(String? menu) {
    return switch (menu) {
      'Curriculum' => _CurriculumView.curriculums,
      'Subjects' => _CurriculumView.subjects,
      'Syllabus' => _CurriculumView.syllabus,
      'Units' => _CurriculumView.units,
      'Competencies' => _CurriculumView.competencies,
      'Strategies' => _CurriculumView.strategies,
      _ => _CurriculumView.curriculums,
    };
  }

  Widget _buildContent(SubjectState state, StrategyState strategyState) {
    if (state.error != null) {
      return Center(child: Text(context.l10n.errorWithDetails(state.error!)));
    }
    if (strategyState.error != null) {
      return Center(
        child: Text(context.l10n.errorWithDetails(strategyState.error!)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildContentHeader(state),
        AppLoadingStrip(isLoading: state.isLoading || strategyState.isLoading),
        const SizedBox(height: AppPageHeaderStyle.bottomGap),
        Expanded(child: _buildSelectedTable(state, strategyState)),
      ],
    );
  }

  Widget _buildContentHeader(SubjectState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 680;
        final search = SizedBox(
          width: compact ? double.infinity : 320,
          child: TextField(
            key: ValueKey(_selectedView),
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: context.l10n.searchItems(
                _viewLabel(context, _selectedView).toLowerCase(),
              ),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: context.l10n.clearSearch,
                      onPressed: () {
                        setState(() => _searchQuery = '');
                        _searchController.clear();
                      },
                      icon: const Icon(Icons.close, size: 18),
                    ),
            ),
          ),
        );
        final action = _buildAddButton(state);
        final refresh = IconButton(
          tooltip: context.l10n.refresh,
          onPressed: () {
            context.read<SubjectCubit>().loadCurriculum(forceRefresh: true);
            context.read<StrategyCubit>().loadStrategies(forceRefresh: true);
          },
          icon: const Icon(Icons.refresh),
        );
        final title = AppPageHeader(
          title: _viewLabel(context, _selectedView),
          subtitle: _viewDescription(context, _selectedView),
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
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            search,
            const SizedBox(width: 8),
            action,
            refresh,
          ],
        );
      },
    );
  }

  Widget _buildAddButton(SubjectState state) {
    return FilledButton.icon(
      onPressed: switch (_selectedView) {
        _CurriculumView.curriculums => () => _showCurriculumForm(),
        _CurriculumView.syllabus =>
          state.curriculums.isEmpty || state.subjects.isEmpty
              ? null
              : () => _showSyllabusForm(
                  state.curriculums,
                  subjects: state.subjects,
                ),
        _CurriculumView.subjects => () => _showSubjectForm(),
        _CurriculumView.units =>
          state.subjects.isEmpty ? null : () => _showUnitForm(state.subjects),
        _CurriculumView.competencies =>
          state.units.isEmpty ? null : () => _showCompetencyForm(state.units),
        _CurriculumView.strategies => () => _showStrategyForm(),
      },
      icon: const Icon(Icons.add),
      label: Text(_viewAddLabel(context, _selectedView)),
    );
  }

  Widget _buildSelectedTable(SubjectState state, StrategyState strategyState) {
    return switch (_selectedView) {
      _CurriculumView.curriculums => _buildCurriculumTable(state),
      _CurriculumView.syllabus => _buildSyllabusTable(state),
      _CurriculumView.subjects => _buildSubjectTable(state),
      _CurriculumView.units => _buildUnitTable(state),
      _CurriculumView.competencies => _buildCompetencyTable(state),
      _CurriculumView.strategies => _buildStrategyTable(strategyState),
    };
  }

  Widget _buildCurriculumTable(SubjectState state) {
    final rows = state.curriculums.where((curriculum) {
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return curriculum.name.toLowerCase().contains(query) ||
          (curriculum.version ?? '').toLowerCase().contains(query) ||
          (curriculum.description ?? '').toLowerCase().contains(query) ||
          (curriculum.effectiveYear ?? '').toLowerCase().contains(query) ||
          curriculum.status.toLowerCase().contains(query);
    }).toList();

    return AppTable<Curriculum>(
      data: rows,
      pageable: _pageableFor(rows.length),
      emptyMessage: context.l10n.noCurriculumsFound,
      onRowTap: (curriculum) =>
          _showCurriculumForm(existingCurriculum: curriculum),
      columns: [
        AppTableColumn(
          title: context.l10n.curriculum,
          flex: 2,
          cell: (curriculum) =>
              _titleCell(curriculum.name, subtitle: curriculum.description),
        ),
        AppTableColumn(
          title: context.l10n.version,
          cell: (curriculum) => _textCell(_dash(curriculum.version)),
        ),
        AppTableColumn(
          title: context.l10n.effectiveYear,
          sortValue: (curriculum) =>
              int.tryParse(curriculum.effectiveYear ?? ''),
          cell: (curriculum) => _textCell(_dash(curriculum.effectiveYear)),
        ),
        AppTableColumn(
          title: context.l10n.status,
          cell: (curriculum) => _StatusChip(label: curriculum.status),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          cell: (curriculum) => _actionCell(
            onEdit: () => _showCurriculumForm(existingCurriculum: curriculum),
            onDelete: () => _confirmDelete(
              title: context.l10n.curriculum,
              subject: context.l10n.curriculum,
              onDelete: () =>
                  context.read<SubjectCubit>().deleteCurriculum(curriculum.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSyllabusTable(SubjectState state) {
    final rows = state.syllabi.where((syllabus) {
      final curriculum = _findCurriculum(
        state.curriculums,
        syllabus.curriculumId,
      );
      final subject = _findSubject(state.subjects, syllabus.subjectId);
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return syllabus.title.toLowerCase().contains(query) ||
          (curriculum?.name ?? '').toLowerCase().contains(query) ||
          (subject?.name ?? '').toLowerCase().contains(query) ||
          (syllabus.description ?? '').toLowerCase().contains(query) ||
          (syllabus.academicYear ?? '').toLowerCase().contains(query) ||
          _schoolTypeLabel(syllabus.schoolType).toLowerCase().contains(query) ||
          (syllabus.level ?? '').toLowerCase().contains(query) ||
          (syllabus.semester ?? '').toLowerCase().contains(query) ||
          syllabus.status.toLowerCase().contains(query);
    }).toList();

    return AppTable<Syllabus>(
      data: rows,
      pageable: _pageableFor(rows.length),
      emptyMessage: context.l10n.noSyllabusFound,
      onRowTap: (syllabus) => _showSyllabusForm(
        state.curriculums,
        subjects: state.subjects,
        existingSyllabus: syllabus,
      ),
      columns: [
        AppTableColumn(
          title: context.l10n.syllabus,
          flex: 4,
          cell: (syllabus) =>
              _titleCell(syllabus.title, subtitle: syllabus.description),
        ),
        AppTableColumn(
          title: '${context.l10n.curriculum}\n${context.l10n.subject}',
          flex: 3,
          cell: (syllabus) => _textCell(
            '${_findCurriculum(state.curriculums, syllabus.curriculumId)?.name ?? '-'}\n${_findSubject(state.subjects, syllabus.subjectId)?.name ?? '-'}',
            maxLines: 2,
          ),
        ),
        AppTableColumn(
          title: '${context.l10n.academic}\n${context.l10n.semester}',
          flex: 2,
          sortValue: (syllabus) => int.tryParse(syllabus.academicYear ?? ''),
          cell: (syllabus) => _textCell(
            '${_dash(syllabus.academicYear)}\nSemester ${_dash(syllabus.semester)}',
            maxLines: 2,
          ),
        ),
        AppTableColumn(
          title: '${context.l10n.schoolType}\n${context.l10n.level}',
          flex: 2,
          cell: (syllabus) => _textCell(
            '${_schoolTypeLabel(syllabus.schoolType).toUpperCase()}\nLevel ${_dash(syllabus.level)}',
            maxLines: 2,
          ),
        ),
        AppTableColumn(
          title: context.l10n.status,
          flex: 1,
          cell: (syllabus) => _StatusChip(label: syllabus.status),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          flex: 1,
          cell: (syllabus) => _actionCell(
            onEdit: () => _showSyllabusForm(
              state.curriculums,
              subjects: state.subjects,
              existingSyllabus: syllabus,
            ),
            onDelete: () => _confirmDelete(
              title: context.l10n.syllabus,
              subject: context.l10n.syllabus,
              onDelete: () =>
                  context.read<SubjectCubit>().deleteSyllabus(syllabus.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectTable(SubjectState state) {
    final rows = state.subjects.where((subject) {
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return subject.name.toLowerCase().contains(query) ||
          (subject.description ?? '').toLowerCase().contains(query) ||
          subject.status.toLowerCase().contains(query);
    }).toList();

    return AppTable<Subject>(
      data: rows,
      pageable: _pageableFor(rows.length),
      emptyMessage: context.l10n.noSubjectsFound,
      onRowTap: (subject) => _showSubjectForm(existingSubject: subject),
      columns: [
        AppTableColumn(
          title: context.l10n.subject,
          flex: 2,
          cell: (subject) =>
              _titleCell(subject.name, subtitle: subject.description),
        ),
        AppTableColumn(
          title: context.l10n.status,
          cell: (subject) => _StatusChip(label: subject.status),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          cell: (subject) => _actionCell(
            onEdit: () => _showSubjectForm(existingSubject: subject),
            onDelete: () => _confirmDelete(
              title: context.l10n.subject,
              subject: context.l10n.subject,
              impactLoader: () => context
                  .read<SubjectCubit>()
                  .getSubjectDeleteImpact(subject.id),
              onDelete: () =>
                  context.read<SubjectCubit>().deleteSubject(subject.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitTable(SubjectState state) {
    final rows = state.units.where((unit) {
      final subject = _findSubject(state.subjects, unit.subjectId);
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return unit.name.toLowerCase().contains(query) ||
          (unit.description ?? '').toLowerCase().contains(query) ||
          (subject?.name ?? '').toLowerCase().contains(query) ||
          (unit.sequenceNo?.toString() ?? '').contains(query);
    }).toList();

    return AppTable<Unit>(
      data: rows,
      pageable: _pageableFor(rows.length),
      emptyMessage: context.l10n.noUnitsFound,
      onRowTap: (unit) => _showUnitForm(state.subjects, existingUnit: unit),
      columns: [
        AppTableColumn(
          title: context.l10n.sequence,
          sortValue: (unit) => unit.sequenceNo,
          cell: (unit) => _textCell(unit.sequenceNo?.toString() ?? '-'),
        ),
        AppTableColumn(
          title: context.l10n.unit,
          flex: 2,
          cell: (unit) => _titleCell(unit.name, subtitle: unit.description),
        ),
        AppTableColumn(
          title: context.l10n.subject,
          flex: 2,
          cell: (unit) => _textCell(
            _findSubject(state.subjects, unit.subjectId)?.name ?? '-',
          ),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          cell: (unit) => _actionCell(
            onEdit: () => _showUnitForm(state.subjects, existingUnit: unit),
            onDelete: () => _confirmDelete(
              title: context.l10n.unit,
              subject: context.l10n.unit,
              impactLoader: () =>
                  context.read<SubjectCubit>().getUnitDeleteImpact(unit.id),
              onDelete: () => context.read<SubjectCubit>().deleteUnit(unit.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompetencyTable(SubjectState state) {
    final rows = state.competencies.where((competency) {
      final unit = _findUnit(state.units, competency.unitId);
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return competency.description.toLowerCase().contains(query) ||
          (competency.code ?? '').toLowerCase().contains(query) ||
          (competency.level ?? '').toLowerCase().contains(query) ||
          (unit?.name ?? '').toLowerCase().contains(query);
    }).toList();

    return AppTable<Competency>(
      data: rows,
      pageable: _pageableFor(rows.length),
      emptyMessage: context.l10n.noCompetenciesFound,
      onRowTap: (competency) =>
          _showCompetencyForm(state.units, existingCompetency: competency),
      columns: [
        AppTableColumn(
          title: context.l10n.code,
          cell: (competency) => _textCell(_dash(competency.code)),
        ),
        AppTableColumn(
          title: context.l10n.competency,
          flex: 3,
          cell: (competency) => _textCell(competency.description, maxLines: 2),
        ),
        AppTableColumn(
          title: context.l10n.unit,
          flex: 2,
          cell: (competency) =>
              _textCell(_findUnit(state.units, competency.unitId)?.name ?? '-'),
        ),
        AppTableColumn(
          title: context.l10n.level,
          cell: (competency) => _textCell(_dash(competency.level)),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          cell: (competency) => _actionCell(
            onEdit: () => _showCompetencyForm(
              state.units,
              existingCompetency: competency,
            ),
            onDelete: () => _confirmDelete(
              title: context.l10n.competency,
              subject: context.l10n.competency,
              onDelete: () =>
                  context.read<SubjectCubit>().deleteCompetency(competency.id),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStrategyTable(StrategyState strategyState) {
    final rows = strategyState.strategies.where((strategy) {
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return strategy.name.toLowerCase().contains(query) ||
          (strategy.code ?? '').toLowerCase().contains(query) ||
          (strategy.description ?? '').toLowerCase().contains(query) ||
          (strategy.rule ?? '').toLowerCase().contains(query) ||
          (strategy.sampleFileName ?? '').toLowerCase().contains(query);
    }).toList();

    return AppTable<Strategy>(
      data: rows,
      pageable: _pageableFor(rows.length),
      emptyMessage: context.l10n.noStrategiesFound,
      onRowTap: (strategy) => _showStrategyForm(existingStrategy: strategy),
      columns: [
        AppTableColumn(
          title: context.l10n.code,
          cell: (strategy) => _textCell(_dash(strategy.code)),
        ),
        AppTableColumn(
          title: context.l10n.strategy,
          flex: 2,
          cell: (strategy) =>
              _titleCell(strategy.name, subtitle: strategy.description),
        ),
        AppTableColumn(
          title: context.l10n.rule,
          flex: 3,
          cell: (strategy) => _textCell(_dash(strategy.rule), maxLines: 2),
        ),
        AppTableColumn(
          title: context.l10n.sample,
          flex: 2,
          cell: (strategy) => _textCell(_dash(strategy.sampleFileName)),
        ),
        AppTableColumn(
          title: context.l10n.actions,
          flex: 2,
          cell: (strategy) => _actionCell(
            onDownload: strategy.sampleFilePath?.trim().isNotEmpty == true
                ? () => _downloadStrategySample(strategy)
                : null,
            onEdit: () => _showStrategyForm(existingStrategy: strategy),
            onDelete: () => _confirmDelete(
              title: context.l10n.strategy,
              subject: context.l10n.strategy,
              onDelete: () =>
                  context.read<StrategyCubit>().deleteStrategy(strategy.id),
            ),
          ),
        ),
      ],
    );
  }

  int _countForView(
    _CurriculumView view,
    SubjectState state,
    StrategyState strategyState,
  ) {
    return switch (view) {
      _CurriculumView.curriculums => state.curriculums.length,
      _CurriculumView.syllabus => state.syllabi.length,
      _CurriculumView.subjects => state.subjects.length,
      _CurriculumView.units => state.units.length,
      _CurriculumView.competencies => state.competencies.length,
      _CurriculumView.strategies => strategyState.strategies.length,
    };
  }

  Pageable _pageableFor(int count) {
    return Pageable(
      page: 0,
      size: count == 0 ? 20 : count,
      totalPages: 1,
      totalItems: count,
    );
  }

  Widget _titleCell(String title, {String? subtitle}) {
    return Tooltip(
      message: [
        title,
        if (subtitle?.trim().isNotEmpty == true) subtitle!,
      ].join('\n'),
      waitDuration: const Duration(milliseconds: 450),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          if (subtitle?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _textCell(String value, {int maxLines = 1}) {
    return Tooltip(
      message: value,
      waitDuration: const Duration(milliseconds: 450),
      child: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _actionCell({
    Future<void> Function()? onDownload,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onDownload != null)
            IconButton(
              tooltip: context.l10n.downloadSample,
              onPressed: onDownload,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.download_outlined, size: 17),
            ),
          IconButton(
            tooltip: context.l10n.edit,
            onPressed: onEdit,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.edit_outlined, size: 17),
          ),
          IconButton(
            tooltip: context.l10n.delete,
            onPressed: onDelete,
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            padding: EdgeInsets.zero,
            color: AppColors.errorDark,
            icon: const Icon(
              Icons.delete_outline,
              size: 17,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _dash(String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return '-';
    return text;
  }

  String _schoolTypeLabel(String? rawType) {
    final normalized = rawType?.trim().toLowerCase();
    if (normalized == null || normalized.isEmpty) return '-';
    final type = SchoolType.values.firstWhere(
      (type) => type.name == normalized,
      orElse: () => SchoolType.sd,
    );
    return type.label;
  }

  Curriculum? _findCurriculum(List<Curriculum> curriculums, String? id) {
    for (final curriculum in curriculums) {
      if (curriculum.id == id) return curriculum;
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
}

class _DeleteImpactContent extends StatelessWidget {
  const _DeleteImpactContent({required this.subject, required this.impact});

  final String subject;
  final CurriculumDeleteImpact? impact;

  @override
  Widget build(BuildContext context) {
    final lines = _impactLines(context, impact);
    if (lines.isEmpty) {
      return Text(context.l10n.deleteItemConfirm(subject));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.deleteConnectedItemConfirm(subject)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.28),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.thisWillAlsoAffect,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(line, style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.reviewCannotUndo,
          style: const TextStyle(
            color: AppColors.errorDark,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  List<String> _impactLines(
    BuildContext context,
    CurriculumDeleteImpact? impact,
  ) {
    if (impact == null || !impact.hasImpact) return const [];
    return [
      if (impact.units > 0) context.l10n.impactUnitsDeleted(impact.units),
      if (impact.syllabiDetached > 0)
        context.l10n.impactSyllabiDetached(impact.syllabiDetached),
      if (impact.schedules > 0)
        context.l10n.impactSchedulesDeleted(impact.schedules),
      if (impact.assessments > 0)
        context.l10n.impactAssessmentsDeleted(impact.assessments),
      if (impact.competencies > 0)
        context.l10n.impactCompetenciesDeleted(impact.competencies),
      if (impact.studentScoresDetached > 0)
        context.l10n.impactStudentScoresDetached(impact.studentScoresDetached),
    ];
  }
}

enum _CurriculumView {
  curriculums(
    'Curriculum',
    'Manage curriculum versions, effective years, and active learning frameworks.',
    'Curriculum',
    Icons.account_tree_outlined,
  ),
  subjects(
    'Subjects',
    'Maintain subject master data before it is used in syllabus and schedules.',
    'Subject',
    Icons.library_books_outlined,
  ),
  syllabus(
    'Syllabus',
    'Define learning plans by curriculum, school type, level, and semester.',
    'Syllabus',
    Icons.menu_book_outlined,
  ),
  units(
    'Units',
    'Organize ordered learning units under each subject.',
    'Unit',
    Icons.view_agenda_outlined,
  ),
  competencies(
    'Competencies',
    'Maintain measurable competency targets for each learning unit.',
    'Competency',
    Icons.checklist_outlined,
  ),
  strategies(
    'Strategies',
    'Maintain teaching strategies used by schedule and lesson planning.',
    'Strategy',
    Icons.lightbulb_outline,
  );

  const _CurriculumView(this.label, this.description, this.addLabel, this.icon);

  final String label;
  final String description;
  final String addLabel;
  final IconData icon;
}

String _viewLabel(BuildContext context, _CurriculumView view) {
  return switch (view) {
    _CurriculumView.curriculums => context.l10n.curriculum,
    _CurriculumView.subjects => context.l10n.subjects,
    _CurriculumView.syllabus => context.l10n.syllabus,
    _CurriculumView.units => context.l10n.units,
    _CurriculumView.competencies => context.l10n.competencies,
    _CurriculumView.strategies => context.l10n.strategies,
  };
}

String _viewDescription(BuildContext context, _CurriculumView view) {
  return switch (view) {
    _CurriculumView.curriculums => context.l10n.curriculumSectionDescription,
    _CurriculumView.subjects => context.l10n.subjectSectionDescription,
    _CurriculumView.syllabus => context.l10n.syllabusSectionDescription,
    _CurriculumView.units => context.l10n.unitSectionDescription,
    _CurriculumView.competencies => context.l10n.competencySectionDescription,
    _CurriculumView.strategies => context.l10n.strategySectionDescription,
  };
}

String _viewAddLabel(BuildContext context, _CurriculumView view) {
  return switch (view) {
    _CurriculumView.curriculums => context.l10n.addCurriculum,
    _CurriculumView.subjects => context.l10n.addSubject,
    _CurriculumView.syllabus => context.l10n.addSyllabus,
    _CurriculumView.units => context.l10n.addUnit,
    _CurriculumView.competencies => context.l10n.addCompetency,
    _CurriculumView.strategies => context.l10n.addStrategy,
  };
}

class _CurriculumNavigator extends StatelessWidget {
  const _CurriculumNavigator({
    required this.width,
    required this.selectedView,
    required this.countForView,
    required this.onSelect,
    required this.onResize,
  });

  final double width;
  final _CurriculumView selectedView;
  final int Function(_CurriculumView view) countForView;
  final ValueChanged<_CurriculumView> onSelect;
  final ValueChanged<double> onResize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.curriculum,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          context.l10n.setupStructure,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      children: [
                        _CurriculumNavGroup(
                          title: context.l10n.structure,
                          views: const [
                            _CurriculumView.curriculums,
                            _CurriculumView.subjects,
                            _CurriculumView.syllabus,
                            _CurriculumView.units,
                            _CurriculumView.competencies,
                          ],
                          selectedView: selectedView,
                          countForView: countForView,
                          onSelect: onSelect,
                        ),
                        const SizedBox(height: 12),
                        _CurriculumNavGroup(
                          title: context.l10n.teachingParameters,
                          views: const [_CurriculumView.strategies],
                          selectedView: selectedView,
                          countForView: countForView,
                          onSelect: onSelect,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) => onResize(details.delta.dx),
              child: Container(
                width: 4,
                color: AppColors.transparent,
                alignment: Alignment.center,
                child: Container(
                  width: 2,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurriculumCompactNavigator extends StatelessWidget {
  const _CurriculumCompactNavigator({
    required this.selectedView,
    required this.countForView,
    required this.onSelect,
  });

  final _CurriculumView selectedView;
  final int Function(_CurriculumView view) countForView;
  final ValueChanged<_CurriculumView> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _CurriculumView.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final view = _CurriculumView.values[index];
          return _CurriculumNavItem(
            view: view,
            selected: selectedView == view,
            count: countForView(view),
            compact: true,
            onTap: () => onSelect(view),
          );
        },
      ),
    );
  }
}

class _CurriculumNavGroup extends StatelessWidget {
  const _CurriculumNavGroup({
    required this.title,
    required this.views,
    required this.selectedView,
    required this.countForView,
    required this.onSelect,
  });

  final String title;
  final List<_CurriculumView> views;
  final _CurriculumView selectedView;
  final int Function(_CurriculumView view) countForView;
  final ValueChanged<_CurriculumView> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final view in views)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _CurriculumNavItem(
              view: view,
              selected: selectedView == view,
              count: countForView(view),
              onTap: () => onSelect(view),
            ),
          ),
      ],
    );
  }
}

class _CurriculumNavItem extends StatelessWidget {
  const _CurriculumNavItem({
    required this.view,
    required this.selected,
    required this.count,
    required this.onTap,
    this.compact = false,
  });

  final _CurriculumView view;
  final bool selected;
  final int count;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final background = selected
        ? AppColors.primary.withValues(alpha: 0.13)
        : AppColors.surface;
    final borderColor = selected
        ? AppColors.primary.withValues(alpha: 0.28)
        : AppColors.border;
    final foreground = selected ? AppColors.primaryDark : AppColors.textPrimary;

    return Tooltip(
      message: _viewLabel(context, view),
      waitDuration: const Duration(milliseconds: 450),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: compact ? 168 : null,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(view.icon, size: 18, color: foreground),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  _viewLabel(context, view),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                count.toString(),
                style: TextStyle(
                  color: selected ? AppColors.primaryDark : AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final active = label.toLowerCase() == 'active';
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.success.withValues(alpha: 0.12)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? AppColors.success.withValues(alpha: 0.24)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: active ? AppColors.success : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
