// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Student _$StudentFromJson(Map<String, dynamic> json) => _Student(
  id: json['id'] as String,
  studentId: json['student_id'] as String,
  classId: json['class_id'] as String,
  teachingLocationId: json['teaching_location_id'] as String?,
  nickName: json['nick_name'] as String?,
  fullName: json['full_name'] as String,
  joinAt: json['join_at'] as String,
  nis: json['nis'] as String?,
  birthDate: json['birth_date'] as String?,
  gender: $enumDecodeNullable(_$GenderEnumMap, json['gender']),
  mobileNo: json['mobile_no'] as String?,
  emailAddr: json['email_addr'] as String?,
  shoeSize: json['shoe_size'] as String?,
  uniformSize: json['uniform_size'] as String?,
  pantsSize: json['pants_size'] as String?,
  height: (json['height'] as num?)?.toDouble(),
  weight: (json['weight'] as num?)?.toDouble(),
  photoPath: json['photo_path'] as String?,
  status: $enumDecode(_$StudentStatusEnumMap, json['status']),
  profileStatus: json['profile_status'] as String? ?? 'complete',
);

Map<String, dynamic> _$StudentToJson(_Student instance) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'class_id': instance.classId,
  'teaching_location_id': instance.teachingLocationId,
  'nick_name': instance.nickName,
  'full_name': instance.fullName,
  'join_at': instance.joinAt,
  'nis': instance.nis,
  'birth_date': instance.birthDate,
  'gender': _$GenderEnumMap[instance.gender],
  'mobile_no': instance.mobileNo,
  'email_addr': instance.emailAddr,
  'shoe_size': instance.shoeSize,
  'uniform_size': instance.uniformSize,
  'pants_size': instance.pantsSize,
  'height': instance.height,
  'weight': instance.weight,
  'photo_path': instance.photoPath,
  'status': _$StudentStatusEnumMap[instance.status]!,
  'profile_status': instance.profileStatus,
};

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

const _$StudentStatusEnumMap = {
  StudentStatus.active: 'active',
  StudentStatus.warning: 'warning',
  StudentStatus.inactive: 'inactive',
};
