import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/students/student_model.dart';

class StudentRepository {
  final dbProvider = DatabaseProvider.instance;

  Future<List<Student>> getAll() async {
    final db = await dbProvider.database;
    final result = await db.query('students');
    return result.map(Student.fromMap).toList();
  }

  Future<void> insert(Student student) async {
    final db = await dbProvider.database;
    await db.insert('students', student.toMap());
  }
}
