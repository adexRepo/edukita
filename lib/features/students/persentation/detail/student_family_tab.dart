import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
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
        _RelationsTable(studentId: student.id),
      ],
    );
  }
}

class _RelationsTable extends StatelessWidget {
  const _RelationsTable({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentRelationFormData>>(
      future: context.read<StudentDetailCubit>().loadRelations(studentId),
      builder: (context, snapshot) {
        final relations = snapshot.data ?? const <StudentRelationFormData>[];

        return DetailSectionCard(
          title: context.l10n.studentRelations,
          icon: Icons.account_tree_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loadingStudentRelations)
            else
              DetailDataTable(
                columns: [
                  context.l10n.studentNo,
                  context.l10n.name,
                  context.l10n.relation,
                  context.l10n.agePosition,
                ],
                rows: relations
                    .where((relation) => relation.hasData)
                    .map(
                      (relation) => [
                        _textOrDash(relation.relatedStudentNo),
                        _textOrDash(relation.relatedStudentName),
                        _textOrDash(relation.relationType),
                        _textOrDash(relation.agePosition),
                      ],
                    )
                    .toList(),
                emptyText: context.l10n.noStudentRelations,
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
          title: context.l10n.parentsGuardians,
          icon: Icons.family_restroom_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loadingGuardianInformation)
            else
              DetailDataTable(
                columns: [
                  context.l10n.relationship,
                  context.l10n.primary,
                  context.l10n.name,
                  context.l10n.mobile,
                  context.l10n.email,
                  context.l10n.occupation,
                  context.l10n.address,
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
                emptyText: context.l10n.noGuardianInformation,
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
