import 'dart:io' as io;

import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/core/utils/generated_file_name.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/data/student_exam_score_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/students/persentation/student_form_card.dart';
import 'package:edukita/features/students/persentation/student_form_dialog.dart';
import 'package:edukita/features/teaching_locations/data/teaching_location_model.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_dialog_skeleton.dart';
import 'package:edukita/widgets/app_toast.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class StudentStoryReportCard extends StatefulWidget {
  const StudentStoryReportCard({
    super.key,
    required this.student,
    required this.canUpdateStudent,
  });

  final StudentDetailData student;
  final bool canUpdateStudent;

  @override
  State<StudentStoryReportCard> createState() => _StudentStoryReportCardState();
}

class _StudentStoryReportCardState extends State<StudentStoryReportCard> {
  bool _loading = false;
  bool _openingFullRegistration = false;
  Future<_StudentDataCompleteness>? _completenessFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _completenessFuture ??= _loadCompleteness();
  }

  Future<_StudentDataCompleteness> _loadCompleteness() async {
    final cubit = context.read<StudentDetailCubit>();
    try {
      final currentStudent = cubit.state.data?.id == widget.student.id
          ? cubit.state.data!
          : widget.student;
      final advanced = await cubit.loadAdvancedFormData(widget.student.id);
      final guardians = await cubit.loadGuardians(widget.student.id);
      return _StudentDataCompleteness.fromData(
        student: currentStudent,
        advanced: advanced,
        guardians: guardians,
      );
    } catch (_) {
      return _StudentDataCompleteness.unknown(widget.student.profileStatus);
    }
  }

  Future<_StudentStorySnapshot?> _loadSnapshot() async {
    setState(() => _loading = true);
    final cubit = context.read<StudentDetailCubit>();
    try {
      final latestStudent =
          await cubit.refreshLatest(widget.student.id) ?? widget.student;
      final advanced = await cubit.loadAdvancedFormData(widget.student.id);
      final guardians = await cubit.loadGuardians(widget.student.id);
      final relations = await cubit.loadRelations(widget.student.id);
      final activities = await cubit.loadActivities(widget.student.id);
      final insights = await cubit.loadDetailInsights(widget.student.id);
      final examScores = await cubit.loadStudentExamScores(widget.student.id);
      final latestSpecialNote = await cubit.loadLatestSpecialNote(widget.student.id);

      return _StudentStorySnapshot(
        student: latestStudent,
        advanced: advanced,
        guardians: guardians,
        relations: relations,
        activities: activities,
        insights: insights,
        examScores: examScores,
        latestSpecialNote: latestSpecialNote,
      );
    } catch (error) {
      AppToast.showFailed('Gagal memuat student story: $error');
      return null;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _preview() async {
    final completeness = await (_completenessFuture ??= _loadCompleteness());
    if (!mounted) return;
    if (completeness.isQuickRegistered) {
      await _showCompletenessChecklist();
      return;
    }
    final snapshotFuture = _loadSnapshot();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _StudentStoryLoaderDialog(
        snapshotFuture: snapshotFuture,
        onDownload: _downloadPdf,
      ),
    );
  }

  Future<void> _download() async {
    final completeness = await (_completenessFuture ??= _loadCompleteness());
    if (!mounted) return;
    if (completeness.isQuickRegistered) {
      AppToast.showFailed(
        'Student story belum tersedia untuk siswa daftar cepat. Lengkapi profil siswa terlebih dahulu.',
      );
      await _showCompletenessChecklist();
      return;
    }
    final snapshot = await _loadSnapshot();
    if (!mounted || snapshot == null) return;
    await _downloadPdf(_StudentStoryReportBuilder.build(snapshot, _storyText(context)));
  }

  Future<void> _showCompletenessChecklist() async {
    final completeness = await (_completenessFuture ??= _loadCompleteness());
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => _CompletenessChecklistDialog(
        completeness: completeness,
        onCompleteProfile: _openFullRegistration,
      ),
    );
  }

  Future<void> _openFullRegistration() async {
    Navigator.of(context, rootNavigator: true).pop();
    if (!widget.canUpdateStudent) {
      AppToast.showFailed(context.l10n.studentUpdateDenied);
      return;
    }
    if (_openingFullRegistration) return;
    setState(() => _openingFullRegistration = true);

    final cubit = context.read<StudentDetailCubit>();
    final loadFuture = _loadFullRegistrationData(cubit);
    try {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => _FullRegistrationLoaderDialog(
          loadFuture: loadFuture,
          onClose: () => Navigator.of(dialogContext).pop(),
          onSubmit: (data, updatedStudent, schoolId, guardians, advanced) async {
            await cubit.updateStudent(
              updatedStudent,
              schoolId,
              guardians,
              advanced,
            );
            _completenessFuture = _loadCompleteness();
          },
        ),
      );
      if (!mounted) return;
      setState(() {
        _completenessFuture = _loadCompleteness();
      });
    } finally {
      if (mounted) setState(() => _openingFullRegistration = false);
    }
  }

  Future<_FullRegistrationData> _loadFullRegistrationData(
    StudentDetailCubit cubit,
  ) async {
    final studentNotFoundMessage = 'Student not found.';
    final createSchoolMessage = context.l10n.createSchoolBeforeAddingStudents;
    final createClassMessage = context.l10n.createClassBeforeAddingStudents;
    final createLocationMessage =
        context.l10n.createTeachingLocationBeforeStudents;
    final results = await Future.wait<Object?>([
      cubit.loadAvailableSchools(),
      cubit.loadAvailableClasses(),
      cubit.loadAvailableTeachingLocations(),
      cubit.loadStudent(widget.student.id),
      cubit.loadGuardians(widget.student.id),
      cubit.loadAdvancedFormData(widget.student.id),
    ]);

    final schools = results[0] as List<School>;
    final classes = results[1] as List<SchoolClass>;
    final teachingLocations = results[2] as List<TeachingLocation>;
    final student = results[3] as Student?;
    final guardians = results[4] as List<StudentGuardianFormData>;
    final advancedData = results[5] as StudentAdvancedFormData;

    if (student == null) {
      throw StateError(studentNotFoundMessage);
    }
    if (schools.isEmpty) {
      throw StateError(createSchoolMessage);
    }
    if (classes.isEmpty) {
      throw StateError(createClassMessage);
    }
    if (teachingLocations.isEmpty) {
      throw StateError(createLocationMessage);
    }

    return _FullRegistrationData(
      schools: schools,
      classes: classes,
      teachingLocations: teachingLocations,
      student: student,
      guardians: guardians,
      advancedData: advancedData,
      onSiblingLookup: cubit.lookupSiblingFamily,
    );
  }

  Future<void> _downloadPdf(_StudentStoryReport report) async {
    final canContinue = await _confirmReportQuality(report);
    if (!mounted || !canContinue) return;
    final versionNote = await _askReportVersionNote(report);
    if (!mounted || versionNote == null) return;

    final cubit = context.read<StudentDetailCubit>();
    final generatedAt = DateTime.now();
    final session = await AuthSessionCache.instance.read();
    final generatedBy = session?.username ?? 'Edukita';
    final documentNo =
        'SSR-${report.student.studentNo}-${_compactTimestamp(generatedAt)}';
    final fileBaseName = _safeFileName(
      '${report.student.studentNo}-${report.student.fullName}-student-story.pdf',
    );
    final location = await getSaveLocation(
      suggestedName: generatedFileName(fileBaseName),
      acceptedTypeGroups: [
        const XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    );
    if (location == null) return;

    try {
      final document = pw.Document();
      document.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            margin: const pw.EdgeInsets.all(32),
            theme: pw.ThemeData.withFont(
              base: pw.Font.helvetica(),
              bold: pw.Font.helveticaBold(),
            ),
          ),
          build: (_) => [
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: PdfColors.cyan50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.cyan200),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 34,
                    height: 34,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.cyan400,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'E',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Edukita ${report.text.reportTitle}',
                          style: pw.TextStyle(
                            fontSize: 17,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          '${report.text.documentNo}: $documentNo | ${report.text.preparedBy}: $generatedBy',
                          style: pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.blueGrey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.6),
              columnWidths: {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  children: [
                    _pdfInfoCell(report.text.student, report.student.fullName),
                    _pdfInfoCell(report.text.studentNo, report.student.studentNo),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _pdfInfoCell(report.text.classSchool, '${report.student.className} / ${report.student.schoolName}'),
                    _pdfInfoCell(report.text.teachingLocation, _orDash(report.student.teachingLocationName)),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _pdfInfoCell(report.text.profileStatus, _profileStatus(report.student.profileStatus)),
                    _pdfInfoCell(report.text.dataCompleteness, '${report.completeness.label} ${report.completeness.total > 0 ? '(${report.completeness.scoreLabel})' : ''}'),
                  ],
                ),
                pw.TableRow(
                  children: [
                    _pdfInfoCell(report.text.documentNo, documentNo),
                    _pdfInfoCell(report.text.generatedBy, generatedBy),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: report.completeness.isQuickRegistered
                    ? PdfColors.amber50
                    : PdfColors.blueGrey50,
                borderRadius: pw.BorderRadius.circular(6),
                border: pw.Border.all(
                  color: report.completeness.isQuickRegistered
                      ? PdfColors.amber300
                      : PdfColors.blueGrey100,
                ),
              ),
              child: pw.Text(
                report.completeness.message,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.blueGrey800,
                  height: 1.35,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            _pdfStorySection(
              indexLabel: '00',
              title: report.text.executiveSummary,
              paragraphs: [report.executiveSummary],
              highlight: true,
            ),
            pw.SizedBox(height: 10),
            ...report.sections
                .where((section) => section.title != report.text.executiveSummary)
                .toList()
                .asMap()
                .entries
                .map(
                  (entry) => _pdfStorySection(
                    indexLabel: (entry.key + 1).toString().padLeft(2, '0'),
                    title: entry.value.title,
                    paragraphs: entry.value.paragraphs,
                  ),
                ),
            pw.Divider(color: PdfColors.grey400),
            pw.Text(
              report.text.pdfDisclaimer,
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 24),
            pw.Row(
              children: [
                _pdfSignatureBox(report.text.preparedBy, report.text.nameSignature),
                pw.SizedBox(width: 12),
                _pdfSignatureBox(report.text.reviewedBy, report.text.nameSignature),
                pw.SizedBox(width: 12),
                _pdfSignatureBox(report.text.parentGuardian, report.text.nameSignature),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                '${report.text.generated}: ${generatedAt.toIso8601String()}',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ),
          ],
        ),
      );

      await io.File(location.path).writeAsBytes(await document.save());
      await cubit.registerStudentStoryReport(
        studentId: report.student.id,
        filePath: location.path,
        fileName: p.basename(location.path),
        remarks: _reportRemarks(report, versionNote),
      );
      AppToast.showSuccess('Student story berhasil diunduh.');
    } catch (error) {
      AppToast.showFailed('Gagal membuat PDF: $error');
    }
  }

  Future<String?> _askReportVersionNote(_StudentStoryReport report) async {
    final l10n = context.l10n;
    final controller = TextEditingController(
      text: report.completeness.isQuickRegistered
          ? l10n.studentStoryDefaultDraftNote
          : l10n.studentStoryDefaultGeneratedNote,
    );
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.reportVersionNoteTitle),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: TextField(
            controller: controller,
            maxLength: 120,
            decoration: InputDecoration(
              labelText: l10n.versionNote,
              hintText: l10n.versionNoteHint,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.buttonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(
              controller.text.trim().isEmpty
                  ? l10n.studentStoryDefaultGeneratedNote
                  : controller.text.trim(),
            ),
            child: Text(l10n.buttonContinue),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<bool> _confirmReportQuality(_StudentStoryReport report) async {
    if (report.completeness.isQuickRegistered) {
      AppToast.showFailed(
        'Student story belum tersedia untuk siswa daftar cepat. Lengkapi profil siswa terlebih dahulu.',
      );
      return false;
    }
    if (!report.completeness.needsQualityWarning) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.reportDataIncompleteTitle),
        content: SingleChildScrollView(
          child: Text(
            '${report.completeness.message}\n\n${context.l10n.reportDataIncompleteMessage}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.buttonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.downloadDraftPdf),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      title: context.l10n.studentStoryReportTitle,
      icon: Icons.auto_stories_outlined,
      wrapChildren: false,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              return FutureBuilder<_StudentDataCompleteness>(
                future: _completenessFuture,
                builder: (context, snapshot) {
                  final completeness =
                      snapshot.data ??
                      _StudentDataCompleteness.unknown(
                        widget.student.profileStatus,
                      );
                  final isQuick = completeness.isQuickRegistered;
                  final description = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isQuick
                            ? 'Student story belum tersedia'
                            : 'Narasi lengkap yang selalu dibuat dari data terbaru siswa.',
                        style: AppTypography.bodyStrongStyle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isQuick
                            ? 'Siswa ini dibuat melalui daftar cepat. Lengkapi profil siswa terlebih dahulu sebelum membuat cerita siswa atau PDF report.'
                            : 'Mencakup profil, keluarga, kondisi ekonomi, akademik, kehadiran, catatan guru, aktivitas, bantuan, kekuatan, perkembangan, area dukungan, dan saran ringan.',
                        style: AppTypography.secondaryStyle,
                      ),
                      const SizedBox(height: 10),
                      _CompletenessIndicator(
                        completeness: completeness,
                        onTap: _showCompletenessChecklist,
                      ),
                    ],
                  );
                  final actions = Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: compact
                        ? WrapAlignment.start
                        : WrapAlignment.end,
                    children: [
                      if (!isQuick) ...[
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _preview,
                          icon: _loading
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.visibility_outlined, size: 17),
                          label: const Text('Preview'),
                        ),
                        FilledButton.icon(
                          onPressed: _loading ? null : _download,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          icon: const Icon(Icons.download_outlined, size: 17),
                          label: Text(context.l10n.downloadPdf),
                        ),
                      ],
                      if (completeness.needsAction)
                        TextButton.icon(
                          onPressed: _showCompletenessChecklist,
                          icon: const Icon(Icons.playlist_add_check, size: 17),
                          label: Text(
                            'Lengkapi Profil',
                          ),
                        ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        description,
                        const SizedBox(height: 12),
                        actions,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: description),
                      const SizedBox(width: 16),
                      actions,
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StudentStoryLoaderDialog extends StatelessWidget {
  const _StudentStoryLoaderDialog({
    required this.snapshotFuture,
    required this.onDownload,
  });

  final Future<_StudentStorySnapshot?> snapshotFuture;
  final Future<void> Function(_StudentStoryReport report) onDownload;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_StudentStorySnapshot?>(
      future: snapshotFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StudentStoryLoadingDialog();
        }
        final data = snapshot.data;
        if (data == null) {
          return Dialog(
            insetPadding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.studentStoryLoadFailed,
                      style: AppTypography.pageTitleStyle,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Silakan tutup dialog dan coba buka preview lagi.',
                      style: AppTypography.bodyStyle,
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.close),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        final report = _StudentStoryReportBuilder.build(data, _storyText(context));
        return _StudentStoryDialog(
          report: report,
          onDownload: () => onDownload(report),
        );
      },
    );
  }
}

