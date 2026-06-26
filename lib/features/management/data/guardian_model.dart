import 'package:uuid/uuid.dart';

class Guardian {
  Guardian({
    String? id,
    required this.fullName,
    this.mobileNo,
    this.email,
    this.occupation,
    this.address,
    this.income,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String fullName;
  final String? mobileNo;
  final String? email;
  final String? occupation;
  final String? address;
  final double? income;

  Guardian copyWith({
    String? id,
    String? fullName,
    String? mobileNo,
    String? email,
    String? occupation,
    String? address,
    double? income,
  }) {
    return Guardian(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobileNo: mobileNo ?? this.mobileNo,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
      income: income ?? this.income,
    );
  }

  factory Guardian.fromMap(Map<String, Object?> map) {
    return Guardian(
      id: map['id']?.toString(),
      fullName: map['full_name'] as String,
      mobileNo: map['mobile_no'] as String?,
      email: map['email'] as String?,
      occupation: map['occupation'] as String?,
      address: map['address'] as String?,
      income: (map['income'] as num?)?.toDouble(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'mobile_no': mobileNo,
      'email': email,
      'occupation': occupation,
      'address': address,
      'income': income,
    };
  }

  @override
  String toString() =>
      'Guardian(id: $id, fullName: $fullName, mobileNo: $mobileNo, email: $email, occupation: $occupation, address: $address, income: $income)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Guardian &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          mobileNo == other.mobileNo &&
          email == other.email &&
          occupation == other.occupation &&
          address == other.address &&
          income == other.income;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      mobileNo.hashCode ^
      email.hashCode ^
      occupation.hashCode ^
      address.hashCode ^
      income.hashCode;
}

class StudentGuardianFormData {
  const StudentGuardianFormData({
    this.guardianId,
    this.fullName,
    this.relationship,
    this.isPrimary = false,
    this.isDeceased,
    this.mobileNo,
    this.email,
    this.occupation,
    this.address,
    this.income,
  });

  final String? guardianId;
  final String? fullName;
  final String? relationship;
  final bool isPrimary;
  final bool? isDeceased;
  final String? mobileNo;
  final String? email;
  final String? occupation;
  final String? address;
  final double? income;

  bool get hasData {
    if (isDeceased == true &&
        relationship != null &&
        relationship!.trim().isNotEmpty) {
      return true;
    }
    return [
      fullName,
      mobileNo,
      email,
      occupation,
      address,
      income?.toString(),
    ].any((value) => value != null && value.trim().isNotEmpty);
  }
}

class GuardianRelationshipOptions {
  GuardianRelationshipOptions._();

  static const values = [
    'MOTHER',
    'FATHER',
    'BROTHER',
    'SISTER',
    'UNCLE',
    'AUNTY',
    'GRANDPA',
    'GRANDMA',
  ];
}

class StudentGuardian {
  StudentGuardian({
    required this.studentId,
    required this.guardianId,
    required this.relationship,
    this.isPrimary = true,
  });

  final String studentId;
  final String guardianId;
  final String relationship;
  final bool isPrimary;

  StudentGuardian copyWith({
    String? studentId,
    String? guardianId,
    String? relationship,
    bool? isPrimary,
  }) {
    return StudentGuardian(
      studentId: studentId ?? this.studentId,
      guardianId: guardianId ?? this.guardianId,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory StudentGuardian.fromMap(Map<String, Object?> map) {
    return StudentGuardian(
      studentId: map['student_id'] as String,
      guardianId: map['guardian_id'] as String,
      relationship: map['relationship'] as String,
      isPrimary: (map['is_primary'] as num?)?.toInt() == 1,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'student_id': studentId,
      'guardian_id': guardianId,
      'relationship': relationship,
      'is_primary': isPrimary ? 1 : 0,
    };
  }

  @override
  String toString() =>
      'StudentGuardian(studentId: $studentId, guardianId: $guardianId, relationship: $relationship, isPrimary: $isPrimary)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentGuardian &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          guardianId == other.guardianId &&
          relationship == other.relationship &&
          isPrimary == other.isPrimary;

  @override
  int get hashCode =>
      studentId.hashCode ^
      guardianId.hashCode ^
      relationship.hashCode ^
      isPrimary.hashCode;
}
