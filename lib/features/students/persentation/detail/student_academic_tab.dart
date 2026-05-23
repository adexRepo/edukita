import 'package:edukita/core/utils/text_case.dart';
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
              title: 'Learning Summary',
              icon: Icons.assignment_outlined,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const DetailEmptySectionText('Loading learning summary...')
                else if (insights == null)
                  const DetailEmptySectionText('No learning summary available.')
                else ...[
                  DetailInfoPill(
                    label: 'Average Score',
                    value: _scoreOrDash(insights.learning.averageScore),
                  ),
                  DetailInfoPill(
                    label: 'Assessments',
                    value: insights.learning.assessmentCount.toString(),
                  ),
                  DetailInfoPill(
                    label: 'Latest',
                    value: _textOrDash(insights.learning.latestAssessmentDate),
                  ),
                ],
              ],
            ),
            DetailSectionCard(
              title: 'Competency Average',
              icon: Icons.stacked_bar_chart_outlined,
              wrapChildren: false,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const DetailEmptySectionText('Loading competency records...')
                else
                  DetailDataTable(
                    columns: const ['Competency', 'Average', 'Records'],
                    rows: (insights?.competencies ?? const [])
                        .map(
                          (item) => [
                            item.label,
                            item.averageScore.toStringAsFixed(0),
                            item.recordCount.toString(),
                          ],
                        )
                        .toList(),
                    emptyText:
                        'No competency scores have been saved from teaching sessions.',
                  ),
              ],
            ),
            DetailSectionCard(
              title: 'Teaching Attendance',
              icon: Icons.fact_check_outlined,
              wrapChildren: false,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const DetailEmptySectionText('Loading attendance records...')
                else
                  DetailDataTable(
                    columns: const [
                      'Date',
                      'Session',
                      'Time',
                      'Status',
                      'Check In',
                      'Note',
                    ],
                    rows: (insights?.recentAttendance ?? const [])
                        .map(
                          (item) => [
                            item.date,
                            item.session,
                            _textOrDash(item.time),
                            item.status.titleWords,
                            _textOrDash(item.checkIn),
                            _textOrDash(item.note),
                          ],
                        )
                        .toList(),
                    emptyText:
                        'No teaching attendance has been saved for this student.',
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
