import 'package:uuid/uuid.dart';

class Guardian {
  Guardian({
    String? id,
    required this.fullName,
    this.mobileNo,
    this.occupation,
    this.address,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String fullName;
  final String? mobileNo;
  final String? occupation;
  final String? address;

  Guardian copyWith({
    String? id,
    String? fullName,
    String? mobileNo,
    String? occupation,
    String? address,
  }) {
    return Guardian(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobileNo: mobileNo ?? this.mobileNo,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
    );
  }

  factory Guardian.fromMap(Map<String, Object?> map) {
    return Guardian(
      id: map['id']?.toString(),
      fullName: map['full_name'] as String,
      mobileNo: map['mobile_no'] as String?,
      occupation: map['occupation'] as String?,
      address: map['address'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'mobile_no': mobileNo,
      'occupation': occupation,
      'address': address,
    };
  }

  @override
  String toString() =>
      'Guardian(id: $id, fullName: $fullName, mobileNo: $mobileNo, occupation: $occupation, address: $address)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Guardian &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          mobileNo == other.mobileNo &&
          occupation == other.occupation &&
          address == other.address;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      mobileNo.hashCode ^
      occupation.hashCode ^
      address.hashCode;
}

class StudentGuardian {
  StudentGuardian({
    required this.studentId,
    required this.guardianId,
    required this.relationship,
  });

  final String studentId;
  final String guardianId;
  final String relationship;

  StudentGuardian copyWith({
    String? studentId,
    String? guardianId,
    String? relationship,
  }) {
    return StudentGuardian(
      studentId: studentId ?? this.studentId,
      guardianId: guardianId ?? this.guardianId,
      relationship: relationship ?? this.relationship,
    );
  }

  factory StudentGuardian.fromMap(Map<String, Object?> map) {
    return StudentGuardian(
      studentId: map['student_id'] as String,
      guardianId: map['guardian_id'] as String,
      relationship: map['relationship'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'student_id': studentId,
      'guardian_id': guardianId,
      'relationship': relationship,
    };
  }

  @override
  String toString() =>
      'StudentGuardian(studentId: $studentId, guardianId: $guardianId, relationship: $relationship)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentGuardian &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          guardianId == other.guardianId &&
          relationship == other.relationship;

  @override
  int get hashCode =>
      studentId.hashCode ^ guardianId.hashCode ^ relationship.hashCode;
}
