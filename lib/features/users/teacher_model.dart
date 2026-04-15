import 'package:uuid/uuid.dart';

class Teacher {
  Teacher({
    String? id,
    this.nickName,
    required this.fullName,
    this.lastEducationType,
    this.gender,
    this.email,
    this.mobileNo,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String? nickName;
  final String fullName;
  final String? lastEducationType;
  final String? gender;
  final String? email;
  final String? mobileNo;

  Teacher copyWith({
    String? id,
    String? nickName,
    String? fullName,
    String? lastEducationType,
    String? gender,
    String? email,
    String? mobileNo,
  }) {
    return Teacher(
      id: id ?? this.id,
      nickName: nickName ?? this.nickName,
      fullName: fullName ?? this.fullName,
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
      'last_education_type': lastEducationType,
      'gender': gender,
      'email': email,
      'mobile_no': mobileNo,
    };
  }

  @override
  String toString() =>
      'Teacher(id: $id, nickName: $nickName, fullName: $fullName, lastEducationType: $lastEducationType, gender: $gender, email: $email, mobileNo: $mobileNo)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Teacher &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nickName == other.nickName &&
          fullName == other.fullName &&
          lastEducationType == other.lastEducationType &&
          gender == other.gender &&
          email == other.email &&
          mobileNo == other.mobileNo;

  @override
  int get hashCode =>
      id.hashCode ^
      nickName.hashCode ^
      fullName.hashCode ^
      lastEducationType.hashCode ^
      gender.hashCode ^
      email.hashCode ^
      mobileNo.hashCode;
}
