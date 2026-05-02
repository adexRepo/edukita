import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
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
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                'Activity',
                'Role',
                'Achievement',
                'Start Date',
                'End Date',
              ],
              rows: [],
              emptyText:
                  'Extracurricular activities, roles, and achievements will appear here from activities and student_activities.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Extra Activity Records',
          icon: Icons.event_note_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Date', 'Activity', 'Role', 'Achievement'],
              rows: [],
              emptyText:
                  'Additional extra activity records will appear here from extra_activities.',
            ),
          ],
        ),
      ],
    );
  }
}
