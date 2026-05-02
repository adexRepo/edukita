import 'package:edukita/features/management/guardian_model.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentFamilyTab extends StatelessWidget {
  const StudentFamilyTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        _GuardianTable(studentId: student.id),
        const DetailSectionCard(
          title: 'Student Relations',
          icon: Icons.account_tree_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Student', 'Relationship', 'Class', 'Status'],
              rows: [],
              emptyText:
                  'Sibling and family relations between students will appear here when relation records are available.',
            ),
          ],
        ),
      ],
    );
  }
}

class _GuardianTable extends StatelessWidget {
  const _GuardianTable({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentGuardianFormData>>(
      future: context.read<StudentDetailCubit>().loadGuardians(studentId),
      builder: (context, snapshot) {
        final guardians = snapshot.data ?? const <StudentGuardianFormData>[];

        return DetailSectionCard(
          title: 'Parents / Guardians',
          icon: Icons.family_restroom_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const DetailEmptySectionText('Loading guardian information...')
            else
              DetailDataTable(
                columns: const [
                  'Relationship',
                  'Primary',
                  'Name',
                  'Mobile',
                  'Email',
                  'Occupation',
                  'Address',
                ],
                rows: guardians
                    .where((item) => item.hasData)
                    .map(
                      (guardian) => [
                        _textOrDash(guardian.relationship),
                        guardian.isPrimary ? 'YES' : 'NO',
                        _textOrDash(guardian.fullName),
                        _textOrDash(guardian.mobileNo),
                        _textOrDash(guardian.email),
                        _textOrDash(guardian.occupation),
                        _textOrDash(guardian.address),
                      ],
                    )
                    .toList(),
                emptyText:
                    'No parent or guardian information has been added yet.',
              ),
          ],
        );
      },
    );
  }

  String _textOrDash(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value;
  }
}
