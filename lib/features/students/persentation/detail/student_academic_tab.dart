import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/localization/localized_display.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_metric_summary.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentAcademicTab extends StatelessWidget {
  const StudentAcademicTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentDetailInsights>(
      future: context.read<StudentDetailCubit>().loadDetailInsights(student.id),
      builder: (context, snapshot) {
        final insights = snapshot.data;
        return DetailTabScroll(
          children: [
            DetailMetricSummary(student: student),
            DetailSectionCard(
              title: context.l10n.learningSummary,
              icon: Icons.assignment_outlined,
              children: [
                if (snapshot.hasError)
                  DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
                else if (snapshot.connectionState == ConnectionState.waiting)
                  DetailEmptySectionText(context.l10n.loadingLearningSummary)
                else if (insights == null)
                  DetailEmptySectionText(context.l10n.noLearningSummary)
                else ...[
                  DetailInfoPill(
                    label: context.l10n.averageScore,
                    value: _scoreOrDash(insights.learning.averageScore),
                  ),
                  DetailInfoPill(
                    label: context.l10n.assessments,
                    value: insights.learning.assessmentCount.toString(),
                  ),
                  DetailInfoPill(
                    label: context.l10n.latest,
                    value: _textOrDash(insights.learning.latestAssessmentDate),
                  ),
                ],
              ],
            ),
            DetailSectionCard(
              title: context.l10n.competencyAverage,
              icon: Icons.stacked_bar_chart_outlined,
              wrapChildren: false,
              children: [
                if (snapshot.hasError)
                  DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
                else if (snapshot.connectionState == ConnectionState.waiting)
                  DetailEmptySectionText(context.l10n.loadingCompetencyRecords)
                else
                  DetailDataTable(
                    columns: [
                      context.l10n.competency,
                      context.l10n.averageScore,
                      context.l10n.records,
                    ],
                    rows: (insights?.competencies ?? const [])
                        .map(
                          (item) => [
                            item.label,
                            item.averageScore.toStringAsFixed(0),
                            item.recordCount.toString(),
                          ],
                        )
                        .toList(),
                    emptyText: context.l10n.noCompetencyScores,
                  ),
              ],
            ),
            DetailSectionCard(
              title: context.l10n.teachingAttendance,
              icon: Icons.fact_check_outlined,
              wrapChildren: false,
              children: [
                if (snapshot.hasError)
                  DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
                else if (snapshot.connectionState == ConnectionState.waiting)
                  DetailEmptySectionText(context.l10n.loadingAttendanceRecords)
                else
                  DetailDataTable(
                    columns: [
                      context.l10n.date,
                      context.l10n.session,
                      context.l10n.time,
                      context.l10n.status,
                      context.l10n.checkIn,
                      context.l10n.note,
                    ],
                    rows: (insights?.recentAttendance ?? const [])
                        .map(
                          (item) => [
                            item.date,
                            item.session,
                            _textOrDash(item.time),
                            translateAttendanceStatus(context, item.status),
                            _textOrDash(item.checkIn),
                            _textOrDash(item.note),
                          ],
                        )
                        .toList(),
                    emptyText: context.l10n.noTeachingAttendance,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

String _scoreOrDash(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(0);
}

String _textOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value;
}
