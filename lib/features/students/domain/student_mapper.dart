import 'package:edukita/core/database/mapper.dart';
import 'package:edukita/features/students/data/student.dart';

class StudentMapper extends Mapper<Student> {
  @override
  Student fromMap(Map<String, Object?> map) {
    final json = <String, dynamic>{
      ...map,
      'id': _stringValue(map['id']) ?? '',
      'student_id': _stringValue(map['student_no']) ?? '',
      'class_id': _stringValue(map['class_id']) ?? '',
      'teaching_location_id': _stringValue(map['teaching_location_id']),
      'nick_name': _stringValue(map['nick_name']),
      'full_name': _stringValue(map['full_name']) ?? '',
      'join_at': _stringValue(map['join_at']) ?? '',
      'nis': _stringValue(map['nis']),
      'birth_date': _stringValue(map['birth_date']),
      'gender': _stringValue(map['gender']),
      'mobile_no': _stringValue(map['mobile_no']),
      'email_addr': _stringValue(map['email_addr']),
      'shoe_size': _stringValue(map['shoes_size']),
      'uniform_size': _stringValue(map['uniform_size']),
      'pants_size': _stringValue(map['pants_size']),
      'height': _doubleValue(map['height']),
      'weight': _doubleValue(map['weight']),
      'photo_path': _stringValue(map['photo_path']),
      'status': _stringValue(map['status']) ?? 'active',
      'profile_status': _stringValue(map['profile_status']) ?? 'complete',
    };

    return Student.fromJson(json);
  }

  @override
  Map<String, Object?> toMap(Student entity) {
    final json = entity.toJson();

    return {
      'id': json['id'],
      'student_no': json['student_id'],
      'class_id': json['class_id'],
      'teaching_location_id': json['teaching_location_id'],
      'nick_name': json['nick_name'],
      'full_name': json['full_name'],
      'join_at': json['join_at'],
      'nis': json['nis'],
      'birth_date': json['birth_date'],
      'gender': json['gender'],
      'mobile_no': json['mobile_no'],
      'email_addr': json['email_addr'],
      'shoes_size': json['shoe_size'],
      'uniform_size': json['uniform_size'],
      'pants_size': json['pants_size'],
      'height': json['height'],
      'weight': json['weight'],
      'photo_path': json['photo_path'],
      'status': json['status'],
      'profile_status': json['profile_status'],
    };
  }

  String? _stringValue(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  double? _doubleValue(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }
}
