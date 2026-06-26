import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/localization/localized_display.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_metric_summary.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/students/persentation/detail/student_exam_scores_tab.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentAcademicTab extends StatelessWidget {
  const StudentAcademicTab({
    super.key,
    required this.student,
    required this.canUpdateStudent,
    required this.canDeleteStudent,
  });

  final StudentDetailData student;
  final bool canUpdateStudent;
  final bool canDeleteStudent;

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
            _AchievementsSection(studentId: student.id),
            StudentExamScoresTab(
              student: student,
              canUpdateStudent: canUpdateStudent,
              canDeleteStudent: canDeleteStudent,
              wrapWithScroll: false,
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

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentAdvancedFormData>(
      future: context.read<StudentDetailCubit>().loadAdvancedFormData(
        studentId,
      ),
      builder: (context, snapshot) {
        final household =
            snapshot.data?.householdProfile ??
            const StudentHouseholdProfileFormData();
        final rows = [
          if (_hasText(household.academicAchievement))
            [context.l10n.academicAchievement, household.academicAchievement!],
          if (_hasText(household.nonAcademicAchievement))
            [
              context.l10n.nonAcademicAchievement,
              household.nonAcademicAchievement!,
            ],
        ];

        return DetailSectionCard(
          title: context.l10n.achievement,
          icon: Icons.emoji_events_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.hasError)
              DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
            else if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loading)
            else
              DetailDataTable(
                columns: [context.l10n.category, context.l10n.value],
                rows: rows,
                emptyText: context.l10n.emptyData,
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

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _textOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value;
}
