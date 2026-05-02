import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:edukita/features/students/persentation/detail/student_information_section.dart';
import 'package:flutter/material.dart';

class StudentPersonalTab extends StatelessWidget {
  const StudentPersonalTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        StudentInformationSection(student: student),
        const DetailSectionCard(
          title: 'Health',
          icon: Icons.medical_information_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                'Blood Type',
                'Allergies',
                'Medical Notes',
                'Disabilities',
                'Updated At',
              ],
              rows: [],
              emptyText: 'Health records will appear here from student_health.',
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Learning Profile',
          icon: Icons.psychology_alt_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                'Learning Style',
                'Pace',
                'Attention',
                'Motivation',
                'Notes',
              ],
              rows: [],
              emptyText:
                  'Learning profile records will appear here from student_learning_profiles.',
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Well-being',
          icon: Icons.self_improvement_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                'Recorded At',
                'Stress',
                'Confidence',
                'Counseling Notes',
                'Notes',
              ],
              rows: [],
              emptyText:
                  'Well-being records will appear here from student_wellbeing.',
            ),
          ],
        ),
      ],
    );
  }
}
