import 'package:edukita/core/helper/com_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'student_detail_data.freezed.dart';
part 'student_detail_data.g.dart';

@freezed
abstract class StudentDetailData with _$StudentDetailData {
  const factory StudentDetailData({
    required String id,
    required String studentNo,
    required String classId,
    required String nickName,
    required String fullName,
    required String joinAt,
    required Gender gender,
    required StudentStatus status,
    required String className,
    required String schoolName,
    required int age,
    required String birthDate,
    String? nis,
    String? mobileNo,
    String? emailAddr,
    String? shoesSize,
    String? uniformSize,
    String? pantsSize,
    String? teachingLocationName,
    @Default('complete') String profileStatus,
    double? height,
    double? weight,
    String? photoPath,
  }) = _StudentDetailData;

  factory StudentDetailData.fromJson(Map<String, dynamic> json) =>
      _$StudentDetailDataFromJson(json);
}