class _StudentStoryLoadingDialog extends StatelessWidget {
  const _StudentStoryLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.generatingStudentStory,
                          style: AppTypography.pageTitleStyle,
                        ),
                        SizedBox(height: 3),
                        Text(
                          context.l10n.generatingStudentStoryDescription,
                          style: AppTypography.secondaryStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              for (var index = 0; index < 4; index++) ...[
                Container(
                  height: index == 0 ? 16 : 12,
                  width: index == 0 ? 240 : double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentStoryDialog extends StatelessWidget {
  const _StudentStoryDialog({required this.report, required this.onDownload});

  final _StudentStoryReport report;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 760),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.studentStoryReportTitle,
                          style: AppTypography.pageTitleStyle,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${report.student.fullName} (${report.student.studentNo})',
                          style: AppTypography.secondaryStyle,
                        ),
                        const SizedBox(height: 8),
                        _CompletenessIndicator(
                          completeness: report.completeness,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.downloadPdf,
                    onPressed: onDownload,
                    icon: const Icon(Icons.download_outlined),
                  ),
                  IconButton(
                    tooltip: context.l10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                children: [
                  _StoryExecutiveCard(report: report),
                  const SizedBox(height: 16),
                  for (final entry in report.sections
                      .where((section) => section.title != report.text.executiveSummary)
                      .toList()
                      .asMap()
                      .entries) ...[
                    _StorySectionCard(
                      index: entry.key + 1,
                      section: entry.value,
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryExecutiveCard extends StatelessWidget {
  const _StoryExecutiveCard({required this.report});

  final _StudentStoryReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '00',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  report.text.executiveSummary,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StoryParagraphText(report.executiveSummary),
        ],
      ),
    );
  }
}

class _StorySectionCard extends StatelessWidget {
  const _StorySectionCard({
    required this.index,
    required this.section,
  });

  final int index;
  final _StudentStorySection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  index.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    section.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < section.paragraphs.length; i++) ...[
            _StoryParagraphText(section.paragraphs[i]),
            if (i != section.paragraphs.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _StoryParagraphText extends StatelessWidget {
  const _StoryParagraphText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final split = _splitParagraphLead(text);
    final textStyle = AppTypography.bodyStyle.copyWith(
      height: 1.55,
      fontSize: 13,
      color: AppColors.textPrimary,
    );
    if (split == null) {
      return Text(text, style: textStyle);
    }

    return RichText(
      text: TextSpan(
        style: textStyle,
        children: [
          TextSpan(
            text: '${split.lead}: ',
            style: textStyle.copyWith(fontWeight: FontWeight.w900),
          ),
          TextSpan(text: split.body),
        ],
      ),
    );
  }
}

pw.Widget _pdfInfoCell(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 7,
            color: PdfColors.grey600,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 9, color: PdfColors.blueGrey900),
        ),
      ],
    ),
  );
}

