import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/localization/localized_display.dart';
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
              title: context.l10n.quickProfile,
              icon: Icons.dashboard_outlined,
              children: [
                DetailInfoPill(
                  label: context.l10n.name,
                  value: student.fullName,
                ),
                DetailInfoPill(
                  label: context.l10n.studentNo,
                  value: student.studentNo,
                ),
                DetailInfoPill(
                  label: context.l10n.age,
                  value: '${student.age} ${context.l10n.years}',
                ),
                DetailInfoPill(
                  label: context.l10n.className,
                  value: student.className,
                ),
                DetailInfoPill(
                  label: context.l10n.status,
                  value: translateStudentStatus(context, student.status.name),
                ),
              ],
            ),
            DetailSectionCard(
              title: context.l10n.aggregatedSnapshot,
              icon: Icons.insights_outlined,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  DetailEmptySectionText(context.l10n.loadingStudentSnapshot)
                else if (insights == null)
                  DetailEmptySectionText(context.l10n.noStudentSnapshot)
                else ...[
                  DetailInfoPill(
                    label: context.l10n.attendance,
                    value: _percentOrDash(
                      insights.attendance.attendancePercentage,
                    ),
                  ),
                  DetailInfoPill(
                    label: context.l10n.attendanceRecords,
                    value: insights.attendance.totalRecords.toString(),
                  ),
                  DetailInfoPill(
                    label: context.l10n.averageScore,
                    value: _scoreOrDash(insights.learning.averageScore),
                  ),
                  DetailInfoPill(
                    label: context.l10n.teacherNotes,
                    value: insights.recentTeacherNotes.length.toString(),
                  ),
                  DetailInfoPill(
                    label: context.l10n.assistance,
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
        context.l10n.attendanceBelowThreshold,
      if (attendance.absentCount > 0)
        context.l10n.absenceRecords(attendance.absentCount),
      if (attendance.permissionCount > 0)
        context.l10n.permissionRecords(attendance.permissionCount),
      if (insights.recentTeacherNotes.isNotEmpty)
        context.l10n.recentTeacherNotesCount(
          insights.recentTeacherNotes.length,
        ),
    ];

    return DetailSectionCard(
      title: context.l10n.needsAttention,
      icon: Icons.flag_outlined,
      children: [
        if (attention.isEmpty)
          DetailEmptySectionText(context.l10n.noAttentionNeeded)
        else
          for (final item in attention)
            DetailInfoPill(label: context.l10n.signal, value: item),
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
