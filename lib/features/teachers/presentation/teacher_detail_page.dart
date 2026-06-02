import 'package:edukita/core/router/service_locator.dart';
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
          const DetailBreadcrumbItem(
            label: 'Teachers',
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
        body: const Center(
          child: Text(
            'You do not have permission to view teachers.',
            style: TextStyle(
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
              child: Text(snapshot.error?.toString() ?? 'Teacher not found'),
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
                  const DetailTabBar(
                    tabs: [
                      'Overview',
                      'Impact',
                      'Classes',
                      'Notes',
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
      title: 'Teacher Profile',
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
                        ? 'No subjects assigned'
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
              label: 'Students',
              value: data.totalStudents.toString(),
            ),
            _MetricTile(label: 'Classes', value: data.classCount.toString()),
            _MetricTile(label: 'Notes', value: data.notesWritten.toString()),
            _MetricTile(
              label: 'Follow-up',
              value: data.followUpNotes.toString(),
            ),
            _MetricTile(
              label: 'Need Care',
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
          title: 'Teaching Load',
          icon: Icons.work_outline,
          children: [
            _MetricTile(label: 'Classes', value: data.classCount.toString()),
            _MetricTile(
              label: 'Students',
              value: data.totalStudents.toString(),
            ),
            _MetricTile(
              label: 'Subjects',
              value: data.subjects.length.toString(),
            ),
            _MetricTile(
              label: 'Teaching Hours',
              value: _formatHours(data.teachingHours),
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Summary Insight',
          icon: Icons.auto_awesome_outlined,
          wrapChildren: false,
          children: [DetailEmptySectionText(data.summary)],
        ),
        DetailSectionCard(
          title: 'Alerts',
          icon: Icons.warning_amber_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: const ['Signal', 'Detail', 'Level'],
              rows: data.alertRows,
              emptyText: 'No management alerts detected for this teacher.',
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
          title: 'Student Impact Snapshot',
          icon: Icons.trending_up_outlined,
          children: [
            _MetricTile(
              label: 'Improved',
              value: '${data.improvedStudents} up',
            ),
            _MetricTile(label: 'Stable', value: '${data.stableStudents} same'),
            _MetricTile(
              label: 'Declined',
              value: '${data.declinedStudents} down',
            ),
            _MetricTile(
              label: 'Need Care',
              value: data.atRiskStudents.toString(),
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Students Under Care',
          icon: Icons.groups_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: const ['Student', 'Class', 'Score Trend', 'Follow-up'],
              rows: data.studentImpactRows,
              emptyText:
                  'Student impact rows will appear after teaching assessment scores are recorded.',
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
          title: 'Assigned Classes & Students',
          icon: Icons.class_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: const ['Class', 'School', 'Students', 'Subjects'],
              rows: data.classRows,
              emptyText:
                  'Assigned classes will appear here after schedules are linked to this teacher.',
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
          title: 'Notes Activity',
          icon: Icons.note_alt_outlined,
          children: [
            _MetricTile(
              label: 'Total Notes',
              value: data.notesWritten.toString(),
            ),
            _MetricTile(
              label: 'Follow-up',
              value: data.followUpNotes.toString(),
            ),
            _MetricTile(
              label: 'Need Care',
              value: data.atRiskStudents.toString(),
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Recent Teacher Notes',
          icon: Icons.history_edu_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: const ['Date', 'Student', 'Class', 'Type', 'Note'],
              rows: data.noteRows,
              emptyText:
                  'No student session notes have been recorded by this teacher.',
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