pw.Widget _pdfStorySection({
  required String indexLabel,
  required String title,
  required List<String> paragraphs,
  bool highlight = false,
}) {
  final borderColor = highlight ? PdfColors.cyan200 : PdfColors.grey300;
  final background = highlight ? PdfColors.cyan50 : PdfColors.white;
  final badgeColor = highlight ? PdfColors.cyan500 : PdfColors.blueGrey100;
  final badgeTextColor = highlight ? PdfColors.white : PdfColors.blueGrey700;

  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 10),
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      color: background,
      borderRadius: pw.BorderRadius.circular(7),
      border: pw.Border.all(color: borderColor, width: 0.7),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 22,
              height: 22,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: badgeColor,
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Text(
                indexLabel,
                style: pw.TextStyle(
                  color: badgeTextColor,
                  fontSize: 7,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.only(top: 3),
                child: pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        for (var i = 0; i < paragraphs.length; i++) ...[
          _pdfParagraph(paragraphs[i]),
          if (i != paragraphs.length - 1) pw.SizedBox(height: 6),
        ],
      ],
    ),
  );
}

pw.Widget _pdfParagraph(String text) {
  final split = _splitParagraphLead(text);
  final baseStyle = pw.TextStyle(
    fontSize: 9.4,
    height: 1.45,
    color: PdfColors.blueGrey900,
  );
  if (split == null) {
    return pw.Text(text, style: baseStyle);
  }

  return pw.RichText(
    text: pw.TextSpan(
      style: baseStyle,
      children: [
        pw.TextSpan(
          text: '${split.lead}: ',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.TextSpan(text: split.body),
      ],
    ),
  );
}

pw.Widget _pdfSignatureBox(String label, String nameSignature) {
  return pw.Expanded(
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 30),
        pw.Container(height: 0.7, color: PdfColors.grey500),
        pw.SizedBox(height: 4),
        pw.Text(nameSignature, style: pw.TextStyle(fontSize: 7)),
      ],
    ),
  );
}

class _StudentStoryReport {
  const _StudentStoryReport({
    required this.student,
    required this.executiveSummary,
    required this.completeness,
    required this.sections,
    required this.text,
  });

  final StudentDetailData student;
  final String executiveSummary;
  final _StudentDataCompleteness completeness;
  final List<_StudentStorySection> sections;
  final _StudentStoryText text;
}

class _StudentStoryText {
  const _StudentStoryText({
    required this.reportTitle,
    required this.executiveSummary,
    required this.student,
    required this.studentNo,
    required this.classSchool,
    required this.teachingLocation,
    required this.profileStatus,
    required this.dataCompleteness,
    required this.documentNo,
    required this.generatedBy,
    required this.preparedBy,
    required this.reviewedBy,
    required this.parentGuardian,
    required this.nameSignature,
    required this.generated,
    required this.pdfDisclaimer,
    required this.defaultGeneratedNote,
  });

  final String reportTitle;
  final String executiveSummary;
  final String student;
  final String studentNo;
  final String classSchool;
  final String teachingLocation;
  final String profileStatus;
  final String dataCompleteness;
  final String documentNo;
  final String generatedBy;
  final String preparedBy;
  final String reviewedBy;
  final String parentGuardian;
  final String nameSignature;
  final String generated;
  final String pdfDisclaimer;
  final String defaultGeneratedNote;
}

_StudentStoryText _storyText(BuildContext context) {
  final l10n = context.l10n;
  return _StudentStoryText(
    reportTitle: l10n.studentStoryReportTitle,
    executiveSummary: l10n.studentStoryExecutiveSummary,
    student: l10n.student,
    studentNo: l10n.studentNo,
    classSchool: l10n.classSchool,
    teachingLocation: l10n.teachingLocation,
    profileStatus: l10n.profileStatus,
    dataCompleteness: l10n.dataCompleteness,
    documentNo: l10n.documentNo,
    generatedBy: l10n.generatedBy,
    preparedBy: l10n.preparedBy,
    reviewedBy: l10n.reviewedBy,
    parentGuardian: l10n.parentGuardian,
    nameSignature: l10n.nameSignature,
    generated: l10n.generated,
    pdfDisclaimer: l10n.studentStoryPdfDisclaimer,
    defaultGeneratedNote: l10n.studentStoryDefaultGeneratedNote,
  );
}

class _StudentStorySection {
  const _StudentStorySection({
    required this.title,
    required this.paragraphs,
  });

  final String title;
  final List<String> paragraphs;
}

class _StudentStorySnapshot {
  const _StudentStorySnapshot({
    required this.student,
    required this.advanced,
    required this.guardians,
    required this.relations,
    required this.activities,
    required this.insights,
    required this.examScores,
    this.latestSpecialNote,
  });

  final StudentDetailData student;
  final StudentAdvancedFormData advanced;
  final List<StudentGuardianFormData> guardians;
  final List<StudentRelationFormData> relations;
  final List<StudentActivityFormData> activities;
  final StudentDetailInsights insights;
  final List<StudentExamScoreGroup> examScores;
  final StudentSpecialNote? latestSpecialNote;
}

class _StudentDataCompleteness {
  const _StudentDataCompleteness({
    required this.completed,
    required this.total,
    required this.missingItems,
    required this.isQuickRegistered,
  });

  final int completed;
  final int total;
  final List<String> missingItems;
  final bool isQuickRegistered;

  double get ratio => total == 0 ? 0 : completed / total;

  String get label {
    if (isQuickRegistered) return 'Draft - perlu dilengkapi';
    if (ratio >= 0.85) return 'Data lengkap';
    if (ratio >= 0.55) return 'Data cukup';
    return 'Data perlu dilengkapi';
  }

  String get message {
    if (isQuickRegistered) {
      return 'Siswa dibuat melalui daftar cepat, sehingga profil lengkap perlu segera dilengkapi sebelum report digunakan sebagai dokumen final.';
    }
    if (missingItems.isEmpty) {
      return 'Data utama sudah tersedia untuk membuat report perkembangan yang lebih utuh.';
    }
    return 'Masih perlu melengkapi ${_joinNatural(missingItems.take(4).toList())}.';
  }

  Color get color {
    if (isQuickRegistered || ratio < 0.55) return AppColors.warning;
    if (ratio >= 0.85) return AppColors.success;
    return AppColors.accentBlue;
  }

  String get scoreLabel => '$completed/$total';

  bool get needsAction => isQuickRegistered || missingItems.isNotEmpty;

  bool get needsQualityWarning {
    if (isQuickRegistered) return true;
    if (total == 0) return true;
    return ratio < 0.85;
  }

  factory _StudentDataCompleteness.fromData({
    required StudentDetailData student,
    required StudentAdvancedFormData advanced,
    required List<StudentGuardianFormData> guardians,
  }) {
    final checks = <String, bool>{
      'data dasar': _hasText(student.fullName) &&
          _hasText(student.studentNo) &&
          _hasText(student.className) &&
          _hasText(student.schoolName),
      'lokasi binaan': _hasText(student.teachingLocationName),
      'kontak siswa': _hasText(student.mobileNo) || _hasText(student.emailAddr),
      'atribut fisik': student.height != null ||
          student.weight != null ||
          _hasText(student.shoesSize) ||
          _hasText(student.uniformSize) ||
          _hasText(student.pantsSize),
      'minat dan cita-cita': _hasText(advanced.hobby) ||
          _hasText(advanced.aspiration),
      'orang tua/wali': guardians.any((item) => item.hasData),
      'profil rumah tangga': advanced.householdProfile.hasData,
      'aktivitas': advanced.activities.any((item) => item.hasData),
    };
    final missing = checks.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
    return _StudentDataCompleteness(
      completed: checks.length - missing.length,
      total: checks.length,
      missingItems: missing,
      isQuickRegistered: student.profileStatus == 'quick_registered',
    );
  }

