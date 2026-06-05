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
  Future<TeacherDetailData>? _detailFuture;

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
        _detailFuture =
            getIt<TeacherRepository>().loadTeacherDetail(widget.teacher);
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
        appBar: _appBar(widget.teacher.fullName),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_canViewTeachers) {
      return Scaffold(
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
        appBar: _appBar(widget.teacher.fullName),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return FutureBuilder<TeacherDetailData>(
      future: detailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: _appBar(widget.teacher.fullName),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: _appBar(widget.teacher.fullName),
            body: Center(
              child: Text(
                snapshot.error?.toString() ?? context.l10n.teacherNotFound,
              ),
            ),
          );
        }

        final data = snapshot.data!;
        return Scaffold(
          appBar: _appBar(data.teacher.fullName),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  DetailTabBar(
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
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withValues(alpha: 0.14),
              child: Text(
                _initials(data.teacher.fullName),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.teacher.fullName,
                    style: const TextStyle(
                      fontSize: 18,
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
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${data.teacher.email ?? '-'} | ${data.teacher.mobileNo ?? '-'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
      width: 132,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
