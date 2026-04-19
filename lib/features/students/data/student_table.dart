import 'package:edukita/core/helper/com_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_table.freezed.dart';
part 'student_table.g.dart';

@freezed
abstract class StudentTable with _$StudentTable {
  const factory StudentTable({
    required String id,
    required String studentId,
    required String fullName,
    required String className,
    required String schoolName,
    required Gender gender,
    required StudentStatus status,
    required String jointDate,
    String? nis,
    String? photoPath,
  }) = _StudentTable;

  factory StudentTable.fromJson(Map<String, dynamic> json) =>
      _$StudentTableFromJson(json);
}
