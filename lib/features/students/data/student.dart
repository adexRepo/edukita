import 'package:edukita/core/helper/com_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart';
part 'student.g.dart';

@freezed
abstract class Student with _$Student {
  const factory Student({
    required String id,
    required String studentId,
    required String classId,
    String? teachingLocationId,
    String? nickName,
    required String fullName,
    required String joinAt,
    String? nis,
    String? birthDate,
    Gender? gender,
    String? mobileNo,
    String? emailAddr,
    String? shoeSize,
    String? uniformSize,
    String? pantsSize,
    double? height,
    double? weight,
    String? photoPath,
    required StudentStatus status,
  }) = _Student;

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
}
