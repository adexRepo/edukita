import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_metric_summary.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/students/persentation/detail/detail_tab_scroll.dart';
import 'package:flutter/material.dart';

class StudentAcademicTab extends StatelessWidget {
  const StudentAcademicTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        DetailMetricSummary(student: student),
        const DetailSectionCard(
          title: 'Scores',
          icon: Icons.assignment_outlined,
          children: [
            DetailInfoPill(label: 'Average score', value: '-'),
            DetailInfoPill(label: 'Last exam', value: '-'),
            DetailInfoPill(label: 'Best subject', value: '-'),
            DetailEmptySectionText(
              'Scores by subject and exams will appear here from student_scores and subjects.',
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Attendance',
          icon: Icons.fact_check_outlined,
          children: [
            DetailInfoPill(label: 'Attendance rate', value: '-'),
            DetailInfoPill(label: 'Present', value: '-'),
            DetailInfoPill(label: 'Absent', value: '-'),
            DetailEmptySectionText(
              'Attendance records will appear here from attendance_sessions and student_attendance.',
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Classes',
          icon: Icons.class_outlined,
          children: [
            DetailInfoPill(label: 'Current class', value: '-'),
            DetailInfoPill(label: 'Enrollment status', value: '-'),
            DetailEmptySectionText(
              'Class and enrollment history will appear here from student_classes and classes.',
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Subject Trends',
          icon: Icons.trending_up_outlined,
          children: [
            DetailEmptySectionText(
              'Subject performance trends will appear here after score history is available.',
            ),
          ],
        ),
      ],
    );
  }
}
