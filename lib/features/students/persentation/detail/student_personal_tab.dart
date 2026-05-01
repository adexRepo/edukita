import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/students/persentation/detail/detail_tab_scroll.dart';
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
          title: 'Family',
          icon: Icons.family_restroom_outlined,
          children: [
            DetailInfoPill(label: 'Primary guardian', value: '-'),
            DetailInfoPill(label: 'Relationship', value: '-'),
            DetailInfoPill(label: 'Contact', value: '-'),
            DetailEmptySectionText(
              'Guardian contact information will appear here from guardians and student_guardians.',
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Health',
          icon: Icons.medical_information_outlined,
          children: [
            DetailInfoPill(label: 'Allergies', value: '-'),
            DetailInfoPill(label: 'Medical notes', value: '-'),
            DetailInfoPill(label: 'Disabilities', value: '-'),
          ],
        ),
        const DetailSectionCard(
          title: 'Learning Profile',
          icon: Icons.psychology_alt_outlined,
          children: [
            DetailInfoPill(label: 'Learning style', value: '-'),
            DetailInfoPill(label: 'Pace', value: '-'),
            DetailInfoPill(label: 'Motivation', value: '-'),
            DetailEmptySectionText(
              'Learning profile records will appear here from student_learning_profiles.',
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Well-being',
          icon: Icons.self_improvement_outlined,
          children: [
            DetailInfoPill(label: 'Stress level', value: '-'),
            DetailInfoPill(label: 'Confidence', value: '-'),
            DetailInfoPill(label: 'Counseling notes', value: '-'),
          ],
        ),
      ],
    );
  }
}
