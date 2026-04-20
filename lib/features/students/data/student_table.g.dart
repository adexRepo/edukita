// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentTable _$StudentTableFromJson(Map<String, dynamic> json) =>
    _StudentTable(
      id: json['id'] as String,
      studentNo: json['student_no'] as String,
      fullName: json['full_name'] as String,
      className: json['class_name'] as String,
      schoolName: json['school_name'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      status: $enumDecode(_$StudentStatusEnumMap, json['status']),
      joinAt: json['join_at'] as String,
      age: (json['age'] as num).toInt(),
      nis: json['nis'] as String?,
      photoPath: json['photo_path'] as String?,
    );

Map<String, dynamic> _$StudentTableToJson(_StudentTable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_no': instance.studentNo,
      'full_name': instance.fullName,
      'class_name': instance.className,
      'school_name': instance.schoolName,
      'gender': _$GenderEnumMap[instance.gender]!,
      'status': _$StudentStatusEnumMap[instance.status]!,
      'join_at': instance.joinAt,
      'age': instance.age,
      'nis': instance.nis,
      'photo_path': instance.photoPath,
    };

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

const _$StudentStatusEnumMap = {
  StudentStatus.active: 'active',
  StudentStatus.warning: 'warning',
  StudentStatus.inactive: 'inactive',
};
