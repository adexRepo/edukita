import 'package:edukita/core/database/base_repository.dart';
import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/core/helper/pageable.dart';
import 'package:edukita/features/management/data/guardian_model.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';
import 'package:edukita/features/students/data/student.dart';
import 'package:edukita/features/students/data/student_advanced_form_data.dart';
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
    StudentAdvancedFormData advanced = const StudentAdvancedFormData(),
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
      await _saveAdvancedData(txn, student, guardians, advanced);
    });
  }

  Future<void> updateStudentWithSchool(
    Student student,
    String schoolId, [
    List<StudentGuardianFormData> guardians = const [],
    StudentAdvancedFormData advanced = const StudentAdvancedFormData(),
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
      await _saveAdvancedData(txn, student, guardians, advanced);
    });
  }

  Future<StudentAdvancedFormData> loadAdvancedFormData(String studentId) async {
    final db = await _dbProvider.database;
    final health = await _loadHealth(db, studentId);
    final relations = await loadRelations(studentId);
    final activities = await loadActivities(studentId);
    final goals = await _loadGoalInputs(db, studentId);

    return StudentAdvancedFormData(
      health: health,
      relations: relations,
      activities: activities,
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

  Future<void> _saveAdvancedData(
    Transaction txn,
    Student student,
    List<StudentGuardianFormData> guardians,
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
    }
    await _saveActivities(txn, student.id, advanced.activities);
    await _saveGoals(txn, student.id, advanced);
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
