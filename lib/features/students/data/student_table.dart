import 'package:edukita/core/helper/com_enum.dart';

class StudentTable {
  const StudentTable({
    required this.id,
    required this.studentNo,
    required this.fullName,
    required this.className,
    required this.schoolName,
    required this.gender,
    required this.status,
    required this.joinAt,
    required this.age,
    required this.duafaStatus,
    required this.teachingLocationName,
    required this.profileStatus,
    this.averageScore,
    this.nis,
    this.photoPath,
  });

  final String id;
  final String studentNo;
  final String fullName;
  final String className;
  final String schoolName;
  final Gender gender;
  final StudentStatus status;
  final String joinAt;
  final int age;
  final String duafaStatus;
  final String teachingLocationName;
  final String profileStatus;
  final double? averageScore;
  final String? nis;
  final String? photoPath;

  factory StudentTable.fromJson(Map<String, dynamic> json) {
    return StudentTable(
      id: json['id']?.toString() ?? '',
      studentNo: json['student_no']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '-',
      className: json['class_name']?.toString() ?? '-',
      schoolName: json['school_name']?.toString() ?? '-',
      gender: _genderFromValue(json['gender']),
      status: _statusFromValue(json['status']),
      joinAt: json['join_at']?.toString() ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      duafaStatus: json['duafa_status']?.toString() ?? 'Dhuafa',
      teachingLocationName: json['teaching_location_name']?.toString() ?? '-',
      profileStatus: json['profile_status']?.toString() ?? 'complete',
      averageScore: (json['average_score'] as num?)?.toDouble(),
      nis: json['nis']?.toString(),
      photoPath: json['photo_path']?.toString(),
    );
  }

  static Gender _genderFromValue(Object? value) {
    final normalized = value?.toString().toLowerCase();
    return Gender.values.firstWhere(
      (item) => item.name == normalized,
      orElse: () => Gender.male,
    );
  }

  static StudentStatus _statusFromValue(Object? value) {
    final normalized = value?.toString().toLowerCase();
    return StudentStatus.values.firstWhere(
      (item) => item.name == normalized,
      orElse: () => StudentStatus.inactive,
    );
  }
}
