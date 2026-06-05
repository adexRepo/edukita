import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentActivitiesTab extends StatelessWidget {
  const StudentActivitiesTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        FutureBuilder<List<StudentActivityFormData>>(
          future: context.read<StudentDetailCubit>().loadActivities(student.id),
          builder: (context, snapshot) {
            final activities =
                snapshot.data ?? const <StudentActivityFormData>[];
            final extracurricular = activities
                .where(
                  (activity) => !StudentActivityTypeOptions.isOtherActivity(
                    activity.type,
                  ),
                )
                .toList();
            final otherActivities = activities
                .where(
                  (activity) =>
                      StudentActivityTypeOptions.isOtherActivity(activity.type),
                )
                .toList();

            if (snapshot.connectionState == ConnectionState.waiting) {
              return DetailSectionCard(
                title: context.l10n.extracurricular,
                icon: Icons.emoji_events_outlined,
                wrapChildren: false,
                children: [
                  DetailEmptySectionText(context.l10n.loadingActivities),
                ],
              );
            }

            return Column(
              children: [
                DetailSectionCard(
                  title: context.l10n.extracurricular,
                  icon: Icons.emoji_events_outlined,
                  wrapChildren: false,
                  children: [
                    DetailDataTable(
                      columns: [
                        context.l10n.type,
                        context.l10n.activity,
                        context.l10n.role,
                        context.l10n.achievement,
                        context.l10n.startDate,
                        context.l10n.endDate,
                      ],
                      rows: extracurricular.map(_activityRow).toList(),
                      emptyText: context.l10n.noExtracurricularActivity,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DetailSectionCard(
                  title: context.l10n.extraActivityRecords,
                  icon: Icons.event_note_outlined,
                  wrapChildren: false,
                  children: [
                    DetailDataTable(
                      columns: [
                        context.l10n.type,
                        context.l10n.activity,
                        context.l10n.role,
                        context.l10n.achievement,
                        context.l10n.startDate,
                        context.l10n.endDate,
                      ],
                      rows: otherActivities.map(_activityRow).toList(),
                      emptyText: context.l10n.noExtraActivity,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<String> _activityRow(StudentActivityFormData activity) {
    return [
      StudentActivityTypeOptions.normalize(activity.type),
      _textOrDash(activity.name),
      _textOrDash(activity.role),
      _textOrDash(activity.achievement),
      _textOrDash(activity.startDate),
      _textOrDash(activity.endDate),
    ];
  }

  String _textOrDash(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value;
  }
}
