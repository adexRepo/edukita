import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'dart:io' as io;

class DatabaseProvider {
  DatabaseProvider._internal();

  static final DatabaseProvider instance = DatabaseProvider._internal();

  Database? _database;
  static bool _factoryInitialized = false;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      if (kIsWeb) {
        if (!_factoryInitialized) {
          databaseFactory = databaseFactoryFfiWeb;
          _factoryInitialized = true;
        }
        // For web, use a persistent path with IndexedDB backend
        final path = 'edukita.db';
        debugPrint('Database path (web): $path');
        final db = await openDatabase(
          path,
          version: 6,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        );
        await _ensureAdminUser(db);
        return db;
      } else {
        if (!_factoryInitialized) {
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          _factoryInitialized = true;
        }

        // Get database path from .env file or use default
        String dbPath = dotenv.env['DB_PATH'] ?? '../../../../../data';

        // Use absolute path
        final directory = io.Directory(join(io.Directory.current.path, dbPath));
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final path = join(directory.path, 'edukita.db');
        debugPrint('Database path (desktop): $path');

        final db = await openDatabase(
          path,
          version: 5,
          onConfigure: _onConfigure,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        );
        await _ensureAdminUser(db);
        return db;
      }
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nick_name TEXT NOT NULL,
        full_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE classes(
        id TEXT PRIMARY KEY NOT NULL,
        class_name TEXT NOT NULL UNIQUE,
        level INTEGER NOT NULL,
        section TEXT,
        year TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE students(
        id TEXT PRIMARY KEY NOT NULL,
        student_no TEXT NOT NULL UNIQUE,
        class_id TEXT NOT NULL,
        nick_name TEXT,
        full_name TEXT NOT NULL,
        join_at TEXT NOT NULL,
        nis TEXT,
        birth_date TEXT,
        gender TEXT,
        mobile_no TEXT,
        email_addr TEXT,
        shoe_size INTEGER,
        uniform_size INTEGER,
        pants_size INTEGER,
        height REAL,
        weight REAL,
        photo_path TEXT,
        FOREIGN KEY(class_id) REFERENCES classes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE guardians(
        id TEXT PRIMARY KEY NOT NULL,
        full_name TEXT NOT NULL,
        mobile_no TEXT,
        occupation TEXT,
        address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE student_guardians(
        student_id TEXT NOT NULL,
        guardian_id TEXT NOT NULL,
        relationship TEXT,
        PRIMARY KEY (student_id, guardian_id),
        FOREIGN KEY(student_id) REFERENCES students(id),
        FOREIGN KEY(guardian_id) REFERENCES guardians(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE schools(
        id TEXT PRIMARY KEY NOT NULL,
        type TEXT,
        name TEXT,
        address TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE student_schools(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        school_id TEXT NOT NULL,
        FOREIGN KEY(student_id) REFERENCES students(id),
        FOREIGN KEY(school_id) REFERENCES schools(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE student_class_history(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        from_class_id TEXT,
        to_class_id TEXT,
        changed_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id),
        FOREIGN KEY(from_class_id) REFERENCES classes(id),
        FOREIGN KEY(to_class_id) REFERENCES classes(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE students_stories(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        story TEXT,
        create_by TEXT,
        create_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id),
        FOREIGN KEY(create_by) REFERENCES users(username)
      )
    ''');

    await db.execute('''
      CREATE TABLE teachers(
        id TEXT PRIMARY KEY NOT NULL,
        nick_name TEXT,
        full_name TEXT,
        last_education_type TEXT,
        gender TEXT,
        email TEXT,
        mobile_no TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE subjects(
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE units(
        id TEXT PRIMARY KEY NOT NULL,
        subject_id TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE competencies(
        id TEXT PRIMARY KEY NOT NULL,
        unit_id TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY(unit_id) REFERENCES units(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE strategies(
        id TEXT PRIMARY KEY NOT NULL,
        code TEXT,
        name TEXT,
        rule TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules(
        id TEXT PRIMARY KEY NOT NULL,
        class_id TEXT,
        teacher_id TEXT,
        unit_id TEXT,
        strategies_id TEXT,
        start_at TEXT,
        end_at TEXT,
        title TEXT,
        date TEXT,
        description TEXT,
        FOREIGN KEY(class_id) REFERENCES classes(id),
        FOREIGN KEY(teacher_id) REFERENCES teachers(id),
        FOREIGN KEY(unit_id) REFERENCES units(id),
        FOREIGN KEY(strategies_id) REFERENCES strategies(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE assessments(
        id TEXT PRIMARY KEY NOT NULL,
        unit_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT,
        max_score INTEGER,
        FOREIGN KEY(unit_id) REFERENCES units(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE student_assessments(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        assessment_id TEXT NOT NULL,
        score REAL,
        FOREIGN KEY(student_id) REFERENCES students(id),
        FOREIGN KEY(assessment_id) REFERENCES assessments(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE grading_scale(
        id TEXT PRIMARY KEY NOT NULL,
        min_percent INTEGER,
        max_percent INTEGER,
        grade TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance_sessions(
        id TEXT PRIMARY KEY NOT NULL,
        schedule_id TEXT NOT NULL,
        date TEXT,
        start_time TEXT,
        end_time TEXT,
        FOREIGN KEY(schedule_id) REFERENCES schedules(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE student_attendance(
        id TEXT PRIMARY KEY NOT NULL,
        attendance_session_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        status TEXT,
        check_in_time TEXT,
        note TEXT,
        FOREIGN KEY(attendance_session_id) REFERENCES attendance_sessions(id),
        FOREIGN KEY(student_id) REFERENCES students(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE student_activity(
        student_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        questions_asked INTEGER,
        answers_given INTEGER,
        PRIMARY KEY (student_id, session_id),
        FOREIGN KEY(student_id) REFERENCES students(id),
        FOREIGN KEY(session_id) REFERENCES attendance_sessions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE syllabus(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.insert('users', {
      'id': const Uuid().v4(),
      'username': 'admin',
      'password': 'admin',
      'nick_name': 'Admin',
      'full_name': 'Administrator',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final existing = await db.rawQuery("PRAGMA table_info(users)");
      final existingColumns = existing
          .map((row) => row['name'] as String)
          .toList(growable: false);
      if (!existingColumns.contains('username')) {
        await db.execute('''
          CREATE TABLE users_new(
            id TEXT PRIMARY KEY NOT NULL,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL,
            nick_name TEXT NOT NULL,
            full_name TEXT NOT NULL
          )
        ''');

        await db.execute('''
          INSERT INTO users_new(id, username, password, nick_name, full_name)
          SELECT CAST(id AS TEXT), name || '_' || CAST(id AS TEXT), '', name, name FROM users
        ''');

        await db.execute('DROP TABLE users');
        await db.execute('ALTER TABLE users_new RENAME TO users');
      }

      await _ensureAdminUser(db);
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS classes(
          id TEXT PRIMARY KEY NOT NULL,
          class_name TEXT NOT NULL UNIQUE,
          level INTEGER NOT NULL,
          section TEXT,
          year TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 4) {
      final studentColumns = await db.rawQuery("PRAGMA table_info(students)");
      final studentColumnNames = studentColumns
          .map((row) => row['name'] as String)
          .toList(growable: false);

      if (studentColumnNames.isEmpty) {
        await db.execute('''
          CREATE TABLE students(
            id TEXT PRIMARY KEY NOT NULL,
            student_no TEXT NOT NULL UNIQUE,
            class_id TEXT NOT NULL,
            nick_name TEXT,
            full_name TEXT NOT NULL,
            join_at TEXT NOT NULL,
            nis TEXT,
            birth_date TEXT,
            gender TEXT,
            mobile_no TEXT,
            email_addr TEXT,
            shoe_size INTEGER,
            uniform_size INTEGER,
            pants_size INTEGER,
            height REAL,
            weight REAL,
            photo_path TEXT,
            FOREIGN KEY(class_id) REFERENCES classes(id)
          )
        ''');
      } else if (!studentColumnNames.contains('student_no')) {
        final defaultClassId = const Uuid().v4();
        await db.execute('''
          INSERT OR IGNORE INTO classes(id, class_name, level, section, year)
          VALUES('$defaultClassId', 'Unassigned', 0, 'U', '0000')
        ''');

        await db.execute('''
          CREATE TABLE students_new(
            id TEXT PRIMARY KEY NOT NULL,
            student_no TEXT NOT NULL UNIQUE,
            class_id TEXT NOT NULL,
            nick_name TEXT,
            full_name TEXT NOT NULL,
            join_at TEXT NOT NULL,
            nis TEXT,
            birth_date TEXT,
            gender TEXT,
            mobile_no TEXT,
            email_addr TEXT,
            shoe_size INTEGER,
            uniform_size INTEGER,
            pants_size INTEGER,
            height REAL,
            weight REAL,
            photo_path TEXT,
            FOREIGN KEY(class_id) REFERENCES classes(id)
          )
        ''');

        final oldStudents = await db.query('students');
        final batch = db.batch();
        for (final row in oldStudents) {
          final fullName = row['name'] as String? ?? 'Unknown';
          final enrolledAt =
              row['enrolledAt'] as String? ?? DateTime.now().toIso8601String();
          batch.insert('students_new', {
            'id': const Uuid().v4(),
            'student_no': 'JKTM${DateTime.now().millisecondsSinceEpoch}',
            'class_id': defaultClassId,
            'nick_name': '',
            'full_name': fullName,
            'join_at': enrolledAt,
            'nis': null,
            'birth_date': null,
            'gender': null,
            'mobile_no': null,
            'email_addr': null,
            'shoe_size': null,
            'uniform_size': null,
            'pants_size': null,
            'height': null,
            'weight': null,
            'photo_path': null,
          });
        }
        await batch.commit(noResult: true);
        await db.execute('DROP TABLE students');
        await db.execute('ALTER TABLE students_new RENAME TO students');
      }

      await db.execute('''
        CREATE TABLE IF NOT EXISTS guardians(
          id TEXT PRIMARY KEY NOT NULL,
          full_name TEXT NOT NULL,
          mobile_no TEXT,
          occupation TEXT,
          address TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS student_guardians(
          student_id TEXT NOT NULL,
          guardian_id TEXT NOT NULL,
          relationship TEXT,
          PRIMARY KEY (student_id, guardian_id),
          FOREIGN KEY(student_id) REFERENCES students(id),
          FOREIGN KEY(guardian_id) REFERENCES guardians(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS schools(
          id TEXT PRIMARY KEY NOT NULL,
          type TEXT,
          name TEXT,
          address TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS student_schools(
          id TEXT PRIMARY KEY NOT NULL,
          student_id TEXT NOT NULL,
          school_id TEXT NOT NULL,
          FOREIGN KEY(student_id) REFERENCES students(id),
          FOREIGN KEY(school_id) REFERENCES schools(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS student_class_history(
          id TEXT PRIMARY KEY NOT NULL,
          student_id TEXT NOT NULL,
          from_class_id TEXT,
          to_class_id TEXT,
          changed_at TEXT,
          FOREIGN KEY(student_id) REFERENCES students(id),
          FOREIGN KEY(from_class_id) REFERENCES classes(id),
          FOREIGN KEY(to_class_id) REFERENCES classes(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS students_stories(
          id TEXT PRIMARY KEY NOT NULL,
          student_id TEXT NOT NULL,
          story TEXT,
          create_by TEXT,
          create_at TEXT,
          FOREIGN KEY(student_id) REFERENCES students(id),
          FOREIGN KEY(create_by) REFERENCES users(username)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS teachers(
          id TEXT PRIMARY KEY NOT NULL,
          nick_name TEXT,
          full_name TEXT,
          last_education_type TEXT,
          gender TEXT,
          email TEXT,
          mobile_no TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS subjects(
          id TEXT PRIMARY KEY NOT NULL,
          name TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS units(
          id TEXT PRIMARY KEY NOT NULL,
          subject_id TEXT NOT NULL,
          name TEXT NOT NULL,
          FOREIGN KEY(subject_id) REFERENCES subjects(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS competencies(
          id TEXT PRIMARY KEY NOT NULL,
          unit_id TEXT NOT NULL,
          description TEXT,
          FOREIGN KEY(unit_id) REFERENCES units(id)
        )
      ''');

      final strategiesInfo = await db.rawQuery("PRAGMA table_info(strategies)");
      final strategyColumns = strategiesInfo
          .map((row) => row['name'] as String)
          .toList(growable: false);
      if (!strategyColumns.contains('code')) {
        await db.execute('ALTER TABLE strategies ADD COLUMN code TEXT');
      }
      if (!strategyColumns.contains('rule')) {
        await db.execute('ALTER TABLE strategies ADD COLUMN rule TEXT');
      }

      final scheduleInfo = await db.rawQuery("PRAGMA table_info(schedules)");
      final scheduleColumns = scheduleInfo
          .map((row) => row['name'] as String)
          .toList(growable: false);
      if (!scheduleColumns.contains('class_id')) {
        await db.execute('ALTER TABLE schedules ADD COLUMN class_id TEXT');
      }
      if (!scheduleColumns.contains('teacher_id')) {
        await db.execute('ALTER TABLE schedules ADD COLUMN teacher_id TEXT');
      }
      if (!scheduleColumns.contains('unit_id')) {
        await db.execute('ALTER TABLE schedules ADD COLUMN unit_id TEXT');
      }
      if (!scheduleColumns.contains('strategies_id')) {
        await db.execute('ALTER TABLE schedules ADD COLUMN strategies_id TEXT');
      }
      if (!scheduleColumns.contains('start_at')) {
        await db.execute('ALTER TABLE schedules ADD COLUMN start_at TEXT');
      }
      if (!scheduleColumns.contains('end_at')) {
        await db.execute('ALTER TABLE schedules ADD COLUMN end_at TEXT');
      }

      await db.execute('''
        CREATE TABLE IF NOT EXISTS assessments(
          id TEXT PRIMARY KEY NOT NULL,
          unit_id TEXT NOT NULL,
          name TEXT NOT NULL,
          type TEXT,
          max_score INTEGER,
          FOREIGN KEY(unit_id) REFERENCES units(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS student_assessments(
          id TEXT PRIMARY KEY NOT NULL,
          student_id TEXT NOT NULL,
          assessment_id TEXT NOT NULL,
          score REAL,
          FOREIGN KEY(student_id) REFERENCES students(id),
          FOREIGN KEY(assessment_id) REFERENCES assessments(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS grading_scale(
          id TEXT PRIMARY KEY NOT NULL,
          min_percent INTEGER,
          max_percent INTEGER,
          grade TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS attendance_sessions(
          id TEXT PRIMARY KEY NOT NULL,
          schedule_id TEXT NOT NULL,
          date TEXT,
          start_time TEXT,
          end_time TEXT,
          FOREIGN KEY(schedule_id) REFERENCES schedules(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS student_attendance(
          id TEXT PRIMARY KEY NOT NULL,
          attendance_session_id TEXT NOT NULL,
          student_id TEXT NOT NULL,
          status TEXT,
          check_in_time TEXT,
          note TEXT,
          FOREIGN KEY(attendance_session_id) REFERENCES attendance_sessions(id),
          FOREIGN KEY(student_id) REFERENCES students(id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS student_activity(
          student_id TEXT NOT NULL,
          session_id TEXT NOT NULL,
          questions_asked INTEGER,
          answers_given INTEGER,
          PRIMARY KEY (student_id, session_id),
          FOREIGN KEY(student_id) REFERENCES students(id),
          FOREIGN KEY(session_id) REFERENCES attendance_sessions(id)
        )
      ''');
    }

    if (oldVersion < 6) {
      // Fix students_stories create_by FK from users.username to users.id
      final storiesTableInfo = await db.rawQuery(
        "PRAGMA table_info(students_stories)",
      );
      final storiesColumns = storiesTableInfo
          .map((row) => row['name'] as String)
          .toList(growable: false);

      if (storiesColumns.isNotEmpty) {
        // Recreate students_stories table with fixed FK
        await db.execute('DROP TABLE IF EXISTS students_stories_new');
        await db.execute('''
          CREATE TABLE students_stories_new(
            id TEXT PRIMARY KEY NOT NULL,
            student_id TEXT NOT NULL,
            story TEXT,
            create_by TEXT,
            create_at TEXT,
            FOREIGN KEY(student_id) REFERENCES students(id),
            FOREIGN KEY(create_by) REFERENCES users(id)
          )
        ''');

        // Copy existing data
        await db.execute('''
          INSERT INTO students_stories_new(id, student_id, story, create_by, create_at)
          SELECT id, student_id, story, create_by, create_at FROM students_stories
        ''');

        await db.execute('DROP TABLE students_stories');
        await db.execute(
          'ALTER TABLE students_stories_new RENAME TO students_stories',
        );
      }
    }
  }

  Future<void> _ensureAdminUser(Database db) async {
    final result = await db.query(
      'users',
      columns: ['COUNT(*) as count'],
      where: 'username = ?',
      whereArgs: ['admin'],
    );
    final adminCount = Sqflite.firstIntValue(result) ?? 0;
    if (adminCount == 0) {
      await db.insert('users', {
        'id': const Uuid().v4(),
        'username': 'admin',
        'password': 'admin',
        'nick_name': 'Admin',
        'full_name': 'Administrator',
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    final db = await database;
    return db.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, Object?>>> queryAll(String table) async {
    final db = await database;
    return db.query(table, orderBy: 'id DESC');
  }

  Future<Map<String, Object?>?> getUserByUsernameAndPassword(
    String username,
    String password,
  ) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  Future<int> count(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
