import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/localization/localized_display.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/student_info_item.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentInformationSection extends StatelessWidget {
  const StudentInformationSection({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: boxDecoration.copyWith(color: AppColors.white),
      child: FutureBuilder<List<StudentGuardianFormData>>(
        future: context.read<StudentDetailCubit>().loadGuardians(student.id),
        builder: (context, snapshot) {
          final items = [
            MapEntry(context.l10n.fullName, student.fullName),
            MapEntry(context.l10n.nickName, student.nickName),
            MapEntry(context.l10n.studentNo, student.studentNo),
            MapEntry(context.l10n.nis, _textOrDash(student.nis)),
            MapEntry(context.l10n.birthDate, student.birthDate),
            MapEntry(context.l10n.joinDate, student.joinAt),
            MapEntry(
              context.l10n.gender,
              translateGender(context, student.gender.name),
            ),
            MapEntry(
              context.l10n.duafaStatus,
              _duafaStatus(context, snapshot.data ?? const []),
            ),
            MapEntry(
              context.l10n.teachingLocation,
              _textOrDash(student.teachingLocationName),
            ),
            MapEntry(context.l10n.school, student.schoolName),
            MapEntry(context.l10n.className, student.className),
            MapEntry(context.l10n.mobileNo, _textOrDash(student.mobileNo)),
            MapEntry(context.l10n.email, _textOrDash(student.emailAddr)),
          ];

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              var columnCount = 1;
              if (width >= 1100) {
                columnCount = 4;
              } else if (width >= 760) {
                columnCount = 3;
              } else if (width >= 520) {
                columnCount = 2;
              }
              const spacing = 10.0;
              final itemWidth =
                  (width - (spacing * (columnCount - 1))) / columnCount;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.personalProfile,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: spacing,
                    runSpacing: 8,
                    children: items
                        .map(
                          (item) => SizedBox(
                            width: itemWidth,
                            child: StudentInfoItem(
                              label: item.key,
                              value: item.value,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

String _duafaStatus(
  BuildContext context,
  List<StudentGuardianFormData> guardians,
) {
  final fatherDeceased = guardians.any(
    (guardian) =>
        guardian.relationship?.toUpperCase() == 'FATHER' &&
        guardian.isDeceased == true,
  );
  final motherDeceased = guardians.any(
    (guardian) =>
        guardian.relationship?.toUpperCase() == 'MOTHER' &&
        guardian.isDeceased == true,
  );

  if (fatherDeceased && motherDeceased) {
    return context.l10n.studentStatusYatimPiatu;
  }
  if (fatherDeceased) return context.l10n.studentStatusYatim;
  if (motherDeceased) return context.l10n.studentStatusPiatu;
  return context.l10n.studentStatusDhuafa;
}

String _textOrDash(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '-';
  }
  return value;
}
