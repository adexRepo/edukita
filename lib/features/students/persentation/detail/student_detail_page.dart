import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/domain/detail/student_detail_cubit.dart';
import 'package:edukita/features/students/persentation/detail/student_academic_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_activities_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_behavior_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_family_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_more_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_overview_tab.dart';
import 'package:edukita/features/students/persentation/detail/student_personal_tab.dart';
import 'package:edukita/widgets/detail_breadcrumbs.dart';
import 'package:edukita/widgets/detail_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentDetailPage extends StatefulWidget {
  final String studentId;
  const StudentDetailPage({super.key, required this.studentId});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        leading: const DetailAppBarBackButton(fallbackRoute: '/students'),
        title: BlocBuilder<StudentDetailCubit, FeatureState<StudentDetailData>>(
          builder: (context, state) {
            return DetailBreadcrumbs(
              items: [
                const DetailBreadcrumbItem(
                  label: 'Students',
                  route: '/students',
                ),
                DetailBreadcrumbItem(
                  label: state.data?.fullName ?? 'Student Detail',
                ),
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<StudentDetailCubit, FeatureState<StudentDetailData>>(
        builder: (context, state) {
          if (state.loading && state.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.loading && state.data == null) {
            return Center(child: Text(state.message ?? "Failed"));
          }

          return _buildContent(state.data!);
        },
      ),
    );
  }

  Widget _buildContent(StudentDetailData student) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DefaultTabController(
        initialIndex: 0,
        length: 7,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 8),
            const DetailTabBar(
              tabs: [
                "Overview",
                "Personal",
                "Family",
                "Academic",
                "Behavior",
                "Activities",
                "More",
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StudentOverviewTab(student: student),
                  StudentPersonalTab(student: student),
                  StudentFamilyTab(student: student),
                  StudentAcademicTab(student: student),
                  const StudentBehaviorTab(),
                  StudentActivitiesTab(student: student),
                  StudentMoreTab(student: student),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
