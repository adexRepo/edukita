import 'package:edukita/core/database/mapper.dart';
import 'package:edukita/features/students/data/student.dart';

class StudentMapper extends Mapper<Student> {
  @override
  Student fromMap(Map<String, Object?> map) {
    return Student.fromJson(map);
  }

  @override
  Map<String, Object?> toMap(Student entity) {
    return entity.toJson();
  }
}
