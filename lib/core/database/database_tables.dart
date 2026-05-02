import 'package:sqflite_common/sqlite_api.dart';

class DatabaseTables {
  DatabaseTables._();

  static Future<void> createAll(Database db) async {
    await users(db);

    await teachers(db);
    await guardians(db);
    await schools(db);
    await classes(db);
    await students(db);

    await studentGuardians(db);
    await studentSchools(db);
    await studentClasses(db);
    await studentClassHistory(db);
    await studentStories(db);

    await subjects(db);
    await units(db);
    await competencies(db);
    await strategies(db);
    await schedules(db);

    await assessments(db);
    await studentAssessments(db);
    await studentScores(db);
    await gradingScale(db);

    await attendanceSessions(db);
    await studentAttendance(db);
    await studentActivity(db);
    await teachingNotes(db);

    await studentHealth(db);
    await studentBehavior(db);
    await studentSocialNotes(db);
    await activities(db);
    await studentActivities(db);
    await extraActivities(db);
    await studentRisks(db);
    await studentInterventions(db);
    await studentFinance(db);
    await studentDocuments(db);
    await studentGoals(db);
    await studentLearningProfiles(db);
    await studentWellbeing(db);
    await studentWellBeing(db);

    await syllabus(db);
    await reports(db);
    await indexes(db);
  }

