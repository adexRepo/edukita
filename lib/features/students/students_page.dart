import 'package:edukita/features/common/clay_card.dart';
import 'package:edukita/features/common/feature_cubit.dart';
import 'package:edukita/features/common/feature_page.dart';
import 'package:edukita/features/common/feature_state.dart';
import 'package:edukita/features/common/simple_count_item.dart';
import 'package:edukita/features/management/class_model.dart';
import 'package:edukita/features/students/student_detail_page.dart';
import 'package:edukita/features/students/student_form_card.dart';
import 'package:edukita/features/students/student_model.dart';
import 'package:edukita/theme/app_theme.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<FeatureCubit<Student>>().loadItems();
    context.read<FeatureCubit<SchoolClass>>().loadItems();
  }

  void _sort(String column) {
    setState(() {
      if (sortColumn == column) {
        isAscending = !isAscending;
      } else {
        sortColumn = column;
        isAscending = true;
      }
    });
  }

  Future<void> _showStudentFormDialog(
    BuildContext context, {
    Student? existingStudent,
  }) async {
    final studentCubit = context.read<FeatureCubit<Student>>();
    final classCubit = context.read<FeatureCubit<SchoolClass>>();
    final isEditing = existingStudent != null;

    // Reload classes from database to get real-time data
    await classCubit.loadItems();

    // check if context still valid
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Update Student' : 'Add Student'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child:
                  BlocBuilder<
                    FeatureCubit<SchoolClass>,
                    FeatureState<SchoolClass>
                  >(
                    builder: (builderContext, classState) {
                      return StudentFormCard(
                        availableClasses: classState.items,
                        initialStudent: existingStudent,
                        isEditing: isEditing,
                        onSubmit: (student) async {
                          if (isEditing) {
                            await studentCubit.updateItem(
                              existingStudent.id,
                              student.toMap(),
                              dialogContext,
                            );
                          } else {
                            await studentCubit.addItem(student, dialogContext);
                          }

                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                      );
                    },
                  ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final cubit = context.read<FeatureCubit<Student>>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (deleteContext) {
        return AlertDialog(
          title: const Text('Delete Student'),
          content: const Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(deleteContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(deleteContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await cubit.deleteItem(id);
    }
  }

  String _classLabel(String classId, List<SchoolClass> availableClasses) {
    final schoolClass = availableClasses.firstWhere(
      (item) => item.id == classId,
      orElse: () => SchoolClass(className: 'Unknown', level: 0, year: ''),
    );
    return schoolClass.className;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FeatureCubit<Student>, FeatureState<Student>>(
        builder: (context, studentState) {
          final students = studentState.items;
          final stats = getSummary(students);
          final sortedStudents = sortedStudent(students);

          return Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildStats(stats),
                      const SizedBox(height: 16),
                      _buildHeader(),
                      const SizedBox(height: 12),
                      _buildTable(sortedStudents),
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
          ElevatedButton.icon(
            onPressed: () => _showStudentFormDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Student'),
          ),
        ],
      ),
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

  // ================= SEARCH =================
  Widget _buildHeader() {
    return Row(
      children: [
        _buildSearchField(),
        const SizedBox(width: 8),
        _buildFilterButton(),
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

  // ================= TABLE =================
  Widget _buildTable(List<Student> students) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            _buildTableHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  return _buildRow(students[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderItem(String title, String key) {
    final isActive = sortColumn == key;

    return InkWell(
      onTap: () => _sort(key),
      child: Row(
        children: [
          Text(title),
          const SizedBox(width: 4),
          if (isActive)
            Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              size: 14,
            ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          const Expanded(flex: 1, child: Text("No")),
          Expanded(flex: 3, child: _buildHeaderItem("Name", "name")),
          Expanded(flex: 2, child: _buildHeaderItem("Age", "age")),
          const Expanded(flex: 4, child: Text("Progress")),
          const Expanded(flex: 4, child: Text("Last Activity")),
          const Expanded(flex: 2, child: Text("Action")),
        ],
      ),
    );
  }

  Widget _buildRow(Student student, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 1, child: Text("${index + 1}")),
          Expanded(flex: 3, child: Text(student.fullName)),
          Expanded(flex: 2, child: Text(student.classId)),
          Expanded(
            flex: 4,
            child: LinearProgressIndicator(
              value: 0.6,
              backgroundColor: AppColors.divider,
              color: AppColors.primary,
            ),
          ),
          const Expanded(flex: 4, child: Text("-")),
          Expanded(
            flex: 2,
            child: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  List<Student> sortedStudent(List<Student> students) {
    final sortedStudents = [...students];
    if (sortColumn != null) {
      sortedStudents.sort((a, b) {
        dynamic aValue;
        dynamic bValue;

        switch (sortColumn) {
          case 'name':
            aValue = a.fullName;
            bValue = b.fullName;
            break;
          case 'classId':
            aValue = a.classId;
            bValue = b.classId;
            break;
          default:
            return 0;
        }

        return isAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      });
    }
    return sortedStudents;
  }

  List<StatItem> getSummary(List<Student> students) {
    return [
      StatItem('Total Students', students.length),
      StatItem('Male', students.where((e) => e.gender == 'Male').length),
      StatItem('Female', students.where((e) => e.gender == 'Female').length),
      StatItem('Active', students.where((e) => e.isActive == true).length),
    ];
  }

  // @override
  // Widget build(BuildContext context) {
  //   final studentState = context.watch<FeatureCubit<Student>>().state;
  //   final classState = context.watch<FeatureCubit<SchoolClass>>().state;

  //   return FeaturePage(
  //     title: 'Students',
  //     subtitle: 'Track student enrollment and linked class assignments.',
  //     itemsCount: studentState.items.length,
  //     addButtonLabel: 'Add Student',
  //     onAddPressed: classState.items.isEmpty
  //         ? () {
  //             showDialog<void>(
  //               context: context,
  //               builder: (dialogContext) {
  //                 return AlertDialog(
  //                   title: const Text('Add Class First'),
  //                   content: const Text(
  //                     'Please create a class in Management before adding students.',
  //                   ),
  //                   actions: [
  //                     FilledButton(
  //                       onPressed: () => Navigator.of(dialogContext).pop(),
  //                       child: const Text('OK'),
  //                     ),
  //                   ],
  //                 );
  //               },
  //             );
  //           }
  //         : () => _showStudentFormDialog(context),
  //     errorMessage: studentState.message,
  //     body: studentState.loading
  //         ? const Center(child: CircularProgressIndicator())
  //         : studentState.items.isEmpty
  //         ? const Center(child: Text('No students yet. Add a new student.'))
  //         : ListView.builder(
  //             itemCount: studentState.items.length,
  //             itemBuilder: (context, index) {
  //               final student = studentState.items[index];
  //               return Card(
  //                 child: ListTile(
  //                   leading: const Icon(Icons.school),
  //                   title: Text(student.fullName),
  //                   subtitle: Text(
  //                     '${student.studentId} • ${student.nickName ?? 'No nickname'}\nClass: ${_classLabel(student.classId, classState.items)}',
  //                   ),
  //                   isThreeLine: true,
  //                   onTap: () => Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                       builder: (_) => StudentDetailPage(student: student),
  //                     ),
  //                   ),
  //                   trailing: Row(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       IconButton(
  //                         icon: const Icon(Icons.edit),
  //                         onPressed: () => _showStudentFormDialog(
  //                           context,
  //                           existingStudent: student,
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: const Icon(Icons.delete),
  //                         onPressed: () => _confirmDelete(context, student.id),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //   );
  // }
}
