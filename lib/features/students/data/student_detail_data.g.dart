// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_detail_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentDetailData _$StudentDetailDataFromJson(Map<String, dynamic> json) =>
    _StudentDetailData(
      id: json['id'] as String,
      studentNo: json['student_no'] as String,
      classId: json['class_id'] as String,
      nickName: json['nick_name'] as String,
      fullName: json['full_name'] as String,
      joinAt: json['join_at'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      status: $enumDecode(_$StudentStatusEnumMap, json['status']),
      className: json['class_name'] as String,
      schoolName: json['school_name'] as String,
      age: (json['age'] as num).toInt(),
      birthDate: json['birth_date'] as String,
      nis: json['nis'] as String?,
      mobileNo: json['mobile_no'] as String?,
      emailAddr: json['email_addr'] as String?,
      shoesSize: (json['shoes_size'] as num?)?.toInt(),
      uniformSize: (json['uniform_size'] as num?)?.toInt(),
      pantsSize: (json['pants_size'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      photoPath: json['photo_path'] as String?,
    );

Map<String, dynamic> _$StudentDetailDataToJson(_StudentDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_no': instance.studentNo,
      'class_id': instance.classId,
      'nick_name': instance.nickName,
      'full_name': instance.fullName,
      'join_at': instance.joinAt,
      'gender': _$GenderEnumMap[instance.gender]!,
      'status': _$StudentStatusEnumMap[instance.status]!,
      'class_name': instance.className,
      'school_name': instance.schoolName,
      'age': instance.age,
      'birth_date': instance.birthDate,
      'nis': instance.nis,
      'mobile_no': instance.mobileNo,
      'email_addr': instance.emailAddr,
      'shoes_size': instance.shoesSize,
      'uniform_size': instance.uniformSize,
      'pants_size': instance.pantsSize,
      'height': instance.height,
      'weight': instance.weight,
      'photo_path': instance.photoPath,
    };

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

const _$StudentStatusEnumMap = {
  StudentStatus.active: 'active',
  StudentStatus.warning: 'warning',
  StudentStatus.inactive: 'inactive',
};
