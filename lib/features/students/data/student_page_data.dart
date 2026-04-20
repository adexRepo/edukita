import 'package:edukita/core/helper/Sort.dart';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/students/data/student_table.dart';

class StudentPageData {
  final int totalStudents;
  final int maleStudents;
  final int femaleStudents;
  final int activeStudents;
  final Pageable pageable;
  final List<StudentTable>? students;

  StudentPageData({
    required this.totalStudents,
    required this.maleStudents,
    required this.femaleStudents,
    required this.activeStudents,
    required this.students,
    required this.pageable,
  });

  factory StudentPageData.empty() {
    return StudentPageData(
      totalStudents: 0,
      maleStudents: 0,
      femaleStudents: 0,
      activeStudents: 0,
      students: [],
      pageable: Pageable.empty(),
    );
  }

  StudentPageData copyWith({
    int? totalStudents,
    int? maleStudents,
    int? femaleStudents,
    int? activeStudents,
    List<StudentTable>? students,
    Pageable? pageable,
    Sort? sort,
  }) {
    return StudentPageData(
      totalStudents: totalStudents ?? this.totalStudents,
      maleStudents: maleStudents ?? this.maleStudents,
      femaleStudents: femaleStudents ?? this.femaleStudents,
      activeStudents: activeStudents ?? this.activeStudents,
      students: students ?? this.students,
      pageable: pageable ?? this.pageable,
    );
  }
}
