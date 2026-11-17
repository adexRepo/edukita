import 'package:edukita/widgets/app_error_dialog.dart';
import 'package:edukita/widgets/app_inline_error.dart';
import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/features/auth/domain/auth_session_cache.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:edukita/features/users/domain/user_authorization.dart';
import 'package:edukita/features/users/domain/user_management_repository.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/detail_breadcrumbs.dart';
import 'package:edukita/widgets/detail_tab_bar.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:flutter/material.dart';

typedef _TeacherDetailResult = ({TeacherDetailData? data, Object? error});

class TeacherDetailPage extends StatefulWidget {
  const TeacherDetailPage({super.key, required this.teacher});

  final Teacher teacher;

  @override
  State<TeacherDetailPage> createState() => _TeacherDetailPageState();
}

class _TeacherDetailPageState extends State<TeacherDetailPage> {
  AppAuthorizationScope _authScope = AppAuthorizationScope(
    role: AppUserRole.admin,
    permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
      AppUserRole.admin,
    ),
  );
  bool _authorizationLoaded = false;
  Future<_TeacherDetailResult>? _detailFuture;
  Future<_TeacherDetailResult> _readDetail() async {
    try {
      return (
        data: await getIt<TeacherRepository>().loadTeacherDetail(
          widget.teacher,
        ),
        error: null,
      );
    } catch (error) {
      return (data: null, error: error);
    }
  }

  bool get _canViewTeachers =>
      _authScope.canView(AppMenuAccessRegistry.teachers.code);

  @override
  void initState() {
    super.initState();
    _loadAuthorizationAndDetail();
  }

  Future<void> _loadAuthorizationAndDetail() async {
    final session = await AuthSessionCache.instance.read();
    AppAuthorizationScope scope;
    if (session == null || session.isAdmin) {
      scope = AppAuthorizationScope(
        role: AppUserRole.admin,
        permissions: AppMenuAccessRegistry.defaultPermissionsForRole(
          AppUserRole.admin,
        ),
      );
    } else {
      scope = await getIt<UserManagementRepository>()
          .getAuthorizationScopeForUser(session.userId);
    }
    if (!mounted) return;
    setState(() {
      _authScope = scope;
      _authorizationLoaded = true;
      if (scope.canView(AppMenuAccessRegistry.teachers.code)) {
        _detailFuture = _readDetail();
      }
    });
  }

  PreferredSizeWidget _appBar(String label) {
    return AppBar(
      leadingWidth: 40,
      leading: const DetailAppBarBackButton(fallbackRoute: '/teachers'),
      title: DetailBreadcrumbs(
        items: [
          DetailBreadcrumbItem(
            label: context.l10n.menuTeachers,
            route: '/teachers',
          ),
          DetailBreadcrumbItem(label: label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_authorizationLoaded) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        appBar: _appBar(widget.teacher.fullName),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canViewTeachers) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        appBar: _appBar(widget.teacher.fullName),
        body: Center(
          child: Text(
            context.l10n.teacherAccessDenied,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    final detailFuture = _detailFuture;
    if (detailFuture == null) {
      return Scaffold(
        backgroundColor: AppColors.surfaceSoft,
        appBar: _appBar(widget.teacher.fullName),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<_TeacherDetailResult>(
      future: detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.surfaceSoft,
            appBar: _appBar(widget.teacher.fullName),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data?.data == null) {
          return Scaffold(
            backgroundColor: AppColors.surfaceSoft,
            appBar: _appBar(widget.teacher.fullName),
            body: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: AppInlineError(
                message: context.l10n.operationFailedTryAgain,
                onRetry: () {
                  setState(() {
                    _detailFuture = _readDetail();
                  });
                },
                onDetails: () => showErrorDetailDialog(
                  context,
                  title: context.l10n.operationFailedTryAgain,
                  error:
                      snapshot.data?.error ??
                      snapshot.error ??
                      context.l10n.teacherNotFound,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!.data!;
        return Scaffold(
          backgroundColor: AppColors.surfaceSoft,
          appBar: _appBar(data.teacher.fullName),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  DetailTabBar(
                    filledStyle: true,
                    tabs: [
                      context.l10n.overview,
                      context.l10n.impact,
                      context.l10n.classes,
                      context.l10n.notes,
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(data: data),
                        _ImpactTab(data: data),
                        _ClassesTab(data: data),
                        _NotesTab(data: data),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TeacherHeader extends StatelessWidget {
  const _TeacherHeader({required this.data});

  final TeacherDetailData data;

  @override
  Widget build(BuildContext context) {
    return DetailSectionCard(
      title: context.l10n.teacherProfile,
      icon: Icons.badge_outlined,
      wrapChildren: false,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
              ),
              child: Center(
                child: Text(
                  _initials(data.teacher.fullName),
                  style: const TextStyle(
                    color: AppColors.primaryForeground,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.teacher.fullName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subjects.isEmpty
                        ? context.l10n.noSubjectsAssigned
                        : data.subjects.join(', '),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${data.teacher.email ?? '-'} | ${data.teacher.mobileNo ?? '-'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetricTile(
              label: context.l10n.students,
              value: data.totalStudents.toString(),
            ),
            _MetricTile(
              label: context.l10n.classes,
              value: data.classCount.toString(),
            ),
            _MetricTile(
              label: context.l10n.notes,
              value: data.notesWritten.toString(),
            ),
            _MetricTile(
              label: context.l10n.followUp,
              value: data.followUpNotes.toString(),
            ),
            _MetricTile(
              label: context.l10n.needCare,
              value: data.atRiskStudents.toString(),
            ),
          ],
        ),
      ],
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.data});

  final TeacherDetailData data;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        _TeacherHeader(data: data),
        DetailSectionCard(
          title: context.l10n.teachingLoad,
          icon: Icons.work_outline,
          children: [
            _MetricTile(
              label: context.l10n.classes,
              value: data.classCount.toString(),
            ),
            _MetricTile(
              label: context.l10n.students,
              value: data.totalStudents.toString(),
            ),
            _MetricTile(
              label: context.l10n.subjects,
              value: data.subjects.length.toString(),
            ),
            _MetricTile(
              label: context.l10n.teachingHours,
              value: _formatHours(data.teachingHours),
            ),
          ],
        ),
        DetailSectionCard(
          title: context.l10n.summaryInsight,
          icon: Icons.auto_awesome_outlined,
          wrapChildren: false,
          children: [DetailEmptySectionText(data.summary)],
        ),
        DetailSectionCard(
          title: context.l10n.alerts,
          icon: Icons.warning_amber_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                context.l10n.signal,
                context.l10n.detail,
                context.l10n.level,
              ],
              rows: data.alertRows,
              emptyText: context.l10n.noManagementAlerts,
            ),
          ],
        ),
      ],
    );
  }
}

class _ImpactTab extends StatelessWidget {
  const _ImpactTab({required this.data});

  final TeacherDetailData data;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        DetailSectionCard(
          title: context.l10n.studentImpactSnapshot,
          icon: Icons.trending_up_outlined,
          children: [
            _MetricTile(
              label: context.l10n.improved,
              value: '${data.improvedStudents} ${context.l10n.up}',
            ),
            _MetricTile(
              label: context.l10n.stable,
              value: '${data.stableStudents} ${context.l10n.same}',
            ),
            _MetricTile(
              label: context.l10n.declined,
              value: '${data.declinedStudents} ${context.l10n.down}',
            ),
            _MetricTile(
              label: context.l10n.needCare,
              value: data.atRiskStudents.toString(),
            ),
          ],
        ),
        DetailSectionCard(
          title: context.l10n.studentsUnderCare,
          icon: Icons.groups_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                context.l10n.studentName,
                context.l10n.className,
                context.l10n.scoreTrend,
                context.l10n.followUp,
              ],
              rows: data.studentImpactRows,
              emptyText: context.l10n.noStudentImpactRows,
            ),
          ],
        ),
      ],
    );
  }
}

class _ClassesTab extends StatelessWidget {
  const _ClassesTab({required this.data});

  final TeacherDetailData data;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        DetailSectionCard(
          title: context.l10n.assignedClassesStudents,
          icon: Icons.class_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                context.l10n.className,
                context.l10n.school,
                context.l10n.students,
                context.l10n.subjects,
              ],
              rows: data.classRows,
              emptyText: context.l10n.assignedClassesEmpty,
            ),
          ],
        ),
      ],
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.data});

  final TeacherDetailData data;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        DetailSectionCard(
          title: context.l10n.notesActivity,
          icon: Icons.note_alt_outlined,
          children: [
            _MetricTile(
              label: context.l10n.totalNotes,
              value: data.notesWritten.toString(),
            ),
            _MetricTile(
              label: context.l10n.followUp,
              value: data.followUpNotes.toString(),
            ),
            _MetricTile(
              label: context.l10n.needCare,
              value: data.atRiskStudents.toString(),
            ),
          ],
        ),
        DetailSectionCard(
          title: context.l10n.recentTeacherNotes,
          icon: Icons.history_edu_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: [
                context.l10n.date,
                context.l10n.studentName,
                context.l10n.className,
                context.l10n.type,
                context.l10n.note,
              ],
              rows: data.noteRows,
              emptyText: context.l10n.noStudentSessionNotes,
            ),
          ],
        ),
      ],
    );
  }
}

String _formatHours(double hours) {
  if (hours <= 0) return '-';
  if (hours == hours.roundToDouble()) return '${hours.round()}h';
  return '${hours.toStringAsFixed(1)}h';
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 192,
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.numericStyle.copyWith(fontSize: 17)),
        ],
      ),
    );
  }
}
