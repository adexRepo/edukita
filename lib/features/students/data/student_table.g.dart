// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentTable _$StudentTableFromJson(Map<String, dynamic> json) =>
    _StudentTable(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      fullName: json['full_name'] as String,
      className: json['class_name'] as String,
      schoolName: json['school_name'] as String,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      status: $enumDecode(_$StudentStatusEnumMap, json['status']),
      jointDate: json['joint_date'] as String,
      nis: json['nis'] as String?,
      photoPath: json['photo_path'] as String?,
    );

Map<String, dynamic> _$StudentTableToJson(_StudentTable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'full_name': instance.fullName,
      'class_name': instance.className,
      'school_name': instance.schoolName,
      'gender': _$GenderEnumMap[instance.gender]!,
      'status': _$StudentStatusEnumMap[instance.status]!,
      'joint_date': instance.jointDate,
      'nis': instance.nis,
      'photo_path': instance.photoPath,
    };

const _$GenderEnumMap = {Gender.male: 'male', Gender.female: 'female'};

const _$StudentStatusEnumMap = {
  StudentStatus.active: 'active',
  StudentStatus.warning: 'warning',
  StudentStatus.inactive: 'inactive',
};
