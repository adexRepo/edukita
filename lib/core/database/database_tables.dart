import 'package:sqflite/sqflite.dart';

class DatabaseTables {
  DatabaseTables._();

  /// 🔥 ENTRY POINT
  static Future<void> createAll(Database db) async {
    await _users(db);
    await _classes(db);
    await _students(db);
    await _guardians(db);
    await _studentGuardians(db);
    await _schools(db);
    await _studentSchools(db);
    await _studentClassHistory(db);
    await _studentStories(db);
    await _teachers(db);
    await _subjects(db);
    await _units(db);
    await _competencies(db);
    await _strategies(db);
    await _schedules(db);
    await _assessments(db);
    await _studentAssessments(db);
    await _gradingScale(db);
    await _attendanceSessions(db);
    await _studentAttendance(db);
    await _studentActivity(db);
    await _miscTables(db);
  }

  // ==============================
  // 🔐 AUTH / USERS
  // ==============================

  static Future<void> _users(Database db) async {
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nick_name TEXT NOT NULL,
        full_name TEXT NOT NULL
      )
    ''');
  }

  // ==============================
  // 🏫 CORE MASTER DATA
  // ==============================

  static Future<void> _classes(Database db) async {
    await db.execute('''
      CREATE TABLE classes(
        id TEXT PRIMARY KEY NOT NULL,
        class_name TEXT NOT NULL UNIQUE,
        level INTEGER NOT NULL,
        section TEXT,
        year TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _students(Database db) async {
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
        is_active INTEGER,
        FOREIGN KEY(class_id) REFERENCES classes(id)
      )
    ''');
  }

  // ==============================
  // 👨‍👩‍👧 RELATIONS
  // ==============================

  static Future<void> _guardians(Database db) async {
    await db.execute('''
      CREATE TABLE guardians(
        id TEXT PRIMARY KEY NOT NULL,
        full_name TEXT NOT NULL,
        mobile_no TEXT,
        occupation TEXT,
        address TEXT
      )
    ''');
  }

  static Future<void> _studentGuardians(Database db) async {
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
  }

  static Future<void> _schools(Database db) async {
    await db.execute('''
      CREATE TABLE schools(
        id TEXT PRIMARY KEY NOT NULL,
        type TEXT,
        name TEXT,
        address TEXT
      )
    ''');
  }

  static Future<void> _studentSchools(Database db) async {
    await db.execute('''
      CREATE TABLE student_schools(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        school_id TEXT NOT NULL,
        FOREIGN KEY(student_id) REFERENCES students(id),
        FOREIGN KEY(school_id) REFERENCES schools(id)
      )
    ''');
  }

  static Future<void> _studentClassHistory(Database db) async {
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
  }

  static Future<void> _studentStories(Database db) async {
    await db.execute('''
      CREATE TABLE students_stories(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        story TEXT,
        create_by TEXT,
        create_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id),
        FOREIGN KEY(create_by) REFERENCES users(id)
      )
    ''');
  }

  // ==============================
  // 👩‍🏫 TEACHING
  // ==============================

  static Future<void> _teachers(Database db) async {
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
  }

  static Future<void> _subjects(Database db) async {
    await db.execute('''
      CREATE TABLE subjects(
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _units(Database db) async {
    await db.execute('''
      CREATE TABLE units(
        id TEXT PRIMARY KEY NOT NULL,
        subject_id TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id)
      )
    ''');
  }

  static Future<void> _competencies(Database db) async {
    await db.execute('''
      CREATE TABLE competencies(
        id TEXT PRIMARY KEY NOT NULL,
        unit_id TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY(unit_id) REFERENCES units(id)
      )
    ''');
  }

  static Future<void> _strategies(Database db) async {
    await db.execute('''
      CREATE TABLE strategies(
        id TEXT PRIMARY KEY NOT NULL,
        code TEXT,
        name TEXT,
        rule TEXT
      )
    ''');
  }

  static Future<void> _schedules(Database db) async {
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
  }

  // ==============================
  // 📊 ASSESSMENT
  // ==============================

  static Future<void> _assessments(Database db) async {
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
  }

  static Future<void> _studentAssessments(Database db) async {
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
  }

  static Future<void> _gradingScale(Database db) async {
    await db.execute('''
      CREATE TABLE grading_scale(
        id TEXT PRIMARY KEY NOT NULL,
        min_percent INTEGER,
        max_percent INTEGER,
        grade TEXT
      )
    ''');
  }

  // ==============================
  // 📅 ATTENDANCE
  // ==============================

  static Future<void> _attendanceSessions(Database db) async {
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
  }

  static Future<void> _studentAttendance(Database db) async {
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
  }

  static Future<void> _studentActivity(Database db) async {
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
  }

  // ==============================
  // 🧾 MISC
  // ==============================

  static Future<void> _miscTables(Database db) async {
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
  }
}
