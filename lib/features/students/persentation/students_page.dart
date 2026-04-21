import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_feature_cubit.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
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
  StudentFilter? _filter;
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    context.read<StudentFeatureCubit>().init();
  }

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton.icon(
          onPressed: () => {},
          icon: const Icon(Icons.add),
          label: const Text('Add Student'),
        ),
        const SizedBox(width: 8),
        MultiFilterButton(
          fields: studentFilterFields,
          onApply: (filters) {
            for (var f in filters) {
              print("${f.fieldCode} ${f.operator} ${f.value}");
            }
          },
        ),
      ],
    );
  }

  StudentFilter buildStudentFilter(List<MultiFilterItem> items) {
    List<String>? map(String field) {
      final values = items
          .where((e) => e.fieldCode == field)
          .map((e) => e.value)
          .whereType<String>()
          .toList();

      return values.isEmpty ? null : values;
    }

    return StudentFilter(
      keyword: map("keyword"),
      status: map("status"),
      classNames: map("className"),
      schoolNames: map("schoolName"),
      joinAt: map("joinAt"),
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

  final List<FilterField> studentFilterFields = [
    FilterField(
      code: "name",
      label: "Name",
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Name cannot be empty";
        }
        if (value.length < 2) {
          return "Name too short";
        }
        return null;
      },
    ),

    FilterField(
      code: "student_id",
      label: "Student ID",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Student ID is required";
        }
        final regex = RegExp(r'^[A-Za-z0-9\-]+$');
        if (!regex.hasMatch(value)) {
          return "Invalid Student ID format";
        }
        return null;
      },
    ),

    FilterField(
      code: "class",
      label: "Class",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Class is required";
        }
        return null;
      },
    ),

    FilterField(
      code: "school",
      label: "School",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "School cannot be empty";
        }
        return null;
      },
    ),

    FilterField(
      code: "age",
      label: "Age",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null; // optional filter
        }

        final age = int.tryParse(value);
        if (age == null) {
          return "Age must be a number";
        }
        if (age < 1 || age > 120) {
          return "Age must be between 1–120";
        }
        return null;
      },
    ),

    FilterField(
      code: "gender",
      label: "Gender",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }

        final v = value.toLowerCase();
        if (v != "male" && v != "female") {
          return "Gender must be male or female";
        }
        return null;
      },
    ),

    FilterField(
      code: "score",
      label: "Score",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }

        final score = double.tryParse(value);
        if (score == null) {
          return "Score must be numeric";
        }
        if (score < 0 || score > 100) {
          return "Score must be 0–100";
        }
        return null;
      },
    ),

    FilterField(
      code: "status",
      label: "Status",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }

        const allowed = ["active", "inactive", "graduated"];
        if (!allowed.contains(value.toLowerCase())) {
          return "Status must be active/inactive/graduated";
        }
        return null;
      },
    ),

    FilterField(
      code: "join_date",
      label: "Join Date",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return null;
        }

        try {
          DateTime.parse(value);
        } catch (_) {
          return "Invalid date format (YYYY-MM-DD)";
        }

        return null;
      },
    ),
  ];
}
