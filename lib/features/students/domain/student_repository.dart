import 'dart:io' as io;

import 'package:edukita/core/database/base_repository.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/storage/app_storage_paths.dart';
import 'package:edukita/core/storage/uploaded_file_repository.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/data/student_detail_insight_data.dart';
import 'package:edukita/features/students/data/student_exam_score_data.dart';
import 'package:edukita/features/students/data/student_page_data.dart';
import 'package:edukita/features/students/data/student_table.dart';
import 'package:edukita/features/students/domain/student_mapper.dart';
import 'package:edukita/features/students/domain/sudent_filter.dart';
import 'package:edukita/features/syllabus/data/subject_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

class StudentRepository extends BaseRepository<Student> {
  final DatabaseProvider _dbProvider;

  StudentRepository(this._dbProvider)
    : super(table: 'students', mapper: StudentMapper());

  void _appendStudentIdentityFilters(
    List<String> where,
    List<dynamic> args,
    StudentFilter filter,
  ) {
    if (filter.namesEqual.isNotEmpty) {
      where.add(
        's.full_name COLLATE NOCASE IN (${placeholders(filter.namesEqual.length)})',
      );
      args.addAll(filter.namesEqual);
    }
    if (filter.namesContains.isNotEmpty) {
      where.add(
        '(${List.filled(filter.namesContains.length, 's.full_name LIKE ?').join(' OR ')})',
      );
      args.addAll(filter.namesContains.map((value) => '%$value%'));
    }
    if (filter.namesNot.isNotEmpty) {
      where.add(
        's.full_name COLLATE NOCASE NOT IN (${placeholders(filter.namesNot.length)})',
      );
      args.addAll(filter.namesNot);
    }
    if (filter.studentIdsEqual.isNotEmpty) {
      final slots = placeholders(filter.studentIdsEqual.length);
      where.add(
        '(s.student_no IN ($slots) OR COALESCE(s.nis, \'\') IN ($slots))',
      );
      args
        ..addAll(filter.studentIdsEqual)
        ..addAll(filter.studentIdsEqual);
    }
    if (filter.studentIdsContains.isNotEmpty) {
      where.add(
        '(${List.filled(filter.studentIdsContains.length, '(s.student_no LIKE ? OR COALESCE(s.nis, \'\') LIKE ?)').join(' OR ')})',
      );
      for (final value in filter.studentIdsContains) {
        final pattern = '%$value%';
        args.addAll([pattern, pattern]);
      }
    }
    if (filter.studentIdsNot.isNotEmpty) {
      final slots = placeholders(filter.studentIdsNot.length);
      where.add(
        'NOT (s.student_no IN ($slots) OR COALESCE(s.nis, \'\') IN ($slots))',
      );
      args
        ..addAll(filter.studentIdsNot)
        ..addAll(filter.studentIdsNot);
    }
  }

  Future<List<StudentTable>> getStudents(
    StudentFilter filter,
    Pageable pageable,
  ) async {
    final db = await _dbProvider.database;

    final where = <String>[];
    final args = <dynamic>[];

    // 🔍 keyword (search multiple fields)
    _appendStudentIdentityFilters(where, args, filter);

    // 📌 status
    if (filter.status.isNotEmpty) {
      where.add('s.status IN (${placeholders(filter.status.length)})');
      args.addAll(filter.status.map((value) => value.toLowerCase()));
    }

    if (filter.statusNot.isNotEmpty) {
      where.add('s.status NOT IN (${placeholders(filter.statusNot.length)})');
      args.addAll(filter.statusNot.map((value) => value.toLowerCase()));
    }

    if (filter.genders.isNotEmpty) {
      where.add('s.gender IN (${placeholders(filter.genders.length)})');
      args.addAll(filter.genders.map((value) => value.toLowerCase()));
    }

    if (filter.gendersNot.isNotEmpty) {
      where.add('s.gender NOT IN (${placeholders(filter.gendersNot.length)})');
      args.addAll(filter.gendersNot.map((value) => value.toLowerCase()));
    }

    // 📅 join date
    if (filter.joinAt.isNotEmpty) {
      where.add('s.join_at IN (${placeholders(filter.joinAt.length)})');
      args.addAll(filter.joinAt);
    }

    if (filter.joinAtNot.isNotEmpty) {
      where.add('s.join_at NOT IN (${placeholders(filter.joinAtNot.length)})');
      args.addAll(filter.joinAtNot);
    }

    if (filter.ages.isNotEmpty) {
      where.add('''
      ((strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
      (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)))
      IN (${placeholders(filter.ages.length)})
    ''');
      args.addAll(filter.ages);
    }

    if (filter.agesNot.isNotEmpty) {
      where.add('''
      ((strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
      (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)))
      NOT IN (${placeholders(filter.agesNot.length)})
    ''');
      args.addAll(filter.agesNot);
    }

    if (filter.scores.isNotEmpty) {
      where.add('''
      ROUND((
        SELECT AVG(COALESCE(ta.normalized_score, ta.score, ta.raw_score))
        FROM teaching_assessments ta
        INNER JOIN teaching_activities act ON act.id = ta.teaching_activity_id
        WHERE ta.student_id = s.id
          AND act.status <> 'cancelled'
          AND COALESCE(ta.normalized_score, ta.score, ta.raw_score) IS NOT NULL
      )) IN (${placeholders(filter.scores.length)})
    ''');
      args.addAll(filter.scores);
    }

    if (filter.scoresNot.isNotEmpty) {
      where.add('''
      COALESCE(ROUND((
        SELECT AVG(COALESCE(ta.normalized_score, ta.score, ta.raw_score))
        FROM teaching_assessments ta
        INNER JOIN teaching_activities act ON act.id = ta.teaching_activity_id
        WHERE ta.student_id = s.id
          AND act.status <> 'cancelled'
          AND COALESCE(ta.normalized_score, ta.score, ta.raw_score) IS NOT NULL
      )), -1) NOT IN (${placeholders(filter.scoresNot.length)})
    ''');
      args.addAll(filter.scoresNot);
    }

    // 🏫 class
    if (filter.classNames.isNotEmpty) {
      where.add('c.name IN (${placeholders(filter.classNames.length)})');
      args.addAll(filter.classNames);
    }

    if (filter.classNamesNot.isNotEmpty) {
      where.add(
        "COALESCE(c.name, '') NOT IN (${placeholders(filter.classNamesNot.length)})",
      );
      args.addAll(filter.classNamesNot);
    }

    // 🏫 school
    if (filter.schoolNames.isNotEmpty) {
      where.add('sc.name IN (${placeholders(filter.schoolNames.length)})');
      args.addAll(filter.schoolNames);
    }

    if (filter.schoolNamesNot.isNotEmpty) {
      where.add(
        "COALESCE(sc.name, '') NOT IN (${placeholders(filter.schoolNamesNot.length)})",
      );
      args.addAll(filter.schoolNamesNot);
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
      (
        SELECT AVG(COALESCE(ta.normalized_score, ta.score, ta.raw_score))
        FROM teaching_assessments ta
        INNER JOIN teaching_activities act ON act.id = ta.teaching_activity_id
        WHERE ta.student_id = s.id
          AND act.status <> 'cancelled'
          AND COALESCE(ta.normalized_score, ta.score, ta.raw_score) IS NOT NULL
      ) AS average_score,
      COALESCE(
        (strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
        (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)),
        0
      ) AS age
    FROM students s
    LEFT JOIN classes c ON c.id = s.class_id
    LEFT JOIN student_schools ss ON ss.id = (
      SELECT active_school.id
      FROM student_schools active_school
      WHERE active_school.student_id = s.id AND active_school.status = 1
      ORDER BY active_school.rowid DESC
      LIMIT 1
    )
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

    _appendStudentIdentityFilters(where, args, filter);

    if (filter.status.isNotEmpty) {
      where.add('s.status IN (${placeholders(filter.status.length)})');
      args.addAll(filter.status.map((value) => value.toLowerCase()));
    }

    if (filter.statusNot.isNotEmpty) {
      where.add('s.status NOT IN (${placeholders(filter.statusNot.length)})');
      args.addAll(filter.statusNot.map((value) => value.toLowerCase()));
    }

    if (filter.genders.isNotEmpty) {
      where.add('s.gender IN (${placeholders(filter.genders.length)})');
      args.addAll(filter.genders.map((value) => value.toLowerCase()));
    }

    if (filter.gendersNot.isNotEmpty) {
      where.add('s.gender NOT IN (${placeholders(filter.gendersNot.length)})');
      args.addAll(filter.gendersNot.map((value) => value.toLowerCase()));
    }

    if (filter.joinAt.isNotEmpty) {
      where.add('s.join_at IN (${placeholders(filter.joinAt.length)})');
      args.addAll(filter.joinAt);
    }

    if (filter.joinAtNot.isNotEmpty) {
      where.add('s.join_at NOT IN (${placeholders(filter.joinAtNot.length)})');
      args.addAll(filter.joinAtNot);
    }

    if (filter.ages.isNotEmpty) {
      where.add('''
      ((strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
      (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)))
      IN (${placeholders(filter.ages.length)})
    ''');
      args.addAll(filter.ages);
    }

    if (filter.agesNot.isNotEmpty) {
      where.add('''
      ((strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
      (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)))
      NOT IN (${placeholders(filter.agesNot.length)})
    ''');
      args.addAll(filter.agesNot);
    }

    if (filter.scores.isNotEmpty) {
      where.add('''
      ROUND((
        SELECT AVG(COALESCE(ta.normalized_score, ta.score, ta.raw_score))
        FROM teaching_assessments ta
        INNER JOIN teaching_activities act ON act.id = ta.teaching_activity_id
        WHERE ta.student_id = s.id
          AND act.status <> 'cancelled'
          AND COALESCE(ta.normalized_score, ta.score, ta.raw_score) IS NOT NULL
      )) IN (${placeholders(filter.scores.length)})
    ''');
      args.addAll(filter.scores);
    }

    if (filter.scoresNot.isNotEmpty) {
      where.add('''
      COALESCE(ROUND((
        SELECT AVG(COALESCE(ta.normalized_score, ta.score, ta.raw_score))
        FROM teaching_assessments ta
        INNER JOIN teaching_activities act ON act.id = ta.teaching_activity_id
        WHERE ta.student_id = s.id
          AND act.status <> 'cancelled'
          AND COALESCE(ta.normalized_score, ta.score, ta.raw_score) IS NOT NULL
      )), -1) NOT IN (${placeholders(filter.scoresNot.length)})
    ''');
      args.addAll(filter.scoresNot);
    }

    if (filter.classNames.isNotEmpty) {
      where.add('c.name IN (${placeholders(filter.classNames.length)})');
      args.addAll(filter.classNames);
    }

    if (filter.classNamesNot.isNotEmpty) {
      where.add(
        "COALESCE(c.name, '') NOT IN (${placeholders(filter.classNamesNot.length)})",
      );
      args.addAll(filter.classNamesNot);
    }

    if (filter.schoolNames.isNotEmpty) {
      where.add('sc.name IN (${placeholders(filter.schoolNames.length)})');
      args.addAll(filter.schoolNames);
    }

    if (filter.schoolNamesNot.isNotEmpty) {
      where.add(
        "COALESCE(sc.name, '') NOT IN (${placeholders(filter.schoolNamesNot.length)})",
      );
      args.addAll(filter.schoolNamesNot);
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
        LEFT JOIN student_schools ss ON ss.id = (
          SELECT active_school.id
          FROM student_schools active_school
          WHERE active_school.student_id = s.id AND active_school.status = 1
          ORDER BY active_school.rowid DESC
          LIMIT 1
        )
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
    StudentAdvancedFormData advanced = const StudentAdvancedFormData(),
  ]) async {
    final db = await _dbProvider.database;
    final prepared = await _prepareRegistrationForm(student.id, advanced);
    try {
      await db.transaction((txn) async {
        await txn.insert(table, mapper.toMap(student));
        await txn.insert('student_schools', {
          'id': const Uuid().v4(),
          'student_id': student.id,
          'school_id': schoolId,
          'status': 1,
        });
        final savedGuardians = await _saveGuardians(txn, student.id, guardians);
        await _saveAdvancedData(
          txn,
          student,
          guardians,
          savedGuardians,
          prepared.$1,
        );
        final photoPath = student.photoPath?.trim();
        if (photoPath != null && photoPath.isNotEmpty) {
          await UploadedFileRepository.register(
            txn,
            entityType: 'student',
            entityId: student.id,
            documentType: 'student_photo',
            filePath: photoPath,
          );
        }
      });
    } catch (_) {
      await _deleteFileQuietly(prepared.$2);
      rethrow;
    }
  }

  Future<void> updateStudentWithSchool(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
    StudentAdvancedFormData advanced = const StudentAdvancedFormData(),
  ]) async {
    final db = await _dbProvider.database;
    final prepared = await _prepareRegistrationForm(student.id, advanced);
    try {
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
        final savedGuardians = await _saveGuardians(txn, student.id, guardians);
        await _saveAdvancedData(
          txn,
          student,
          guardians,
          savedGuardians,
          prepared.$1,
        );
        final photoPath = student.photoPath?.trim();
        if (photoPath == null || photoPath.isEmpty) {
          await UploadedFileRepository.deactivate(
            txn,
            entityType: 'student',
            entityId: student.id,
            documentType: 'student_photo',
          );
        } else {
          await UploadedFileRepository.register(
            txn,
            entityType: 'student',
            entityId: student.id,
            documentType: 'student_photo',
            filePath: photoPath,
          );
        }
      });
    } catch (_) {
      await _deleteFileQuietly(prepared.$2);
      rethrow;
    }
  }

  Future<StudentAdvancedFormData> loadAdvancedFormData(String studentId) async {
    final db = await _dbProvider.database;
    final health = await _loadHealth(db, studentId);
    final relations = await loadRelations(studentId);
    final activities = await loadActivities(studentId);
    final goals = await _loadGoalInputs(db, studentId);
    final registrationForm = await _loadRegistrationForm(db, studentId);
    final householdProfile = await _loadHouseholdProfile(db, studentId);

    return StudentAdvancedFormData(
      health: health,
      relations: relations,
      activities: activities,
      registrationForm: registrationForm,
      householdProfile: householdProfile,
      hobby: goals.$1,
      aspiration: goals.$2,
    );
  }

  Future<List<StudentRelationFormData>> loadRelations(String studentId) async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery(
      '''
        SELECT
          sr.id,
          sr.related_student_id,
          sr.relation_type,
          sr.age_position,
          s.student_no,
          s.full_name
        FROM student_relations sr
        INNER JOIN students s ON s.id = sr.related_student_id
        WHERE sr.student_id = ?
        ORDER BY sr.age_position, s.full_name
      ''',
      [studentId],
    );

    return result.map((row) {
      return StudentRelationFormData(
        id: row['id'] as String?,
        relatedStudentId: row['related_student_id'] as String?,
        relatedStudentNo: row['student_no'] as String?,
        relatedStudentName: row['full_name'] as String?,
        relationType: row['relation_type'] as String?,
        agePosition: row['age_position'] as String?,
      );
    }).toList();
  }

  Future<List<StudentActivityFormData>> loadActivities(String studentId) async {
    final db = await _dbProvider.database;
    final result = await db.rawQuery(
      '''
        SELECT
          sa.id,
          sa.activity_id,
          sa.role,
          sa.achievement,
          sa.start_date,
          sa.end_date,
          a.name,
          a.type
        FROM student_activities sa
        INNER JOIN activities a ON a.id = sa.activity_id
        WHERE sa.student_id = ?
        ORDER BY sa.start_date DESC, a.name
      ''',
      [studentId],
    );

    return result.map((row) {
      return StudentActivityFormData(
        id: row['id'] as String?,
        activityId: row['activity_id'] as String?,
        name: row['name'] as String?,
        type: row['type'] as String?,
        role: row['role'] as String?,
        achievement: row['achievement'] as String?,
        startDate: row['start_date'] as String?,
        endDate: row['end_date'] as String?,
      );
    }).toList();
  }

  Future<StudentSiblingLookupResult?> lookupSiblingFamily(String lookup) async {
    final value = _nullIfBlank(lookup);
    if (value == null) return null;

    final db = await _dbProvider.database;
    final result = await db.rawQuery(
      '''
        SELECT id, student_no, full_name
        FROM students
        WHERE id = ? OR student_no = ?
        LIMIT 1
      ''',
      [value, value],
    );

    if (result.isEmpty) return null;

    final row = result.first;
    final studentId = row['id'] as String;
    return StudentSiblingLookupResult(
      studentId: studentId,
      studentNo: row['student_no'] as String?,
      fullName: row['full_name'] as String?,
      guardians: await loadGuardians(studentId),
    );
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

  Future<List<_SavedStudentGuardian>> _saveGuardians(
    Transaction txn,
    String studentId,
    List<StudentGuardianFormData> guardians,
  ) async {
    await txn.delete(
      'student_guardians',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    final validGuardians = guardians.where((guardian) => guardian.hasData);
    final savedGuardians = <_SavedStudentGuardian>[];

    for (final guardian in validGuardians) {
      final guardianId = guardian.guardianId ?? const Uuid().v4();
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
      savedGuardians.add(
        _SavedStudentGuardian(
          guardianId: guardianId,
          relationship: _nullIfBlank(guardian.relationship) ?? '-',
          isPrimary: guardian.isPrimary,
        ),
      );
    }

    return savedGuardians;
  }

  Future<void> _saveAdvancedData(
    Transaction txn,
    Student student,
    List<StudentGuardianFormData> guardians,
    List<_SavedStudentGuardian> savedGuardians,
    StudentAdvancedFormData advanced,
  ) async {
    await _saveHealth(txn, student.id, advanced.health);
    final resolvedRelations = await _saveRelations(
      txn,
      student,
      advanced.relations,
    );
    if (!guardians.any((guardian) => guardian.hasData)) {
      await _copyGuardiansFromRelations(txn, student.id, resolvedRelations);
    } else {
      await _copyGuardiansToRelations(
        txn,
        savedGuardians,
        resolvedRelations,
      );
    }
    await _saveActivities(txn, student.id, advanced.activities);
    await _saveRegistrationForm(txn, student.id, advanced.registrationForm);
    await _saveHouseholdProfile(txn, student.id, advanced.householdProfile);
    await _saveGoals(txn, student.id, advanced);
  }

  Future<StudentHouseholdProfileFormData> _loadHouseholdProfile(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final result = await db.query(
      'student_household_profiles',
      where: 'student_id = ?',
      whereArgs: [studentId],
      limit: 1,
    );
    if (result.isEmpty) return const StudentHouseholdProfileFormData();

    final row = result.first;
    return StudentHouseholdProfileFormData(
      id: row['id']?.toString(),
      homeAddress: row['home_address']?.toString(),
      dailySchoolTransportCost:
          (row['daily_school_transport_cost'] as num?)?.toDouble(),
      fatherIncome: (row['father_income'] as num?)?.toDouble(),
      motherIncome: (row['mother_income'] as num?)?.toDouble(),
      housingStatus: row['housing_status']?.toString(),
      householdMemberCount:
          (row['household_member_count'] as num?)?.toInt(),
      educationArrears: (row['education_arrears'] as num?)?.toDouble(),
      academicAchievement: row['academic_achievement']?.toString(),
      nonAcademicAchievement: row['non_academic_achievement']?.toString(),
    );
  }

  Future<void> _saveHouseholdProfile(
    Transaction txn,
    String studentId,
    StudentHouseholdProfileFormData profile,
  ) async {
    if (!profile.hasData) {
      await txn.delete(
        'student_household_profiles',
        where: 'student_id = ?',
        whereArgs: [studentId],
      );
      return;
    }

    final now = DateTime.now().toIso8601String();
    final values = <String, Object?>{
      'home_address': _nullIfBlank(profile.homeAddress) ?? '',
      'daily_school_transport_cost': profile.dailySchoolTransportCost ?? 0,
      'father_income': profile.fatherIncome ?? 0,
      'mother_income': profile.motherIncome ?? 0,
      'housing_status': _nullIfBlank(profile.housingStatus) ?? '',
      'household_member_count': profile.householdMemberCount ?? 0,
      'education_arrears': profile.educationArrears ?? 0,
      'academic_achievement': _nullIfBlank(profile.academicAchievement) ?? '',
      'non_academic_achievement':
          _nullIfBlank(profile.nonAcademicAchievement) ?? '',
      'updated_at': now,
    };
    final updated = await txn.update(
      'student_household_profiles',
      values,
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    if (updated > 0) return;

    await txn.insert('student_household_profiles', {
      'id': profile.id ?? const Uuid().v4(),
      'student_id': studentId,
      ...values,
      'created_at': now,
    });
  }

  Future<StudentHealthFormData> _loadHealth(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final result = await db.query(
      'student_health',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'updated_at DESC',
      limit: 1,
    );
    if (result.isEmpty) return const StudentHealthFormData();

    final row = result.first;
    return StudentHealthFormData(
      id: row['id'] as String?,
      bloodType: row['blood_type'] as String?,
      allergies: row['allergies'] as String?,
      medicalNotes: row['medical_notes'] as String?,
      disabilities: row['disabilities'] as String?,
      updatedAt: row['updated_at'] as String?,
    );
  }

  Future<void> _saveHealth(
    Transaction txn,
    String studentId,
    StudentHealthFormData health,
  ) async {
    await txn.delete(
      'student_health',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    if (!health.hasData) return;

    await txn.insert('student_health', {
      'id': health.id ?? const Uuid().v4(),
      'student_id': studentId,
      'blood_type': _nullIfBlank(health.bloodType),
      'allergies': _nullIfBlank(health.allergies),
      'medical_notes': _nullIfBlank(health.medicalNotes),
      'disabilities': _nullIfBlank(health.disabilities),
      'updated_at': DateTime.now().toIso8601String().split('T').first,
    });
  }

  Future<List<StudentRelationFormData>> _saveRelations(
    Transaction txn,
    Student student,
    List<StudentRelationFormData> relations,
  ) async {
    await txn.delete(
      'student_relations',
      where: 'student_id = ? OR related_student_id = ?',
      whereArgs: [student.id, student.id],
    );

    final validRelations = relations.where((relation) => relation.hasData);
    final resolved = <StudentRelationFormData>[];

    for (final relation in validRelations) {
      final related = await _findStudentRelationTarget(txn, student, relation);
      final relationType = _nullIfBlank(relation.relationType);
      final agePosition = _nullIfBlank(relation.agePosition);
      if (relationType == null || agePosition == null) {
        throw Exception('Sibling relation and age position are required.');
      }

      final now = DateTime.now().toIso8601String();
      await txn.insert('student_relations', {
        'id': relation.id ?? const Uuid().v4(),
        'student_id': student.id,
        'related_student_id': related.id,
        'relation_type': relationType,
        'age_position': agePosition,
        'created_at': now,
      });

      await txn.insert('student_relations', {
        'id': const Uuid().v4(),
        'student_id': related.id,
        'related_student_id': student.id,
        'relation_type': _relationTypeForStudent(student.gender?.name),
        'age_position': _oppositeAgePosition(agePosition),
        'created_at': now,
      });

      resolved.add(
        StudentRelationFormData(
          relatedStudentId: related.id,
          relatedStudentNo: related.studentNo,
          relatedStudentName: related.fullName,
          relationType: relationType,
          agePosition: agePosition,
        ),
      );
    }

    return resolved;
  }

  Future<_StudentRelationTarget> _findStudentRelationTarget(
    Transaction txn,
    Student student,
    StudentRelationFormData relation,
  ) async {
    final lookup =
        _nullIfBlank(relation.relatedStudentId) ??
        _nullIfBlank(relation.relatedStudentNo);
    if (lookup == null) {
      throw Exception('Sibling student ID or student number is required.');
    }

    final result = await txn.rawQuery(
      '''
        SELECT id, student_no, full_name
        FROM students
        WHERE id = ? OR student_no = ?
        LIMIT 1
      ''',
      [lookup, lookup],
    );

    if (result.isEmpty) {
      throw Exception('Sibling student "$lookup" was not found.');
    }

    final row = result.first;
    final relatedId = row['id'] as String;
    if (relatedId == student.id) {
      throw Exception('Student cannot be related to themself.');
    }

    return _StudentRelationTarget(
      id: relatedId,
      studentNo: row['student_no'] as String?,
      fullName: row['full_name'] as String?,
    );
  }

  Future<void> _copyGuardiansFromRelations(
    Transaction txn,
    String studentId,
    List<StudentRelationFormData> relations,
  ) async {
    for (final relation in relations) {
      final relatedStudentId = relation.relatedStudentId;
      if (relatedStudentId == null) continue;

      final relatedGuardians = await txn.query(
        'student_guardians',
        where: 'student_id = ?',
        whereArgs: [relatedStudentId],
        orderBy: 'is_primary DESC, relationship',
      );
      if (relatedGuardians.isEmpty) continue;

      for (final guardian in relatedGuardians) {
        await txn.insert('student_guardians', {
          'student_id': studentId,
          'guardian_id': guardian['guardian_id'],
          'relationship': guardian['relationship'],
          'is_primary': guardian['is_primary'],
        });
      }
      return;
    }
  }

  Future<void> _copyGuardiansToRelations(
    Transaction txn,
    List<_SavedStudentGuardian> guardians,
    List<StudentRelationFormData> relations,
  ) async {
    if (guardians.isEmpty || relations.isEmpty) return;

    final relatedStudentIds = <String>{};
    for (final relation in relations) {
      final relatedStudentId = relation.relatedStudentId;
      if (relatedStudentId == null) continue;
      relatedStudentIds.add(relatedStudentId);
    }

    final guardianIds = guardians
        .map((guardian) => guardian.guardianId)
        .toList(growable: false);
    final guardianPlaceholders = List.filled(guardianIds.length, '?').join(', ');

    for (final relatedStudentId in relatedStudentIds) {
      await txn.delete(
        'student_guardians',
        where: 'student_id = ? AND guardian_id NOT IN ($guardianPlaceholders)',
        whereArgs: [relatedStudentId, ...guardianIds],
      );

      final hasPrimaryGuardian = guardians.any((guardian) => guardian.isPrimary);
      if (hasPrimaryGuardian) {
        await txn.update(
          'student_guardians',
          {'is_primary': 0},
          where: 'student_id = ?',
          whereArgs: [relatedStudentId],
        );
      }

      for (final guardian in guardians) {
        final existingLink = await txn.query(
          'student_guardians',
          where: 'student_id = ? AND guardian_id = ?',
          whereArgs: [relatedStudentId, guardian.guardianId],
          limit: 1,
        );

        final guardianLink = {
          'student_id': relatedStudentId,
          'guardian_id': guardian.guardianId,
          'relationship': guardian.relationship,
          'is_primary': guardian.isPrimary ? 1 : 0,
        };

        if (existingLink.isNotEmpty) {
          await txn.update(
            'student_guardians',
            guardianLink,
            where: 'student_id = ? AND guardian_id = ?',
            whereArgs: [relatedStudentId, guardian.guardianId],
          );
          continue;
        }

        await txn.insert('student_guardians', guardianLink);
      }
    }
  }

  Future<void> _saveActivities(
    Transaction txn,
    String studentId,
    List<StudentActivityFormData> activities,
  ) async {
    await txn.delete(
      'student_activities',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );
    await txn.delete(
      'extra_activities',
      where: 'student_id = ?',
      whereArgs: [studentId],
    );

    for (final activity in activities.where((item) => item.hasData)) {
      final activityName = _nullIfBlank(activity.name);
      if (activityName == null) {
        throw Exception('Activity name is required.');
      }

      final type = StudentActivityTypeOptions.normalize(activity.type);
      final activityId = await _findOrCreateActivity(txn, activityName, type);

      await txn.insert('student_activities', {
        'id': activity.id ?? const Uuid().v4(),
        'student_id': studentId,
        'activity_id': activityId,
        'role': _nullIfBlank(activity.role),
        'achievement': _nullIfBlank(activity.achievement),
        'start_date': _nullIfBlank(activity.startDate),
        'end_date': _nullIfBlank(activity.endDate),
      });

      if (StudentActivityTypeOptions.isOtherActivity(type)) {
        await txn.insert('extra_activities', {
          'id': const Uuid().v4(),
          'student_id': studentId,
          'activity_id': activityId,
          'role': _nullIfBlank(activity.role),
          'achievement': _nullIfBlank(activity.achievement),
          'date': _nullIfBlank(activity.startDate),
        });
      }
    }
  }

  Future<String> _findOrCreateActivity(
    Transaction txn,
    String name,
    String type,
  ) async {
    final existing = await txn.rawQuery(
      '''
        SELECT id
        FROM activities
        WHERE lower(name) = lower(?) AND COALESCE(type, '') = ?
        LIMIT 1
      ''',
      [name, type],
    );

    if (existing.isNotEmpty) {
      return existing.first['id'] as String;
    }

    final id = const Uuid().v4();
    await txn.insert('activities', {
      'id': id,
      'name': name,
      'type': type,
      'description': null,
    });
    return id;
  }

  Future<(String?, String?)> _loadGoalInputs(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final result = await db.query(
      'student_goals',
      where: 'student_id = ? AND category IN (?, ?)',
      whereArgs: [studentId, 'HOBBY', 'ASPIRATION'],
      orderBy: 'created_at DESC',
    );

    String? hobby;
    String? aspiration;
    for (final row in result) {
      final category = row['category'] as String?;
      if (category == 'HOBBY' && hobby == null) {
        hobby = row['goal'] as String?;
      }
      if (category == 'ASPIRATION' && aspiration == null) {
        aspiration = row['goal'] as String?;
      }
    }
    return (hobby, aspiration);
  }

  Future<void> _saveGoals(
    Transaction txn,
    String studentId,
    StudentAdvancedFormData advanced,
  ) async {
    await txn.delete(
      'student_goals',
      where: 'student_id = ? AND category IN (?, ?)',
      whereArgs: [studentId, 'HOBBY', 'ASPIRATION'],
    );

    final now = DateTime.now().toIso8601String().split('T').first;
    final goals = [
      ('HOBBY', _nullIfBlank(advanced.hobby)),
      ('ASPIRATION', _nullIfBlank(advanced.aspiration)),
    ];

    for (final (category, goal) in goals) {
      if (goal == null) continue;
      await txn.insert('student_goals', {
        'id': const Uuid().v4(),
        'student_id': studentId,
        'goal': goal,
        'category': category,
        'created_at': now,
      });
    }
  }

  Future<StudentDocumentFormData> _loadRegistrationForm(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final result = await db.query(
      'student_documents',
      where: 'student_id = ? AND document_type = ?',
      whereArgs: [
        studentId,
        StudentDocumentTypeOptions.registrationForm,
      ],
      orderBy: 'uploaded_at DESC',
      limit: 1,
    );
    if (result.isEmpty) {
      return const StudentDocumentFormData(
        documentType: StudentDocumentTypeOptions.registrationForm,
      );
    }

    final row = result.first;
    final filePath = row['file_url'] as String?;
    return StudentDocumentFormData(
      id: row['id'] as String?,
      documentType:
          row['document_type'] as String? ??
          StudentDocumentTypeOptions.registrationForm,
      fileName: filePath == null ? null : p.basename(filePath),
      filePath: filePath,
      uploadedAt: row['uploaded_at'] as String?,
    );
  }

  Future<void> _saveRegistrationForm(
    Transaction txn,
    String studentId,
    StudentDocumentFormData document,
  ) async {
    final sourcePath = _nullIfBlank(document.sourcePath);
    var filePath = _nullIfBlank(document.filePath);

    if (sourcePath != null) {
      if (filePath == null ||
          p.normalize(sourcePath) != p.normalize(filePath)) {
        filePath = await _copyStudentRegistrationForm(
          studentId: studentId,
          sourcePath: sourcePath,
          originalFileName: document.fileName,
        );
      }
    }

    if (filePath == null) {
      throw Exception('Registration form is required.');
    }

    await txn.delete(
      'student_documents',
      where: 'student_id = ? AND document_type = ?',
      whereArgs: [
        studentId,
        StudentDocumentTypeOptions.registrationForm,
      ],
    );
    await txn.insert('student_documents', {
      'id': document.id ?? const Uuid().v4(),
      'student_id': studentId,
      'document_type': StudentDocumentTypeOptions.registrationForm,
      'file_url': filePath,
      'uploaded_at':
          _nullIfBlank(document.uploadedAt) ??
          DateTime.now().toIso8601String(),
    });
    await UploadedFileRepository.register(
      txn,
      entityType: 'student',
      entityId: studentId,
      documentType: 'registration_form',
      filePath: filePath,
      originalFileName: document.fileName,
    );
  }

  Future<(StudentAdvancedFormData, String?)> _prepareRegistrationForm(
    String studentId,
    StudentAdvancedFormData advanced,
  ) async {
    final document = advanced.registrationForm;
    final sourcePath = _nullIfBlank(document.sourcePath);
    final currentPath = _nullIfBlank(document.filePath);
    if (sourcePath == null) return (advanced, null);

    if (currentPath != null &&
        p.normalize(sourcePath) == p.normalize(currentPath)) {
      return (
        advanced.copyWith(
          registrationForm: document.copyWith(clearSourcePath: true),
        ),
        null,
      );
    }

    final copiedPath = await _copyStudentRegistrationForm(
      studentId: studentId,
      sourcePath: sourcePath,
      originalFileName: document.fileName,
    );
    return (
      advanced.copyWith(
        registrationForm: document.copyWith(
          filePath: copiedPath,
          clearSourcePath: true,
        ),
      ),
      copiedPath,
    );
  }

  Future<String> _copyStudentRegistrationForm({
    required String studentId,
    required String sourcePath,
    String? originalFileName,
  }) async {
    final sourceFile = io.File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Registration form file not found.');
    }
    if (await sourceFile.length() > 20 * 1024 * 1024) {
      throw StateError('Registration form must be 20 MB or smaller.');
    }
    final extension = p.extension(sourceFile.path).toLowerCase();
    if (!const ['.pdf', '.jpg', '.jpeg', '.png'].contains(extension)) {
      throw StateError('Registration form must be PDF, JPG, or PNG.');
    }

    final storagePath = await AppStoragePaths.storageDirectory();
    final directory = io.Directory(
      p.join(storagePath, 'student_documents', studentId),
    );
    await directory.create(recursive: true);

    final baseName = _safeFileName(
      originalFileName?.trim().isNotEmpty == true
          ? p.basenameWithoutExtension(originalFileName!.trim())
          : 'registration-form',
    );
    final fileName =
        '${baseName}_${_compactDateTime(DateTime.now())}$extension';
    final destinationPath = p.join(directory.path, fileName);

    if (p.normalize(sourceFile.path) != p.normalize(destinationPath)) {
      await sourceFile.copy(destinationPath);
    }

    return destinationPath;
  }

  String _safeFileName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9]+'), '-');
    final normalized = cleaned.replaceAll(RegExp(r'^-+|-+$'), '');
    return normalized.isEmpty ? 'file' : normalized;
  }

  String _relationTypeForStudent(String? gender) {
    return gender == 'female' ? 'SISTER' : 'BROTHER';
  }

  String _oppositeAgePosition(String agePosition) {
    return agePosition == 'OLDER' ? 'YOUNGER' : 'OLDER';
  }

  String? _nullIfBlank(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  Future<void> setStudentActiveStatus(String studentId, bool active) async {
    final db = await _dbProvider.database;
    await db.update(
      table,
      {
        'status': active
            ? StudentStatus.active.name
            : StudentStatus.inactive.name,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [studentId],
    );
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
            COALESCE(NULLIF(s.nick_name, ''), s.full_name) AS nick_name,
            s.student_no,
            s.class_id ,
            COALESCE(c.name, '-') as class_name ,
            s.full_name ,
            s.join_at ,
            s.nis ,
            COALESCE(s.birth_date, '') AS birth_date,
            CASE
              WHEN LOWER(COALESCE(s.gender, '')) IN ('male', 'female')
                THEN LOWER(s.gender)
              ELSE 'male'
            END AS gender,
            s.mobile_no ,
            s.email_addr ,
            s.shoes_size ,
            s.uniform_size ,
            s.pants_size ,
            s.height ,
            s.weight ,
            s.photo_path ,
            CASE
              WHEN LOWER(COALESCE(s.status, '')) IN ('active', 'warning', 'inactive')
                THEN LOWER(s.status)
              ELSE 'inactive'
            END AS status,
            COALESCE(sc.name, '-') as school_name,
            COALESCE(
              (strftime('%Y', 'now') - strftime('%Y', s.birth_date)) -
              (strftime('%m-%d', 'now') < strftime('%m-%d', s.birth_date)),
              0
            ) AS age
          from
            students as s
            LEFT JOIN classes c ON c.id = s.class_id
            LEFT JOIN student_schools ss ON ss.id = (
              SELECT active_school.id
              FROM student_schools active_school
              WHERE active_school.student_id = s.id AND active_school.status = 1
              ORDER BY active_school.rowid DESC
              LIMIT 1
            )
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

  Future<StudentDetailInsights> loadDetailInsights(String studentId) async {
    final db = await _dbProvider.database;
    final now = DateTime.now();
    final attendance = await _loadTeachingAttendanceInsight(db, studentId);
    final monthlyAttendance = await _loadMonthlyTeachingAttendance(
      db,
      studentId,
      now.year,
    );
    final recentAttendance = await _loadRecentTeachingAttendance(db, studentId);
    final learning = await _loadLearningInsight(db, studentId);
    final competencies = await _loadCompetencyInsights(db, studentId);
    final teacherNotes = await _loadTeacherNoteInsights(db, studentId);
    final noteTypeCounts = await _loadTeacherNoteTypeCounts(db, studentId);
    final assistanceHistory = await _loadAssistanceHistoryInsights(
      db,
      studentId,
    );

    return StudentDetailInsights(
      attendance: attendance,
      monthlyAttendance: monthlyAttendance,
      recentAttendance: recentAttendance,
      learning: learning,
      competencies: competencies,
      recentTeacherNotes: teacherNotes,
      noteTypeCounts: noteTypeCounts,
      assistanceHistory: assistanceHistory,
    );
  }

  Future<StudentExamScoreOptions> loadExamScoreOptions(String studentId) async {
    final db = await _dbProvider.database;
    await _ensureStudentExamScoreSchema(db);
    final studentLevel = await _loadStudentClassLevel(db, studentId);
    final subjectRows = await db.query(
      'subjects',
      where: "LOWER(COALESCE(status, 'active')) <> 'inactive'",
      orderBy: 'name COLLATE NOCASE',
    );
    final unitRows = studentLevel == null
        ? await db.query('units', orderBy: 'sequence_no ASC, name COLLATE NOCASE')
        : await db.rawQuery(
            '''
            SELECT DISTINCT u.*
            FROM units u
            LEFT JOIN syllabus sy ON sy.subject_id = u.subject_id
            WHERE sy.id IS NULL
               OR sy.level IS NULL
               OR sy.level = ''
               OR sy.level = ?
            ORDER BY u.sequence_no ASC, u.name COLLATE NOCASE
            ''',
            [studentLevel.toString()],
          );
    return StudentExamScoreOptions(
      subjects: subjectRows.map((row) => Subject.fromMap(row)).toList(),
      units: unitRows.map((row) => Unit.fromMap(row)).toList(),
    );
  }

  Future<int?> _loadStudentClassLevel(DatabaseExecutor db, String studentId) async {
    final rows = await db.rawQuery(
      '''
      SELECT c.level
      FROM students s
      LEFT JOIN classes c ON c.id = s.class_id
      WHERE s.id = ?
      LIMIT 1
      ''',
      [studentId],
    );
    if (rows.isEmpty) return null;
    return (rows.first['level'] as num?)?.toInt();
  }

  Future<List<StudentExamScoreGroup>> loadStudentExamScores(
    String studentId,
  ) async {
    final db = await _dbProvider.database;
    await _ensureStudentExamScoreSchema(db);
    final groupRows = await db.rawQuery(
      '''
      SELECT *
      FROM student_exam_score_groups
      WHERE student_id = ?
      ORDER BY exam_date DESC, created_at DESC
      ''',
      [studentId],
    );
    final legacyGroups = await _loadLegacyStudentExamScores(db, studentId);
    if (groupRows.isEmpty) return legacyGroups;

    final groupIds = groupRows.map((row) => row['id']?.toString() ?? '').toList();
    final itemRows = await db.rawQuery(
      '''
      SELECT
        item.*,
        subject.name AS subject_name,
        unit.name AS unit_name
      FROM student_exam_score_items item
      LEFT JOIN subjects subject ON subject.id = item.subject_id
      LEFT JOIN units unit ON unit.id = item.unit_id
      WHERE item.group_id IN (${placeholders(groupIds.length)})
      ORDER BY subject.name COLLATE NOCASE, unit.sequence_no ASC, unit.name COLLATE NOCASE
      ''',
      groupIds,
    );
    final itemsByGroup = <String, List<StudentExamScoreItem>>{};
    for (final row in itemRows) {
      final item = StudentExamScoreItem.fromMap(row);
      itemsByGroup.putIfAbsent(item.groupId, () => []).add(item);
    }

    final groups = groupRows.map((row) {
      final id = row['id']?.toString() ?? '';
      return StudentExamScoreGroup.fromMap(
        row,
        items: itemsByGroup[id] ?? const <StudentExamScoreItem>[],
      );
    }).toList();
    return [...groups, ...legacyGroups]
      ..sort((a, b) {
        final dateCompare = b.examDate.compareTo(a.examDate);
        if (dateCompare != 0) return dateCompare;
        return b.createdAt.compareTo(a.createdAt);
      });
  }

  Future<List<StudentExamScoreGroup>> _loadLegacyStudentExamScores(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        score.*,
        subject.name AS subject_name,
        unit.name AS unit_name
      FROM student_exam_scores score
      LEFT JOIN subjects subject ON subject.id = score.subject_id
      LEFT JOIN units unit ON unit.id = score.unit_id
      WHERE score.student_id = ?
      ORDER BY score.exam_date DESC, score.created_at DESC
      ''',
      [studentId],
    );

    return rows.map((row) {
      final id = row['id']?.toString() ?? '';
      final scope = row['scope']?.toString() ?? 'school';
      final item = StudentExamScoreItem(
        id: 'legacy_item_$id',
        groupId: 'legacy_$id',
        subjectId: row['subject_id']?.toString(),
        subjectName: row['subject_name']?.toString(),
        unitId: row['unit_id']?.toString(),
        unitName: row['unit_name']?.toString(),
        score: (row['score'] as num?)?.toDouble() ?? 0,
        maxScore: (row['max_score'] as num?)?.toDouble(),
        note: row['note']?.toString(),
        createdAt: row['created_at']?.toString(),
        updatedAt: row['updated_at']?.toString(),
      );
      return StudentExamScoreGroup(
        id: 'legacy_$id',
        studentId: studentId,
        scope: scope,
        examType: row['exam_type']?.toString() ?? '-',
        source: row['source']?.toString(),
        academicYear: row['academic_year']?.toString(),
        semester: row['semester']?.toString(),
        examDate: row['exam_date']?.toString() ?? '',
        evidenceRequired:
            ((row['evidence_required'] as num?)?.toInt() ?? 0) == 1,
        evidenceFileName: row['evidence_file_name']?.toString(),
        evidenceFilePath: row['evidence_file_path']?.toString(),
        evidenceFileType: row['evidence_file_type']?.toString(),
        note: row['note']?.toString(),
        items: [item],
        createdAt: row['created_at']?.toString(),
        updatedAt: row['updated_at']?.toString(),
      );
    }).toList();
  }

  Future<void> saveStudentExamScoreGroup(
    StudentExamScoreGroup group, {
    String? evidenceSourcePath,
    String? evidenceFileName,
  }) async {
    final db = await _dbProvider.database;
    await _ensureStudentExamScoreSchema(db);
    _validateStudentExamScoreGroup(
      group,
      hasNewEvidence: evidenceSourcePath?.trim().isNotEmpty == true,
    );

    var values = group.toMap();
    String? copiedEvidencePath;
    if (evidenceSourcePath?.trim().isNotEmpty == true) {
      final evidence = await _copyExamScoreEvidence(
        scoreId: group.id,
        studentId: group.studentId,
        sourcePath: evidenceSourcePath!.trim(),
        originalFileName: evidenceFileName,
      );
      values = {
        ...values,
        'evidence_file_name': evidence.fileName,
        'evidence_file_path': evidence.filePath,
        'evidence_file_type': evidence.fileType,
      };
      copiedEvidencePath = evidence.filePath;
    }

    try {
      await db.transaction((txn) async {
        await txn.insert('student_exam_score_groups', values);
        for (final item in group.items) {
          await txn.insert('student_exam_score_items', item.toMap());
        }
        final evidencePath = values['evidence_file_path']?.toString();
        if (evidencePath?.isNotEmpty == true) {
          await UploadedFileRepository.register(
            txn,
            entityType: 'student_exam_score_group',
            entityId: group.id,
            documentType: 'exam_evidence',
            filePath: evidencePath!,
            originalFileName: values['evidence_file_name']?.toString(),
          );
        }
      });
    } catch (_) {
      await _deleteFileQuietly(copiedEvidencePath);
      rethrow;
    }
  }

  Future<void> deleteStudentExamScoreGroup(StudentExamScoreGroup group) async {
    final db = await _dbProvider.database;
    await _ensureStudentExamScoreSchema(db);

    await db.transaction((txn) async {
      if (group.id.startsWith('legacy_')) {
        final legacyId = group.id.replaceFirst('legacy_', '');
        await txn.delete(
          'student_exam_scores',
          where: 'id = ?',
          whereArgs: [legacyId],
        );
        await UploadedFileRepository.deactivate(
          txn,
          entityType: 'student_exam_score',
          entityId: legacyId,
          documentType: 'exam_evidence',
        );
        return;
      }

      await txn.delete(
        'student_exam_score_items',
        where: 'group_id = ?',
        whereArgs: [group.id],
      );
      await txn.delete(
        'student_exam_score_groups',
        where: 'id = ?',
        whereArgs: [group.id],
      );
      await UploadedFileRepository.deactivate(
        txn,
        entityType: 'student_exam_score_group',
        entityId: group.id,
        documentType: 'exam_evidence',
      );
    });
  }

  Future<void> updateStudentExamScoreGroup(
    StudentExamScoreGroup group, {
    String? evidenceSourcePath,
    String? evidenceFileName,
  }) async {
    final db = await _dbProvider.database;
    await _ensureStudentExamScoreSchema(db);
    _validateStudentExamScoreGroup(
      group,
      hasNewEvidence: evidenceSourcePath?.trim().isNotEmpty == true,
    );

    var values = group.toMap()
      ..['updated_at'] = DateTime.now().toIso8601String();
    String? copiedEvidencePath;
    if (evidenceSourcePath?.trim().isNotEmpty == true) {
      final evidence = await _copyExamScoreEvidence(
        scoreId: group.id,
        studentId: group.studentId,
        sourcePath: evidenceSourcePath!.trim(),
        originalFileName: evidenceFileName,
      );
      values = {
        ...values,
        'evidence_file_name': evidence.fileName,
        'evidence_file_path': evidence.filePath,
        'evidence_file_type': evidence.fileType,
      };
      copiedEvidencePath = evidence.filePath;
    }

    try {
      await db.transaction((txn) async {
        if (group.id.startsWith('legacy_')) {
          final legacyId = group.id.replaceFirst('legacy_', '');
          final migratedGroupId = const Uuid().v4();
          final migratedValues = {...values, 'id': migratedGroupId};
          await txn.delete(
            'student_exam_scores',
            where: 'id = ?',
            whereArgs: [legacyId],
          );
          await UploadedFileRepository.deactivate(
            txn,
            entityType: 'student_exam_score',
            entityId: legacyId,
            documentType: 'exam_evidence',
          );
          await txn.insert('student_exam_score_groups', migratedValues);
          for (final item in group.items) {
            await txn.insert('student_exam_score_items', {
              ...item.toMap(),
              'group_id': migratedGroupId,
            });
          }
          final evidencePath = migratedValues['evidence_file_path']?.toString();
          if (evidencePath?.isNotEmpty == true) {
            await UploadedFileRepository.register(
              txn,
              entityType: 'student_exam_score_group',
              entityId: migratedGroupId,
              documentType: 'exam_evidence',
              filePath: evidencePath!,
              originalFileName: migratedValues['evidence_file_name']?.toString(),
            );
          }
          return;
        }

        await txn.update(
          'student_exam_score_groups',
          values,
          where: 'id = ?',
          whereArgs: [group.id],
        );
        final evidencePath = values['evidence_file_path']?.toString();
        if (evidencePath?.isNotEmpty == true) {
          await UploadedFileRepository.register(
            txn,
            entityType: 'student_exam_score_group',
            entityId: group.id,
            documentType: 'exam_evidence',
            filePath: evidencePath!,
            originalFileName: values['evidence_file_name']?.toString(),
          );
        } else {
          await UploadedFileRepository.deactivate(
            txn,
            entityType: 'student_exam_score_group',
            entityId: group.id,
            documentType: 'exam_evidence',
          );
        }
        await txn.delete(
          'student_exam_score_items',
          where: 'group_id = ?',
          whereArgs: [group.id],
        );
        for (final item in group.items) {
          await txn.insert('student_exam_score_items', item.toMap());
        }
      });
    } catch (_) {
      await _deleteFileQuietly(copiedEvidencePath);
      rethrow;
    }
  }

  Future<void> _deleteFileQuietly(String? filePath) async {
    if (filePath == null || filePath.trim().isEmpty) return;
    try {
      final file = io.File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // File cleanup must not hide the original database failure.
    }
  }

  void _validateStudentExamScoreGroup(
    StudentExamScoreGroup group, {
    required bool hasNewEvidence,
  }) {
    if (group.items.isEmpty) {
      throw Exception('At least one score item is required.');
    }
    if (group.evidenceRequired && !group.hasEvidence && !hasNewEvidence) {
      throw Exception('Evidence file is required for this exam type.');
    }

    final itemKeys = <String>{};
    for (final item in group.items) {
      final subjectId = _nullIfBlank(item.subjectId);
      final unitId = _nullIfBlank(item.unitId);
      if (subjectId == null) {
        throw Exception('Subject is required for every score item.');
      }
      if (!group.isSchool && unitId == null) {
        throw Exception('Unit is required for every internal score item.');
      }
      final maxScore = item.maxScore;
      if (maxScore == null || maxScore <= 0) {
        throw Exception('Max score must be greater than zero.');
      }
      if (item.score < 0 || item.score > maxScore) {
        throw Exception('Score must be between 0 and max score.');
      }

      final key = group.isSchool ? subjectId : '$subjectId:$unitId';
      if (!itemKeys.add(key)) {
        throw Exception(
          group.isSchool
              ? 'Duplicate subject score is not allowed.'
              : 'Duplicate subject and unit score is not allowed.',
        );
      }
    }
  }

  Future<_StoredExamEvidence> _copyExamScoreEvidence({
    required String scoreId,
    required String studentId,
    required String sourcePath,
    String? originalFileName,
  }) async {
    final sourceFile = io.File(sourcePath);
    if (!await sourceFile.exists()) {
      throw StateError('Evidence file not found.');
    }
    if (await sourceFile.length() > 20 * 1024 * 1024) {
      throw StateError('Evidence file must be 20 MB or smaller.');
    }
    final extension = p.extension(sourceFile.path).toLowerCase();
    if (!const ['.pdf', '.jpg', '.jpeg', '.png'].contains(extension)) {
      throw StateError('Evidence file must be PDF, JPG, or PNG.');
    }

    final storagePath = await AppStoragePaths.storageDirectory();
    final directory = io.Directory(
      p.join(storagePath, 'student_exam_scores', studentId),
    );
    await directory.create(recursive: true);

    final fileName =
        '${scoreId}_${_compactDateTime(DateTime.now())}$extension';
    final destinationPath = p.join(directory.path, fileName);

    if (p.normalize(sourceFile.path) != p.normalize(destinationPath)) {
      await sourceFile.copy(destinationPath);
    }

    return _StoredExamEvidence(
      fileName: originalFileName?.trim().isNotEmpty == true
          ? originalFileName!.trim()
          : p.basename(sourcePath),
      filePath: destinationPath,
      fileType: extension.replaceFirst('.', ''),
    );
  }

  Future<void> _ensureStudentExamScoreSchema(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_exam_scores(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        scope TEXT NOT NULL CHECK(scope IN ('internal', 'school')),
        subject_id TEXT,
        unit_id TEXT,
        competency_id TEXT,
        exam_type TEXT NOT NULL,
        source TEXT,
        academic_year TEXT,
        semester TEXT,
        exam_date TEXT NOT NULL,
        score REAL,
        max_score REAL,
        evidence_required INTEGER NOT NULL DEFAULT 0,
        evidence_file_name TEXT,
        evidence_file_path TEXT,
        evidence_file_type TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_scores_student ON student_exam_scores(student_id)',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_exam_score_groups(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        scope TEXT NOT NULL CHECK(scope IN ('internal', 'school')),
        exam_type TEXT NOT NULL,
        source TEXT,
        academic_year TEXT,
        semester TEXT,
        exam_date TEXT NOT NULL,
        evidence_required INTEGER NOT NULL DEFAULT 0,
        evidence_file_name TEXT,
        evidence_file_path TEXT,
        evidence_file_type TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_exam_score_items(
        id TEXT PRIMARY KEY NOT NULL,
        group_id TEXT NOT NULL,
        subject_id TEXT,
        unit_id TEXT,
        score REAL NOT NULL,
        max_score REAL,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_score_groups_student ON student_exam_score_groups(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_exam_score_items_group ON student_exam_score_items(group_id)',
    );
  }

  String _compactDateTime(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '${date.year}$month$day$hour$minute$second';
  }

  Future<StudentAttendanceInsight> _loadTeachingAttendanceInsight(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT ta.status, COUNT(*) AS count
      FROM teaching_attendances ta
      INNER JOIN teaching_activities act ON act.id = ta.teaching_activity_id
      WHERE ta.student_id = ?
        AND act.status <> 'cancelled'
      GROUP BY ta.status
      ''',
      [studentId],
    );

    var present = 0;
    var late = 0;
    var absent = 0;
    var sick = 0;
    var permission = 0;
    for (final row in rows) {
      final count = (row['count'] as num?)?.toInt() ?? 0;
      switch (row['status']?.toString()) {
        case 'present':
          present = count;
          break;
        case 'late':
          late = count;
          break;
        case 'absent':
          absent = count;
          break;
        case 'sick':
          sick = count;
          break;
        case 'permission':
          permission = count;
          break;
      }
    }

    final total = present + late + absent + sick + permission;
    return StudentAttendanceInsight(
      totalRecords: total,
      attendedRecords: present + late,
      presentCount: present,
      lateCount: late,
      absentCount: absent,
      sickCount: sick,
      permissionCount: permission,
    );
  }

  Future<List<double?>> _loadMonthlyTeachingAttendance(
    DatabaseExecutor db,
    String studentId,
    int year,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        CAST(strftime('%m', act.activity_date) AS INTEGER) AS month_no,
        COUNT(*) AS total_count,
        SUM(CASE WHEN ta.status IN ('present', 'late') THEN 1 ELSE 0 END)
          AS attended_count
      FROM teaching_attendances ta
      INNER JOIN teaching_activities act ON act.id = ta.teaching_activity_id
      WHERE ta.student_id = ?
        AND act.status <> 'cancelled'
        AND strftime('%Y', act.activity_date) = ?
      GROUP BY month_no
      ORDER BY month_no
      ''',
      [studentId, year.toString()],
    );

    final values = List<double?>.filled(12, null);
    for (final row in rows) {
      final monthNo = (row['month_no'] as num?)?.toInt();
      final total = (row['total_count'] as num?)?.toInt() ?? 0;
      final attended = (row['attended_count'] as num?)?.toInt() ?? 0;
      if (monthNo == null || monthNo < 1 || monthNo > 12 || total == 0) {
        continue;
      }
      values[monthNo - 1] = (attended / total) * 100;
    }
    return values;
  }

  Future<List<StudentAttendanceRecordView>> _loadRecentTeachingAttendance(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        act.activity_date,
        COALESCE(NULLIF(s.title, ''), u.name, 'Teaching Session') AS session_name,
        s.start_at,
        s.end_at,
        ta.status,
        ta.check_in_time,
        ta.notes
      FROM teaching_attendances ta
      INNER JOIN teaching_activities act ON act.id = ta.teaching_activity_id
      LEFT JOIN schedules s ON s.id = act.schedule_id
      LEFT JOIN units u ON u.id = s.unit_id
      WHERE ta.student_id = ?
        AND act.status <> 'cancelled'
      ORDER BY act.activity_date DESC, s.start_at DESC
      LIMIT 12
      ''',
      [studentId],
    );

    return rows.map((row) {
      final start = row['start_at']?.toString();
      final end = row['end_at']?.toString();
      final time = [start, end]
          .where((value) => value != null && value.trim().isNotEmpty)
          .join(' - ');
      return StudentAttendanceRecordView(
        date: row['activity_date']?.toString() ?? '-',
        session: row['session_name']?.toString() ?? 'Teaching Session',
        status: row['status']?.toString() ?? '-',
        time: time.isEmpty ? null : time,
        checkIn: row['check_in_time']?.toString(),
        note: row['notes']?.toString(),
      );
    }).toList();
  }

  Future<StudentLearningInsight> _loadLearningInsight(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        COUNT(*) AS assessment_count,
        AVG(COALESCE(ta.normalized_score, ta.score)) AS average_score,
        MAX(act.activity_date) AS latest_date
      FROM teaching_assessments ta
      LEFT JOIN teaching_activities act ON act.id = ta.teaching_activity_id
      WHERE ta.student_id = ?
        AND COALESCE(ta.normalized_score, ta.score) IS NOT NULL
        AND act.status <> 'cancelled'
      ''',
      [studentId],
    );
    final row = rows.isEmpty ? const <String, Object?>{} : rows.first;
    return StudentLearningInsight(
      assessmentCount: (row['assessment_count'] as num?)?.toInt() ?? 0,
      averageScore: (row['average_score'] as num?)?.toDouble(),
      latestAssessmentDate: row['latest_date']?.toString(),
    );
  }

  Future<List<StudentCompetencyInsight>> _loadCompetencyInsights(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        COALESCE(
          CASE
            WHEN c.code IS NULL OR c.code = '' THEN c.description
            ELSE c.code || ' - ' || c.description
          END,
          ta.assessment_type,
          'Assessment'
        ) AS competency_label,
        AVG(COALESCE(ta.normalized_score, ta.score)) AS average_score,
        COUNT(*) AS record_count
      FROM teaching_assessments ta
      LEFT JOIN competencies c ON c.id = ta.competency_id
      LEFT JOIN teaching_activities act ON act.id = ta.teaching_activity_id
      WHERE ta.student_id = ?
        AND COALESCE(ta.normalized_score, ta.score) IS NOT NULL
        AND act.status <> 'cancelled'
      GROUP BY competency_label
      ORDER BY average_score DESC, competency_label COLLATE NOCASE
      LIMIT 8
      ''',
      [studentId],
    );

    return rows.map((row) {
      return StudentCompetencyInsight(
        label: row['competency_label']?.toString() ?? 'Assessment',
        averageScore: (row['average_score'] as num?)?.toDouble() ?? 0,
        recordCount: (row['record_count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<List<StudentTeacherNoteInsight>> _loadTeacherNoteInsights(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        ssn.note_type,
        ssn.comment,
        ssn.raw_score,
        COALESCE(ssn.created_at, act.activity_date) AS note_date,
        COALESCE(created_teacher.full_name, activity_teacher.full_name) AS teacher_name
      FROM student_session_notes ssn
      LEFT JOIN teaching_activities act ON act.id = ssn.teaching_activity_id
      LEFT JOIN teachers created_teacher ON created_teacher.id = ssn.created_by_teacher_id
      LEFT JOIN teachers activity_teacher ON activity_teacher.id = act.teacher_id
      WHERE ssn.student_id = ?
      ORDER BY COALESCE(act.activity_date, ssn.created_at) DESC, ssn.created_at DESC
      LIMIT 8
      ''',
      [studentId],
    );

    return rows.map((row) {
      return StudentTeacherNoteInsight(
        date: row['note_date']?.toString() ?? '-',
        type: row['note_type']?.toString() ?? '-',
        comment: row['comment']?.toString() ?? '-',
        rawScore: (row['raw_score'] as num?)?.toDouble(),
        teacherName: row['teacher_name']?.toString(),
      );
    }).toList();
  }

  Future<List<StudentNoteTypeCount>> _loadTeacherNoteTypeCounts(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT note_type, COUNT(*) AS count
      FROM student_session_notes
      WHERE student_id = ?
      GROUP BY note_type
      ORDER BY count DESC, note_type COLLATE NOCASE
      ''',
      [studentId],
    );

    return rows.map((row) {
      return StudentNoteTypeCount(
        type: row['note_type']?.toString() ?? '-',
        count: (row['count'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<List<StudentAssistanceHistoryInsight>> _loadAssistanceHistoryInsights(
    DatabaseExecutor db,
    String studentId,
  ) async {
    final rows = await db.rawQuery(
      '''
      SELECT
        COALESCE(program.name, 'Assistance Program') AS program_name,
        COALESCE(period.period_name, period.period_month || '/' || period.period_year) AS period_name,
        ar.status,
        ar.rule_name,
        ar.benefit_type,
        ar.benefit_amount,
        ar.benefit_description,
        ar.approved_at
      FROM assistance_recipients ar
      LEFT JOIN assistance_periods period ON period.id = ar.assistance_period_id
      LEFT JOIN assistance_programs program ON program.id = period.assistance_program_id
      WHERE ar.student_id = ?
      ORDER BY COALESCE(ar.approved_at, ar.created_at) DESC
      LIMIT 8
      ''',
      [studentId],
    );

    return rows.map((row) {
      final amount = (row['benefit_amount'] as num?)?.toDouble();
      final description = row['benefit_description']?.toString();
      final type = row['benefit_type']?.toString();
      final benefit = amount != null
          ? 'Rp ${amount.toStringAsFixed(0)}'
          : _nullIfBlank(description) ?? _nullIfBlank(type);
      return StudentAssistanceHistoryInsight(
        programName: row['program_name']?.toString() ?? 'Assistance Program',
        periodName: row['period_name']?.toString() ?? '-',
        status: row['status']?.toString() ?? '-',
        ruleName: row['rule_name']?.toString(),
        benefit: benefit,
        approvedAt: row['approved_at']?.toString(),
      );
    }).toList();
  }
}

class _StoredExamEvidence {
  const _StoredExamEvidence({
    required this.fileName,
    required this.filePath,
    required this.fileType,
  });

  final String fileName;
  final String filePath;
  final String fileType;
}

class _StudentRelationTarget {
  const _StudentRelationTarget({
    required this.id,
    required this.studentNo,
    required this.fullName,
  });

  final String id;
  final String? studentNo;
  final String? fullName;
}

class _SavedStudentGuardian {
  const _SavedStudentGuardian({
    required this.guardianId,
    required this.relationship,
    required this.isPrimary,
  });

  final String guardianId;
  final String relationship;
  final bool isPrimary;
}
