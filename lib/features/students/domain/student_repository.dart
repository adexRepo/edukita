import 'package:edukita/core/database/base_repository.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_mapper.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';

class StudentRepository extends BaseRepository<Student> {
  final DatabaseProvider _dbProvider;

  StudentRepository(this._dbProvider)
    : super(table: 'students', mapper: StudentMapper());

  Future<List<StudentTable>> getStudents(
    StudentFilter filter,
    Pageable pageable,
  ) async {
    final db = await _dbProvider.database;

    final where = <String>[];
    final args = <dynamic>[];

    // 🔍 keyword (search multiple fields)
    if (filter.keyword.isNotEmpty) {
      where.add('''
      (s.student_no IN (${placeholders(filter.keyword.length)}) 
      OR s.nis IN (${placeholders(filter.keyword.length)}) 
      OR s.full_name LIKE ?)
    ''');

      args.addAll(filter.keyword);
      args.addAll(filter.keyword);
      args.add('%${filter.keyword.first}%');
    }

    // 📌 status
    if (filter.status.isNotEmpty) {
      where.add('s.status IN (${placeholders(filter.status.length)})');
      args.addAll(filter.status.map((value) => value.toLowerCase()));
    }

    if (filter.genders.isNotEmpty) {
      where.add('s.gender IN (${placeholders(filter.genders.length)})');
      args.addAll(filter.genders.map((value) => value.toLowerCase()));
    }

    // 📅 join date
    if (filter.joinAt.isNotEmpty) {
      where.add('s.join_at IN (${placeholders(filter.joinAt.length)})');
      args.addAll(filter.joinAt);
    }

    if (filter.ages.isNotEmpty) {
      where.add('''
      ((strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
      (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)))
      IN (${placeholders(filter.ages.length)})
    ''');
      args.addAll(filter.ages);
    }

    if (filter.scores.isNotEmpty) {
      where.add('''
      EXISTS (
        SELECT 1
        FROM student_assessments sa
        WHERE sa.student_id = s.id
        AND sa.score IN (${placeholders(filter.scores.length)})
      )
    ''');
      args.addAll(filter.scores);
    }

    // 🏫 class
    if (filter.classNames.isNotEmpty) {
      where.add('c.class_name IN (${placeholders(filter.classNames.length)})');
      args.addAll(filter.classNames);
    }

    // 🏫 school
    if (filter.schoolNames.isNotEmpty) {
      where.add('sc.name IN (${placeholders(filter.schoolNames.length)})');
      args.addAll(filter.schoolNames);
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final query =
        '''
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
      s.join_at,
      (strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
      (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)) AS age
    FROM students s
    LEFT JOIN classes c ON c.id = s.class_id
    LEFT JOIN student_schools ss ON ss.student_id = s.id
    LEFT JOIN schools sc ON sc.id = ss.school_id
    $whereClause
    ${pageable.buildOrderBy()}
    ${pageable.buildLimitOffset()}
  ''';

    final result = await db.rawQuery(query, args);

    return result.map((e) => StudentTable.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> countStudents([
    StudentFilter filter = const StudentFilter(),
  ]) async {
    final db = await _dbProvider.database;
    final where = <String>[];
    final args = <dynamic>[];

    if (filter.keyword.isNotEmpty) {
      where.add('''
      (s.student_no IN (${placeholders(filter.keyword.length)}) 
      OR s.nis IN (${placeholders(filter.keyword.length)}) 
      OR s.full_name LIKE ?)
    ''');

      args.addAll(filter.keyword);
      args.addAll(filter.keyword);
      args.add('%${filter.keyword.first}%');
    }

    if (filter.status.isNotEmpty) {
      where.add('s.status IN (${placeholders(filter.status.length)})');
      args.addAll(filter.status.map((value) => value.toLowerCase()));
    }

    if (filter.genders.isNotEmpty) {
      where.add('s.gender IN (${placeholders(filter.genders.length)})');
      args.addAll(filter.genders.map((value) => value.toLowerCase()));
    }

    if (filter.joinAt.isNotEmpty) {
      where.add('s.join_at IN (${placeholders(filter.joinAt.length)})');
      args.addAll(filter.joinAt);
    }

    if (filter.ages.isNotEmpty) {
      where.add('''
      ((strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
      (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)))
      IN (${placeholders(filter.ages.length)})
    ''');
      args.addAll(filter.ages);
    }

    if (filter.scores.isNotEmpty) {
      where.add('''
      EXISTS (
        SELECT 1
        FROM student_assessments sa
        WHERE sa.student_id = s.id
        AND sa.score IN (${placeholders(filter.scores.length)})
      )
    ''');
      args.addAll(filter.scores);
    }

    if (filter.classNames.isNotEmpty) {
      where.add('c.class_name IN (${placeholders(filter.classNames.length)})');
      args.addAll(filter.classNames);
    }

    if (filter.schoolNames.isNotEmpty) {
      where.add('sc.name IN (${placeholders(filter.schoolNames.length)})');
      args.addAll(filter.schoolNames);
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final result = await db.rawQuery(
      '''
        SELECT 
          COUNT(DISTINCT s.id) AS total_students,
          COALESCE(COUNT(DISTINCT CASE WHEN s.gender = 'male' THEN s.id END),0) AS male_students,
          COALESCE(COUNT(DISTINCT CASE WHEN s.gender = 'female' THEN s.id END),0) AS female_students,
          COALESCE(COUNT(DISTINCT CASE WHEN s.status = 'active' THEN s.id END),0) AS active_students
        FROM students s
        LEFT JOIN classes c ON c.id = s.class_id
        LEFT JOIN student_schools ss ON ss.student_id = s.id
        LEFT JOIN schools sc ON sc.id = ss.school_id
        $whereClause;
      ''',
      args,
    );

    return result.isNotEmpty
        ? result.first
        : {
            'total_students': 0,
            'male_students': 0,
            'female_students': 0,
            'active_students': 0,
          };
  }

  Future<StudentPageData> loadItems(
    StudentFilter filter,
    Pageable pageable,
  ) async {
    final students = await getStudents(filter, pageable);
    final counts = await countStudents(filter);

    return StudentPageData(
      totalStudents: counts['total_students'],
      maleStudents: counts['male_students'],
      femaleStudents: counts['female_students'],
      activeStudents: counts['active_students'],
      students: students,
      pageable: Pageable(
        page: pageable.page,
        size: pageable.size,
        totalItems: counts['total_students'],
        totalPages: (counts['total_students'] / pageable.size).ceil(),
        sorts: pageable.sorts,
      ),
    );
  }

  Future<StudentDetailData> loadDetailItem(String studentId) async {
    final db = await _dbProvider.database;
    print(studentId);

    final query = '''
          select
            s.id,
            s.nick_name,
            s.student_no,
            s.class_id ,
            c.class_name ,
            s.full_name ,
            s.join_at ,
            s.nis ,
            s.birth_date ,
            s.gender ,
            s.mobile_no ,
            s.email_addr ,
            s.shoes_size ,
            s.uniform_size ,
            s.pants_size ,
            s.height ,
            s.weight ,
            s.photo_path ,
            s.status ,
            sc.name as school_name,
            (strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
            (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)) AS age
          from
            students as s
            LEFT JOIN classes c ON c.id = s.class_id
            LEFT JOIN student_schools ss ON ss.student_id = s.id
            LEFT JOIN schools sc ON sc.id = ss.school_id
          where 
            ss.status = 1
            and s.id = ?
        ''';

    final result = await db.rawQuery(query, [studentId]);

    if (result.isEmpty) {
      throw Exception('Student not found');
    }

    print(result.first);
    return StudentDetailData.fromJson(result.first);
  }
}