  factory _StudentDataCompleteness.unknown(String profileStatus) {
    return _StudentDataCompleteness(
      completed: profileStatus == 'quick_registered' ? 1 : 0,
      total: 0,
      missingItems: const [],
      isQuickRegistered: profileStatus == 'quick_registered',
    );
  }
}

class _CompletenessChecklistDialog extends StatelessWidget {
  const _CompletenessChecklistDialog({
    required this.completeness,
    required this.onCompleteProfile,
  });

  final _StudentDataCompleteness completeness;
  final VoidCallback onCompleteProfile;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: completeness.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.playlist_add_check,
                      color: completeness.color,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lengkapi Profil Siswa',
                          style: AppTypography.pageTitleStyle,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${completeness.label}${completeness.total > 0 ? ' (${completeness.scoreLabel})' : ''}',
                          style: AppTypography.secondaryStyle,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: completeness.color.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: completeness.color.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Text(
                      completeness.message,
                      style: AppTypography.bodyStyle,
                    ),
                  ),
                  if (completeness.isQuickRegistered) ...[
                    const SizedBox(height: 12),
                    _quickRegisterNotice(
                      onPressed: onCompleteProfile,
                    ),
                  ],
                  const SizedBox(height: 14),
                  if (completeness.missingItems.isEmpty)
                    const Text(
                      'Data utama sudah terlihat cukup lengkap. Tetap periksa tab detail jika ada informasi terbaru.',
                      style: AppTypography.bodyStyle,
                    )
                  else ...[
                    const Text(
                      'Data yang masih perlu dilengkapi:',
                      style: AppTypography.bodyStrongStyle,
                    ),
                    const SizedBox(height: 8),
                    for (final item in completeness.missingItems) ...[
                      _MissingProfileDataItem(label: item),
                      const SizedBox(height: 8),
                    ],
                  ],
                  if (!completeness.isQuickRegistered) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: onCompleteProfile,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 17),
                        label: const Text('Lengkapi Profil'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickRegisterNotice({required VoidCallback onPressed}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;
          final text = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline, size: 18, color: AppColors.primaryDark),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Siswa quick register tetap bisa masuk target mengajar, tetapi profil lengkap perlu dilengkapi agar report, bantuan, dan analisis akademik lebih akurat.',
                  style: AppTypography.secondaryStyle,
                ),
              ),
            ],
          );
          final button = TextButton(
            onPressed: onPressed,
            child: const Text('Lengkapi Profil'),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text,
                const SizedBox(height: 8),
                button,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: text),
              const SizedBox(width: 10),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _FullRegistrationData {
  const _FullRegistrationData({
    required this.schools,
    required this.classes,
    required this.teachingLocations,
    required this.student,
    required this.guardians,
    required this.advancedData,
    required this.onSiblingLookup,
  });

  final List<School> schools;
  final List<SchoolClass> classes;
  final List<TeachingLocation> teachingLocations;
  final Student student;
  final List<StudentGuardianFormData> guardians;
  final StudentAdvancedFormData advancedData;
  final StudentSiblingLookupCallback onSiblingLookup;
}

class _FullRegistrationLoaderDialog extends StatelessWidget {
  const _FullRegistrationLoaderDialog({
    required this.loadFuture,
    required this.onClose,
    required this.onSubmit,
  });

  final Future<_FullRegistrationData> loadFuture;
  final VoidCallback onClose;
  final Future<void> Function(
    _FullRegistrationData data,
    Student student,
    String schoolId,
    List<StudentGuardianFormData> guardians,
    StudentAdvancedFormData advancedData,
  ) onSubmit;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FullRegistrationData>(
      future: loadFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return Dialog(
            backgroundColor: AppColors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 22,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Menyiapkan Form Profil Siswa',
                      style: AppTypography.pageTitleStyle,
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Data siswa, sekolah, kelas, wali, dan informasi tambahan sedang dimuat.',
                      style: AppTypography.secondaryStyle,
                    ),
                    SizedBox(height: 18),
                    AppDialogSkeleton(rows: 6),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError || data == null) {
          return Dialog(
            backgroundColor: AppColors.white,
            insetPadding: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gagal Membuka Form Profil',
                      style: AppTypography.pageTitleStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error?.toString().replaceFirst(
                            'Bad state: ',
                            '',
                          ) ??
                          context.l10n.errorSomethingWentWrong,
                      style: AppTypography.bodyStyle.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: onClose,
                        child: Text(context.l10n.close),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return StudentFormDialog(
          availableSchools: data.schools,
          availableClasses: data.classes,
          availableTeachingLocations: data.teachingLocations,
          generatedStudentNo: data.student.studentId,
          initialStudent: data.student,
          initialGuardians: data.guardians,
          initialAdvancedData: data.advancedData,
          onSiblingLookup: data.onSiblingLookup,
          onSubmit: (student, schoolId, guardians, advancedData) {
            return onSubmit(data, student, schoolId, guardians, advancedData);
          },
        );
      },
    );
  }
}

class _MissingProfileDataItem extends StatelessWidget {
  const _MissingProfileDataItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.warning,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _missingProfileLabel(label),
                  style: AppTypography.bodyStrongStyle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _missingProfileLabel(String item) {
  return switch (item) {
    'data dasar' => 'Data dasar siswa',
    'lokasi binaan' => 'Lokasi binaan',
    'kontak siswa' => 'Kontak siswa',
    'atribut fisik' => 'Atribut fisik',
    'minat dan cita-cita' => 'Minat dan cita-cita',
    'orang tua/wali' => 'Orang tua atau wali',
    'profil rumah tangga' => 'Profil rumah tangga',
    'aktivitas' => 'Aktivitas siswa',
    _ => item,
  };
}

class _CompletenessIndicator extends StatelessWidget {
  const _CompletenessIndicator({required this.completeness, this.onTap});

