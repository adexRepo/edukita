import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/students/persentation/detail/detail_tab_scroll.dart';
import 'package:flutter/material.dart';

class StudentMoreTab extends StatelessWidget {
  const StudentMoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailTabScroll(
      children: [
        DetailSectionCard(
          title: 'Documents',
          icon: Icons.description_outlined,
          children: [
            DetailInfoPill(label: 'Uploaded files', value: '-'),
            DetailEmptySectionText(
              'Uploaded documents will appear here from student_documents.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Finance',
          icon: Icons.payments_outlined,
          children: [
            DetailInfoPill(label: 'Fee amount', value: '-'),
            DetailInfoPill(label: 'Scholarship', value: '-'),
            DetailInfoPill(label: 'Status', value: '-'),
          ],
        ),
        DetailSectionCard(
          title: 'Goals',
          icon: Icons.flag_outlined,
          children: [
            DetailInfoPill(label: 'Career goal', value: '-'),
            DetailInfoPill(label: 'Development goal', value: '-'),
            DetailEmptySectionText(
              'Career and personal development goals will appear here from student_goals.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Social Notes',
          icon: Icons.groups_2_outlined,
          children: [
            DetailEmptySectionText(
              'Friend observations and social behavior notes will appear here from student_social_notes.',
            ),
          ],
        ),
      ],
    );
  }
}
