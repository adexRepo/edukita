import 'package:edukita/core/utils/text_case.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:edukita/features/students/persentation/detail/student_header_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentOverviewTab extends StatelessWidget {
  const StudentOverviewTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentDetailInsights>(
      future: context.read<StudentDetailCubit>().loadDetailInsights(student.id),
      builder: (context, snapshot) {
        final insights = snapshot.data;
        return DetailTabScroll(
          children: [
            StudentHeaderDetail(
              student: student,
              monthlyAttendance: insights?.monthlyAttendance,
            ),
            DetailSectionCard(
              title: 'Quick Profile',
              icon: Icons.dashboard_outlined,
              children: [
                DetailInfoPill(label: 'Name', value: student.fullName),
                DetailInfoPill(label: 'Student No', value: student.studentNo),
                DetailInfoPill(label: 'Age', value: '${student.age} years'),
                DetailInfoPill(label: 'Class', value: student.className),
                DetailInfoPill(
                  label: 'Status',
                  value: student.status.name.titleWords,
                ),
              ],
            ),
            DetailSectionCard(
              title: 'Aggregated Snapshot',
              icon: Icons.insights_outlined,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const DetailEmptySectionText('Loading student snapshot...')
                else if (insights == null)
                  const DetailEmptySectionText('No student snapshot available.')
                else ...[
                  DetailInfoPill(
                    label: 'Attendance',
                    value: _percentOrDash(
                      insights.attendance.attendancePercentage,
                    ),
                  ),
                  DetailInfoPill(
                    label: 'Attendance Records',
                    value: insights.attendance.totalRecords.toString(),
                  ),
                  DetailInfoPill(
                    label: 'Average Score',
                    value: _scoreOrDash(insights.learning.averageScore),
                  ),
                  DetailInfoPill(
                    label: 'Teacher Notes',
                    value: insights.recentTeacherNotes.length.toString(),
                  ),
                  DetailInfoPill(
                    label: 'Assistance',
                    value: insights.assistanceHistory.length.toString(),
                  ),
                ],
              ],
            ),
            if (insights != null) _OverviewSignals(insights: insights),
          ],
        );
      },
    );
  }
}

class _OverviewSignals extends StatelessWidget {
  const _OverviewSignals({required this.insights});

  final StudentDetailInsights insights;

  @override
  Widget build(BuildContext context) {
    final attendance = insights.attendance;
    final attention = <String>[
      if (attendance.totalRecords > 0 &&
          (attendance.attendancePercentage ?? 100) < 75)
        'Attendance below 75%',
      if (attendance.absentCount > 0) '${attendance.absentCount} absence record(s)',
      if (attendance.permissionCount > 0)
        '${attendance.permissionCount} permission record(s)',
      if (insights.recentTeacherNotes.isNotEmpty)
        '${insights.recentTeacherNotes.length} recent teacher note(s)',
    ];

    return DetailSectionCard(
      title: 'Needs Attention',
      icon: Icons.flag_outlined,
      children: [
        if (attention.isEmpty)
          const DetailEmptySectionText(
            'No attention flags from attendance or teacher notes.',
          )
        else
          for (final item in attention) DetailInfoPill(label: 'Signal', value: item),
      ],
    );
  }
}

String _percentOrDash(double? value) {
  if (value == null) return '-';
  return '${value.toStringAsFixed(0)}%';
}

String _scoreOrDash(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(0);
}
