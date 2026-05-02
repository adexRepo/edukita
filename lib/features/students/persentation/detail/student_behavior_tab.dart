import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';

class StudentBehaviorTab extends StatelessWidget {
  const StudentBehaviorTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const DetailTabScroll(
      children: [
        DetailSectionCard(
          title: 'Behavior Records',
          icon: Icons.record_voice_over_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Date', 'Type', 'Description'],
              rows: [],
              emptyText:
                  'Warnings, rewards, and behavior records will appear here from student_behavior.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Risk Flags',
          icon: Icons.health_and_safety_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Detected At', 'Risk Type', 'Level'],
              rows: [],
              emptyText: 'At-risk flags will appear here from student_risks.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Interventions',
          icon: Icons.support_agent_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Action', 'Start Date', 'End Date', 'Notes'],
              rows: [],
              emptyText:
                  'Counseling, extra class, and intervention actions will appear here from student_interventions.',
            ),
          ],
        ),
      ],
    );
  }
}
