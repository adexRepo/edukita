import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/students/persentation/detail/detail_tab_scroll.dart';
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
          children: [
            DetailInfoPill(label: 'Warnings', value: '-'),
            DetailInfoPill(label: 'Rewards', value: '-'),
            DetailEmptySectionText(
              'Warnings, rewards, and behavior records will appear here from student_behavior.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Risk Flags',
          icon: Icons.health_and_safety_outlined,
          children: [
            DetailInfoPill(label: 'Current level', value: '-'),
            DetailInfoPill(label: 'Risk type', value: '-'),
            DetailEmptySectionText(
              'At-risk flags will appear here from student_risks.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Interventions',
          icon: Icons.support_agent_outlined,
          children: [
            DetailInfoPill(label: 'Active action', value: '-'),
            DetailInfoPill(label: 'Start date', value: '-'),
            DetailInfoPill(label: 'End date', value: '-'),
            DetailEmptySectionText(
              'Counseling, extra class, and intervention actions will appear here from student_interventions.',
            ),
          ],
        ),
      ],
    );
  }
}