  static Future<void> users(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id TEXT PRIMARY KEY NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nick_name TEXT NOT NULL,
        full_name TEXT NOT NULL
      )
    ''');
  }

  static Future<void> classes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS classes(
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        school_id TEXT,
        level INTEGER NOT NULL,
        section TEXT,
        year TEXT NOT NULL,
        FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> teachers(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teachers(
        id TEXT PRIMARY KEY NOT NULL,
        nick_name TEXT,
        full_name TEXT NOT NULL,
        role TEXT,
        last_education_type TEXT,
        gender TEXT,
        email TEXT,
        mobile_no TEXT
      )
    ''');
  }

  static Future<void> guardians(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS guardians(
        id TEXT PRIMARY KEY NOT NULL,
        full_name TEXT NOT NULL,
        mobile_no TEXT,
        email TEXT,
        occupation TEXT,
        address TEXT
      )
    ''');
  }

  static Future<void> schools(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schools(
        id TEXT PRIMARY KEY NOT NULL,
        type TEXT,
        name TEXT,
        address TEXT
      )
    ''');
  }

  static Future<void> students(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS students(
        id TEXT PRIMARY KEY NOT NULL,
        student_no TEXT NOT NULL UNIQUE,
        class_id TEXT NOT NULL,
        nick_name TEXT,
        full_name TEXT NOT NULL,
        join_at TEXT NOT NULL,
        exit_date TEXT,
        nis TEXT,
        birth_date TEXT,
        gender TEXT,
        mobile_no TEXT,
        email_addr TEXT,
        shoes_size INTEGER,
        uniform_size INTEGER,
        pants_size INTEGER,
        height REAL,
        weight REAL,
        photo_path TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(class_id) REFERENCES classes(id)
      )
    ''');
  }

  static Future<void> studentGuardians(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_guardians(
        student_id TEXT NOT NULL,
        guardian_id TEXT NOT NULL,
        relationship TEXT NOT NULL,
        is_primary INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (student_id, guardian_id),
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(guardian_id) REFERENCES guardians(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentSchools(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_schools(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        school_id TEXT NOT NULL,
        status INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentClasses(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_classes(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        start_date TEXT,
        end_date TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(class_id) REFERENCES classes(id)
      )
    ''');
  }

  static Future<void> studentClassHistory(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_class_history(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        from_class_id TEXT,
        to_class_id TEXT,
        changed_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(from_class_id) REFERENCES classes(id),
        FOREIGN KEY(to_class_id) REFERENCES classes(id)
      )
    ''');
  }

  static Future<void> studentStories(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_stories(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        story TEXT NOT NULL,
        created_by TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(created_by) REFERENCES users(id)
      )
    ''');
  }

  static Future<void> subjects(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subjects(
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL
      )
    ''');
  }

  static Future<void> units(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS units(
        id TEXT PRIMARY KEY NOT NULL,
        subject_id TEXT NOT NULL,
        name TEXT NOT NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> competencies(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS competencies(
        id TEXT PRIMARY KEY NOT NULL,
        unit_id TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY(unit_id) REFERENCES units(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> strategies(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS strategies(
        id TEXT PRIMARY KEY,
        code TEXT,
        name TEXT,
        rule TEXT
      )
    ''');
  }

  static Future<void> schedules(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        class_id TEXT,
        teacher_id TEXT,
        unit_id TEXT,
        strategies_id TEXT,
        start_at TEXT,
        end_at TEXT,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY(class_id) REFERENCES classes(id),
        FOREIGN KEY(teacher_id) REFERENCES teachers(id),
        FOREIGN KEY(unit_id) REFERENCES units(id),
        FOREIGN KEY(strategies_id) REFERENCES strategies(id)
      )
    ''');
  }

  static Future<void> assessments(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assessments(
        id TEXT PRIMARY KEY NOT NULL,
        unit_id TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT,
        max_score INTEGER,
        FOREIGN KEY(unit_id) REFERENCES units(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentAssessments(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_assessments(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        assessment_id TEXT NOT NULL,
        score REAL,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(assessment_id) REFERENCES assessments(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentScores(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_scores(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        subject_id TEXT,
        assessment_id TEXT,
        score REAL NOT NULL,
        max_score REAL,
        score_type TEXT,
        recorded_at TEXT,
        notes TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(subject_id) REFERENCES subjects(id),
        FOREIGN KEY(assessment_id) REFERENCES assessments(id)
      )
    ''');
  }

  static Future<void> gradingScale(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS grading_scale(
        id TEXT PRIMARY KEY NOT NULL,
        min_percent INTEGER NOT NULL,
        max_percent INTEGER NOT NULL,
        grade TEXT NOT NULL
      )
    ''');
  }

  static Future<void> attendanceSessions(Database db) async {
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
  }

  static Future<void> studentAttendance(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_attendance(
        id TEXT PRIMARY KEY NOT NULL,
        attendance_session_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        status TEXT,
        check_in_time TEXT,
        note TEXT,
        FOREIGN KEY(attendance_session_id) REFERENCES attendance_sessions(id) ON DELETE CASCADE,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentActivity(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_activity(
        student_id TEXT NOT NULL,
        session_id TEXT NOT NULL,
        questions_asked INTEGER,
        answers_given INTEGER,
        PRIMARY KEY (student_id, session_id),
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(session_id) REFERENCES attendance_sessions(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> teachingNotes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teaching_notes(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        teacher_id TEXT,
        schedule_id TEXT,
        attendance_session_id TEXT,
        note TEXT NOT NULL,
        created_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(teacher_id) REFERENCES teachers(id),
        FOREIGN KEY(schedule_id) REFERENCES schedules(id),
        FOREIGN KEY(attendance_session_id) REFERENCES attendance_sessions(id)
      )
    ''');
  }

  static Future<void> studentHealth(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_health(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        blood_type TEXT,
        allergies TEXT,
        medical_notes TEXT,
        disabilities TEXT,
        updated_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentBehavior(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_behavior(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        type TEXT,
        description TEXT,
        recorded_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentSocialNotes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_social_notes(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        note TEXT,
        recorded_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> activities(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS activities(
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        type TEXT,
        description TEXT
      )
    ''');
  }

  static Future<void> studentActivities(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_activities(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        activity_id TEXT NOT NULL,
        role TEXT,
        achievement TEXT,
        start_date TEXT,
        end_date TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(activity_id) REFERENCES activities(id)
      )
    ''');
  }

  static Future<void> extraActivities(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS extra_activities(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT,
        activity_id TEXT,
        role TEXT,
        achievement TEXT,
        date TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentRisks(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_risks(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT,
        risk_type TEXT,
        level TEXT,
        detected_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentInterventions(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_interventions(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT,
        action TEXT,
        notes TEXT,
        start_date TEXT,
        end_date TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentFinance(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_finance(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT,
        fee_amount REAL,
        scholarship INTEGER NOT NULL DEFAULT 0,
        status TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentDocuments(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_documents(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT,
        document_type TEXT,
        file_url TEXT,
        uploaded_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentGoals(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_goals(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT,
        goal TEXT,
        category TEXT,
        created_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentLearningProfiles(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_learning_profiles(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        learning_style TEXT,
        pace TEXT,
        attention_level TEXT,
        motivation_level TEXT,
        notes TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentWellbeing(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_wellbeing(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        stress_level TEXT,
        confidence_level TEXT,
        counseling_notes TEXT,
        notes TEXT,
        recorded_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentWellBeing(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_well_being(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        stress_level TEXT,
        confidence_level TEXT,
        notes TEXT,
        recorded_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> syllabus(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS syllabus(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> reports(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reports(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> indexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_students_class_id ON students(class_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_classes_student_id ON student_classes(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_schools_student_id ON student_schools(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_scores_student_id ON student_scores(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_assessments_student_id ON student_assessments(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_attendance_student_id ON student_attendance(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_teaching_notes_student_id ON teaching_notes(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_activities_student_id ON student_activities(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_behavior_student_id ON student_behavior(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_risks_student_id ON student_risks(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_interventions_student_id ON student_interventions(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_wellbeing_student_id ON student_wellbeing(student_id)',
    );
  }
}
