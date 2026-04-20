import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/persentation/student_profile_cell.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_table.dart';
import 'package:edukita/widgets/clay_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  String? sortColumn;
  bool isAscending = true;

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StudentFeatureCubit, FeatureState<StudentPageData>>(
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildSearchField(),
        const SizedBox(width: 8),
        _buildFilterButton(),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => {},
          icon: const Icon(Icons.add),
          label: const Text('Add Student'),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      width: 260,
      height: 40,
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search Student",
          prefixIcon: const Icon(Icons.search, size: 18),
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.filter_list),
    );
  }

  Widget _buildTableSection(FeatureState<StudentPageData> state) {
    if (state.loading && state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AppTable<StudentTable>(
      data: state.data?.students ?? [],
      pageable: state.data?.pageable,
      onPageChanged: (page) =>
          context.read<StudentFeatureCubit>().goToPage(page),
      columns: [
        AppTableColumn(
          title: "Student\nProfile",
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
