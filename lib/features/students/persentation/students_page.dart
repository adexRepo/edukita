import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:edukita/features/students/persentation/student_detail_page.dart';
import 'package:edukita/features/students/persentation/student_profile_cell.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/clay_card.dart';
import 'package:edukita/widgets/multi_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String? sortColumn;
  StudentFilter _filter = const StudentFilter();
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    context.read<StudentPageCubit>().init();
  }

  void _inquiry() {
    if (_filter.isEmpty) {
      context.read<StudentPageCubit>().init();
    } else {
      context.read<StudentPageCubit>().applyFilter(_filter);
    }
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StudentPageCubit, FeatureState<StudentPageData>>(
        builder: (context, state) {
          return Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildStatsFromState(
                        state.data ?? StudentPageData.empty(),
                      ),

                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 12),

                      Expanded(child: _buildTableSection(state)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= TOP BAR =================
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Students',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATS =================
  Widget _buildStatsFromState(StudentPageData state) {
    return Row(
      children: [
        Expanded(
          child: ClayCard(
            title: "Total",
            value: state.totalStudents.toString(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClayCard(title: "Male", value: state.maleStudents.toString()),
        ),
        const SizedBox(width: 8),

        Expanded(
          child: ClayCard(
            title: "Female",
            value: state.femaleStudents.toString(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClayCard(
            title: "Active",
            value: state.activeStudents.toString(),
          ),
        ),
      ],
    );
  }

  // ================= SEARCH =================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () => {},
          icon: const Icon(Icons.add),
          label: const Text('Add Student'),
        ),

        const SizedBox(width: 8),
        Row(
          children: [
            MultiFilterButton(
              title: "Filter Students",
              fields: studentFilterFields,
              onApply: (filters) => {_filter = buildStudentFilter(filters)},
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _inquiry,
              icon: Icon(Icons.search, color: AppColors.card),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableSection(FeatureState<StudentPageData> state) {
    if (state.loading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AppTable<StudentTable>(
      data: state.data?.students ?? [],
      pageable: state.data?.pageable,
      onRowTap: (item) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StudentDetailPage(student: item)),
        );
      },
      onPageChanged: (page) => context.read<StudentPageCubit>().goToPage(page),
      columns: [
        AppTableColumn(
          title: "Student Profile",
          flex: 2,
          sortValue: (data) => data.fullName.codeUnitAt(0),
          cell: (s) => StudentProfileCell(student: s),
        ),
        AppTableColumn(
          title: "Class\nSchool",
          flex: 2,
          sortValue: (data) => data.className.codeUnitAt(0),
          cell: (s) => Text('${s.className}\n${s.schoolName}'),
        ),
        AppTableColumn(
          title: "Age\nGender",
          flex: 1,
          sortValue: (data) => data.age,
          cell: (s) => Text('${s.age} y.o\n${s.gender.name.toUpperCase()}'),
        ),
        AppTableColumn(
          title: "Score\nStatus",
          flex: 1,
          sortValue: (data) => data.age,
          cell: (s) => Text('${s.age}/100\n${s.status.name.toUpperCase()}'),
        ),
        AppTableColumn(
          title: "Join Date",
          flex: 1,
          sortValue: (data) =>
              DateTime.parse(data.joinAt).millisecondsSinceEpoch,
          cell: (s) => Text(s.joinAt),
        ),
        AppTableColumn(
          title: "Actions",
          flex: 1,
          cell: (s) => Row(
            children: [
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.edit, size: 18),
              ),
              IconButton(
                onPressed: () => {},
                icon: const Icon(Icons.delete, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
