import 'package:edukita/features/students/data/student_table.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_page_data.freezed.dart';
part 'student_page_data.g.dart';

@freezed
abstract class StudentPageData with _$StudentPageData {
  const factory StudentPageData({
    required int totalStudents,
    required int maleStudents,
    required int femaleStudents,
    required int activeStudents,
    List<StudentTable>? students,
  }) = _StudentPageData;

  factory StudentPageData.fromJson(Map<String, dynamic> json) =>
      _$StudentPageDataFromJson(json);
}
