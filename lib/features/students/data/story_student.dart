import 'package:freezed_annotation/freezed_annotation.dart';

part 'story_student.freezed.dart';
part 'story_student.g.dart';

@freezed
abstract class StoryStudent with _$StoryStudent {
  const factory StoryStudent({
    required String id,
    required String studentId,
    required String story,
    required String createdBy,
    String? createdAt,
  }) = _StoryStudent;

  factory StoryStudent.fromJson(Map<String, dynamic> json) =>
      _$StoryStudentFromJson(json);
}
