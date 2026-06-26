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
        _HouseholdProfileSection(studentId: student.id),
        _RelationsTable(studentId: student.id),
      ],
    );
  }
}

class _HouseholdProfileSection extends StatelessWidget {
  const _HouseholdProfileSection({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentAdvancedFormData>(
      future: context.read<StudentDetailCubit>().loadAdvancedFormData(studentId),
      builder: (context, snapshot) {
        final household =
            snapshot.data?.householdProfile ??
            const StudentHouseholdProfileFormData();
        final rows = [
          if (_hasText(household.homeAddress))
            [context.l10n.homeAddress, household.homeAddress!],
          if (_hasText(household.housingStatus))
            [
              context.l10n.housingStatus,
              _housingStatusLabel(context, household.housingStatus!),
            ],
          if (household.householdMemberCount != null)
            [
              context.l10n.householdMemberCount,
              household.householdMemberCount.toString(),
            ],
          if (household.dailySchoolTransportCost != null)
            [
              context.l10n.dailySchoolTransportCost,
              _formatCurrency(household.dailySchoolTransportCost),
            ],
          if (household.fatherIncome != null)
            [context.l10n.fatherIncome, _formatCurrency(household.fatherIncome)],
          if (household.motherIncome != null)
            [context.l10n.motherIncome, _formatCurrency(household.motherIncome)],
          if (household.educationArrears != null)
            [
              context.l10n.educationArrears,
              _formatCurrency(household.educationArrears),
            ],
        ];

        return DetailSectionCard(
          title: context.l10n.householdProfile,
          icon: Icons.home_work_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.hasError)
              DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
            else if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loadingHouseholdProfile)
            else
              DetailDataTable(
                columns: [context.l10n.field, context.l10n.value],
                rows: rows,
                emptyText: context.l10n.noHouseholdProfile,
              ),
          ],
        );
      },
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
            if (snapshot.hasError)
              DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
            else if (snapshot.connectionState == ConnectionState.waiting)
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
            if (snapshot.hasError)
              DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
            else if (snapshot.connectionState == ConnectionState.waiting)
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
                  context.l10n.income,
                  context.l10n.address,
                ],
                rows: guardians
                    .where((item) => item.hasData)
                    .map(
                      (guardian) => [
                        _relationshipLabel(context, guardian.relationship),
                        guardian.isPrimary
                            ? context.l10n.yes
                            : context.l10n.no,
                        _textOrDash(guardian.fullName),
                        _textOrDash(guardian.mobileNo),
                        _textOrDash(guardian.email),
                        _textOrDash(guardian.occupation),
                        _formatCurrency(guardian.income),
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

  String _relationshipLabel(BuildContext context, String? value) {
    final raw = value?.trim() ?? '';
    return switch (raw.toUpperCase()) {
      'MOTHER' => context.l10n.familyRelationMother,
      'FATHER' => context.l10n.familyRelationFather,
      'BROTHER' => context.l10n.familyRelationBrother,
      'SISTER' => context.l10n.familyRelationSister,
      'UNCLE' => context.l10n.familyRelationUncle,
      'AUNTY' => context.l10n.familyRelationAunt,
      'GRANDPA' => context.l10n.familyRelationGrandfather,
      'GRANDMA' => context.l10n.familyRelationGrandmother,
      _ => _textOrDash(value),
    };
  }
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _formatCurrency(num? value) {
  if (value == null) return '-';
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write('.');
    }
  }
  return 'Rp ${buffer.toString()}';
}

String _housingStatusLabel(BuildContext context, String value) {
  return switch (value) {
    StudentHousingStatusOptions.owned => context.l10n.housingStatusOwned,
    StudentHousingStatusOptions.rented => context.l10n.housingStatusRented,
    StudentHousingStatusOptions.stayingWithFamily =>
      context.l10n.housingStatusStayingWithFamily,
    StudentHousingStatusOptions.other => context.l10n.housingStatusOther,
    _ => value,
  };
}
