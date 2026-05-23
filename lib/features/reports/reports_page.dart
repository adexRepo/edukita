import 'dart:async';

import 'package:edukita/features/common/common_form_widgets.dart';
import 'package:edukita/features/reports/assessment_cubit.dart';
import 'package:edukita/features/reports/assessment_model.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:edukita/features/syllabus/domain/subject_cubit.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_title.dart';
import 'package:edukita/widgets/app_loading.dart';
import 'package:edukita/widgets/app_page_header.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

const List<String> _assessmentTypes = [
  'Ulangan Harian',
  'UTS',
  'UAS',
  'Tryout',
  'Ujian Akhir',
  'Exam',
  'Quiz',
  'Observation',
  'Practical',
  'Other',
];

const Set<String> _requiredEvidenceTypes = {'UTS', 'UAS', 'Ujian Akhir'};

Widget _twoColumnFormRow(Widget first, Widget second) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: first),
      const SizedBox(width: 12),
      Expanded(child: second),
    ],
  );
}

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AssessmentCubit>().loadAssessmentModule();
    context.read<SubjectCubit>().loadCurriculum();
  }

  Future<void> _showAssessmentForm({
    Assessment? existingAssessment,
    required List<Unit> units,
    required List<Competency> competencies,
  }) async {
    final cubit = context.read<AssessmentCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => AssessmentFormDialog(
        assessment: existingAssessment,
        units: units,
        competencies: competencies,
        onSave: (assessment) async {
          if (existingAssessment == null) {
            await cubit.addAssessment(assessment);
          } else {
            await cubit.updateAssessment(assessment);
          }
        },
      ),
    );
  }

  Future<void> _showScoreForm({
    StudentAssessment? existingResult,
    required List<AssessmentStudentOption> students,
    required List<Assessment> assessments,
    required Map<String, int> evidenceCountsByResult,
  }) async {
    final cubit = context.read<AssessmentCubit>();
    await showDialog<void>(
      context: context,
      builder: (_) => StudentAssessmentFormDialog(
        result: existingResult,
        students: students,
        assessments: assessments,
        existingEvidenceCount: existingResult == null
            ? 0
            : evidenceCountsByResult[existingResult.id] ?? 0,
        onSave: cubit.recordStudentAssessment,
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
    final curriculum = context.watch<SubjectCubit>().state;

    return Scaffold(
      body: BlocBuilder<AssessmentCubit, AssessmentState>(
        builder: (context, state) {
          return Padding(
            padding: AppPageHeaderStyle.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                AppLoadingStrip(isLoading: state.isLoading),
                const SizedBox(height: AppPageHeaderStyle.bottomGap),
                _buildToolbar(
                  state: state,
                  units: curriculum.units,
                  competencies: curriculum.competencies,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _buildContent(
                    state,
                    units: curriculum.units,
                    competencies: curriculum.competencies,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AssessmentState state) {
    return AppPageHeader(
      title: 'Assessments & Results',
      subtitle:
          '${state.assessments.length} assessments, ${state.studentAssessments.length} recorded results',
      trailing: IconButton(
        tooltip: 'Refresh assessments',
        onPressed: () => context.read<AssessmentCubit>().loadAssessmentModule(),
        icon: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildToolbar({
    required AssessmentState state,
    required List<Unit> units,
    required List<Competency> competencies,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final search = TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search assessment, unit, competency, student',
          ),
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: units.isEmpty
                  ? null
                  : () => _showAssessmentForm(
                      units: units,
                      competencies: competencies,
                    ),
              icon: const Icon(Icons.add),
              label: const Text('Assessment'),
            ),
            FilledButton.tonalIcon(
              onPressed: state.assessments.isEmpty || state.students.isEmpty
                  ? null
                  : () => _showScoreForm(
                      students: state.students,
                      assessments: state.assessments,
                      evidenceCountsByResult: state.evidenceCountsByResult,
                    ),
              icon: const Icon(Icons.fact_check),
              label: const Text('Record Score'),
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

  Widget _buildContent(
    AssessmentState state, {
    required List<Unit> units,
    required List<Competency> competencies,
  }) {
    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    final query = _searchQuery.trim().toLowerCase();
    final assessments = state.assessments.where((assessment) {
      final unit = _findUnit(units, assessment.unitId);
      final competency = _findCompetency(competencies, assessment.competencyId);
      final haystack = [
        assessment.name,
        assessment.type,
        assessment.assessmentType,
        assessment.assessmentSource,
        assessment.scoreType,
        assessment.evidenceLabel,
        assessment.description,
        unit?.name,
        competency?.code,
        competency?.description,
      ].whereType<String>().join(' ').toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    final results = state.studentAssessments.where((result) {
      final student = _findStudent(state.students, result.studentId);
      final assessment = _findAssessment(
        state.assessments,
        result.assessmentId,
      );
      final unit = _findUnit(units, assessment?.unitId);
      final competency = _findCompetency(
        competencies,
        assessment?.competencyId,
      );
      final haystack = [
        student?.fullName,
        student?.className,
        assessment?.name,
        unit?.name,
        competency?.description,
        result.note,
        result.assessedAt,
      ].whereType<String>().join(' ').toLowerCase();
      return query.isEmpty || haystack.contains(query);
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 860;
        final sections = [
          _AssessmentSection(
            title: 'Assessment Plan',
            icon: Icons.assignment,
            count: assessments.length,
            emptyText: 'No assessments yet.',
            child: _buildAssessmentList(assessments, units, competencies),
          ),
          _AssessmentSection(
            title: 'Student Results',
            icon: Icons.fact_check,
            count: results.length,
            emptyText: 'No student results yet.',
            child: _buildResultList(
              results,
              state.students,
              state.assessments,
              units,
              competencies,
              state.evidenceCountsByResult,
            ),
          ),
        ];

        if (compact) {
          return ListView.separated(
            itemCount: sections.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                SizedBox(height: 360, child: sections[index]),
          );
        }

        return Row(
          children: [
            Expanded(child: sections[0]),
            const SizedBox(width: 12),
            Expanded(child: sections[1]),
          ],
        );
      },
    );
  }

  Widget _buildAssessmentList(
    List<Assessment> assessments,
    List<Unit> units,
    List<Competency> competencies,
  ) {
    return ListView.separated(
      itemCount: assessments.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final assessment = assessments[index];
        final unit = _findUnit(units, assessment.unitId);
        final competency = _findCompetency(
          competencies,
          assessment.competencyId,
        );
        return ListTile(
          title: Text(
            assessment.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            [
              '${assessment.displayType} - ${assessment.assessmentSource ?? 'internal'} - max ${assessment.maxScore?.toStringAsFixed(0) ?? '-'}',
              assessment.isEvidenceRequired
                  ? 'Evidence required: ${assessment.evidenceLabel ?? 'Evidence file'}'
                  : 'Evidence optional',
              unit?.name ?? '-',
              if (competency != null)
                '${competency.code ?? 'Competency'}: ${competency.description}',
              if (assessment.description?.trim().isNotEmpty == true)
                assessment.description!,
            ].join('\n'),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit assessment',
                onPressed: () => _showAssessmentForm(
                  existingAssessment: assessment,
                  units: units,
                  competencies: competencies,
                ),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Delete assessment',
                color: AppColors.errorDark,
                onPressed: () => _confirmDelete(
                  title: 'Assessment',
                  subject: 'assessment',
                  onDelete: () => context
                      .read<AssessmentCubit>()
                      .deleteAssessment(assessment.id),
                ),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultList(
    List<StudentAssessment> results,
    List<AssessmentStudentOption> students,
    List<Assessment> assessments,
    List<Unit> units,
    List<Competency> competencies,
    Map<String, int> evidenceCountsByResult,
  ) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = results[index];
        final student = _findStudent(students, result.studentId);
        final assessment = _findAssessment(assessments, result.assessmentId);
        final evidenceCount = evidenceCountsByResult[result.id] ?? 0;
        final unit = _findUnit(units, assessment?.unitId);
        final competency = _findCompetency(
          competencies,
          assessment?.competencyId,
        );
        return ListTile(
          title: Text(
            '${student?.fullName ?? '-'} - ${result.score?.toStringAsFixed(1) ?? '-'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            [
              '${student?.className ?? '-'} - ${result.assessedAt ?? '-'}',
              assessment?.name ?? '-',
              unit?.name ?? '-',
              if (competency != null)
                competency.code?.trim().isNotEmpty == true
                    ? competency.code!
                    : competency.description,
              if (result.note?.trim().isNotEmpty == true) result.note!,
            ].join('\n'),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, height: 1.25),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit result',
                onPressed: () => _showScoreForm(
                  existingResult: result,
                  students: students,
                  assessments: assessments,
                  evidenceCountsByResult: evidenceCountsByResult,
                ),
                icon: const Icon(Icons.edit),
              ),
              _EvidenceChip(
                requiredEvidence: assessment?.isEvidenceRequired ?? false,
                count: evidenceCount,
              ),
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Delete result',
                color: AppColors.errorDark,
                onPressed: () => _confirmDelete(
                  title: 'Student Result',
                  subject: 'student result',
                  onDelete: () => context
                      .read<AssessmentCubit>()
                      .deleteStudentAssessment(result.id),
                ),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        );
      },
    );
  }

  Assessment? _findAssessment(List<Assessment> assessments, String? id) {
    for (final assessment in assessments) {
      if (assessment.id == id) return assessment;
    }
    return null;
  }

  AssessmentStudentOption? _findStudent(
    List<AssessmentStudentOption> students,
    String? id,
  ) {
    for (final student in students) {
      if (student.id == id) return student;
    }
    return null;
  }

  Unit? _findUnit(List<Unit> units, String? id) {
    for (final unit in units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  Competency? _findCompetency(List<Competency> competencies, String? id) {
    for (final competency in competencies) {
      if (competency.id == id) return competency;
    }
    return null;
  }
}

class AssessmentFormDialog extends StatefulWidget {
  final Assessment? assessment;
  final List<Unit> units;
  final List<Competency> competencies;
  final FutureOr<void> Function(Assessment) onSave;

  const AssessmentFormDialog({
    super.key,
    this.assessment,
    required this.units,
    required this.competencies,
    required this.onSave,
  });

  @override
  State<AssessmentFormDialog> createState() => _AssessmentFormDialogState();
}

class _AssessmentFormDialogState extends State<AssessmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String unitId;
  late String? competencyId;
  late String name;
  late String? type;
  late String? assessmentType;
  late String? assessmentSource;
  late String? scoreType;
  late bool isEvidenceRequired;
  late String? evidenceLabel;
  late double? maxScore;
  late String? description;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    unitId =
        widget.assessment?.unitId ??
        (widget.units.isNotEmpty ? widget.units.first.id : '');
    competencyId = widget.assessment?.competencyId;
    name = widget.assessment?.name ?? '';
    type = widget.assessment?.type;
    assessmentType =
        widget.assessment?.assessmentType ?? widget.assessment?.type;
    assessmentSource = widget.assessment?.assessmentSource ?? 'internal';
    scoreType = widget.assessment?.scoreType ?? 'numeric_100';
    isEvidenceRequired =
        widget.assessment?.isEvidenceRequired ??
        _requiredEvidenceTypes.contains(assessmentType);
    evidenceLabel = widget.assessment?.evidenceLabel ?? 'Scan raport / result';
    maxScore = widget.assessment?.maxScore ?? 100;
    description = widget.assessment?.description;
  }

  @override
  Widget build(BuildContext context) {
    final selectedUnit = _firstWhereOrNull(
      widget.units,
      (item) => item.id == unitId,
    );
    final unitCompetencies = widget.competencies
        .where((competency) => competency.unitId == unitId)
        .toList();
    final selectedCompetency = _firstWhereOrNull(
      unitCompetencies,
      (item) => item.id == competencyId,
    );

    return AlertDialog(
      title: AppDialogTitle(
        widget.assessment == null ? 'Add Assessment' : 'Edit Assessment',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _twoColumnFormRow(
                  CommonFormWidgets.dropdownFieldTyped<Unit>(
                    label: 'Unit',
                    items: widget.units,
                    labelBuilder: (item) => item.name,
                    valueBuilder: (item) => item.id,
                    value: selectedUnit,
                    onChanged: (value) => setState(() {
                      unitId = value?.id ?? '';
                      competencyId = null;
                    }),
                    onSaved: (value) => unitId = value?.id ?? '',
                  ),
                  AppDropdownButtonFormField<String>(
                    initialValue: selectedCompetency?.id ?? '',
                    isExpanded: false,
                    decoration: const InputDecoration(labelText: 'Competency'),
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: AppDropdownStyle.menuItemLabel(
                          label: 'None',
                          selected: selectedCompetency == null,
                        ),
                      ),
                      ...unitCompetencies.map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: AppDropdownStyle.menuItemLabel(
                            label: item.code?.trim().isNotEmpty == true
                                ? '${item.code} - ${item.description}'
                                : item.description,
                            selected: item.id == selectedCompetency?.id,
                          ),
                        ),
                      ),
                    ],
                    selectedItemBuilder: (context) =>
                        AppDropdownStyle.selectedLabels([
                          'None',
                          ...unitCompetencies.map(
                            (item) => item.code?.trim().isNotEmpty == true
                                ? '${item.code} - ${item.description}'
                                : item.description,
                          ),
                        ]),
                    dropdownColor: AppColors.white,
                    focusColor: AppColors.transparent,
                    iconEnabledColor: AppColors.primary,
                    borderRadius: AppDropdownStyle.menuBorderRadius,
                    menuMaxHeight: AppDropdownStyle.menuMaxHeight,
                    style: AppDropdownStyle.textStyle,
                    onChanged: (value) => setState(
                      () => competencyId = value == null || value.isEmpty
                          ? null
                          : value,
                    ),
                    onSaved: (value) => competencyId =
                        value == null || value.isEmpty ? null : value,
                  ),
                ),
                const SizedBox(height: 16),
                _twoColumnFormRow(
                  CommonFormWidgets.textField(
                    label: 'Name',
                    value: name,
                    onSaved: (value) => name = value?.trim() ?? '',
                    validator: (value) {
                      if (value?.trim().isEmpty ?? true) {
                        return 'Assessment name is required';
                      }
                      return null;
                    },
                  ),
                  CommonFormWidgets.dropdownField(
                    label: 'Assessment Type',
                    items: _assessmentTypes,
                    value: assessmentType,
                    onChanged: (value) {
                      setState(() {
                        assessmentType = value;
                        type = value;
                        if (_requiredEvidenceTypes.contains(value)) {
                          isEvidenceRequired = true;
                          evidenceLabel ??= 'Scan raport / result';
                        }
                      });
                    },
                    onSaved: (value) {
                      assessmentType = _nullIfBlank(value);
                      type = assessmentType;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _twoColumnFormRow(
                  CommonFormWidgets.dropdownField(
                    label: 'Source',
                    items: const [
                      'internal',
                      'school_report',
                      'tryout',
                      'external',
                    ],
                    value: assessmentSource,
                    onChanged: (value) =>
                        setState(() => assessmentSource = value),
                    onSaved: (value) =>
                        assessmentSource = _nullIfBlank(value) ?? 'internal',
                  ),
                  CommonFormWidgets.dropdownField(
                    label: 'Score Type',
                    items: const ['numeric_100', 'star_5', 'grade'],
                    value: scoreType,
                    onChanged: (value) => setState(() => scoreType = value),
                    onSaved: (value) =>
                        scoreType = _nullIfBlank(value) ?? 'numeric_100',
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value:
                      isEvidenceRequired ||
                      _requiredEvidenceTypes.contains(assessmentType),
                  onChanged: _requiredEvidenceTypes.contains(assessmentType)
                      ? null
                      : (value) {
                          setState(
                            () => isEvidenceRequired = value ?? false,
                          );
                        },
                  title: const Text('Evidence required'),
                  subtitle: const Text(
                    'UTS, UAS, and Ujian Akhir always require an uploaded file.',
                  ),
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: 12),
                _twoColumnFormRow(
                  CommonFormWidgets.textField(
                    label: 'Evidence Label',
                    value: evidenceLabel,
                    onSaved: (value) => evidenceLabel = _nullIfBlank(value),
                    validator: (_) => null,
                    isRequired: false,
                  ),
                  CommonFormWidgets.doubleField(
                    label: 'Max Score',
                    value: maxScore,
                    onSaved: (value) => maxScore = value,
                  ),
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.textField(
                  label: 'Description',
                  value: description,
                  onSaved: (value) => description = _nullIfBlank(value),
                  maxLines: 3,
                  validator: (_) => null,
                  isRequired: false,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final action = widget.assessment == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final assessment = Assessment(
      id: widget.assessment?.id,
      unitId: unitId,
      competencyId: competencyId,
      name: name,
      type: type,
      assessmentType: assessmentType,
      assessmentSource: assessmentSource,
      scoreType: scoreType,
      isEvidenceRequired:
          isEvidenceRequired || _requiredEvidenceTypes.contains(assessmentType),
      evidenceLabel: evidenceLabel,
      maxScore: maxScore,
      description: description,
    );

    setState(() => _isSaving = true);
    try {
      await widget.onSave(assessment);
      AppToast.showSubmissionSuccess(action: action, subject: 'assessment');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'assessment');
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class StudentAssessmentFormDialog extends StatefulWidget {
  final StudentAssessment? result;
  final List<AssessmentStudentOption> students;
  final List<Assessment> assessments;
  final int existingEvidenceCount;
  final FutureOr<void> Function(
    StudentAssessment, {
    String? evidenceSourcePath,
    String? evidenceFileName,
    String? evidenceRemarks,
  }) onSave;

  const StudentAssessmentFormDialog({
    super.key,
    this.result,
    required this.students,
    required this.assessments,
    this.existingEvidenceCount = 0,
    required this.onSave,
  });

  @override
  State<StudentAssessmentFormDialog> createState() =>
      _StudentAssessmentFormDialogState();
}

class _StudentAssessmentFormDialogState
    extends State<StudentAssessmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String studentId;
  late String assessmentId;
  late double? score;
  late String? note;
  late String? assessedAt;
  String? _evidenceSourcePath;
  String? _evidenceFileName;
  String? _evidenceRemarks;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    studentId =
        widget.result?.studentId ??
        (widget.students.isNotEmpty ? widget.students.first.id : '');
    assessmentId =
        widget.result?.assessmentId ??
        (widget.assessments.isNotEmpty ? widget.assessments.first.id : '');
    score = widget.result?.score;
    note = widget.result?.note;
    assessedAt =
        widget.result?.assessedAt ??
        DateTime.now().toIso8601String().split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    final selectedStudent = _firstWhereOrNull(
      widget.students,
      (item) => item.id == studentId,
    );
    final selectedAssessment = _firstWhereOrNull(
      widget.assessments,
      (item) => item.id == assessmentId,
    );

    return AlertDialog(
      title: AppDialogTitle(
        widget.result == null ? 'Record Score' : 'Edit Score',
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CommonFormWidgets.dropdownFieldTyped<AssessmentStudentOption>(
                  label: 'Student',
                  items: widget.students,
                  labelBuilder: (item) =>
                      '${item.fullName} - ${item.className}',
                  valueBuilder: (item) => item.id,
                  value: selectedStudent,
                  onSaved: (value) => studentId = value?.id ?? '',
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.dropdownFieldTyped<Assessment>(
                  label: 'Assessment',
                  items: widget.assessments,
                  labelBuilder: (item) => item.name,
                  valueBuilder: (item) => item.id,
                  value: selectedAssessment,
                  onChanged: (value) =>
                      setState(() => assessmentId = value?.id ?? ''),
                  onSaved: (value) => assessmentId = value?.id ?? '',
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.doubleField(
                  label: 'Score',
                  value: score,
                  onSaved: (value) => score = value,
                  isRequired: true,
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Score is required';
                    }
                    final parsed = double.tryParse(value!.trim());
                    if (parsed == null) return 'Score must be a number';
                    final maxScore = selectedAssessment?.maxScore;
                    if (maxScore != null && parsed > maxScore) {
                      return 'Score cannot exceed $maxScore';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.textField(
                  label: 'Assessed At',
                  value: assessedAt,
                  hint: AppFormFieldStyle.dateFormat,
                  onSaved: (value) => assessedAt = _nullIfBlank(value),
                  validator: (value) {
                    if (value?.trim().isEmpty ?? true) {
                      return 'Assessment date is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CommonFormWidgets.textField(
                  label: 'Note',
                  value: note,
                  onSaved: (value) => note = _nullIfBlank(value),
                  maxLines: 3,
                  validator: (_) => null,
                  isRequired: false,
                ),
                const SizedBox(height: 16),
                _buildEvidencePicker(selectedAssessment),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _submit,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildEvidencePicker(Assessment? selectedAssessment) {
    final required = selectedAssessment?.isEvidenceRequired ?? false;
    final hasExisting = widget.existingEvidenceCount > 0;
    final hasSelected = _evidenceSourcePath?.trim().isNotEmpty == true;
    final fileName = _evidenceFileName ?? 'No file selected';

    return FormField<String>(
      validator: (_) {
        if (required && !hasExisting && !hasSelected) {
          return '${selectedAssessment?.evidenceLabel ?? 'Evidence'} is required';
        }
        return null;
      },
      builder: (field) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: selectedAssessment?.evidenceLabel ?? 'Evidence File',
            helperText: required
                ? 'Required for this assessment type. Allowed: PDF, JPG, PNG.'
                : 'Optional. Allowed: PDF, JPG, PNG.',
            errorText: field.errorText,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasSelected
                      ? fileName
                      : hasExisting
                          ? '${widget.existingEvidenceCount} file uploaded'
                          : 'No file selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: hasSelected || hasExisting
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _isSaving ? null : _pickEvidenceFile,
                icon: const Icon(Icons.upload_file, size: 16),
                label: Text(hasSelected || hasExisting ? 'Change' : 'Upload'),
              ),
              if (hasSelected) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Remove selected file',
                  onPressed: _isSaving
                      ? null
                      : () {
                          setState(() {
                            _evidenceSourcePath = null;
                            _evidenceFileName = null;
                          });
                        },
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickEvidenceFile() async {
    const evidenceGroup = XTypeGroup(
      label: 'Assessment evidence',
      extensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [evidenceGroup]);
    if (file == null) return;

    final extension = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    if (!['pdf', 'jpg', 'jpeg', 'png'].contains(extension)) {
      AppToast.showFailed('Only PDF, JPG, and PNG files are allowed.');
      return;
    }

    setState(() {
      _evidenceSourcePath = file.path;
      _evidenceFileName = file.name;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final action = widget.result == null
        ? SubmissionAction.create
        : SubmissionAction.update;
    _formKey.currentState!.save();
    final result = StudentAssessment(
      id: widget.result?.id,
      studentId: studentId,
      assessmentId: assessmentId,
      score: score,
      note: note,
      assessedAt: assessedAt,
    );

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        result,
        evidenceSourcePath: _evidenceSourcePath,
        evidenceFileName: _evidenceFileName,
        evidenceRemarks: _evidenceRemarks,
      );
      AppToast.showSubmissionSuccess(action: action, subject: 'student result');
      if (mounted) Navigator.pop(context);
    } catch (_) {
      AppToast.showSubmissionFailed(action: action, subject: 'student result');
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _AssessmentSection extends StatelessWidget {
  const _AssessmentSection({
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

class _EvidenceChip extends StatelessWidget {
  const _EvidenceChip({required this.requiredEvidence, required this.count});

  final bool requiredEvidence;
  final int count;

  @override
  Widget build(BuildContext context) {
    final hasEvidence = count > 0;
    final color = hasEvidence
        ? AppColors.success
        : requiredEvidence
            ? AppColors.error
            : AppColors.textSecondary;
    final label = hasEvidence
        ? '$count file'
        : requiredEvidence
            ? 'Missing'
            : 'Optional';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasEvidence ? Icons.attachment : Icons.warning_amber_outlined,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String? _nullIfBlank(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T) test) {
  for (final item in items) {
    if (test(item)) return item;
  }
  return null;
}
