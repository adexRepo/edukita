import 'package:edukita/core/database/database_provider.dart';
import 'package:edukita/features/schools/data/class_model.dart';
import 'package:edukita/features/schools/data/school_model.dart';

class ClassRepository {
  final DatabaseProvider _dbProvider;

  ClassRepository(this._dbProvider);

  Future<List<SchoolClass>> getAllClasses() async {
    final db = await _dbProvider.database;
    final maps = await db.query('classes', orderBy: 'level, section, name');
    return maps.map((map) => SchoolClass.fromMap(map)).toList();
  }

  Future<List<SchoolClass>> getClassesBySchool(String schoolId) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'classes',
      where: 'school_id = ?',
      whereArgs: [schoolId],
      orderBy: 'level, section, name',
    );
    return maps.map((map) => SchoolClass.fromMap(map)).toList();
  }

  Future<SchoolClass?> getClassById(String id) async {
    final db = await _dbProvider.database;
    final maps = await db.query('classes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) {
      return null;
    }
    return SchoolClass.fromMap(maps.first);
  }

  Future<SchoolClass?> getClassByName(String name) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'classes',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isEmpty) {
      return null;
    }
    return SchoolClass.fromMap(maps.first);
  }

  Future<int> insertClass(SchoolClass schoolClass) async {
    final db = await _dbProvider.database;
    await _ensureClassIsUnique(schoolClass);
    return db.insert('classes', await _classMapForDb(schoolClass));
  }

  Future<int> updateClass(SchoolClass schoolClass) async {
    final db = await _dbProvider.database;
    await _ensureClassIsUnique(schoolClass, excludingId: schoolClass.id);
    return db.update(
      'classes',
      await _classMapForDb(schoolClass),
      where: 'id = ?',
      whereArgs: [schoolClass.id],
    );
  }

  Future<int> deleteClass(String id) async {
    final db = await _dbProvider.database;
    return db.delete('classes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SchoolClass>> getClassesByLevel(int level) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'classes',
      where: 'level = ?',
      whereArgs: [level],
    );
    return maps.map((map) => SchoolClass.fromMap(map)).toList();
  }

  Future<List<SchoolClass>> getClassesByYear(String year) async {
    final db = await _dbProvider.database;
    final maps = await db.query(
      'classes',
      where: 'year = ?',
      whereArgs: [year],
    );
    return maps.map((map) => SchoolClass.fromMap(map)).toList();
  }

  Future<Map<String, Object?>> _classMapForDb(SchoolClass schoolClass) async {
    final db = await _dbProvider.database;
    final columns = await db.rawQuery('PRAGMA table_info(classes)');
    final names = columns.map((row) => row['name']).toSet();
    final map = schoolClass.toMap();

    if (names.contains('class_name')) {
      map['class_name'] = schoolClass.schoolId == null
          ? schoolClass.name
          : '${schoolClass.schoolId}_${schoolClass.name}';
    }
    map.removeWhere((key, value) => !names.contains(key));
    return map;
  }

  Future<void> _ensureClassIsUnique(
    SchoolClass schoolClass, {
    String? excludingId,
  }) async {
    final db = await _dbProvider.database;
    SchoolType schoolType;
    if (schoolClass.schoolId == null) {
      schoolType = SchoolType.fromLevel(schoolClass.level);
    } else {
      final schoolRows = await db.query(
        'schools',
        columns: ['type'],
        where: 'id = ?',
        whereArgs: [schoolClass.schoolId],
        limit: 1,
      );
      final rawType = schoolRows.isEmpty
          ? null
          : schoolRows.first['type']?.toString().toLowerCase();
      schoolType = SchoolType.values.firstWhere(
        (type) => type.name == rawType,
        orElse: () => SchoolType.fromLevel(schoolClass.level),
      );
    }

    final normalizedSection =
        SchoolClass.normalizeSection(schoolClass.section) ?? '';
    final identityCondition = schoolType.usesAutoClassName
        ? '''
        level = ?
        AND COALESCE(UPPER(TRIM(section)), '') = ?
        '''
        : "UPPER(TRIM(name)) = ?";
    final rows = await db.rawQuery(
      '''
      SELECT id
      FROM classes
      WHERE school_id IS ?
        AND year = ?
        AND $identityCondition
        ${excludingId == null ? '' : 'AND id <> ?'}
      LIMIT 1
      ''',
      [
        schoolClass.schoolId,
        schoolClass.year,
        if (schoolType.usesAutoClassName) ...[
          schoolClass.level,
          normalizedSection,
        ] else
          schoolClass.name.trim().toUpperCase(),
        ?excludingId,
      ],
    );
    if (rows.isNotEmpty) {
      throw StateError(
        'A class with the same school, level, section, and year already exists.',
      );
    }
  }
}
