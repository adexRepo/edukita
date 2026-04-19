// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_page_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StudentPageData _$StudentPageDataFromJson(Map<String, dynamic> json) =>
    _StudentPageData(
      totalStudents: (json['total_students'] as num).toInt(),
      maleStudents: (json['male_students'] as num).toInt(),
      femaleStudents: (json['female_students'] as num).toInt(),
      activeStudents: (json['active_students'] as num).toInt(),
      students: (json['students'] as List<dynamic>?)
          ?.map((e) => StudentTable.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$StudentPageDataToJson(_StudentPageData instance) =>
    <String, dynamic>{
      'total_students': instance.totalStudents,
      'male_students': instance.maleStudents,
      'female_students': instance.femaleStudents,
      'active_students': instance.activeStudents,
      'students': instance.students,
    };
