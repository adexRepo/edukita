import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentMoreTab extends StatelessWidget {
  const StudentMoreTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        const DetailSectionCard(
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
        const DetailSectionCard(
          title: 'Finance',
          icon: Icons.payments_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Fee Amount', 'Scholarship', 'Status'],
              rows: [],
              emptyText:
                  'Finance records will appear here from student_finance.',
            ),
          ],
        ),
        _GoalsTable(studentId: student.id),
        const DetailSectionCard(
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

class _GoalsTable extends StatelessWidget {
  const _GoalsTable({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentAdvancedFormData>(
      future: context.read<StudentDetailCubit>().loadAdvancedFormData(
        studentId,
      ),
      builder: (context, snapshot) {
        final advanced = snapshot.data ?? const StudentAdvancedFormData();
        final rows = <List<String>>[
          if (_hasText(advanced.hobby)) ['HOBBY', advanced.hobby!],
          if (_hasText(advanced.aspiration))
            ['ASPIRATION', advanced.aspiration!],
        ];

        return DetailSectionCard(
          title: 'Goals',
          icon: Icons.flag_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const DetailEmptySectionText('Loading goals...')
            else
              DetailDataTable(
                columns: const ['Category', 'Goal'],
                rows: rows,
                emptyText: 'No hobby or cita-cita has been added yet.',
              ),
          ],
        );
      },
    );
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
