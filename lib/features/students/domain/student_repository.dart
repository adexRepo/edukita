import 'package:edukita/core/database/base_repository.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_mapper.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

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
      where.add('c.name IN (${placeholders(filter.classNames.length)})');
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
      c.name as class_name,
      COALESCE(sc.name, '-') as school_name,
      s.gender,
      s.status,
      s.join_at,
      COALESCE(
        (strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
        (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)),
        0
      ) AS age
    FROM students s
    LEFT JOIN classes c ON c.id = s.class_id
    LEFT JOIN student_schools ss ON ss.student_id = s.id AND ss.status = 1
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
      where.add('c.name IN (${placeholders(filter.classNames.length)})');
      args.addAll(filter.classNames);
    }

    if (filter.schoolNames.isNotEmpty) {
      where.add('sc.name IN (${placeholders(filter.schoolNames.length)})');
      args.addAll(filter.schoolNames);
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final result = await db.rawQuery('''
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
      ''', args);

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

  Future<List<SchoolClass>> loadAvailableClasses() async {
    final db = await _dbProvider.database;
    final result = await db.query('classes', orderBy: 'level, section, name');
    return result.map(SchoolClass.fromMap).toList();
  }

  Future<List<School>> loadAvailableSchools() async {
    final db = await _dbProvider.database;
    final result = await db.query('schools', orderBy: 'name');
    return result.map(School.fromMap).toList();
  }

  Future<void> insertStudentWithSchool(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
  ]) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.insert(table, mapper.toMap(student));
      await txn.insert('student_schools', {
        'id': const Uuid().v4(),
        'student_id': student.id,
        'school_id': schoolId,
        'status': 1,
      });
      await _saveGuardians(txn, student.id, guardians);
    });
  }

  Future<void> updateStudentWithSchool(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
  ]) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.update(
        table,
        mapper.toMap(student),
        where: 'id = ?',
        whereArgs: [student.id],
      );
      await txn.delete(
        'student_schools',
        where: 'student_id = ?',
        whereArgs: [student.id],
      );
      await txn.insert('student_schools', {
        'id': const Uuid().v4(),
        'student_id': student.id,
        'school_id': schoolId,
        'status': 1,
      });
      await _saveGuardians(txn, student.id, guardians);
    });
  }

  Future<StudentGuardianFormData?> loadPrimaryGuardian(String studentId) async {
    final guardians = await loadGuardians(studentId);
    return guardians.isEmpty ? null : guardians.first;
  }

  Future<List<StudentGuardianFormData>> loadGuardians(String studentId) async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery(
      '''
        SELECT 
          g.id AS guardian_id,
          g.full_name,
          g.mobile_no,
          g.email,
          g.occupation,
          g.address,
          sg.relationship,
          sg.is_primary
        FROM student_guardians sg
        INNER JOIN guardians g ON g.id = sg.guardian_id
        WHERE sg.student_id = ?
        ORDER BY sg.is_primary DESC, sg.relationship
      ''',
      [studentId],
    );

    return result.map((row) {
      return StudentGuardianFormData(
        guardianId: row['guardian_id'] as String?,
        fullName: row['full_name'] as String?,
        relationship: row['relationship'] as String?,
        isPrimary: (row['is_primary'] as num?)?.toInt() == 1,
        mobileNo: row['mobile_no'] as String?,
        email: row['email'] as String?,
        occupation: row['occupation'] as String?,
        address: row['address'] as String?,
      );
    }).toList();
  }

  Future<void> _saveGuardians(
    Transaction txn,
    String studentId,
    List<StudentGuardianFormData> guardians,
  ) async {
    final existing = await txn.rawQuery(
      '''
        SELECT guardian_id
        FROM student_guardians
        WHERE student_id = ?
        ORDER BY is_primary DESC
        LIMIT 1
      ''',
      [studentId],
    );
    final existingGuardianId = existing.isEmpty
        ? null
        : existing.first['guardian_id'] as String?;

    await txn.delete(
      'student_guardians',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    final validGuardians = guardians.where((guardian) => guardian.hasData);

    var index = 0;
    for (final guardian in validGuardians) {
      final guardianId =
          guardian.guardianId ??
          (index == 0 ? existingGuardianId : null) ??
          const Uuid().v4();
      final guardianMap = Guardian(
        id: guardianId,
        fullName: guardian.fullName?.trim().isNotEmpty == true
            ? guardian.fullName!.trim()
            : '-',
        mobileNo: _nullIfBlank(guardian.mobileNo),
        email: _nullIfBlank(guardian.email),
        occupation: _nullIfBlank(guardian.occupation),
        address: _nullIfBlank(guardian.address),
      ).toMap();

      final updated = await txn.update(
        'guardians',
        guardianMap,
        where: 'id = ?',
        whereArgs: [guardianId],
      );
      if (updated == 0) {
        await txn.insert('guardians', guardianMap);
      }

      await txn.insert('student_guardians', {
        'student_id': studentId,
        'guardian_id': guardianId,
        'relationship': _nullIfBlank(guardian.relationship) ?? '-',
        'is_primary': guardian.isPrimary ? 1 : 0,
      });
      index++;
    }
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<void> deleteStudent(String studentId) async {
    final db = await _dbProvider.database;
    await db.transaction((txn) async {
      await txn.delete(
        'student_schools',
        where: 'student_id = ?',
        whereArgs: [studentId],
      );
      await txn.delete(table, where: 'id = ?', whereArgs: [studentId]);
    });
  }

  Future<String> generateStudentNumber() async {
    final db = await _dbProvider.database;
    final now = DateTime.now();
    final branchId = dotenv.env['BRANCH_ID'] ?? 'BRANCH';
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final prefix = '$branchId$year$month';

    final result = await db.rawQuery(
      '''
      SELECT student_no
      FROM students
      WHERE student_no LIKE ?
      ORDER BY student_no DESC
      LIMIT 1
      ''',
      ['$prefix%'],
    );

    final lastStudentNo = result.isEmpty
        ? null
        : result.first['student_no'] as String?;
    final lastRunningNumber = lastStudentNo == null
        ? 0
        : int.tryParse(lastStudentNo.substring(prefix.length)) ?? 0;
    final nextRunningNumber = (lastRunningNumber + 1).toString().padLeft(
      4,
      '0',
    );

    return '$prefix$nextRunningNumber';
  }

  Future<StudentDetailData> loadDetailItem(String studentId) async {
    final db = await _dbProvider.database;
    // print(studentId);

    final query = '''
          select
            s.id,
            s.nick_name,
            s.student_no,
            s.class_id ,
            c.name as class_name ,
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
            COALESCE(sc.name, '-') as school_name,
            COALESCE(
              (strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
              (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)),
              0
            ) AS age
          from
            students as s
            LEFT JOIN classes c ON c.id = s.class_id
            LEFT JOIN student_schools ss ON ss.student_id = s.id AND ss.status = 1
            LEFT JOIN schools sc ON sc.id = ss.school_id
          where 
            s.id = ?
        ''';

    final result = await db.rawQuery(query, [studentId]);

    if (result.isEmpty) {
      throw Exception('Student not found');
    }

    // print(result.first);
    return StudentDetailData.fromJson(result.first);
  }
}
