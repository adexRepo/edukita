import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/text_case.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentMoreTab extends StatelessWidget {
  const StudentMoreTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        _AssistanceHistoryTable(studentId: student.id),
        _GoalsTable(studentId: student.id),
      ],
    );
  }
}

class _AssistanceHistoryTable extends StatelessWidget {
  const _AssistanceHistoryTable({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentDetailInsights>(
      future: context.read<StudentDetailCubit>().loadDetailInsights(studentId),
      builder: (context, snapshot) {
        final history =
            snapshot.data?.assistanceHistory ??
            const <StudentAssistanceHistoryInsight>[];

        return DetailSectionCard(
          title: context.l10n.assistanceHistory,
          icon: Icons.volunteer_activism_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loadingAssistanceHistory)
            else
              DetailDataTable(
                columns: [
                  context.l10n.program,
                  context.l10n.period,
                  context.l10n.rule,
                  context.l10n.benefit,
                  context.l10n.status,
                  context.l10n.approvedAt,
                ],
                rows: history
                    .map(
                      (item) => [
                        item.programName,
                        item.periodName,
                        _textOrDash(item.ruleName),
                        _textOrDash(item.benefit),
                        item.status.titleWords,
                        _textOrDash(item.approvedAt),
                      ],
                    )
                    .toList(),
                emptyText: context.l10n.noAssistanceHistory,
              ),
          ],
        );
      },
    );
  }
}

class _GoalsTable extends StatelessWidget {
  const _GoalsTable({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentAdvancedFormData>(
      future: context.read<StudentDetailCubit>().loadAdvancedFormData(
        studentId,
      ),
      builder: (context, snapshot) {
        final advanced = snapshot.data ?? const StudentAdvancedFormData();
        final rows = <List<String>>[
          if (_hasText(advanced.hobby)) ['HOBBY', advanced.hobby!],
          if (_hasText(advanced.aspiration))
            ['ASPIRATION', advanced.aspiration!],
        ];

        return DetailSectionCard(
          title: context.l10n.goals,
          icon: Icons.flag_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loadingGoals)
            else
              DetailDataTable(
                columns: [context.l10n.category, context.l10n.goal],
                rows: rows,
                emptyText: context.l10n.noGoals,
              ),
          ],
        );
      },
    );
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}

String _textOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value;
}
