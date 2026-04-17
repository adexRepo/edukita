import 'package:edukita/core/database/mapper.dart';
import 'package:edukita/features/students/student_model.dart';

class StudentMapper extends Mapper<Student> {
  @override
  Student fromMap(Map<String, Object?> map) {
    return Student.fromMap(map);
  }

  @override
  Map<String, Object?> toMap(Student entity) {
    return entity.toMap();
  }
}
