import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:edukita/features/students/persentation/detail/student_information_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentPersonalTab extends StatelessWidget {
  const StudentPersonalTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        StudentInformationSection(student: student),
        _HealthTable(studentId: student.id),
        const DetailSectionCard(
          title: 'Learning Profile',
          icon: Icons.psychology_alt_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                'Learning Style',
                'Pace',
                'Attention',
                'Motivation',
                'Notes',
              ],
              rows: [],
              emptyText:
                  'Learning profile records will appear here from student_learning_profiles.',
            ),
          ],
        ),
        const DetailSectionCard(
          title: 'Well-being',
          icon: Icons.self_improvement_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                'Recorded At',
                'Stress',
                'Confidence',
                'Counseling Notes',
                'Notes',
              ],
              rows: [],
              emptyText:
                  'Well-being records will appear here from student_wellbeing.',
            ),
          ],
        ),
      ],
    );
  }
}

class _HealthTable extends StatelessWidget {
  const _HealthTable({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentAdvancedFormData>(
      future: context.read<StudentDetailCubit>().loadAdvancedFormData(
        studentId,
      ),
      builder: (context, snapshot) {
        final health = snapshot.data?.health ?? const StudentHealthFormData();
        return DetailSectionCard(
          title: 'Health',
          icon: Icons.medical_information_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const DetailEmptySectionText('Loading health information...')
            else
              DetailDataTable(
                columns: const [
                  'Blood Type',
                  'Allergies',
                  'Medical Notes',
                  'Disabilities',
                  'Updated At',
                ],
                rows: health.hasData
                    ? [
                        [
                          _textOrDash(health.bloodType),
                          _textOrDash(health.allergies),
                          _textOrDash(health.medicalNotes),
                          _textOrDash(health.disabilities),
                          _textOrDash(health.updatedAt),
                        ],
                      ]
                    : const [],
                emptyText: 'No health information has been added yet.',
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