  final _StudentDataCompleteness completeness;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = completeness.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              completeness.isQuickRegistered
                  ? Icons.pending_actions_outlined
                  : Icons.fact_check_outlined,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '${completeness.label}${completeness.total > 0 ? ' (${completeness.scoreLabel})' : ''}',
                style: AppTypography.bodyStrongStyle.copyWith(color: color),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (completeness.missingItems.isNotEmpty) ...[
              const SizedBox(width: 6),
              Tooltip(
                message: completeness.message,
                child: Icon(Icons.info_outline, size: 15, color: color),
              ),
            ],
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentStoryReportBuilder {
  static _StudentStoryReport build(
    _StudentStorySnapshot data,
    _StudentStoryText text,
  ) {
    final completeness = _StudentDataCompleteness.fromData(
      student: data.student,
      advanced: data.advanced,
      guardians: data.guardians,
    );
    if (completeness.isQuickRegistered) {
      final sections = <_StudentStorySection>[
        _StudentStorySection(
          title: text.executiveSummary,
          paragraphs: [
            'Student story belum tersedia karena siswa masih berstatus daftar cepat.',
            completeness.message,
          ],
        ),
      ];
      return _StudentStoryReport(
        student: data.student,
        executiveSummary:
            'Student story belum tersedia karena profil siswa belum lengkap.',
        completeness: completeness,
        sections: sections,
        text: text,
      );
    }
    final sections = <_StudentStorySection>[
      _executive(data, completeness, text),
      _profile(data),
      _family(data),
      _household(data),
      _academic(data),
      _attendance(data),
      _teacherNotes(data),
      _specialManagementNote(data),
      _activitiesAndAssistance(data),
      _learningDataAvailability(data),
      _progressIndicators(data),
      _developmentSummary(data),
      _missingData(data),
    ].where((section) => section.paragraphs.isNotEmpty).toList();

    return _StudentStoryReport(
      student: data.student,
      executiveSummary: _executiveSummaryText(data, completeness),
      completeness: completeness,
      sections: sections,
      text: text,
    );
  }

  static _StudentStorySection _executive(
    _StudentStorySnapshot data,
    _StudentDataCompleteness completeness,
    _StudentStoryText text,
  ) {
    return _StudentStorySection(
      title: text.executiveSummary,
      paragraphs: [
        _executiveSummaryText(data, completeness),
        'Status kelengkapan data: ${completeness.label}. ${completeness.message}',
      ],
    );
  }

  static _StudentStorySection _profile(_StudentStorySnapshot data) {
    final student = data.student;
    final advanced = data.advanced;
    final physical = <String>[
      if (student.height != null) 'tinggi ${_cleanNumber(student.height)} cm',
      if (student.weight != null) 'berat ${_cleanNumber(student.weight)} kg',
      if (_hasText(student.shoesSize)) 'sepatu ${student.shoesSize}',
      if (_hasText(student.uniformSize)) 'seragam ${student.uniformSize}',
      if (_hasText(student.pantsSize)) 'celana ${student.pantsSize}',
    ];

    final paragraphs = <String>[
      '${student.fullName} terdaftar dengan nomor siswa ${student.studentNo}. Siswa saat ini berada di ${_orDash(student.className)} pada ${_orDash(student.schoolName)}, dengan lokasi binaan ${_orDash(student.teachingLocationName)}. Status profil siswa tercatat sebagai ${_profileStatus(student.profileStatus)} dan status administrasi siswa ${student.status.name.toLowerCase()}.',
      'Data dasar yang tercatat: nama panggilan ${_orDash(student.nickName)}, gender ${student.gender.name.toLowerCase()}, usia ${student.age} tahun, tanggal lahir ${_orDash(student.birthDate)}, NIS ${_orDash(student.nis)}, kontak ${_orDash(student.mobileNo)}, dan email ${_orDash(student.emailAddr)}.',
      if (physical.isNotEmpty)
        'Atribut fisik yang tercatat meliputi ${_joinNatural(physical)}. Data ini bersifat administratif untuk kebutuhan perlengkapan dan pendampingan.',
      if (_hasText(advanced.hobby) || _hasText(advanced.aspiration))
        'Minat dan tujuan yang tercatat: hobi ${_orDash(advanced.hobby)} dan cita-cita ${_orDash(advanced.aspiration)}.',
    ];

    return _StudentStorySection(title: 'Profil dan Data Dasar', paragraphs: paragraphs);
  }

  static _StudentStorySection _family(_StudentStorySnapshot data) {
    final guardians = data.guardians.where((item) => item.hasData).toList();
    final fatherDeceased = guardians.any(
      (item) => _isRelationship(item.relationship, 'FATHER') && item.isDeceased == true,
    );
    final motherDeceased = guardians.any(
      (item) => _isRelationship(item.relationship, 'MOTHER') && item.isDeceased == true,
    );
    final duafaStatus = _duafaStatus(fatherDeceased, motherDeceased);
    final primary = guardians.where((item) => item.isPrimary).toList();
    final relations = data.relations.where((item) => item.hasData).toList();

    final paragraphs = <String>[
      'Status dukungan keluarga siswa tercatat sebagai $duafaStatus berdasarkan data ayah/ibu yang tersedia.',
      if (guardians.isEmpty)
        'Data orang tua atau wali belum tersedia secara lengkap.'
      else
        'Data orang tua/wali yang tercatat: ${guardians.map(_guardianSummary).join('; ')}.',
      if (primary.isNotEmpty)
        'Wali utama yang tercatat adalah ${primary.map((item) => _orDash(item.fullName)).join(', ')}.',
      if (relations.isNotEmpty)
        'Relasi saudara yang tercatat: ${relations.map(_relationSummary).join('; ')}.',
    ];

    return _StudentStorySection(title: 'Keluarga dan Wali', paragraphs: paragraphs);
  }

  static _StudentStorySection _household(_StudentStorySnapshot data) {
    final household = data.advanced.householdProfile;
    final income = _incomeSummary(household, data.guardians);
    final paragraphs = <String>[
      if (_hasText(household.homeAddress))
        'Alamat rumah yang tercatat: ${household.homeAddress}.',
      if (_hasText(household.housingStatus) ||
          household.householdMemberCount != null ||
          household.dailySchoolTransportCost != null ||
          household.educationArrears != null)
        'Profil rumah tangga: status tempat tinggal ${_housingStatus(household.housingStatus)}, jumlah anggota keluarga ${_orDash(household.householdMemberCount?.toString())}, biaya transport harian ${_formatCurrency(household.dailySchoolTransportCost)}, dan tunggakan pendidikan ${_formatCurrency(household.educationArrears)}.',
      if (income.isNotEmpty) income,
    ];

    return _StudentStorySection(
      title: 'Kondisi Sosial Ekonomi',
      paragraphs: paragraphs,
    );
  }

  static _StudentStorySection _academic(_StudentStorySnapshot data) {
    final learning = data.insights.learning;
    final competencies = data.insights.competencies;
    final household = data.advanced.householdProfile;
    final examGroups = data.examScores;
    final bestCompetencies = [...competencies]
      ..sort((a, b) => b.averageScore.compareTo(a.averageScore));
    final recentExams = examGroups.take(5).map(_examSummary).toList();
    final trend = _examScoreTrend(examGroups);
    final topCompetency = bestCompetencies.isEmpty ? null : bestCompetencies.first;

    final paragraphs = <String>[
      if (learning.assessmentCount > 0)
        'Catatan akademik internal: terdapat ${learning.assessmentCount} penilaian dengan rata-rata ${_score(learning.averageScore)}. Penilaian terbaru tercatat pada ${_orDash(learning.latestAssessmentDate)}, sehingga perkembangan akademik mulai dapat dipantau dari data sesi belajar.'
      else
        'Catatan akademik internal: belum ada penilaian internal yang cukup untuk membaca perkembangan akademik dari kegiatan belajar di Edukita.',
      if (bestCompetencies.isNotEmpty)
        'Kompetensi yang terlihat kuat: ${bestCompetencies.take(3).map((item) => '${item.label} (${item.averageScore.toStringAsFixed(0)})').join(', ')}.${topCompetency == null ? '' : ' Area ini dapat menjadi pintu masuk untuk membangun rasa percaya diri belajar.'}',
      if (recentExams.isNotEmpty)
        'Nilai ujian sekolah/internal yang tercatat: ${recentExams.join('; ')}.',
      if (trend.hasData)
        'Arah nilai: ${trend.description}',
      if (_hasText(household.academicAchievement))
        'Pencapaian akademik: ${household.academicAchievement}. Pencapaian ini perlu tetap diapresiasi sebagai bagian dari motivasi belajar siswa.',
      if (_hasText(household.nonAcademicAchievement))
        'Pencapaian non-akademik: ${household.nonAcademicAchievement}. Catatan ini menunjukkan potensi siswa tidak hanya dibaca dari nilai akademik.',
    ];

    return _StudentStorySection(title: 'Akademik dan Pencapaian', paragraphs: paragraphs);
  }

  static _StudentStorySection _attendance(_StudentStorySnapshot data) {
    final attendance = data.insights.attendance;
    final recent = data.insights.recentAttendance.take(5).toList();
    final percentage = attendance.attendancePercentage;
    final trend = _attendanceTrend(data.insights.monthlyAttendance);
    final message = percentage == null
        ? 'Ringkasan kehadiran: belum ada data kehadiran yang cukup.'
        : 'Ringkasan kehadiran: ${percentage.toStringAsFixed(0)}% dari ${attendance.totalRecords} sesi. Rinciannya adalah hadir ${attendance.presentCount}, sakit ${attendance.sickCount}, izin ${attendance.permissionCount}, dan tidak hadir ${attendance.absentCount}.';

    final paragraphs = <String>[
      message,
      if (percentage != null && percentage >= 90)
        'Makna data: kehadiran sangat kuat dan menjadi modal baik untuk menjaga kontinuitas belajar.'
      else if (percentage != null && percentage >= 75)
        'Makna data: kehadiran sudah cukup konsisten dan mendukung proses belajar.'
      else if (percentage != null && percentage >= 50)
        'Makna data: kehadiran mulai terbaca, namun masih perlu pendampingan agar kesempatan belajar tidak terputus.'
      else if (percentage != null)
        'Makna data: kehadiran masih perlu perhatian karena kesempatan belajar siswa berpotensi belum optimal.',
      if (trend.hasData) 'Arah kehadiran: ${trend.description}',
      if (recent.isNotEmpty)
        'Kehadiran terbaru: ${recent.map(_attendanceSummary).join('; ')}.',
    ];

    return _StudentStorySection(title: 'Kehadiran', paragraphs: paragraphs);
  }

  static _StudentStorySection _teacherNotes(_StudentStorySnapshot data) {
    final notes = data.insights.recentTeacherNotes;
    final distribution = data.insights.noteTypeCounts;
    final positiveNotes = notes.where((note) => (note.rawScore ?? 0) >= 4).toList();
    final supportNotes = notes.where((note) => (note.rawScore ?? 5) <= 2).toList();
    final latest = notes.isEmpty ? null : notes.first;
    final paragraphs = <String>[
      if (notes.isEmpty)
        'Catatan guru: belum ada catatan guru terbaru yang dapat dirangkum.'
      else ...[
        'Catatan terbaru: ${_noteSummary(latest!)}',
        if (positiveNotes.isNotEmpty)
          'Sinyal positif: terdapat ${positiveNotes.length} catatan dengan rating tinggi. Ini dapat menjadi indikasi adanya perilaku, usaha, atau keterlibatan yang patut diperkuat.',
        if (supportNotes.isNotEmpty)
          'Sinyal dukungan: terdapat ${supportNotes.length} catatan dengan rating rendah. Catatan ini perlu dibaca sebagai kebutuhan pendampingan, bukan label terhadap siswa.',
        if (notes.length > 1)
          'Catatan lain yang relevan: ${notes.skip(1).take(5).map(_noteSummary).join(' ')}',
      ],
      if (distribution.isNotEmpty)
        'Sebaran tipe catatan: ${distribution.map((item) => '${item.type} ${item.count}').join(', ')}. Sebaran ini membantu melihat apakah observasi lebih banyak menyangkut progres belajar, perilaku, kehadiran, dukungan, atau pencapaian.',
    ];

    return _StudentStorySection(title: 'Catatan Guru dan Observasi', paragraphs: paragraphs);
  }

  static _StudentStorySection _specialManagementNote(_StudentStorySnapshot data) {
    final note = data.latestSpecialNote;
    if (note == null) {
      return const _StudentStorySection(
        title: 'Catatan Khusus Management',
        paragraphs: [],
      );
    }

    final type = StudentSpecialNoteTypeOptions.label(note.noteType);
    final paragraphs = <String>[
      'Catatan khusus management terbaru tercatat pada ${note.noteDate} dengan tipe $type. Isi catatan yang tercatat: ${note.note}',
      if (note.followUpNeeded)
        'Catatan ini ditandai perlu tindak lanjut${_hasText(note.followUpNote) ? ': ${note.followUpNote}' : '.'}',
    ];

    return _StudentStorySection(
      title: 'Catatan Khusus Management',
      paragraphs: paragraphs,
    );
  }

  static _StudentStorySection _activitiesAndAssistance(_StudentStorySnapshot data) {
    final activities = data.activities.where((item) => item.hasData).toList();
    final assistance = data.insights.assistanceHistory;
    final paragraphs = <String>[
      if (activities.isNotEmpty)
        'Aktivitas siswa: ${activities.map(_activitySummary).join('; ')}. Aktivitas ini dapat dipakai untuk memahami minat, konsistensi, dan ruang berkembang siswa di luar nilai akademik.',
      if (assistance.isNotEmpty)
        'Riwayat bantuan: ${assistance.map(_assistanceSummary).join('; ')}. Data ini menunjukkan bentuk dukungan yang sudah pernah diterima siswa.',
      if (activities.isEmpty && assistance.isEmpty)
        'Aktivitas dan bantuan: belum ada aktivitas tambahan atau riwayat bantuan yang tercatat.',
    ];

    return _StudentStorySection(
      title: 'Aktivitas, Dukungan, dan Bantuan',
      paragraphs: paragraphs,
    );
  }

  static _StudentStorySection _learningDataAvailability(
    _StudentStorySnapshot data,
  ) {
    final attendanceAvailable = data.insights.attendance.totalRecords > 0;
    final academicAvailable =
        data.insights.learning.assessmentCount > 0 || data.examScores.isNotEmpty;
    final notesAvailable = data.insights.recentTeacherNotes.isNotEmpty;
    final available = <String>[
      if (attendanceAvailable) 'kehadiran',
      if (academicAvailable) 'nilai akademik',
      if (notesAvailable) 'catatan guru',
    ];
    final pending = <String>[
      if (!attendanceAvailable) 'kehadiran',
      if (!academicAvailable) 'nilai akademik',
      if (!notesAvailable) 'catatan guru',
    ];

    return _StudentStorySection(
      title: 'Ketersediaan Data Belajar',
      paragraphs: [
        if (available.isNotEmpty)
          'Data belajar yang sudah tersedia: ${_joinNatural(available)}.',
        if (pending.isNotEmpty)
          'Data ${_joinNatural(pending)} belum tersedia. Untuk siswa baru, ini normal dan tidak perlu dilengkapi manual dari profil siswa karena akan muncul setelah siswa mulai mengikuti kegiatan belajar dan guru mengisi report sesi.',
      ],
    );
  }

  static _StudentStorySection _progressIndicators(_StudentStorySnapshot data) {
    final signals = <_ProgressSignal>[
      _attendanceTrend(data.insights.monthlyAttendance),
      _examScoreTrend(data.examScores),
      _teacherNoteScoreSignal(data.insights.recentTeacherNotes),
    ].where((signal) => signal.hasData).toList();

    final paragraphs = <String>[
      if (signals.isEmpty)
        'Tren terukur: belum ada data historis yang cukup untuk membaca arah perkembangan. Indikator ini akan lebih bermakna setelah kehadiran, nilai, dan catatan guru terisi rutin.'
      else
        'Tren terukur: ${signals.map((signal) => signal.description).join(' ')}',
      'Batas pembacaan: tren hanya memakai data yang tercatat di aplikasi. Jika data belum lengkap atau belum rutin, hasilnya perlu diperlakukan sebagai sinyal awal, bukan kesimpulan final.',
    ];

    return _StudentStorySection(
      title: 'Indikator Progress Terukur',
      paragraphs: paragraphs,
    );
  }

  static _StudentStorySection _developmentSummary(_StudentStorySnapshot data) {
    final learning = data.insights.learning;
    final attendance = data.insights.attendance.attendancePercentage;
    final notes = data.insights.recentTeacherNotes;
    final latestSpecialNote = data.latestSpecialNote;
    final attendanceTrend = _attendanceTrend(data.insights.monthlyAttendance);
    final examTrend = _examScoreTrend(data.examScores);
    final teacherSignal = _teacherNoteScoreSignal(notes);
    final hasAchievement =
        _hasText(data.advanced.householdProfile.academicAchievement) ||
        _hasText(data.advanced.householdProfile.nonAcademicAchievement);
    final topCompetencies = [...data.insights.competencies]
      ..sort((a, b) => b.averageScore.compareTo(a.averageScore));
    final highNotes = notes.where((note) => (note.rawScore ?? 0) >= 4).toList();
    final lowNotes = notes.where((note) => (note.rawScore ?? 5) <= 2).toList();
    final strengths = <String>[
      if ((learning.averageScore ?? 0) >= 80)
        'menunjukkan capaian akademik yang kuat berdasarkan rata-rata nilai yang tercatat'
      else if ((learning.averageScore ?? 0) > 0)
        'memiliki rekam penilaian akademik yang sudah mulai dapat dipantau',
      if ((attendance ?? 0) >= 90)
        'menunjukkan kehadiran yang sangat konsisten'
      else if ((attendance ?? 0) >= 75)
        'menunjukkan kehadiran yang cukup konsisten',
      if (topCompetencies.isNotEmpty)
        'memiliki area kompetensi yang terlihat menonjol pada ${topCompetencies.first.label}',
      if (highNotes.isNotEmpty)
        'mendapat observasi positif pada ${highNotes.length} catatan guru terbaru',
      if (hasAchievement) 'memiliki pencapaian yang sudah tercatat',
    ];
    final developments = <String>[
      if (attendanceTrend.hasData) attendanceTrend.description,
      if (examTrend.hasData) examTrend.description,
      if (teacherSignal.hasData) teacherSignal.description,
      if (latestSpecialNote != null)
        'catatan khusus management terbaru pada ${latestSpecialNote.noteDate} memberi konteks tambahan untuk memahami kebutuhan pendampingan siswa',
    ];
    final supportAreas = <String>[
      if (attendance != null && attendance < 75)
        'konsistensi kehadiran agar kesempatan belajar lebih penuh',
      if (learning.assessmentCount == 0)
        'pengumpulan data nilai agar perkembangan akademik lebih terlihat',
      if (notes.isEmpty)
        'penambahan catatan guru rutin agar progres sosial dan belajar lebih terpantau',
      if (lowNotes.isNotEmpty)
        'menindaklanjuti ${lowNotes.length} catatan guru yang menunjukkan kebutuhan dukungan',
      if (latestSpecialNote?.followUpNeeded == true)
        'tindak lanjut catatan khusus management terbaru',
    ];

    return _StudentStorySection(
      title: 'Ringkasan Perkembangan',
      paragraphs: [
        'Kekuatan yang terlihat: ${strengths.isEmpty ? 'data kekuatan spesifik belum cukup, namun profil siswa sudah dapat dipantau dari data dasar yang tersedia' : _joinNatural(strengths)}.',
        'Perkembangan yang terjadi: ${developments.isEmpty ? 'belum ada tren historis yang cukup kuat untuk menyatakan ada peningkatan atau penurunan. Untuk saat ini, perkembangan perlu terus dipantau melalui kehadiran, nilai, catatan guru, dan aktivitas belajar berikutnya' : developments.join(' ')}.',
        'Area yang perlu dukungan: ${supportAreas.isEmpty ? 'pendampingan rutin tetap diperlukan agar perkembangan akademik, kehadiran, dan sosial siswa tetap stabil' : _joinNatural(supportAreas)}.',
        'Saran ringan untuk orang tua: ${_parentSuggestion(attendance: attendance, hasAcademicData: learning.assessmentCount > 0, latestSpecialNote: latestSpecialNote)}',
        'Saran ringan untuk guru: ${_teacherSuggestion(hasNotes: notes.isNotEmpty, lowNotes: lowNotes.length, hasAcademicData: learning.assessmentCount > 0)}',
      ],
    );
  }

  static _StudentStorySection _missingData(_StudentStorySnapshot data) {
    final missing = <String>[
      if (data.guardians.where((item) => item.hasData).isEmpty) 'data orang tua/wali',
      if (!data.advanced.householdProfile.hasData) 'profil rumah tangga',
      if (!_hasText(data.student.teachingLocationName)) 'lokasi binaan',
      if (!_hasText(data.student.mobileNo) && !_hasText(data.student.emailAddr))
        'kontak siswa',
      if (!_hasText(data.advanced.hobby) && !_hasText(data.advanced.aspiration))
        'minat atau cita-cita',
    ];

    return _StudentStorySection(
      title: 'Data Profil yang Perlu Dilengkapi',
      paragraphs: missing.isEmpty
          ? ['Data profil utama siswa sudah cukup lengkap. Data belajar seperti kehadiran, nilai, dan catatan guru akan bertambah otomatis setelah kegiatan belajar berjalan.']
          : ['Agar profil siswa lebih utuh, data yang sebaiknya dilengkapi adalah ${_joinNatural(missing)}. Data belajar seperti kehadiran, nilai, dan catatan guru tidak dihitung sebagai kekurangan profil karena berasal dari aktivitas belajar.'],
    );
  }
}

String _executiveSummaryText(
  _StudentStorySnapshot data,
  _StudentDataCompleteness completeness,
) {
  final student = data.student;
  final attendance = data.insights.attendance.attendancePercentage;
  final learning = data.insights.learning;
  final notes = data.insights.recentTeacherNotes;
  final assistanceCount = data.insights.assistanceHistory.length;
  final achievement = data.advanced.householdProfile.academicAchievement ??
      data.advanced.householdProfile.nonAcademicAchievement;
  final attendanceText = attendance == null
      ? 'kehadiran belum memiliki data cukup'
      : 'kehadiran tercatat ${attendance.toStringAsFixed(0)}%';
  final learningText = learning.assessmentCount == 0
      ? 'nilai akademik belum cukup untuk membaca tren'
      : 'rata-rata akademik tercatat ${_score(learning.averageScore)} dari ${learning.assessmentCount} penilaian';
  final notesText = notes.isEmpty
      ? 'catatan guru terbaru belum tersedia'
      : 'terdapat ${notes.length} catatan guru terbaru yang bisa menjadi bahan observasi';
  final assistanceText = assistanceCount == 0
      ? 'belum ada riwayat bantuan tercatat'
      : 'terdapat $assistanceCount riwayat bantuan tercatat';
  final achievementText = _hasText(achievement)
      ? 'Pencapaian yang tercatat, termasuk ${achievement!.trim()}, perlu tetap diapresiasi sebagai bagian dari perkembangan siswa.'
      : 'Pencapaian kecil yang muncul dari kehadiran, catatan guru, atau nilai perlu terus dicatat agar progres siswa makin terlihat.';
  final specialNote = data.latestSpecialNote;
  final specialNoteText = specialNote == null
      ? ''
      : ' Catatan khusus management terbaru pada ${specialNote.noteDate} perlu ikut dipertimbangkan dalam pendampingan, sesuai data yang tercatat.';

  return '${student.fullName} adalah siswa di ${_orDash(student.className)} pada ${_orDash(student.schoolName)} dengan status profil ${_profileStatus(student.profileStatus)}. Secara ringkas, $attendanceText, $learningText, $notesText, dan $assistanceText. ${completeness.isQuickRegistered ? 'Karena siswa ini dibuat melalui daftar cepat, report perlu diperlakukan sebagai ringkasan awal sampai data lengkap dilengkapi. ' : ''}$achievementText$specialNoteText';
}

String _guardianSummary(StudentGuardianFormData guardian) {
  final deceased = guardian.isDeceased == true ? ', almarhum/almarhumah' : '';
  final primary = guardian.isPrimary ? ', wali utama' : '';
  return '${_relationship(guardian.relationship)} ${_orDash(guardian.fullName)}$primary$deceased, pekerjaan ${_orDash(guardian.occupation)}, penghasilan ${_formatCurrency(guardian.income)}';
}

String _relationSummary(StudentRelationFormData relation) {
  return '${_orDash(relation.relatedStudentName)} (${_orDash(relation.relatedStudentNo)}), ${_orDash(relation.relationType)} ${_orDash(relation.agePosition)}';
}

String _examSummary(StudentExamScoreGroup group) {
  final avg = group.averagePercent == null ? '-' : '${group.averagePercent!.toStringAsFixed(0)}%';
  final subjects = group.items
      .map((item) => _orDash(item.subjectName ?? item.unitName))
      .where((item) => item != '-')
      .take(3)
      .join(', ');
  return '${group.examType} ${group.examDate}, rata-rata $avg${subjects.isEmpty ? '' : ', pada $subjects'}';
}

String _attendanceSummary(StudentAttendanceRecordView record) {
  final note = _hasText(record.note) ? ', catatan: ${record.note}' : '';
  return '${record.date} ${record.session} status ${record.status}$note';
}

String _noteSummary(StudentTeacherNoteInsight note) {
  final score = note.rawScore == null ? '' : ' (${note.rawScore!.toStringAsFixed(1)}/5)';
  final teacher = _hasText(note.teacherName) ? ' oleh ${note.teacherName}' : '';
  final source = note.source == 'manual' ? 'catatan manual' : 'catatan sesi';
  return '${note.date}: ${note.type}$score$teacher ($source) - ${note.comment}.';
}

String _activitySummary(StudentActivityFormData activity) {
  final dates = [
    if (_hasText(activity.startDate)) activity.startDate!,
    if (_hasText(activity.endDate)) activity.endDate!,
  ].join(' sampai ');
  return '${_orDash(activity.name)} (${_orDash(activity.type)}), peran ${_orDash(activity.role)}, pencapaian ${_orDash(activity.achievement)}${dates.isEmpty ? '' : ', periode $dates'}';
}

String _assistanceSummary(StudentAssistanceHistoryInsight item) {
  return '${item.programName} periode ${item.periodName}, status ${item.status}, benefit ${_orDash(item.benefit)}';
}

class _ProgressSignal {
  const _ProgressSignal({
    required this.hasData,
    required this.description,
  });

