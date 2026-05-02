import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
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
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Type', 'File', 'Uploaded At'],
              rows: [],
              emptyText:
                  'Uploaded documents will appear here from student_documents.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Finance',
          icon: Icons.payments_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Fee Amount', 'Scholarship', 'Status'],
              rows: [],
              emptyText: 'Finance records will appear here from student_finance.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Goals',
          icon: Icons.flag_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Category', 'Goal', 'Created At'],
              rows: [],
              emptyText:
                  'Career and personal development goals will appear here from student_goals.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Social Notes',
          icon: Icons.groups_2_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Recorded At', 'Note'],
              rows: [],
              emptyText:
                  'Friend observations and social behavior notes will appear here from student_social_notes.',
            ),
          ],
        ),
      ],
    );
  }
}
