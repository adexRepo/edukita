import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/students/persentation/detail/detail_tab_scroll.dart';
import 'package:flutter/material.dart';

class StudentActivitiesTab extends StatelessWidget {
  const StudentActivitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailTabScroll(
      children: [
        DetailSectionCard(
          title: 'Extracurricular',
          icon: Icons.emoji_events_outlined,
          children: [
            DetailInfoPill(label: 'Activity', value: '-'),
            DetailInfoPill(label: 'Role', value: '-'),
            DetailInfoPill(label: 'Achievement', value: '-'),
            DetailEmptySectionText(
              'Extracurricular activities, roles, and achievements will appear here from activities and student_activities.',
            ),
          ],
        ),
      ],
    );
  }
}
