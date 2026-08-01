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
        _GeneratedReportsSection(studentId: student.id),
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

class _GeneratedReportsSection extends StatefulWidget {
  const _GeneratedReportsSection({required this.studentId});

  final String studentId;

  @override
  State<_GeneratedReportsSection> createState() =>
      _GeneratedReportsSectionState();
}

class _GeneratedReportsSectionState extends State<_GeneratedReportsSection> {
  late Future<List<StudentGeneratedReportFile>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = _loadReports();
  }

  Future<List<StudentGeneratedReportFile>> _loadReports() {
    return context.read<StudentDetailCubit>().loadGeneratedReports(
      widget.studentId,
    );
  }

  void _refresh() {
    setState(() {
      _reportsFuture = _loadReports();
    });
  }

  Future<void> _download(
    BuildContext context,
    StudentGeneratedReportFile report,
  ) async {
    final path = report.filePath.trim();
    if (path.isEmpty) {
      AppToast.showFailed('File report tidak tersedia.');
      return;
    }
    final source = io.File(path);
    if (!await source.exists()) {
      AppToast.showFailed('File report tidak ditemukan.');
      return;
    }
    final location = await getSaveLocation(
      suggestedName: generatedFileName(report.fileName),
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    );
    if (location == null) return;
    try {
      if (p.normalize(source.path) != p.normalize(location.path)) {
        await source.copy(location.path);
      }
      AppToast.showSuccess('Report berhasil diunduh.');
    } catch (error) {
      AppToast.showFailed('Gagal mengunduh report: $error');
    }
  }

  Future<void> _archive(
    BuildContext context,
    StudentGeneratedReportFile report,
  ) async {
    final cubit = context.read<StudentDetailCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Archive generated report?'),
        content: Text(
          'Report "${report.fileName}" akan disembunyikan dari history aktif. File fisik tidak dihapus dari lokasi penyimpanan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await cubit.archiveGeneratedReport(
        studentId: widget.studentId,
        reportId: report.id,
      );
      if (!mounted) return;
      _refresh();
      AppToast.showSuccess('Report berhasil di-archive.');
    } catch (error) {
      AppToast.showFailed('Gagal archive report: $error');
    }
  }

  void _showDetail(BuildContext context, StudentGeneratedReportFile report) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Generated report detail'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailLine('File', report.fileName),
                _detailLine('Generated at', _textOrDash(report.generatedAt)),
                _detailLine('Generated by', _textOrDash(report.generatedBy)),
                _detailLine('Completeness', report.completenessSnapshot),
                _detailLine('Version note', report.versionNote),
                _detailLine('File size', _formatFileSize(report.fileSize)),
                _detailLine('Path', report.filePath),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StudentGeneratedReportFile>>(
      future: _reportsFuture,
      builder: (context, snapshot) {
        final reports =
            snapshot.data ?? const <StudentGeneratedReportFile>[];
        return DetailSectionCard(
          title: 'Generated Report History',
          icon: Icons.history_edu_outlined,
          wrapChildren: false,
          children: [
            if (snapshot.hasError)
              DetailEmptySectionText(context.l10n.errorSomethingWentWrong)
            else if (snapshot.connectionState == ConnectionState.waiting)
              DetailEmptySectionText(context.l10n.loading)
            else if (reports.isEmpty)
              const DetailEmptySectionText(
                'Belum ada Student Story PDF yang pernah di-generate.',
              )
            else
              _GeneratedReportsTable(
                reports: reports,
                onDownload: (report) => _download(context, report),
                onDetail: (report) => _showDetail(context, report),
                onArchive: (report) => _archive(context, report),
              ),
          ],
        );
      },
    );
  }

  Widget _detailLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.captionStyle),
          const SizedBox(height: 2),
          SelectableText(value, style: AppTypography.bodyStyle),
        ],
      ),
    );
  }
}

class _GeneratedReportsTable extends StatelessWidget {
  const _GeneratedReportsTable({
    required this.reports,
    required this.onDownload,
    required this.onDetail,
    required this.onArchive,
  });

  final List<StudentGeneratedReportFile> reports;
  final ValueChanged<StudentGeneratedReportFile> onDownload;
  final ValueChanged<StudentGeneratedReportFile> onDetail;
  final ValueChanged<StudentGeneratedReportFile> onArchive;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const minTableWidth = 760.0;
            final tableWidth = constraints.maxWidth > minTableWidth
                ? constraints.maxWidth
                : minTableWidth;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: tableWidth,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: const TableBorder(
                    horizontalInside: BorderSide(color: AppColors.divider),
                    verticalInside: BorderSide(color: AppColors.divider),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1.1),
                    4: FixedColumnWidth(108),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceSoft,
                      ),
                      children: [
                        _header('File'),
                        _header('Generated At'),
                        _header('Generated By'),
                        _header('Completeness'),
                        _header('Action', center: true),
                      ],
                    ),
                    for (final report in reports)
                      TableRow(
                        children: [
                          _cell(report.fileName),
                          _cell(_textOrDash(report.generatedAt)),
                          _cell(_textOrDash(report.generatedBy)),
                          _cell(report.completenessSnapshot),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Center(
                              child: Wrap(
                                spacing: 2,
                                children: [
                                  IconButton(
                                    tooltip: 'Report detail',
                                    constraints:
                                        const BoxConstraints.tightFor(
                                      width: 30,
                                      height: 30,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => onDetail(report),
                                    icon: const Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Download report',
                                    constraints:
                                        const BoxConstraints.tightFor(
                                      width: 30,
                                      height: 30,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => onDownload(report),
                                    icon: const Icon(
                                      Icons.download_outlined,
                                      size: 18,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Archive report',
                                    constraints:
                                        const BoxConstraints.tightFor(
                                      width: 30,
                                      height: 30,
                                    ),
                                    padding: EdgeInsets.zero,
                                    onPressed: () => onArchive(report),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(String value, {bool center = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        value,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _cell(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
          height: 1.25,
        ),
      ),
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

String _formatFileSize(int bytes) {
  if (bytes <= 0) return '-';
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
  final mb = kb / 1024;
  return '${mb.toStringAsFixed(1)} MB';
}