  final bool hasData;
  final String description;
}

_ProgressSignal _attendanceTrend(List<double?> monthlyAttendance) {
  final points = <MapEntry<int, double>>[];
  for (var i = 0; i < monthlyAttendance.length; i++) {
    final value = monthlyAttendance[i];
    if (value != null) points.add(MapEntry(i + 1, value));
  }
  if (points.length < 2) {
    return const _ProgressSignal(
      hasData: false,
      description: '',
    );
  }
  final first = points.first;
  final last = points.last;
  final delta = last.value - first.value;
  final direction = _trendDirection(delta);
  return _ProgressSignal(
    hasData: true,
    description:
        'Kehadiran $direction dari ${_monthName(first.key)} ${first.value.toStringAsFixed(0)}% ke ${_monthName(last.key)} ${last.value.toStringAsFixed(0)}% (${_signedPercent(delta)}).',
  );
}

_ProgressSignal _examScoreTrend(List<StudentExamScoreGroup> groups) {
  final datedScores = groups
      .where((group) => group.averagePercent != null && _hasText(group.examDate))
      .toList()
    ..sort((a, b) => a.examDate.compareTo(b.examDate));
  if (datedScores.length < 2) {
    return const _ProgressSignal(
      hasData: false,
      description: '',
    );
  }
  final first = datedScores.first;
  final last = datedScores.last;
  final firstScore = first.averagePercent!;
  final lastScore = last.averagePercent!;
  final delta = lastScore - firstScore;
  final direction = _trendDirection(delta);
  return _ProgressSignal(
    hasData: true,
    description:
        'Nilai ujian $direction dari ${first.examDate} ${firstScore.toStringAsFixed(0)}% ke ${last.examDate} ${lastScore.toStringAsFixed(0)}% (${_signedPercent(delta)}).',
  );
}

_ProgressSignal _teacherNoteScoreSignal(List<StudentTeacherNoteInsight> notes) {
  final scoredNotes = notes
      .where((note) => note.rawScore != null && _hasText(note.date))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  if (scoredNotes.isEmpty) {
    return const _ProgressSignal(
      hasData: false,
      description: '',
    );
  }
  final average = scoredNotes
          .map((note) => note.rawScore!)
          .reduce((a, b) => a + b) /
      scoredNotes.length;
  if (scoredNotes.length < 2) {
    return _ProgressSignal(
      hasData: true,
      description:
          'Catatan guru berskor rata-rata ${average.toStringAsFixed(1)}/5 dari ${scoredNotes.length} catatan yang tersedia.',
    );
  }
  final first = scoredNotes.first.rawScore!;
  final last = scoredNotes.last.rawScore!;
  final delta = last - first;
  final direction = _trendDirection(delta);
  return _ProgressSignal(
    hasData: true,
    description:
        'Skor observasi guru rata-rata ${average.toStringAsFixed(1)}/5 dan $direction dari ${first.toStringAsFixed(1)} ke ${last.toStringAsFixed(1)} (${_signedScore(delta)}).',
  );
}

String _trendDirection(double delta) {
  if (delta.abs() < 0.5) return 'relatif stabil';
  return delta > 0 ? 'meningkat' : 'menurun';
}

String _signedPercent(double value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(0)}%';
}

String _signedScore(double value) {
  final sign = value > 0 ? '+' : '';
  return '$sign${value.toStringAsFixed(1)}';
}

String _monthName(int month) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  if (month < 1 || month > names.length) return month.toString();
  return names[month - 1];
}

