import 'package:edukita/core/utils/text_case.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentBehaviorTab extends StatelessWidget {
  const StudentBehaviorTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentDetailInsights>(
      future: context.read<StudentDetailCubit>().loadDetailInsights(student.id),
      builder: (context, snapshot) {
        final insights = snapshot.data;
        return DetailTabScroll(
          children: [
            DetailSectionCard(
              title: 'Teacher Notes',
              icon: Icons.record_voice_over_outlined,
              wrapChildren: false,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const DetailEmptySectionText('Loading teacher notes...')
                else
                  DetailDataTable(
                    columns: const [
                      'Date',
                      'Type',
                      'Rating',
                      'Teacher',
                      'Comment',
                    ],
                    rows: (insights?.recentTeacherNotes ?? const [])
                        .map(
                          (note) => [
                            note.date,
                            note.type.titleWords,
                            note.rawScore == null
                                ? '-'
                                : '${note.rawScore!.toStringAsFixed(1)} / 5',
                            _textOrDash(note.teacherName),
                            note.comment,
                          ],
                        )
                        .toList(),
                    emptyText:
                        'No teacher notes have been saved from teaching sessions.',
                  ),
              ],
            ),
            DetailSectionCard(
              title: 'Note Type Distribution',
              icon: Icons.pie_chart_outline,
              wrapChildren: false,
              children: [
                if (snapshot.connectionState == ConnectionState.waiting)
                  const DetailEmptySectionText('Loading note distribution...')
                else
                  DetailDataTable(
                    columns: const ['Type', 'Count'],
                    rows: (insights?.noteTypeCounts ?? const [])
                        .map((item) => [item.type.titleWords, item.count.toString()])
                        .toList(),
                    emptyText: 'No teacher note distribution is available.',
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

String _textOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value;
}
