// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'story_student.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StoryStudent _$StoryStudentFromJson(Map<String, dynamic> json) =>
    _StoryStudent(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      story: json['story'] as String,
      createdBy: json['created_by'] as String,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$StoryStudentToJson(_StoryStudent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'story': instance.story,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt,
    };