String _parentSuggestion({
  required double? attendance,
  required bool hasAcademicData,
  required StudentSpecialNote? latestSpecialNote,
}) {
  final suggestions = <String>[
    if (attendance != null && attendance < 75)
      'bantu menjaga rutinitas hadir agar siswa mendapat kesempatan belajar yang lebih konsisten'
    else if (attendance != null && attendance >= 90)
      'pertahankan rutinitas yang sudah mendukung kehadiran siswa',
    if (hasAcademicData)
      'ajak siswa menceritakan satu hal yang ia pahami setelah sesi belajar'
    else
      'mulai biasakan percakapan singkat setelah belajar agar guru dan orang tua mendapat gambaran proses belajar siswa',
    if (latestSpecialNote?.followUpNeeded == true)
      'komunikasikan tindak lanjut catatan khusus terbaru dengan pengajar atau management',
    'beri apresiasi pada usaha kecil yang terlihat, bukan hanya hasil akhir',
  ];
  return '${_joinNatural(suggestions)}.';
}

String _teacherSuggestion({
  required bool hasNotes,
  required int lowNotes,
  required bool hasAcademicData,
}) {
  final suggestions = <String>[
    if (!hasNotes)
      'mulai isi catatan observasi secara ringkas setelah sesi agar perkembangan sosial dan belajar lebih terlihat'
    else
      'lanjutkan catatan observasi dengan bahasa spesifik agar progres kecil tetap terdokumentasi',
    if (lowNotes > 0)
      'gunakan catatan yang membutuhkan dukungan sebagai dasar intervensi ringan pada sesi berikutnya',
    if (!hasAcademicData)
      'tambahkan penilaian sederhana agar perkembangan akademik dapat mulai dibaca',
    'berikan umpan balik positif yang konkret dan mudah ditindaklanjuti siswa',
  ];
  return '${_joinNatural(suggestions)}.';
}

