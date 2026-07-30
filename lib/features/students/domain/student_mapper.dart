import 'package:edukita/core/database/mapper.dart';
import 'package:edukita/features/students/data/student.dart';

class StudentMapper extends Mapper<Student> {
  @override
  Student fromMap(Map<String, Object?> map) {
    return Student.fromJson({
      ...map,
      'student_id': map['student_no'],
      'shoe_size': map['shoes_size'],
      'teaching_location_id': map['teaching_location_id'],
    });
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
}
