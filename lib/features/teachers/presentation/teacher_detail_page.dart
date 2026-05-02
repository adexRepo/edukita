import 'package:edukita/core/router/service_locator.dart';
import 'package:edukita/features/students/persentation/detail/detail_data_table.dart';
import 'package:edukita/features/students/persentation/detail/detail_empty_section_text.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/features/teachers/data/teacher_model.dart';
import 'package:edukita/features/teachers/domain/teacher_repository.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class TeacherDetailPage extends StatelessWidget {
  const TeacherDetailPage({super.key, required this.teacher});

  final Teacher teacher;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TeacherDetailData>(
      future: getIt<TeacherRepository>().loadTeacherDetail(teacher),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(teacher.fullName)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: Text(teacher.fullName)),
            body: Center(
              child: Text(snapshot.error?.toString() ?? 'Teacher not found'),
            ),
          );
        }

        final data = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(data.teacher.fullName)),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DefaultTabController(
              length: 6,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _TeacherHeader(data: data),
                  const SizedBox(height: 12),
                  const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: 'Overview'),
                      Tab(text: 'Students Impact'),
                      Tab(text: 'Classes'),
                      Tab(text: 'Notes Activity'),
                      Tab(text: 'Risk Management'),
                      Tab(text: 'More'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _OverviewTab(data: data),
                        _ImpactTab(data: data),
                        _ClassesTab(data: data),
                        _NotesTab(data: data),
                        _RiskTab(data: data),
                        const _MoreTab(),
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
                    '${data.role} | ${data.subjects.isEmpty ? 'No subjects assigned' : data.subjects.join(', ')}',
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
            _MetricTile(label: 'Students', value: data.totalStudents.toString()),
            _MetricTile(label: 'Classes', value: data.classCount.toString()),
            _MetricTile(label: 'Notes', value: data.notesWritten.toString()),
            _MetricTile(
              label: 'Interventions',
              value: data.interventionsHandled.toString(),
            ),
            _MetricTile(label: 'At-risk', value: data.atRiskStudents.toString()),
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
    return _TabScroll(
      children: [
        DetailSectionCard(
          title: 'Teaching Load',
          icon: Icons.work_outline,
          children: [
            _MetricTile(label: 'Classes', value: data.classCount.toString()),
            _MetricTile(label: 'Students', value: data.totalStudents.toString()),
            _MetricTile(
              label: 'Subjects',
              value: data.subjects.length.toString(),
            ),
            const _MetricTile(label: 'Teaching Hours', value: '-'),
          ],
        ),
        DetailSectionCard(
          title: 'Summary Insight',
          icon: Icons.auto_awesome_outlined,
          wrapChildren: false,
          children: [
            DetailEmptySectionText(data.summary),
          ],
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
    return _TabScroll(
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
              label: 'At-risk',
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
              columns: const ['Student', 'Class', 'Trend', 'Latest Signal'],
              rows: data.studentImpactRows,
              emptyText:
                  'Student impact rows will appear after score trend history is available.',
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
    return _TabScroll(
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
    return _TabScroll(
      children: [
        DetailSectionCard(
          title: 'Notes Activity',
          icon: Icons.note_alt_outlined,
          children: [
            _MetricTile(label: 'Total Notes', value: data.notesWritten.toString()),
            const _MetricTile(label: 'Academic', value: '-'),
            const _MetricTile(label: 'Behavior', value: '-'),
            const _MetricTile(label: 'Well-being', value: '-'),
            const _MetricTile(label: 'General', value: '-'),
          ],
        ),
        DetailSectionCard(
          title: 'Recent Teacher Notes',
          icon: Icons.history_edu_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: const ['Date', 'Student', 'Class', 'Note'],
              rows: data.noteRows,
              emptyText: 'No teaching notes have been recorded by this teacher.',
            ),
          ],
        ),
      ],
    );
  }
}

class _RiskTab extends StatelessWidget {
  const _RiskTab({required this.data});

  final TeacherDetailData data;

  @override
  Widget build(BuildContext context) {
    return _TabScroll(
      children: [
        DetailSectionCard(
          title: 'Risk Management Performance',
          icon: Icons.health_and_safety_outlined,
          children: [
            _MetricTile(
              label: 'At-risk Assigned',
              value: data.atRiskStudents.toString(),
            ),
            _MetricTile(
              label: 'Resolved',
              value: data.resolvedRiskCases.toString(),
            ),
            _MetricTile(
              label: 'Still Active',
              value: data.activeRiskCases.toString(),
            ),
            _MetricTile(label: 'Follow-up Rate', value: data.followUpRateLabel),
          ],
        ),
        DetailSectionCard(
          title: 'At-risk Students Under Care',
          icon: Icons.report_problem_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: const ['Detected At', 'Student', 'Class', 'Risk Type', 'Level'],
              rows: data.riskRows,
              emptyText: 'No at-risk students are currently linked to this teacher.',
            ),
          ],
        ),
      ],
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    return _TabScroll(
      children: const [
        DetailSectionCard(
          title: 'Attendance / Presence',
          icon: Icons.event_available_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Date', 'Status', 'Check In', 'Note'],
              rows: [],
              emptyText:
                  'Teacher attendance records will appear here when attendance tracking is enabled.',
            ),
          ],
        ),
        DetailSectionCard(
          title: 'Student Interaction Signals',
          icon: Icons.forum_outlined,
          wrapChildren: false,
          children: [
            DetailDataTable(
              columns: ['Student', 'Interaction Count', 'Flags', 'Latest Contact'],
              rows: [],
              emptyText:
                  'Most interacted and most flagged student signals will appear after engagement history is available.',
            ),
          ],
        ),
      ],
    );
  }
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

class _TabScroll extends StatelessWidget {
  const _TabScroll({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: children.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) => children[index],
    );
  }
}
