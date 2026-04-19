import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/features/common/clay_card.dart';
import 'package:edukita/features/common/feature_cubit.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/common/simple_count_item.dart';
import 'package:edukita/features/management/class_model.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/persentation/student_detail_page.dart';
import 'package:edukita/features/students/persentation/student_form_card.dart';
import 'package:edukita/features/students/persentation/student_profile_cell.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/widgets/app_table.dart';
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

  final int _currentPage = 0;
  final int _rowsPerPage = 20;

  @override
  void initState() {
    super.initState();
    context.read<FeatureCubit<StudentPageData>>().loadItems();
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          BlocBuilder<
            FeatureCubit<StudentPageData>,
            FeatureState<StudentPageData>
          >(
            builder: (context, state) {
              final students =
                  generateDummyStudents(); // replace later with state.items

              final sorted = _sortStudents(students);

              final totalPages = (sorted.length / _rowsPerPage).ceil();

              final start = _currentPage * _rowsPerPage;
              final end = (start + _rowsPerPage).clamp(0, sorted.length);

              final paginated = sorted.sublist(start, end);

              final stats = _buildStatsData(students);

              return Column(
                children: [
                  _buildTopBar(context),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildStats(stats),
                          const SizedBox(height: 16),
                          _buildHeader(),
                          const SizedBox(height: 12),
                          Expanded(child: _buildTable(paginated)),
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

  // ================= TABLE =================
  Widget _buildTable(List<Student> students) {
    return AppTable<Student>(
      data: students,
      columns: [
        AppTableColumn(
          title: "Student Profile",
          flex: 3,
          cell: (s) => StudentProfileCell(student: s),
        ),
        AppTableColumn(
          title: "Class & School",
          flex: 3,
          // sortValue: (s) => s.fullName,
          cell: (s) => Text(s.fullName),
        ),
        AppTableColumn(
          title: "Gender",
          flex: 2,
          cell: (s) => Text(s.gender?.toString() ?? "-"),
        ),
        AppTableColumn(
          title: "Active",
          flex: 2,
          sortValue: (s) => (s.status == StudentStatus.active) ? 1 : 0,
          cell: (s) => Icon(
            (s.status == StudentStatus.active)
                ? Icons.check_circle
                : Icons.cancel,
            color: (s.status == StudentStatus.active)
                ? AppColors.success
                : AppColors.error,
          ),
        ),
        AppTableColumn(
          title: "Join Date",
          flex: 3,
          cell: (s) => Text(s.joinAt.split('T').first),
        ),
      ],
    );
  }

  // ================= STATS =================
  Widget _buildStats(List<StatItem> stats) {
    return Row(
      children: List.generate(stats.length * 2 - 1, (index) {
        if (index.isOdd) return const SizedBox(width: 16);

        final stat = stats[index ~/ 2];

        return Expanded(
          child: ClayCard(title: stat.title, value: stat.value.toString()),
        );
      }),
    );
  }

  List<StatItem> _buildStatsData(List<Student> students) {
    return [
      StatItem('Total Students', students.length),
      StatItem('Male', students.where((e) => e.gender == Gender.male).length),
      StatItem(
        'Female',
        students.where((e) => e.gender == Gender.female).length,
      ),
      StatItem(
        'Active',
        students.where((e) => e.status == StudentStatus.active).length,
      ),
    ];
  }

  // ================= SEARCH =================
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSearchField(),
        const SizedBox(width: 8),
        _buildFilterButton(),
        ElevatedButton.icon(
          onPressed: () => _showStudentFormDialog(context),
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

  // ================= SORT =================
  List<Student> _sortStudents(List<Student> students) {
    final list = [...students];

    if (sortColumn != null) {
      list.sort((a, b) {
        dynamic aVal;
        dynamic bVal;

        switch (sortColumn) {
          case 'name':
            aVal = a.fullName;
            bVal = b.fullName;
            break;
          default:
            return 0;
        }

        return isAscending ? aVal.compareTo(bVal) : bVal.compareTo(aVal);
      });
    }

    return list;
  }

  // ================= DUMMY =================
  List<Student> generateDummyStudents() {
    return List.generate(21, (i) {
      return Student(
        studentId: 'STD${1000 + i}',
        classId: 'class-1',
        fullName: 'Student ${i + 1}',
        joinAt: DateTime.now().toIso8601String(),
        gender: i % 2 == 0 ? Gender.male : Gender.female,
        status: i % 3 != 0 ? StudentStatus.active : StudentStatus.inactive,
        id: 'dummy-id-${i + 1}',
      );
    });
  }

  // ================= FORM =================
  Future<void> _showStudentFormDialog(BuildContext context) async {
    final studentCubit = context.read<FeatureCubit<Student>>();
    final classCubit = context.read<FeatureCubit<SchoolClass>>();

    await classCubit.loadItems();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Add Student'),
          content:
              BlocBuilder<FeatureCubit<SchoolClass>, FeatureState<SchoolClass>>(
                builder: (_, classState) {
                  return StudentFormCard(
                    availableClasses: classState.items,
                    onSubmit: (student) async {
                      await studentCubit.addItem(student, context);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
        );
      },
    );
  }
}
