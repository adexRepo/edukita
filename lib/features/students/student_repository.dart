import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/database/base_repository.dart';
import 'package:edukita/features/students/student_mapper.dart';
import 'package:edukita/features/students/student_model.dart';
import 'package:edukita/features/students/student_story_model.dart';

class StudentRepository extends BaseRepository<Student> {
  final DatabaseProvider _dbProvider;

  StudentRepository(this._dbProvider)
    : super(table: 'students', mapper: StudentMapper());

  Future<List<Student>> findByClass(String classId) async {
    final db = await DatabaseProvider.instance.database;

    final result = await db.query(
      table,
      where: 'class_id = ?',
      whereArgs: [classId],
    );

    return result.map(mapper.fromMap).toList();
  }

  Future<List<Student>> search(String keyword) async {
    final db = await DatabaseProvider.instance.database;

    final result = await db.query(
      table,
      where: 'full_name LIKE ?',
      whereArgs: ['%$keyword%'],
    );

    return result.map(mapper.fromMap).toList();
  }

  Future<List<Student>> getAllStudents() async {
    final db = await _dbProvider.database;
    final maps = await db.query('students');
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<Student?> getStudentById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('students', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return Student.fromMap(maps.first);
  }

  Future<Student?> getStudentByNo(String studentNo) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'students',
      where: 'student_no = ?',
      whereArgs: [studentNo],
    );
    if (maps.isEmpty) {
      return null;
    }
    return Student.fromMap(maps.first);
  }

  Future<int> insertStudent(Student student) async {
    final db = await _dbProvider.database;
    return db.insert('students', student.toMap());
  }

  Future<int> updateStudent(Student student) async {
    final db = await _dbProvider.database;
    return db.update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(String id) async {
    final db = await _dbProvider.database;
    return db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Student>> getStudentsByClass(String classId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'students',
      where: 'class_id = ?',
      whereArgs: [classId],
    );
    return maps.map((map) => Student.fromMap(map)).toList();
  }

  Future<int> insertStudentStory(StudentStory story) async {
    final db = await _dbProvider.database;
    return db.insert('students_stories', story.toMap());
  }

  Future<int> updateStudentStory(StudentStory story) async {
    final db = await _dbProvider.database;
    return db.update(
      'students_stories',
      story.toMap(),
      where: 'id = ?',
      whereArgs: [story.id],
    );
  }

  Future<List<StudentStory>> getStudentStories(String studentId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'students_stories',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    return maps.map((map) => StudentStory.fromMap(map)).toList();
  }

  Future<int> deleteStudentStory(String storyId) async {
    final db = await _dbProvider.database;
    return db.delete('students_stories', where: 'id = ?', whereArgs: [storyId]);
  }
}
