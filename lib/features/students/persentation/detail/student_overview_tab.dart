import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/students/persentation/detail/detail_tab_scroll.dart';
import 'package:edukita/features/students/persentation/detail/student_header_detail.dart';
import 'package:flutter/material.dart';

class StudentOverviewTab extends StatelessWidget {
  const StudentOverviewTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        StudentHeaderDetail(student: student),
        DetailSectionCard(
          title: 'Quick Profile',
          icon: Icons.dashboard_outlined,
          children: [
            DetailInfoPill(label: 'Name', value: student.fullName),
            DetailInfoPill(label: 'Age', value: '${student.age} years'),
            DetailInfoPill(label: 'Class', value: student.className),
            DetailInfoPill(
              label: 'Status',
              value: student.status.name.toUpperCase(),
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Aggregated Snapshot',
          icon: Icons.insights_outlined,
          children: [
            DetailInfoPill(label: 'Attendance', value: '-'),
            DetailInfoPill(label: 'Average score', value: '-'),
            DetailInfoPill(label: 'Risk level', value: '-'),
            DetailEmptySectionText(
              'Recent activity is aggregated from scores, attendance, risk, and behavior records.',
            ),
          ],
        ),
      ],
    );
  }
}
