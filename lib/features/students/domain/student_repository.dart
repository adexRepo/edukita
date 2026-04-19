import 'package:edukita/core/database/base_repository.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_mapper.dart';

class StudentRepository extends BaseRepository<Student> {
  final DatabaseProvider _dbProvider;

  StudentRepository(this._dbProvider)
    : super(table: 'students', mapper: StudentMapper());

  Future<List<StudentTable>> inquiryStudent() async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery('''
      SELECT 
        s.id,
        s.nis,
        s.student_no,
        s.full_name,
        s.photo_path,
        c.class_name,
        sc.name as school_name,
        s.gender,
        s.status,
        s.join_at
      FROM students s
      LEFT JOIN classes c ON c.id = s.class_id
      LEFT JOIN student_schools ss ON ss.student_id = s.id
      LEFT JOIN schools sc ON sc.id = ss.school_id
    ''');

    return result.map((e) => StudentTable.fromJson(e)).toList();
  }
}
