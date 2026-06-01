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
    await studentRelations(db);
    await studentSchools(db);
    await studentClasses(db);
    await studentClassHistory(db);
    await studentStories(db);

    await curriculums(db);
    await syllabus(db);
    await subjects(db);
    await units(db);
    await competencies(db);
    await strategies(db);
    await schedules(db);
    await scheduleEvents(db);

    await assessments(db);
    await studentAssessments(db);
    await assessmentEvidences(db);
    await studentExamScores(db);
    await studentExamScoreGroups(db);
    await studentExamScoreItems(db);
    await studentScores(db);
    await gradingScale(db);

    await attendanceSessions(db);
    await studentAttendance(db);
    await studentActivity(db);
    await teachingNotes(db);
    await teachingActivities(db);
    await teachingAttendances(db);
    await teachingAssessments(db);
    await studentSessionNotes(db);

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

    await reportDefinitions(db);
    await reports(db);
    await assistancePrograms(db);
    await assistanceProgramBenefits(db);
    await assistanceProgramBenefitItems(db);
    await assistanceRules(db);
    await assistancePeriods(db);
    await assistancePeriodRules(db);
    await studentAssistanceRules(db);
    await studentAssistanceRuleCandidates(db);
    await studentAssistanceAssessments(db);
    await assistanceRuleTargets(db);
    await assistanceApprovalDocuments(db);
    await assistanceRecipients(db);
    await indexes(db);
  }

  static Future<void> users(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id TEXT PRIMARY KEY NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nick_name TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'user'
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

  static Future<void> studentRelations(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_relations(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        related_student_id TEXT NOT NULL,
        relation_type TEXT NOT NULL,
        age_position TEXT NOT NULL,
        created_at TEXT,
        UNIQUE(student_id, related_student_id),
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(related_student_id) REFERENCES students(id) ON DELETE CASCADE
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
        syllabus_id TEXT,
        name TEXT NOT NULL,
        description TEXT,
        status TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(syllabus_id) REFERENCES syllabus(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> curriculums(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS curriculums(
        id TEXT PRIMARY KEY NOT NULL,
        name TEXT NOT NULL,
        version TEXT,
        description TEXT,
        effective_year TEXT,
        status TEXT
      )
    ''');
  }

  static Future<void> units(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS units(
        id TEXT PRIMARY KEY NOT NULL,
        subject_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        sequence_no INTEGER,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> competencies(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS competencies(
        id TEXT PRIMARY KEY NOT NULL,
        unit_id TEXT NOT NULL,
        code TEXT,
        description TEXT NOT NULL,
        level TEXT,
        FOREIGN KEY(unit_id) REFERENCES units(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> strategies(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS strategies(
        id TEXT PRIMARY KEY NOT NULL,
        code TEXT,
        name TEXT NOT NULL,
        description TEXT,
        rule TEXT,
        sample_file_path TEXT
      )
    ''');
  }

  static Future<void> assistancePrograms(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_programs(
        id TEXT PRIMARY KEY NOT NULL,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        category TEXT NOT NULL
          CHECK(category IN (
            'education',
            'seasonal',
            'uniform',
            'transport',
            'food',
            'emergency',
            'health',
            'other'
          )),
        benefit_type TEXT NOT NULL
          CHECK(benefit_type IN (
            'cash',
            'goods',
            'voucher',
            'service',
            'mixed'
          )),
        frequency TEXT NOT NULL DEFAULT 'as_needed'
          CHECK(frequency IN (
            'monthly',
            'yearly',
            'seasonal',
            'one_time',
            'as_needed'
          )),
        default_amount REAL,
        default_item_description TEXT,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> assistanceProgramBenefits(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_program_benefits(
        id TEXT PRIMARY KEY NOT NULL,
        assistance_program_id TEXT NOT NULL,
        school_type TEXT NOT NULL DEFAULT 'ALL'
          CHECK(school_type IN (
            'ALL',
            'PAUD',
            'TK',
            'SD',
            'SMP',
            'SMA',
            'SMK',
            'UNIV'
          )),
        benefit_type TEXT NOT NULL
          CHECK(benefit_type IN (
            'cash',
            'goods',
            'voucher',
            'service',
            'mixed'
          )),
        amount REAL,
        description TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assistance_program_id) REFERENCES assistance_programs(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> assistanceProgramBenefitItems(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_program_benefit_items(
        id TEXT PRIMARY KEY NOT NULL,
        program_benefit_id TEXT NOT NULL,
        item_name TEXT NOT NULL,
        quantity REAL NOT NULL DEFAULT 1,
        unit TEXT,
        estimated_value REAL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(program_benefit_id) REFERENCES assistance_program_benefits(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> schedules(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedules(
        id TEXT PRIMARY KEY NOT NULL,
        class_id TEXT,
        class_level INTEGER,
        teacher_id TEXT,
        unit_id TEXT NOT NULL,
        strategy_id TEXT,
        title TEXT,
        description TEXT,
        date TEXT,
        start_at TEXT,
        end_at TEXT,
        FOREIGN KEY(class_id) REFERENCES classes(id),
        FOREIGN KEY(teacher_id) REFERENCES teachers(id),
        FOREIGN KEY(unit_id) REFERENCES units(id),
        FOREIGN KEY(strategy_id) REFERENCES strategies(id)
      )
    ''');
  }

  static Future<void> scheduleEvents(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS schedule_events(
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        end_date TEXT,
        start_at TEXT,
        end_at TEXT,
        school_id TEXT,
        type TEXT NOT NULL DEFAULT 'Event',
        whole_day INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(school_id) REFERENCES schools(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> assessments(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assessments(
        id TEXT PRIMARY KEY NOT NULL,
        unit_id TEXT NOT NULL,
        competency_id TEXT,
        name TEXT NOT NULL,
        type TEXT,
        assessment_type TEXT,
        assessment_source TEXT,
        score_type TEXT,
        is_evidence_required INTEGER NOT NULL DEFAULT 0,
        evidence_label TEXT,
        max_score REAL,
        description TEXT,
        FOREIGN KEY(unit_id) REFERENCES units(id) ON DELETE CASCADE,
        FOREIGN KEY(competency_id) REFERENCES competencies(id) ON DELETE SET NULL
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
        note TEXT,
        assessed_at TEXT,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(assessment_id) REFERENCES assessments(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> assessmentEvidences(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assessment_evidences(
        id TEXT PRIMARY KEY NOT NULL,
        assessment_id TEXT NOT NULL,
        student_assessment_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT,
        uploaded_by TEXT,
        uploaded_at TEXT NOT NULL,
        remarks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assessment_id) REFERENCES assessments(id) ON DELETE CASCADE,
        FOREIGN KEY(student_assessment_id) REFERENCES student_assessments(id) ON DELETE CASCADE,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentExamScores(Database db) async {
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
        updated_at TEXT NOT NULL,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE SET NULL,
        FOREIGN KEY(unit_id) REFERENCES units(id) ON DELETE SET NULL,
        FOREIGN KEY(competency_id) REFERENCES competencies(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> studentExamScoreGroups(Database db) async {
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
        updated_at TEXT NOT NULL,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentExamScoreItems(Database db) async {
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
        updated_at TEXT NOT NULL,
        FOREIGN KEY(group_id) REFERENCES student_exam_score_groups(id) ON DELETE CASCADE,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE SET NULL,
        FOREIGN KEY(unit_id) REFERENCES units(id) ON DELETE SET NULL
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

  static Future<void> teachingActivities(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teaching_activities(
        id TEXT PRIMARY KEY NOT NULL,
        schedule_id TEXT NOT NULL UNIQUE,
        teacher_id TEXT,
        class_id TEXT,
        class_level INTEGER,
        activity_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'scheduled'
          CHECK(status IN ('scheduled', 'in_progress', 'completed', 'cancelled')),
        started_at TEXT,
        ended_at TEXT,
        lesson_completion_percent INTEGER,
        material_covered TEXT,
        class_condition TEXT,
        teaching_challenges TEXT,
        follow_up_plan TEXT,
        session_notes TEXT,
        assessment_type TEXT,
        cancelled_at TEXT,
        cancellation_reason TEXT,
        cancellation_notes TEXT,
        replacement_required INTEGER NOT NULL DEFAULT 0,
        replacement_activity_id TEXT,
        created_at TEXT NOT NULL,
        created_by TEXT,
        updated_at TEXT,
        updated_by TEXT,
        FOREIGN KEY(schedule_id) REFERENCES schedules(id),
        FOREIGN KEY(teacher_id) REFERENCES teachers(id),
        FOREIGN KEY(class_id) REFERENCES classes(id),
        FOREIGN KEY(replacement_activity_id) REFERENCES teaching_activities(id)
      )
    ''');
  }

  static Future<void> teachingAttendances(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teaching_attendances(
        id TEXT PRIMARY KEY NOT NULL,
        teaching_activity_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        status TEXT NOT NULL
          CHECK(status IN ('present', 'absent', 'late', 'sick', 'permission')),
        check_in_time TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        UNIQUE(teaching_activity_id, student_id),
        FOREIGN KEY(teaching_activity_id) REFERENCES teaching_activities(id) ON DELETE CASCADE,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> teachingAssessments(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS teaching_assessments(
        id TEXT PRIMARY KEY NOT NULL,
        teaching_activity_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        competency_id TEXT,
        assessment_type TEXT,
        result TEXT,
        score_mode TEXT,
        raw_score REAL,
        normalized_score REAL,
        score REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY(teaching_activity_id) REFERENCES teaching_activities(id) ON DELETE CASCADE,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(competency_id) REFERENCES competencies(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> studentSessionNotes(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_session_notes(
        id TEXT PRIMARY KEY NOT NULL,
        teaching_activity_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        note_type TEXT NOT NULL,
        comment TEXT NOT NULL,
        score_mode TEXT,
        raw_score REAL,
        normalized_score REAL,
        follow_up_needed INTEGER NOT NULL DEFAULT 0,
        follow_up_notes TEXT,
        created_by_teacher_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY(teaching_activity_id) REFERENCES teaching_activities(id) ON DELETE CASCADE,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(created_by_teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
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
        assistance INTEGER NOT NULL DEFAULT 0,
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
        id TEXT PRIMARY KEY NOT NULL,
        curriculum_id TEXT,
        subject_id TEXT,
        title TEXT NOT NULL,
        description TEXT,
        academic_year TEXT,
        school_type TEXT,
        level TEXT,
        semester TEXT,
        status TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY(curriculum_id) REFERENCES curriculums(id) ON DELETE SET NULL,
        FOREIGN KEY(subject_id) REFERENCES subjects(id) ON DELETE SET NULL
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

  static Future<void> reportDefinitions(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS report_definitions(
        id TEXT PRIMARY KEY NOT NULL,
        code TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        file_name_pattern TEXT NOT NULL,
        description TEXT,
        query_sql TEXT NOT NULL,
        parameters_json TEXT,
        columns_json TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> assistancePeriods(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_periods(
        id TEXT PRIMARY KEY NOT NULL,
        assistance_program_id TEXT,
        period_name TEXT,
        start_date TEXT,
        end_date TEXT,
        benefit_amount REAL,
        benefit_item_description TEXT,
        period_month INTEGER NOT NULL,
        period_year INTEGER NOT NULL,
        target_quota INTEGER NOT NULL,
        calculation_window_months INTEGER NOT NULL DEFAULT 3,
        minimum_attendance_percentage REAL NOT NULL DEFAULT 75,
        allow_manual_override_below_attendance INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL DEFAULT 'draft'
          CHECK(status IN ('draft', 'targeted', 'submitted', 'approved', 'cancelled')),
        targeted_at TEXT,
        submitted_at TEXT,
        approved_at TEXT,
        approved_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assistance_program_id) REFERENCES assistance_programs(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> assistanceRules(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_rules(
        id TEXT PRIMARY KEY NOT NULL,
        rule_name TEXT NOT NULL,
        rule_type TEXT NOT NULL,
        selection_mode TEXT NOT NULL,
        description TEXT,
        is_system_default INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> assistancePeriodRules(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_period_rules(
        id TEXT PRIMARY KEY NOT NULL,
        assistance_period_id TEXT NOT NULL,
        assistance_rule_id TEXT,
        rule_type TEXT NOT NULL,
        rule_name TEXT NOT NULL,
        quota INTEGER NOT NULL,
        priority_order INTEGER NOT NULL,
        selection_mode TEXT NOT NULL,
        min_score REAL,
        allow_quota_carry_over INTEGER NOT NULL DEFAULT 1,
        carry_over_to_rule_type TEXT,
        weight_config_json TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assistance_period_id) REFERENCES assistance_periods(id) ON DELETE CASCADE,
        FOREIGN KEY(assistance_rule_id) REFERENCES assistance_rules(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> studentAssistanceRules(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_assistance_rules(
        id TEXT PRIMARY KEY NOT NULL,
        student_id TEXT NOT NULL,
        rule_type TEXT NOT NULL,
        rule_name TEXT,
        reason TEXT NOT NULL,
        score_override REAL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentAssistanceRuleCandidates(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_assistance_rule_candidates(
        id TEXT PRIMARY KEY NOT NULL,
        assistance_period_id TEXT NOT NULL,
        assistance_period_rule_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        nominated_by TEXT,
        reason TEXT,
        attendance_score REAL,
        eligibility_status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assistance_period_id) REFERENCES assistance_periods(id) ON DELETE CASCADE,
        FOREIGN KEY(assistance_period_rule_id) REFERENCES assistance_period_rules(id) ON DELETE CASCADE,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> studentAssistanceAssessments(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS student_assistance_assessments(
        id TEXT PRIMARY KEY NOT NULL,
        assistance_period_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        rule_id TEXT,
        student_rule_id TEXT,
        assistance_period_rule_id TEXT,
        rule_candidate_id TEXT,
        rule_type TEXT NOT NULL,
        rule_name TEXT,
        selection_mode TEXT NOT NULL DEFAULT 'auto',
        priority_level INTEGER NOT NULL,
        priority_order INTEGER,
        priority_reason TEXT,
        economic_score REAL,
        academic_score REAL,
        attendance_score REAL,
        behavior_score REAL,
        teacher_recommendation_score REAL,
        improvement_score REAL,
        rotation_bonus REAL,
        calculation_start_date TEXT,
        calculation_end_date TEXT,
        special_case_note TEXT,
        total_score REAL NOT NULL DEFAULT 0,
        rank_no INTEGER,
        decision_status TEXT NOT NULL DEFAULT 'draft'
          CHECK(decision_status IN ('draft', 'approved', 'waitlist', 'rejected', 'cancelled')),
        eligibility_status TEXT NOT NULL DEFAULT 'eligible',
        approved_amount_or_support TEXT,
        review_date TEXT,
        reviewed_by TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assistance_period_id) REFERENCES assistance_periods(id) ON DELETE CASCADE,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(rule_id) REFERENCES student_assistance_rules(id) ON DELETE SET NULL,
        FOREIGN KEY(student_rule_id) REFERENCES student_assistance_rules(id) ON DELETE SET NULL,
        FOREIGN KEY(assistance_period_rule_id) REFERENCES assistance_period_rules(id) ON DELETE SET NULL,
        FOREIGN KEY(rule_candidate_id) REFERENCES student_assistance_rule_candidates(id) ON DELETE SET NULL
      )
    ''');
  }

  static Future<void> assistanceRuleTargets(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_rule_targets(
        id TEXT PRIMARY KEY NOT NULL,
        assistance_period_id TEXT NOT NULL,
        assistance_period_rule_id TEXT NOT NULL,
        assistance_rule_id TEXT,
        student_rule_id TEXT,
        student_id TEXT NOT NULL,
        rule_name TEXT NOT NULL,
        rule_type TEXT NOT NULL,
        selection_mode TEXT NOT NULL,
        target_source TEXT NOT NULL,
        priority_order INTEGER NOT NULL,
        priority_reason TEXT,
        attendance_score REAL,
        economic_score REAL,
        academic_score REAL,
        behavior_score REAL,
        teacher_recommendation_score REAL,
        improvement_score REAL,
        rotation_bonus REAL,
        total_score REAL NOT NULL DEFAULT 0,
        calculation_start_date TEXT,
        calculation_end_date TEXT,
        rank_no INTEGER,
        eligibility_status TEXT NOT NULL DEFAULT 'eligible',
        target_status TEXT NOT NULL DEFAULT 'selected',
        reason TEXT,
        selected_by TEXT,
        selected_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assistance_period_id) REFERENCES assistance_periods(id) ON DELETE CASCADE,
        FOREIGN KEY(assistance_period_rule_id) REFERENCES assistance_period_rules(id) ON DELETE CASCADE,
        FOREIGN KEY(assistance_rule_id) REFERENCES assistance_rules(id) ON DELETE SET NULL,
        FOREIGN KEY(student_rule_id) REFERENCES student_assistance_rules(id) ON DELETE SET NULL,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> assistanceApprovalDocuments(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_approval_documents(
        id TEXT PRIMARY KEY NOT NULL,
        assistance_period_id TEXT NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT,
        uploaded_by TEXT,
        uploaded_at TEXT NOT NULL,
        remarks TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assistance_period_id) REFERENCES assistance_periods(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> assistanceRecipients(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assistance_recipients(
        id TEXT PRIMARY KEY NOT NULL,
        assistance_period_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        assessment_id TEXT NOT NULL,
        assistance_rule_target_id TEXT,
        assistance_period_rule_id TEXT,
        rule_type TEXT NOT NULL,
        rule_name TEXT,
        final_score REAL NOT NULL DEFAULT 0,
        rank_no INTEGER,
        reason TEXT,
        benefit_school_type TEXT,
        benefit_type TEXT,
        benefit_amount REAL,
        benefit_description TEXT,
        benefit_items_json TEXT,
        status TEXT NOT NULL DEFAULT 'approved'
          CHECK(status IN ('approved', 'paid', 'distributed', 'cancelled')),
        approved_by TEXT,
        approved_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(assistance_period_id) REFERENCES assistance_periods(id) ON DELETE CASCADE,
        FOREIGN KEY(student_id) REFERENCES students(id) ON DELETE CASCADE,
        FOREIGN KEY(assessment_id) REFERENCES student_assistance_assessments(id) ON DELETE CASCADE,
        FOREIGN KEY(assistance_rule_target_id) REFERENCES assistance_rule_targets(id) ON DELETE SET NULL,
        FOREIGN KEY(assistance_period_rule_id) REFERENCES assistance_period_rules(id) ON DELETE SET NULL
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
    await _createIndexIfColumnsExist(
      db,
      table: 'students',
      columns: const ['status', 'full_name'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_students_status_full_name ON students(status, full_name)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'students',
      columns: const ['status', 'class_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_students_status_class_id ON students(status, class_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'students',
      columns: const ['full_name'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_students_full_name ON students(full_name)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'classes',
      columns: const ['school_id', 'level'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_classes_school_level ON classes(school_id, level)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'classes',
      columns: const ['level', 'section'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_classes_level_section ON classes(level, section)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schools',
      columns: const ['type', 'name'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schools_type_name ON schools(type, name)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teachers',
      columns: const ['full_name'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teachers_full_name ON teachers(full_name)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'guardians',
      columns: const ['full_name'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_guardians_full_name ON guardians(full_name)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_schools',
      columns: const ['student_id', 'status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_schools_student_status ON student_schools(student_id, status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_schools',
      columns: const ['school_id', 'status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_schools_school_status ON student_schools(school_id, status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_guardians',
      columns: const ['student_id', 'is_primary'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_guardians_student_primary ON student_guardians(student_id, is_primary)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_guardians',
      columns: const ['guardian_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_guardians_guardian_id ON student_guardians(guardian_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'report_definitions',
      columns: const ['code'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_report_definitions_code ON report_definitions(code)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'report_definitions',
      columns: const ['is_active'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_report_definitions_active ON report_definitions(is_active)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'report_definitions',
      columns: const ['is_active', 'name'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_report_definitions_active_name ON report_definitions(is_active, name)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'syllabus',
      columns: const ['curriculum_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_syllabus_curriculum_id ON syllabus(curriculum_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'syllabus',
      columns: const ['subject_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_syllabus_subject_id ON syllabus(subject_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'syllabus',
      columns: const ['school_type', 'level', 'semester'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_syllabus_school_level_semester ON syllabus(school_type, level, semester)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'subjects',
      columns: const ['status', 'name'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_subjects_status_name ON subjects(status, name)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'subjects',
      columns: const ['syllabus_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_subjects_syllabus_id ON subjects(syllabus_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'units',
      columns: const ['subject_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_units_subject_id ON units(subject_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'units',
      columns: const ['subject_id', 'sequence_no'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_units_subject_sequence ON units(subject_id, sequence_no)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'competencies',
      columns: const ['unit_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_competencies_unit_id ON competencies(unit_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'competencies',
      columns: const ['unit_id', 'sequence_no'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_competencies_unit_sequence ON competencies(unit_id, sequence_no)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedules',
      columns: const ['class_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedules_class_id ON schedules(class_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedules',
      columns: const ['class_level'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedules_class_level ON schedules(class_level)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedules',
      columns: const ['teacher_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedules_teacher_id ON schedules(teacher_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedules',
      columns: const ['teacher_id', 'date', 'start_at'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedules_teacher_date_start ON schedules(teacher_id, date, start_at)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedules',
      columns: const ['date', 'start_at'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedules_date_start ON schedules(date, start_at)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedules',
      columns: const ['class_level', 'date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedules_level_date ON schedules(class_level, date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedules',
      columns: const ['unit_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedules_unit_id ON schedules(unit_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedules',
      columns: const ['strategy_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedules_strategy_id ON schedules(strategy_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedule_events',
      columns: const ['date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedule_events_date ON schedule_events(date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedule_events',
      columns: const ['start_date', 'end_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedule_events_start_end ON schedule_events(start_date, end_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedule_events',
      columns: const ['event_type', 'start_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedule_events_type_start ON schedule_events(event_type, start_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'schedule_events',
      columns: const ['school_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_schedule_events_school_id ON schedule_events(school_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assessments',
      columns: const ['unit_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assessments_unit_id ON assessments(unit_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assessments',
      columns: const ['competency_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assessments_competency_id ON assessments(competency_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_exam_score_groups',
      columns: const ['student_id', 'exam_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_exam_score_groups_student_date ON student_exam_score_groups(student_id, exam_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_exam_score_groups',
      columns: const ['scope', 'exam_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_exam_score_groups_scope_date ON student_exam_score_groups(scope, exam_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_exam_score_items',
      columns: const ['group_id', 'subject_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_exam_score_items_group_subject ON student_exam_score_items(group_id, subject_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_exam_score_items',
      columns: const ['subject_id', 'unit_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_exam_score_items_subject_unit ON student_exam_score_items(subject_id, unit_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_exam_scores',
      columns: const ['student_id', 'exam_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_exam_scores_student_date ON student_exam_scores(student_id, exam_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_exam_scores',
      columns: const ['subject_id', 'exam_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_exam_scores_subject_date ON student_exam_scores(subject_id, exam_date)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_attendance_student_id ON student_attendance(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_teaching_notes_student_id ON teaching_notes(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['schedule_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_schedule_id ON teaching_activities(schedule_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['activity_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_activity_date ON teaching_activities(activity_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['activity_date', 'status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_date_status ON teaching_activities(activity_date, status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['teacher_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_teacher_id ON teaching_activities(teacher_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['teacher_id', 'activity_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_teacher_date ON teaching_activities(teacher_id, activity_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['class_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_class_id ON teaching_activities(class_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['class_level'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_class_level ON teaching_activities(class_level)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['class_level', 'activity_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_level_date ON teaching_activities(class_level, activity_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_activities',
      columns: const ['status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_activities_status ON teaching_activities(status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_attendances',
      columns: const ['teaching_activity_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_attendances_activity_id ON teaching_attendances(teaching_activity_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_attendances',
      columns: const ['student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_attendances_student_id ON teaching_attendances(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_attendances',
      columns: const ['teaching_activity_id', 'student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_attendances_activity_student ON teaching_attendances(teaching_activity_id, student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_attendances',
      columns: const ['student_id', 'status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_attendances_student_status ON teaching_attendances(student_id, status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_attendances',
      columns: const ['teaching_activity_id', 'status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_attendances_activity_status ON teaching_attendances(teaching_activity_id, status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_assessments',
      columns: const ['teaching_activity_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_assessments_activity_id ON teaching_assessments(teaching_activity_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_assessments',
      columns: const ['student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_assessments_student_id ON teaching_assessments(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_assessments',
      columns: const ['teaching_activity_id', 'student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_assessments_activity_student ON teaching_assessments(teaching_activity_id, student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_assessments',
      columns: const ['competency_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_assessments_competency_id ON teaching_assessments(competency_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'teaching_assessments',
      columns: const ['student_id', 'created_at'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_teaching_assessments_student_created ON teaching_assessments(student_id, created_at)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_session_notes',
      columns: const ['student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_session_notes_student_id ON student_session_notes(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_session_notes',
      columns: const ['teaching_activity_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_session_notes_activity_id ON student_session_notes(teaching_activity_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_session_notes',
      columns: const ['student_id', 'created_at'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_session_notes_student_created ON student_session_notes(student_id, created_at)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_session_notes',
      columns: const ['student_id', 'note_type'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_session_notes_student_type ON student_session_notes(student_id, note_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_session_notes',
      columns: const ['created_by_teacher_id', 'created_at'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_session_notes_teacher_created ON student_session_notes(created_by_teacher_id, created_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_activities_student_id ON student_activities(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_activities',
      columns: const ['student_id', 'start_date'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_activities_student_start ON student_activities(student_id, start_date)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_activities',
      columns: const ['activity_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_activities_activity_id ON student_activities(activity_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'activities',
      columns: const ['type', 'name'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_activities_type_name ON activities(type, name)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_relations',
      columns: const ['student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_relations_student_id ON student_relations(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_relations',
      columns: const ['related_student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_relations_related_student_id ON student_relations(related_student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_behavior_student_id ON student_behavior(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_behavior',
      columns: const ['student_id', 'recorded_at'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_behavior_student_recorded ON student_behavior(student_id, recorded_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_risks_student_id ON student_risks(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_risks',
      columns: const ['student_id', 'detected_at'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_risks_student_detected ON student_risks(student_id, detected_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_interventions_student_id ON student_interventions(student_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_wellbeing_student_id ON student_wellbeing(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_documents',
      columns: const ['student_id', 'document_type'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_documents_student_type ON student_documents(student_id, document_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_finance',
      columns: const ['student_id', 'status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_finance_student_status ON student_finance(student_id, status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_periods',
      columns: const ['period_year', 'period_month'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_periods_month_year ON assistance_periods(period_year, period_month)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_periods',
      columns: const ['status', 'period_year', 'period_month'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_periods_status_year_month ON assistance_periods(status, period_year, period_month)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_periods',
      columns: const ['assistance_program_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_periods_program_id ON assistance_periods(assistance_program_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_periods',
      columns: const ['assistance_program_id', 'period_year', 'period_month'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_periods_program_year_month ON assistance_periods(assistance_program_id, period_year, period_month)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_programs',
      columns: const ['category'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_programs_category ON assistance_programs(category)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_programs',
      columns: const ['benefit_type'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_programs_benefit_type ON assistance_programs(benefit_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_programs',
      columns: const ['frequency'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_programs_frequency ON assistance_programs(frequency)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_programs',
      columns: const ['is_active'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_programs_active ON assistance_programs(is_active)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_program_benefits',
      columns: const ['assistance_program_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_program_benefits_program_id ON assistance_program_benefits(assistance_program_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_program_benefits',
      columns: const ['assistance_program_id', 'school_type'],
      sql:
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_assistance_program_benefits_program_school ON assistance_program_benefits(assistance_program_id, school_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_program_benefit_items',
      columns: const ['program_benefit_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_program_benefit_items_benefit_id ON assistance_program_benefit_items(program_benefit_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rules',
      columns: const ['rule_type'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rules_type ON assistance_rules(rule_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rules',
      columns: const ['is_active'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rules_active ON assistance_rules(is_active)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_period_rules',
      columns: const ['assistance_period_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_period_rules_period_id ON assistance_period_rules(assistance_period_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_period_rules',
      columns: const ['assistance_rule_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_period_rules_master ON assistance_period_rules(assistance_rule_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_period_rules',
      columns: const ['rule_type'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_period_rules_type ON assistance_period_rules(rule_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_period_rules',
      columns: const ['selection_mode'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_period_rules_mode ON assistance_period_rules(selection_mode)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_period_rules',
      columns: const ['assistance_period_id', 'priority_order'],
      sql:
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_assistance_period_rules_period_priority ON assistance_period_rules(assistance_period_id, priority_order)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_student_assistance_rules_student_id ON student_assistance_rules(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_rule_candidates',
      columns: const ['assistance_period_rule_id', 'student_id'],
      sql:
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_assistance_rule_candidates_rule_student ON student_assistance_rule_candidates(assistance_period_rule_id, student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_rule_candidates',
      columns: const ['assistance_period_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_candidates_period ON student_assistance_rule_candidates(assistance_period_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_rule_candidates',
      columns: const ['student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_candidates_student ON student_assistance_rule_candidates(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_rule_candidates',
      columns: const ['eligibility_status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_candidates_eligibility ON student_assistance_rule_candidates(eligibility_status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_rules',
      columns: const ['rule_type', 'is_active'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_assistance_rules_type_active ON student_assistance_rules(rule_type, is_active)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_rules',
      columns: const ['student_id', 'is_active'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_student_assistance_rules_student_active ON student_assistance_rules(student_id, is_active)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_assessments',
      columns: const ['assistance_period_id', 'student_id'],
      sql:
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_assistance_assessments_period_student ON student_assistance_assessments(assistance_period_id, student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_assessments',
      columns: const ['assistance_period_id', 'decision_status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_assessments_period_status ON student_assistance_assessments(assistance_period_id, decision_status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_assessments',
      columns: const ['assistance_period_rule_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_assessments_period_rule ON student_assistance_assessments(assistance_period_rule_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_assessments',
      columns: const ['rule_type'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_assessments_rule_type ON student_assistance_assessments(rule_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'student_assistance_assessments',
      columns: const ['eligibility_status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_assessments_eligibility ON student_assistance_assessments(eligibility_status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rule_targets',
      columns: const ['assistance_period_id', 'student_id'],
      sql:
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_assistance_rule_targets_period_student ON assistance_rule_targets(assistance_period_id, student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rule_targets',
      columns: const ['assistance_period_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_targets_period ON assistance_rule_targets(assistance_period_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rule_targets',
      columns: const ['assistance_period_rule_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_targets_period_rule ON assistance_rule_targets(assistance_period_rule_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rule_targets',
      columns: const ['rule_type'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_targets_type ON assistance_rule_targets(rule_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rule_targets',
      columns: const ['target_status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_targets_status ON assistance_rule_targets(target_status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rule_targets',
      columns: const ['assistance_period_id', 'target_status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_targets_period_status ON assistance_rule_targets(assistance_period_id, target_status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rule_targets',
      columns: const ['assistance_period_rule_id', 'target_status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_targets_rule_status ON assistance_rule_targets(assistance_period_rule_id, target_status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_rule_targets',
      columns: const ['eligibility_status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_rule_targets_eligibility ON assistance_rule_targets(eligibility_status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_approval_documents',
      columns: const ['assistance_period_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_approval_documents_period ON assistance_approval_documents(assistance_period_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_recipients',
      columns: const ['assistance_period_id', 'student_id'],
      sql:
          'CREATE UNIQUE INDEX IF NOT EXISTS idx_assistance_recipients_period_student ON assistance_recipients(assistance_period_id, student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_recipients',
      columns: const ['assistance_rule_target_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_recipients_target ON assistance_recipients(assistance_rule_target_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_recipients',
      columns: const ['rule_type'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_recipients_rule_type ON assistance_recipients(rule_type)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_recipients',
      columns: const ['status'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_recipients_status ON assistance_recipients(status)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_recipients',
      columns: const ['student_id'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_recipients_student_id ON assistance_recipients(student_id)',
    );
    await _createIndexIfColumnsExist(
      db,
      table: 'assistance_recipients',
      columns: const ['status', 'approved_at'],
      sql:
          'CREATE INDEX IF NOT EXISTS idx_assistance_recipients_status_approved ON assistance_recipients(status, approved_at)',
    );
  }

  static Future<void> _createIndexIfColumnsExist(
    Database db, {
    required String table,
    required List<String> columns,
    required String sql,
  }) async {
    final tableInfo = await db.rawQuery('PRAGMA table_info($table)');
    if (tableInfo.isEmpty) return;

    final names = tableInfo.map((row) => row['name']?.toString()).toSet();
    if (columns.every(names.contains)) {
      await db.execute(sql);
    }
  }
}
