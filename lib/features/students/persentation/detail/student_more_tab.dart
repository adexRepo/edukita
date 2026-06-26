import 'dart:io' as io;

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/core/utils/text_case.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class StudentMoreTab extends StatelessWidget {
  const StudentMoreTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        _RegistrationFormSection(studentId: student.id),
        _AssistanceHistoryTable(studentId: student.id),
        _GoalsTable(studentId: student.id),
      ],
    );
  }
}

class _RegistrationFormSection extends StatelessWidget {
  const _RegistrationFormSection({required this.studentId});

  final String studentId;

  Future<void> _download(
    BuildContext context,
    StudentDocumentFormData document,
  ) async {
    final unavailableMessage = context.l10n.registrationFormUnavailable;
    final notFoundMessage = context.l10n.registrationFormNotFound;
    final downloadedMessage = context.l10n.registrationFormDownloaded;
    final downloadFailedMessage = context.l10n.registrationFormDownloadFailed;
    final path = document.filePath?.trim();
    if (path == null || path.isEmpty) {
      AppToast.showFailed(unavailableMessage);
      return;
    }
    final source = io.File(path);
    if (!await source.exists()) {
      AppToast.showFailed(notFoundMessage);
      return;
    }
    final fileName = document.fileName?.trim().isNotEmpty == true
        ? document.fileName!
        : p.basename(path);
    final location = await getSaveLocation(
      suggestedName: generatedFileName(fileName),
    );
    if (location == null) return;
    try {
      if (p.normalize(source.path) != p.normalize(location.path)) {
        await source.copy(location.path);
      }
      AppToast.showSuccess(downloadedMessage);
    } catch (error) {
      AppToast.showFailed(downloadFailedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentAdvancedFormData>(
      future: context.read<StudentDetailCubit>().loadAdvancedFormData(studentId),
      builder: (context, snapshot) {
        final document = snapshot.data?.registrationForm;
        return DetailSectionCard(
          title: context.l10n.registrationForm,
          icon: Icons.assignment_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.hasError)
              DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
            else if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loadingRegistrationForm)
            else if (document == null || !document.hasFile)
              DetailEmptySectionText(context.l10n.noRegistrationFormUploaded)
            else
              Row(
                children: [
                  const Icon(Icons.description_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      document.fileName ?? p.basename(document.filePath ?? ''),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _download(context, document),
                    icon: const Icon(Icons.download_outlined, size: 17),
                    label: Text(context.l10n.download),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _AssistanceHistoryTable extends StatelessWidget {
  const _AssistanceHistoryTable({required this.studentId});

  final String studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentDetailInsights>(
      future: context.read<StudentDetailCubit>().loadDetailInsights(studentId),
      builder: (context, snapshot) {
        final history =
            snapshot.data?.assistanceHistory ??
            const <StudentAssistanceHistoryInsight>[];

        return DetailSectionCard(
          title: context.l10n.assistanceHistory,
          icon: Icons.volunteer_activism_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.hasError)
              DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
            else if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loadingAssistanceHistory)
            else
              DetailDataTable(
                columns: [
                  context.l10n.program,
                  context.l10n.period,
                  context.l10n.rule,
                  context.l10n.benefit,
                  context.l10n.status,
                  context.l10n.approvedAt,
                ],
                rows: history
                    .map(
                      (item) => [
                        item.programName,
                        item.periodName,
                        _textOrDash(item.ruleName),
                        _textOrDash(item.benefit),
                        item.status.titleWords,
                        _textOrDash(item.approvedAt),
                      ],
                    )
                    .toList(),
                emptyText: context.l10n.noAssistanceHistory,
              ),
          ],
        );
      },
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
          if (_hasText(advanced.hobby)) [context.l10n.hobby, advanced.hobby!],
          if (_hasText(advanced.aspiration))
            [context.l10n.aspiration, advanced.aspiration!],
        ];

        return DetailSectionCard(
          title: context.l10n.goals,
          icon: Icons.flag_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.hasError)
              DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
            else if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loadingGoals)
            else
              DetailDataTable(
                columns: [context.l10n.category, context.l10n.goal],
                rows: rows,
                emptyText: context.l10n.noGoals,
              ),
          ],
        );
      },
    );
  }

}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _textOrDash(String? value) {
  if (value == null || value.trim().isEmpty) return '-';
  return value;
}