String _incomeSummary(
  StudentHouseholdProfileFormData household,
  List<StudentGuardianFormData> guardians,
) {
  final items = <String>[];
  if (household.fatherIncome != null) {
    items.add('penghasilan ayah ${_formatCurrency(household.fatherIncome)} (${_incomeLevel(household.fatherIncome)})');
  }
  if (household.motherIncome != null) {
    items.add('penghasilan ibu ${_formatCurrency(household.motherIncome)} (${_incomeLevel(household.motherIncome)})');
  }
  for (final guardian in guardians) {
    if (guardian.income != null &&
        !_isRelationship(guardian.relationship, 'FATHER') &&
        !_isRelationship(guardian.relationship, 'MOTHER')) {
      items.add('penghasilan ${_relationship(guardian.relationship).toLowerCase()} ${_formatCurrency(guardian.income)} (${_incomeLevel(guardian.income)})');
    }
  }
  if (items.isEmpty) return '';
  return 'Data ekonomi yang tercatat menunjukkan ${_joinNatural(items)}. Kategori ini hanya indikasi administratif berdasarkan angka yang tersedia, bukan penilaian menyeluruh atas kondisi keluarga.';
}

String _incomeLevel(num? value) {
  if (value == null) return 'belum tersedia';
  if (value <= 1500000) return 'indikasi sangat terbatas';
  if (value <= 3000000) return 'indikasi terbatas';
  return 'tercatat lebih stabil';
}

String _duafaStatus(bool fatherDeceased, bool motherDeceased) {
  if (fatherDeceased && motherDeceased) return 'Yatim Piatu';
  if (fatherDeceased) return 'Yatim';
  if (motherDeceased) return 'Piatu';
  return 'Duafa';
}

bool _isRelationship(String? value, String expected) {
  return value?.trim().toUpperCase() == expected;
}

String _relationship(String? value) {
  return switch (value?.trim().toUpperCase()) {
    'MOTHER' => 'Ibu',
    'FATHER' => 'Ayah',
    'BROTHER' => 'Saudara laki-laki',
    'SISTER' => 'Saudara perempuan',
    'UNCLE' => 'Paman',
    'AUNTY' => 'Bibi',
    'GRANDPA' => 'Kakek',
    'GRANDMA' => 'Nenek',
    _ => _orDash(value),
  };
}

String _housingStatus(String? value) {
  return switch (value) {
    StudentHousingStatusOptions.owned => 'milik sendiri',
    StudentHousingStatusOptions.rented => 'sewa',
    StudentHousingStatusOptions.stayingWithFamily => 'tinggal dengan keluarga',
    StudentHousingStatusOptions.other => 'lainnya',
    _ => _orDash(value),
  };
}

String _profileStatus(String value) {
  return value == 'quick_registered' ? 'daftar cepat' : 'lengkap';
}

String _score(double? value) {
  if (value == null) return '-';
  return value.toStringAsFixed(0);
}

String _cleanNumber(num? value) {
  if (value == null) return '-';
  return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
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

String _joinNatural(List<String> values) {
  final clean = values.where((item) => item.trim().isNotEmpty).toList();
  if (clean.isEmpty) return '-';
  if (clean.length == 1) return clean.first;
  return '${clean.take(clean.length - 1).join(', ')} dan ${clean.last}';
}

String _orDash(String? value) {
  if (value == null || value.trim().isEmpty || value.trim() == '-') return '-';
  return value.trim();
}

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

_ParagraphLead? _splitParagraphLead(String value) {
  final trimmed = value.trim();
  final colonIndex = trimmed.indexOf(':');
  if (colonIndex <= 0 || colonIndex > 48 || colonIndex == trimmed.length - 1) {
    return null;
  }
  final lead = trimmed.substring(0, colonIndex).trim();
  final body = trimmed.substring(colonIndex + 1).trim();
  if (lead.length < 3 || body.isEmpty) return null;
  return _ParagraphLead(lead: lead, body: body);
}

class _ParagraphLead {
  const _ParagraphLead({required this.lead, required this.body});

  final String lead;
  final String body;
}

String _safeFileName(String value) {
  final extension = p.extension(value);
  final base = extension.isEmpty
      ? value
      : value.substring(0, value.length - extension.length);
  final safeBase = base
      .trim()
      .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '-')
      .replaceAll(RegExp(r'\s+'), '-');
  return '${safeBase.isEmpty ? 'student-story' : safeBase}$extension';
}

String _reportRemarks(_StudentStoryReport report, String note) {
  final safeNote = note.replaceAll('|', '/').replaceAll('\n', ' ').trim();
  return [
    'type=${report.text.reportTitle}',
    'note=${safeNote.isEmpty ? report.text.defaultGeneratedNote : safeNote}',
    'completeness=${report.completeness.label} ${report.completeness.total > 0 ? '(${report.completeness.scoreLabel})' : ''}',
  ].join(' | ');
}

String _compactTimestamp(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final second = value.second.toString().padLeft(2, '0');
  return '$year$month$day$hour$minute$second';
}
