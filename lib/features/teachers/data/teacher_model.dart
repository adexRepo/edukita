import 'package:uuid/uuid.dart';

class Teacher {
  Teacher({
    String? id,
    this.nickName,
    required this.fullName,
    this.role,
    this.lastEducationType,
    this.gender,
    this.email,
    this.mobileNo,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String? nickName;
  final String fullName;
  final String? role;
  final String? lastEducationType;
  final String? gender;
  final String? email;
  final String? mobileNo;

  Teacher copyWith({
    String? id,
    String? nickName,
    String? fullName,
    String? role,
    String? lastEducationType,
    String? gender,
    String? email,
    String? mobileNo,
  }) {
    return Teacher(
      id: id ?? this.id,
      nickName: nickName ?? this.nickName,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      lastEducationType: lastEducationType ?? this.lastEducationType,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      mobileNo: mobileNo ?? this.mobileNo,
    );
  }

  factory Teacher.fromMap(Map<String, Object?> map) {
    return Teacher(
      id: map['id']?.toString(),
      nickName: map['nick_name'] as String?,
      fullName: map['full_name'] as String,
      role: map['role'] as String?,
      lastEducationType: map['last_education_type'] as String?,
      gender: map['gender'] as String?,
      email: map['email'] as String?,
      mobileNo: map['mobile_no'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nick_name': nickName,
      'full_name': fullName,
      'role': role,
      'last_education_type': lastEducationType,
      'gender': gender,
      'email': email,
      'mobile_no': mobileNo,
    };
  }

  @override
  String toString() =>
      'Teacher(id: $id, nickName: $nickName, fullName: $fullName, role: $role, lastEducationType: $lastEducationType, gender: $gender, email: $email, mobileNo: $mobileNo)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Teacher &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nickName == other.nickName &&
          fullName == other.fullName &&
          role == other.role &&
          lastEducationType == other.lastEducationType &&
          gender == other.gender &&
          email == other.email &&
          mobileNo == other.mobileNo;

  @override
  int get hashCode =>
      id.hashCode ^
      nickName.hashCode ^
      fullName.hashCode ^
      role.hashCode ^
      lastEducationType.hashCode ^
      gender.hashCode ^
      email.hashCode ^
      mobileNo.hashCode;
}

class TeacherDetailData {
  const TeacherDetailData({
    required this.teacher,
    required this.totalStudents,
    required this.classCount,
    required this.notesWritten,
    required this.interventionsHandled,
    required this.atRiskStudents,
    required this.improvedStudents,
    required this.stableStudents,
    required this.declinedStudents,
    required this.resolvedRiskCases,
    required this.activeRiskCases,
    required this.subjects,
    required this.classes,
    required this.noteRows,
    required this.classRows,
    required this.riskRows,
    required this.studentImpactRows,
    required this.alertRows,
  });

  final Teacher teacher;
  final int totalStudents;
  final int classCount;
  final int notesWritten;
  final int interventionsHandled;
  final int atRiskStudents;
  final int improvedStudents;
  final int stableStudents;
  final int declinedStudents;
  final int resolvedRiskCases;
  final int activeRiskCases;
  final List<String> subjects;
  final List<TeacherClassLoad> classes;
  final List<List<String>> noteRows;
  final List<List<String>> classRows;
  final List<List<String>> riskRows;
  final List<List<String>> studentImpactRows;
  final List<List<String>> alertRows;

  String get role {
    if (teacher.role != null && teacher.role!.trim().isNotEmpty) {
      return teacher.role!;
    }
    if (classes.isNotEmpty) return 'Subject Teacher';
    return 'Teacher';
  }

  String get followUpRateLabel {
    if (atRiskStudents == 0) return '-';
    final rate = (interventionsHandled / atRiskStudents) * 100;
    return '${rate.clamp(0, 100).round()}%';
  }

  String get summary {
    if (totalStudents == 0) {
      return '${teacher.fullName} has no assigned class load recorded yet. Add schedules or class assignments to unlock workload and impact insights.';
    }

    if (atRiskStudents > 0) {
      return '${teacher.fullName} handles $totalStudents students across $classCount classes, with $atRiskStudents at-risk students and a $followUpRateLabel intervention follow-up signal.';
    }

    return '${teacher.fullName} handles $totalStudents students across $classCount classes with no current at-risk signal recorded.';
  }
}

class TeacherClassLoad {
  const TeacherClassLoad({
    required this.className,
    required this.schoolName,
    required this.studentCount,
    required this.subjects,
  });

  final String className;
  final String schoolName;
  final int studentCount;
  final List<String> subjects;
}
