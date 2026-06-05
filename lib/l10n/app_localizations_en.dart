// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Edukita';

  @override
  String get menuDashboard => 'Dashboard';

  @override
  String get menuStudents => 'Students';

  @override
  String get menuTeachers => 'Teachers';

  @override
  String get menuSyllabus => 'Syllabus';

  @override
  String get menuStrategy => 'Strategy';

  @override
  String get menuSchedule => 'Schedule';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuManagement => 'Management';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuTeachingActivity => 'Teaching Activity';

  @override
  String get menuParameter => 'Parameter';

  @override
  String get menuAssistancePrograms => 'Assistance Programs';

  @override
  String get menuUserManagement => 'User Management';

  @override
  String get menuPreferences => 'Preferences';

  @override
  String get menuLogout => 'Logout';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bahasaIndonesia => 'Bahasa Indonesia';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get languageUpdated => 'Language updated successfully';

  @override
  String get personalization => 'Personalization';

  @override
  String get personalizationDescription =>
      'User-facing preferences for language, visual density, and date or number display.';

  @override
  String get generalDefaults => 'General Defaults';

  @override
  String get generalDefaultsDescription =>
      'These values are used as application-wide defaults for exports, currency labels, and eligibility rules.';

  @override
  String get technicalSettingsAdminOnly =>
      'Technical settings below are visible to admin users only.';

  @override
  String get buttonSave => 'Save';

  @override
  String get buttonSaveAndRefresh => 'Save & Refresh';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonEdit => 'Edit';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonRemove => 'Remove';

  @override
  String get buttonAdd => 'Add';

  @override
  String get buttonSearch => 'Search';

  @override
  String get buttonReset => 'Reset';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonConfirm => 'Confirm';

  @override
  String get buttonBack => 'Back';

  @override
  String get buttonNext => 'Next';

  @override
  String get buttonContinue => 'Continue';

  @override
  String get buttonSaving => 'Saving';

  @override
  String get statusActive => 'Active';

  @override
  String get status => 'Status';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusTargeted => 'Targeted';

  @override
  String get statusSubmitted => 'Submitted';

  @override
  String get statusDistributed => 'Distributed';

  @override
  String get statusPaid => 'Paid';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get attendancePresent => 'Present';

  @override
  String get attendanceAbsent => 'Absent';

  @override
  String get attendanceSick => 'Sick';

  @override
  String get attendancePermission => 'Permission';

  @override
  String get attendanceLate => 'Late';

  @override
  String get studentName => 'Student Name';

  @override
  String get studentCode => 'Student Code';

  @override
  String get teacherName => 'Teacher Name';

  @override
  String get className => 'Class';

  @override
  String get school => 'School';

  @override
  String get subject => 'Subject';

  @override
  String get subjects => 'Subjects';

  @override
  String get unit => 'Unit';

  @override
  String get competency => 'Competency';

  @override
  String get records => 'Records';

  @override
  String get checkIn => 'Check In';

  @override
  String get scheduleDate => 'Schedule Date';

  @override
  String get scheduleCalendar => 'Schedule Calendar';

  @override
  String scheduleHeaderSummary(Object scheduleCount, Object eventCount) {
    return '$scheduleCount teaching schedules, $eventCount events';
  }

  @override
  String get scheduleAccessDenied =>
      'You do not have permission to view schedules.';

  @override
  String get scheduleCreateDenied =>
      'You do not have permission to create schedules.';

  @override
  String get scheduleUpdateDenied =>
      'You do not have permission to update this schedule.';

  @override
  String get scheduleDeleteDenied =>
      'You do not have permission to delete this schedule.';

  @override
  String get eventCreateDenied =>
      'You do not have permission to create events.';

  @override
  String get eventUpdateDenied =>
      'You do not have permission to update events.';

  @override
  String get eventDeleteDenied =>
      'You do not have permission to delete events.';

  @override
  String get userNotLinkedTeacher =>
      'Your user is not linked to a teacher profile.';

  @override
  String get refreshSchedules => 'Refresh schedules';

  @override
  String get findScheduleHint => 'Find schedule, event, teacher, level';

  @override
  String get addScheduleOrEvent => 'Add schedule or event';

  @override
  String get teachingSchedule => 'Teaching schedule';

  @override
  String get schoolEvent => 'School event';

  @override
  String get otherEvent => 'Other event';

  @override
  String get events => 'Events';

  @override
  String get noSchoolEventOnDate => 'No school event on this date.';

  @override
  String get noTeacherAssigned => 'No teacher assigned';

  @override
  String get noMatchingSchedule => 'No matching schedule or event.';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String get deleteEvent => 'Delete Event';

  @override
  String deleteScheduleConfirm(Object name) {
    return 'Delete $name?';
  }

  @override
  String deleteEventConfirm(Object name) {
    return 'Delete $name?';
  }

  @override
  String get thisSchedule => 'this schedule';

  @override
  String get addSchedule => 'Add Schedule';

  @override
  String get editSchedule => 'Edit Schedule';

  @override
  String get addEvent => 'Add Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get eventName => 'Event Name';

  @override
  String get wholeDay => 'Whole day';

  @override
  String get wholeDaySubtitle =>
      'Use when this event takes the full selected day.';

  @override
  String get wholeDayUnavailableSubtitle =>
      'Whole day is available only for one-day events.';

  @override
  String get endDateAfterStartDate => 'End date must be after start date';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get title => 'Title';

  @override
  String get description => 'Description';

  @override
  String get cannotSaveSchedule => 'Cannot Save Schedule';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get createdAt => 'Created At';

  @override
  String get updatedAt => 'Updated At';

  @override
  String get emptyData => 'No data available';

  @override
  String get loading => 'Loading...';

  @override
  String get errorSomethingWentWrong => 'Something went wrong';

  @override
  String get messageDataSaved => 'Data saved successfully';

  @override
  String get messageDataUpdated => 'Data updated successfully';

  @override
  String get messageDataDeleted => 'Data deleted successfully';

  @override
  String get messageConfirmDelete =>
      'Are you sure you want to delete this data?';

  @override
  String get dashboardSubtitle =>
      'Foundation education overview and operation snapshot.';

  @override
  String get dashboardRefresh => 'Refresh dashboard';

  @override
  String get dashboardLevel => 'Level';

  @override
  String get dashboardSelectLevels => 'Select Levels';

  @override
  String get dashboardSelectLevelsDescription =>
      'Choose one or multiple school levels.';

  @override
  String get dashboardAllLevels => 'All Levels';

  @override
  String get dashboardAllSd => 'All SD';

  @override
  String get dashboardAllSmp => 'All SMP';

  @override
  String get dashboardAllSma => 'All SMA';

  @override
  String get dashboardUniversity => 'University';

  @override
  String get dashboardLevelLabel => 'Level';

  @override
  String get dashboardClear => 'Clear';

  @override
  String get dashboardApply => 'Apply';

  @override
  String get dashboardActiveStudents => 'Active Students';

  @override
  String get dashboardWithGenderData => 'with gender data';

  @override
  String get dashboardAverageAttendance => 'Avg Attendance';

  @override
  String get dashboardAttendanceRecords => 'attendance records';

  @override
  String get dashboardAverageAcademic => 'Avg Academic';

  @override
  String get dashboardActiveSubjects => 'active subjects';

  @override
  String get dashboardTeachingSessions => 'Teaching Sessions';

  @override
  String get dashboardStudentsTitle => 'Students';

  @override
  String get dashboardStudentsDescription =>
      'Active student composition by gender.';

  @override
  String get dashboardBoys => 'Boys';

  @override
  String get dashboardGirls => 'Girls';

  @override
  String get dashboardAttendanceTitle => 'Attendance';

  @override
  String get dashboardRecords => 'Records';

  @override
  String get dashboardAcademicAverageScore => 'Academic Average Score';

  @override
  String get dashboardSubjectScoreAverage => 'subject score average.';

  @override
  String get dashboardNoSubjectsYet => 'No subjects yet.';

  @override
  String get dashboardPreviousSubjects => 'Previous subjects';

  @override
  String get dashboardNextSubjects => 'Next subjects';

  @override
  String get dashboardSwapSubjects => 'Swap subjects';

  @override
  String get dashboardStudentProgressTrend => 'Student Progress Trend';

  @override
  String dashboardProgressSubtitle(
    Object attendance,
    Object academic,
    Object notes,
  ) {
    return 'Attendance $attendance% | Academic $academic% | Notes $notes%';
  }

  @override
  String get dashboardAcademic => 'Academic';

  @override
  String get dashboardTeacherNotes => 'Teacher Notes';

  @override
  String get dashboardNoProgressData =>
      'No progress data is available for this filter yet.';

  @override
  String get dashboardSessionProgress => 'Session Progress';

  @override
  String get dashboardNoTeachingSessionRange =>
      'No teaching session in this range.';

  @override
  String get dashboardSessions => 'sessions';

  @override
  String get dashboardStatusInProgress => 'In Progress';

  @override
  String get dashboardUpcomingScheduleThisWeek => 'Upcoming Schedule This Week';

  @override
  String get dashboardUpcomingScheduleSubtitle =>
      'Teaching schedule for the next 7 days';

  @override
  String get dashboardNoUpcomingSchedule =>
      'No upcoming teaching schedule this week.';

  @override
  String get dashboardStudentsNeedAttention => 'Students Need Attention';

  @override
  String get dashboardStudentsNeedAttentionSubtitle =>
      'Attendance, score, and follow-up signals';

  @override
  String get dashboardNoAttentionSignal => 'No attention signal in this range.';

  @override
  String get dashboardTopLearners => 'Top Learners';

  @override
  String get dashboardTopLearnersSubtitle =>
      'Academic score and teacher notes ranking';

  @override
  String get dashboardTopLearnersTooltip =>
      'Points = 65% academic average + 35% teacher note score.\nNote score is scaled from 0-5 stars to 0-100.';

  @override
  String get dashboardNoLearnerScore =>
      'No academic or teacher note score is available yet.';

  @override
  String get dashboardPointsShort => 'pts';

  @override
  String get dashboardRecentTeacherNotes => 'Recent Teacher Notes';

  @override
  String get dashboardNoTeacherNotes => 'No teacher notes in this range.';

  @override
  String get rangeWeekly => 'Weekly';

  @override
  String get rangeMonthly => 'Monthly';

  @override
  String get rangeThreeMonths => '3 Months';

  @override
  String get rangeSixMonths => '6 Months';

  @override
  String get rangeOneYear => '1 Year';

  @override
  String get teachingActivityTitle => 'Teaching Activity';

  @override
  String get teachingActivitySubtitle =>
      'Open scheduled classes, record attendance, notes, and teaching results.';

  @override
  String get teachingActivityError => 'Teaching Activity Error';

  @override
  String get teachingActivityAccessDenied =>
      'You do not have permission to view teaching activities.';

  @override
  String get teachingReportAccessDenied =>
      'You do not have permission to view teaching reports.';

  @override
  String get teachingActivityNotFound => 'Teaching activity not found.';

  @override
  String get teachingReportNoAccess =>
      'You do not have access to this teaching report.';

  @override
  String get backToTeachingActivity => 'Back to Teaching Activity';

  @override
  String get allTeachers => 'All teachers';

  @override
  String get allLevels => 'All levels';

  @override
  String get allStatus => 'All status';

  @override
  String get noTeachingSessionsFilter =>
      'No teaching sessions for this filter.';

  @override
  String get unitMaterial => 'Unit / Material';

  @override
  String get action => 'Action';

  @override
  String get selectedDate => 'Selected Date';

  @override
  String get sessions => 'Sessions';

  @override
  String get session => 'Session';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get inProgress => 'In progress';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get startClass => 'Start Class';

  @override
  String get complete => 'Complete';

  @override
  String get viewDetail => 'View Detail';

  @override
  String get cancelSession => 'Cancel Session';

  @override
  String get reason => 'Reason';

  @override
  String get notes => 'Notes';

  @override
  String get note => 'Note';

  @override
  String get replacementNeeded => 'Replacement needed';

  @override
  String get markCancelled => 'Mark Cancelled';

  @override
  String get teachingSessionCancelled => 'Teaching session cancelled.';

  @override
  String get teachingSessionReport => 'Teaching Session Report';

  @override
  String get teachingReportCompleted => 'Teaching report completed.';

  @override
  String get completeReport => 'Complete Report';

  @override
  String get teachingReportReset => 'Teaching report reset.';

  @override
  String get resetReport => 'Reset Report';

  @override
  String get sessionNotes => 'Session Notes';

  @override
  String get sessionOverview => 'Session Overview';

  @override
  String get sessionOverviewSubtitle =>
      'Teaching session details and completion summary.';

  @override
  String get sessionNote => 'Session Note';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get teacher => 'Teacher';

  @override
  String get strategy => 'Strategy';

  @override
  String get assessment => 'Assessment';

  @override
  String get students => 'Students';

  @override
  String get assessments => 'Assessments';

  @override
  String get studentNotes => 'Student Notes';

  @override
  String get completion => 'Completion';

  @override
  String get editSessionNote => 'Edit session note';

  @override
  String get studentsAttendance => 'Students & Attendance';

  @override
  String get studentsAttendanceSubtitle =>
      'Select a student and mark attendance.';

  @override
  String get searchStudentHint => 'Search student name or number';

  @override
  String get saveAttendance => 'Save attendance';

  @override
  String get allPresent => 'All Present';

  @override
  String get student => 'Student';

  @override
  String get attendance => 'Attendance';

  @override
  String get noteHistory => 'Note History';

  @override
  String get saveReporting => 'Save Reporting';

  @override
  String get reporting => 'Reporting';

  @override
  String get searchStudent => 'Search student';

  @override
  String get studentSearchHint => 'Name or student no';

  @override
  String get shown => 'shown';

  @override
  String get noStudentsMatchSearch => 'No students match the current search.';

  @override
  String get competencyScores => 'Competency Scores';

  @override
  String get quizNumericScoreSubtitle => 'Quiz scores use numeric value 0-100.';

  @override
  String get starAssessmentSubtitle => 'Session assessment uses star rating.';

  @override
  String get selectAssessmentType => 'Select assessment type';

  @override
  String get noCompetenciesRegistered =>
      'No competencies registered for this unit.';

  @override
  String attendanceNoteRequiredForStudent(Object student) {
    return 'Attendance note is required for $student.';
  }

  @override
  String get assessmentType => 'Assessment Type';

  @override
  String get studentNotesSubtitle =>
      'Add social observation notes directly by type.';

  @override
  String get attendanceNote => 'Attendance Note';

  @override
  String get attendanceNoteRequired => 'Attendance note *';

  @override
  String get attendanceNoteRequiredSubtitle =>
      'Required because attendance is Permission.';

  @override
  String get attendanceNoteOptionalSubtitle =>
      'Optional attendance note for this student.';

  @override
  String get teacherNotesHistory => 'Teacher Notes History';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get resetTeachingReport => 'Reset Teaching Report?';

  @override
  String get resetTeachingReportMessage =>
      'This will remove all attendance, competency scores, student notes, and session notes for this report.';

  @override
  String get resetAll => 'Reset All';

  @override
  String get changeAssessmentType => 'Change Assessment Type?';

  @override
  String get changeAssessmentTypeMessage =>
      'This session already has assessment rows. Changing the type will make the Assessment tab use a different score mode for future entries.';

  @override
  String get changeType => 'Change Type';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get teacherUnavailable => 'Teacher unavailable';

  @override
  String get studentGroupUnavailable => 'Student group unavailable';

  @override
  String get publicHoliday => 'Public holiday';

  @override
  String get roomUnavailable => 'Room unavailable';

  @override
  String get weatherOrEmergency => 'Weather or emergency';

  @override
  String get scheduleMistake => 'Schedule mistake';

  @override
  String get administrativeReason => 'Administrative reason';

  @override
  String get other => 'Other';

  @override
  String get assessmentObservation => 'Observation';

  @override
  String get assessmentExercise => 'Exercise';

  @override
  String get assessmentQuiz => 'Quiz';

  @override
  String get assessmentOral => 'Oral';

  @override
  String get assessmentPractical => 'Practical';

  @override
  String get assessmentAssignment => 'Assignment';

  @override
  String get assessmentParticipation => 'Participation';

  @override
  String get assessmentMemorization => 'Memorization';

  @override
  String get assessmentReading => 'Reading';

  @override
  String get noteLearningProgress => 'Learning Progress';

  @override
  String get noteBehavior => 'Behavior';

  @override
  String get noteAttendanceConcern => 'Attendance Concern';

  @override
  String get noteNeedsSupport => 'Needs Support';

  @override
  String get noteAchievement => 'Achievement';

  @override
  String get noteParentFollowUp => 'Parent Follow Up';

  @override
  String get studentDetail => 'Student Detail';

  @override
  String get studentAccessDenied =>
      'You do not have permission to view students.';

  @override
  String get studentCreateDenied =>
      'You do not have permission to create students.';

  @override
  String get studentUpdateDenied =>
      'You do not have permission to update students.';

  @override
  String get studentDeleteDenied =>
      'You do not have permission to delete students.';

  @override
  String get teacherAccessDenied =>
      'You do not have permission to view teachers.';

  @override
  String get teacherCreateDenied =>
      'You do not have permission to create teachers.';

  @override
  String get teacherUpdateDenied =>
      'You do not have permission to update teachers.';

  @override
  String get teacherDeleteDenied =>
      'You do not have permission to delete teachers.';

  @override
  String get addStudent => 'Add Student';

  @override
  String get addTeacher => 'Add Teacher';

  @override
  String get editTeacher => 'Edit Teacher';

  @override
  String get deleteTeacher => 'Delete Teacher';

  @override
  String deleteTeacherConfirm(Object name) {
    return 'Delete $name?';
  }

  @override
  String get searchTeacherName => 'Search teacher name';

  @override
  String get noTeachersYet => 'No teachers yet. Add a teacher.';

  @override
  String get noTeachersMatch => 'No teachers match your search.';

  @override
  String get education => 'Education';

  @override
  String get educationLevel => 'Education Level';

  @override
  String get appUser => 'App User';

  @override
  String get linked => 'Linked';

  @override
  String get noUser => 'No user';

  @override
  String get createAppUser => 'Create app user';

  @override
  String get teacherAlreadyHasAppUser => 'Teacher already has app user';

  @override
  String get editTeacherTooltip => 'Edit teacher';

  @override
  String get deleteTeacherTooltip => 'Delete teacher';

  @override
  String get teacherNotFound => 'Teacher not found';

  @override
  String get teacherProfile => 'Teacher Profile';

  @override
  String get noSubjectsAssigned => 'No subjects assigned';

  @override
  String get teachingLoad => 'Teaching Load';

  @override
  String get teachingHours => 'Teaching Hours';

  @override
  String get summaryInsight => 'Summary Insight';

  @override
  String get alerts => 'Alerts';

  @override
  String get detail => 'Detail';

  @override
  String get level => 'Level';

  @override
  String get noManagementAlerts =>
      'No management alerts detected for this teacher.';

  @override
  String get impact => 'Impact';

  @override
  String get classes => 'Classes';

  @override
  String get studentImpactSnapshot => 'Student Impact Snapshot';

  @override
  String get improved => 'Improved';

  @override
  String get stable => 'Stable';

  @override
  String get declined => 'Declined';

  @override
  String get up => 'up';

  @override
  String get same => 'same';

  @override
  String get down => 'down';

  @override
  String get needCare => 'Need Care';

  @override
  String get studentsUnderCare => 'Students Under Care';

  @override
  String get scoreTrend => 'Score Trend';

  @override
  String get followUp => 'Follow-up';

  @override
  String get noStudentImpactRows =>
      'Student impact rows will appear after teaching assessment scores are recorded.';

  @override
  String get assignedClassesStudents => 'Assigned Classes & Students';

  @override
  String get assignedClassesEmpty =>
      'Assigned classes will appear here after schedules are linked to this teacher.';

  @override
  String get notesActivity => 'Notes Activity';

  @override
  String get totalNotes => 'Total Notes';

  @override
  String get recentTeacherNotes => 'Recent Teacher Notes';

  @override
  String get noStudentSessionNotes =>
      'No student session notes have been recorded by this teacher.';

  @override
  String get editStudent => 'Edit Student';

  @override
  String get deleteStudent => 'Delete Student';

  @override
  String deleteStudentConfirm(Object name) {
    return 'Delete $name?';
  }

  @override
  String get filterStudents => 'Filter Students';

  @override
  String get total => 'Total';

  @override
  String get studentProfile => 'Student Profile';

  @override
  String get classSchool => 'Class\nSchool';

  @override
  String get ageGender => 'Age\nGender';

  @override
  String get scoreStatus => 'Score\nStatus';

  @override
  String get joinDate => 'Join Date';

  @override
  String get actions => 'Actions';

  @override
  String get editStudentTooltip => 'Edit student';

  @override
  String get deleteStudentTooltip => 'Delete student';

  @override
  String get overview => 'Overview';

  @override
  String get personal => 'Personal';

  @override
  String get personalProfile => 'Personal Profile';

  @override
  String get fullName => 'Full Name';

  @override
  String get nickName => 'Nick Name';

  @override
  String get nis => 'NIS';

  @override
  String get birthDate => 'Birth Date';

  @override
  String get gender => 'Gender';

  @override
  String get mobileNo => 'Mobile No';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get contact => 'Contact';

  @override
  String get physical => 'Physical';

  @override
  String get photo => 'Photo';

  @override
  String get photos => 'Photos';

  @override
  String get registrationForm => 'Registration Form';

  @override
  String get studentPhoto => 'Student Photo';

  @override
  String get noPhotoSelected => 'No photo selected';

  @override
  String get noFileSelected => 'No file selected';

  @override
  String get uploadRegistrationFormHelp =>
      'Upload signed paper registration form (PDF/JPG/PNG)';

  @override
  String get upload => 'Upload';

  @override
  String get removeFile => 'Remove file';

  @override
  String get generatedNo => 'Generated No';

  @override
  String get selectSchool => 'Select school';

  @override
  String get selectSchoolFirst => 'Select school first';

  @override
  String get selectClass => 'Select class';

  @override
  String get createStudent => 'Create Student';

  @override
  String get updateStudent => 'Update Student';

  @override
  String get advancedDetail => 'Advanced Detail';

  @override
  String get hideAdvancedDetail => 'Hide Advanced Detail';

  @override
  String get studentNumberNotReady => 'Student number is not ready yet.';

  @override
  String get photoSizeLimit => 'Photo must be 20 MB or smaller.';

  @override
  String get registrationFormSizeLimit =>
      'Registration form must be 20 MB or smaller.';

  @override
  String get registrationFormRequired => 'Registration form is required.';

  @override
  String get shoeSize => 'Shoe Size';

  @override
  String get uniformSize => 'Uniform Size';

  @override
  String get pantsSize => 'Pants Size';

  @override
  String get hobby => 'Hobby';

  @override
  String get aspiration => 'Aspiration';

  @override
  String get citaCita => 'Cita-cita';

  @override
  String get family => 'Family';

  @override
  String get siblingRelation => 'Sibling Relation';

  @override
  String get addSiblingRelation => 'Add Sibling Relation';

  @override
  String get guardianParents => 'Guardian / Parents';

  @override
  String get addParentGuardian => 'Add parent / guardian';

  @override
  String get addGuardian => 'Add Guardian';

  @override
  String get editGuardian => 'Edit Guardian';

  @override
  String get primaryGuardian => 'Primary Guardian';

  @override
  String get notPrimary => 'Not Primary';

  @override
  String get parentGuardianName => 'Parent / Guardian Name';

  @override
  String get extracurricularActivity => 'Extracurricular / Activity';

  @override
  String get addActivity => 'Add activity';

  @override
  String get editActivity => 'Edit Activity';

  @override
  String get activityName => 'Activity Name';

  @override
  String get studentIdNo => 'Student ID / No';

  @override
  String get searchSibling => 'Search sibling';

  @override
  String get hobbyAspiration => 'Hobby & Aspiration';

  @override
  String get academic => 'Academic';

  @override
  String get examScores => 'Exam Scores';

  @override
  String get addScoreExam => 'Add Score Exam';

  @override
  String get editScoreExam => 'Edit Score Exam';

  @override
  String get examScoresDescription =>
      'School scores are grouped by report/exam and can contain many subjects. Internal scores can contain many units.';

  @override
  String get loadingExamScores => 'Loading exam scores...';

  @override
  String get noExamScores => 'No internal or school exam score has been added.';

  @override
  String get removeExamScoreTitle => 'Remove Exam Score?';

  @override
  String removeExamScoreMessage(Object type) {
    return 'This will remove $type score data from this student.';
  }

  @override
  String get scoreAvg => 'Score\nAvg';

  @override
  String get scoreAvgTooltip =>
      'Avg is calculated from each item score divided by max score, then averaged for this exam.';

  @override
  String get internal => 'Internal';

  @override
  String get examType => 'Exam Type';

  @override
  String get internalType => 'Internal Type';

  @override
  String get source => 'Source';

  @override
  String get scope => 'Scope';

  @override
  String get academicYear => 'Academic Year';

  @override
  String get semester => 'Semester';

  @override
  String get subjectScores => 'Subject Scores';

  @override
  String get unitScores => 'Unit Scores';

  @override
  String get addSubject => 'Add Subject';

  @override
  String get addUnit => 'Add Unit';

  @override
  String get noSubjectScore =>
      'No subject score added yet. Click Add Subject to input report scores.';

  @override
  String get noUnitScore =>
      'No unit score added yet. Click Add Unit to input internal scores.';

  @override
  String get maxScore => 'Max Score';

  @override
  String get score => 'Score';

  @override
  String get removeRow => 'Remove row';

  @override
  String get downloadEvidence => 'Download evidence';

  @override
  String get removeScoreRecord => 'Remove score record';

  @override
  String get behavior => 'Behavior';

  @override
  String get activities => 'Activities';

  @override
  String get more => 'More';

  @override
  String get quickProfile => 'Quick Profile';

  @override
  String get aggregatedSnapshot => 'Aggregated Snapshot';

  @override
  String get loadingStudentSnapshot => 'Loading student snapshot...';

  @override
  String get noStudentSnapshot => 'No student snapshot available.';

  @override
  String get attendanceRecords => 'Attendance Records';

  @override
  String attendanceChartTitle(Object year) {
    return 'Attendance $year';
  }

  @override
  String get monthlyAttendanceRate => 'Monthly attendance rate';

  @override
  String get attendanceChartEmpty =>
      'Attendance will appear after teaching attendance is saved.';

  @override
  String get averageScore => 'Average Score';

  @override
  String get assistance => 'Assistance';

  @override
  String get needsAttention => 'Needs Attention';

  @override
  String get noAttentionNeeded => 'No attention signal for this student yet.';

  @override
  String get attendanceBelowThreshold => 'Attendance below 75%';

  @override
  String absenceRecords(Object count) {
    return '$count absence record(s)';
  }

  @override
  String permissionRecords(Object count) {
    return '$count permission record(s)';
  }

  @override
  String recentTeacherNotesCount(Object count) {
    return '$count recent teacher note(s)';
  }

  @override
  String get signal => 'Signal';

  @override
  String get physicalAttributes => 'Physical Attributes';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get uniform => 'Uniform';

  @override
  String get pants => 'Pants';

  @override
  String get shoes => 'Shoes';

  @override
  String get studentRelations => 'Student Relations';

  @override
  String get loadingStudentRelations => 'Loading student relations...';

  @override
  String get parentsGuardians => 'Parents / Guardians';

  @override
  String get loadingGuardianInformation => 'Loading guardian information...';

  @override
  String get learningSummary => 'Learning Summary';

  @override
  String get loadingLearningSummary => 'Loading learning summary...';

  @override
  String get noLearningSummary => 'No learning summary available.';

  @override
  String get latest => 'Latest';

  @override
  String get competencyAverage => 'Competency Average';

  @override
  String get loadingCompetencyRecords => 'Loading competency records...';

  @override
  String get teachingAttendance => 'Teaching Attendance';

  @override
  String get loadingAttendanceRecords => 'Loading attendance records...';

  @override
  String get teacherNotes => 'Teacher Notes';

  @override
  String get loadingTeacherNotes => 'Loading teacher notes...';

  @override
  String get noteTypeDistribution => 'Note Type Distribution';

  @override
  String get loadingNoteDistribution => 'Loading note distribution...';

  @override
  String get extracurricular => 'Extracurricular';

  @override
  String get loadingActivities => 'Loading activities...';

  @override
  String get extraActivityRecords => 'Extra Activity Records';

  @override
  String get assistanceHistory => 'Assistance History';

  @override
  String get loadingAssistanceHistory => 'Loading assistance history...';

  @override
  String get goals => 'Goals';

  @override
  String get loadingGoals => 'Loading goals...';

  @override
  String get rating => 'Rating';

  @override
  String get comment => 'Comment';

  @override
  String get count => 'Count';

  @override
  String get type => 'Type';

  @override
  String get activity => 'Activity';

  @override
  String get role => 'Role';

  @override
  String get achievement => 'Achievement';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get program => 'Program';

  @override
  String get period => 'Period';

  @override
  String get rule => 'Rule';

  @override
  String get benefit => 'Benefit';

  @override
  String get approvedAt => 'Approved At';

  @override
  String get category => 'Category';

  @override
  String get goal => 'Goal';

  @override
  String get relationship => 'Relationship';

  @override
  String get relation => 'Relation';

  @override
  String get agePosition => 'Age Position';

  @override
  String get primary => 'Primary';

  @override
  String get mobile => 'Mobile';

  @override
  String get email => 'Email';

  @override
  String get occupation => 'Occupation';

  @override
  String get noTeacherNotes =>
      'No teacher notes have been saved from teaching sessions.';

  @override
  String get noTeacherNoteDistribution =>
      'No teacher note distribution is available.';

  @override
  String get noExtracurricularActivity =>
      'No extracurricular activity has been added.';

  @override
  String get noExtraActivity => 'No extra activity has been added.';

  @override
  String get noAssistanceHistory =>
      'No assistance recipient history is available.';

  @override
  String get noGoals => 'No hobby or cita-cita has been added yet.';

  @override
  String get noStudentRelations =>
      'No sibling or student relation has been added yet.';

  @override
  String get noGuardianInformation =>
      'No parent or guardian information has been added yet.';

  @override
  String get noCompetencyScores =>
      'No competency scores have been saved from teaching sessions.';

  @override
  String get noTeachingAttendance =>
      'No teaching attendance has been saved for this student.';

  @override
  String get name => 'Name';

  @override
  String get studentNo => 'Student No';

  @override
  String get age => 'Age';

  @override
  String get years => 'years';

  @override
  String get assistanceProgramsTitle => 'Assistance Programs';

  @override
  String get assistanceProgramsSubtitle =>
      'Maintain reusable assistance programs, benefit types, and default support values.';

  @override
  String get addProgram => 'Add Program';

  @override
  String get editProgram => 'Edit Program';

  @override
  String get searchCodeNameDescription => 'Search code, name, description';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get noAssistancePrograms => 'No assistance programs found';

  @override
  String get defaultBenefit => 'Default Benefit';

  @override
  String get editProgramTooltip => 'Edit program';

  @override
  String get activate => 'Activate';

  @override
  String get deactivate => 'Deactivate';

  @override
  String get noPermissionViewAssistancePrograms =>
      'You do not have permission to view assistance programs.';

  @override
  String get noPermissionCreateAssistancePrograms =>
      'You do not have permission to create assistance programs.';

  @override
  String get noPermissionUpdateAssistancePrograms =>
      'You do not have permission to update assistance programs.';

  @override
  String get assistanceProgramActivated => 'Assistance program activated.';

  @override
  String get assistanceProgramDeactivated => 'Assistance program deactivated.';

  @override
  String get failedUpdateAssistanceProgramStatus =>
      'Failed to update assistance program status.';

  @override
  String get codeRequired => 'Code is required';

  @override
  String get codeFormatUppercase =>
      'Use uppercase letters, numbers, or underscore';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get benefitType => 'Benefit Type';

  @override
  String get frequency => 'Frequency';

  @override
  String get defaultAmountRp => 'Default Amount (Rp)';

  @override
  String get amountMustBeNumber => 'Amount must be a number';

  @override
  String get amountCannotBeNegative => 'Amount cannot be negative';

  @override
  String get defaultItemDescription => 'Default Item Description';

  @override
  String get benefitPackages => 'Benefit Packages';

  @override
  String get addPackage => 'Add Package';

  @override
  String get usePackagesBySchoolType =>
      'Use packages when benefit amount or goods differ by school type.';

  @override
  String get noPackageYet =>
      'No package yet. If empty, the program default amount/item is used.';

  @override
  String get editPackage => 'Edit package';

  @override
  String get removePackage => 'Remove package';

  @override
  String get addBenefitPackage => 'Add Benefit Package';

  @override
  String get editBenefitPackage => 'Edit Benefit Package';

  @override
  String get schoolType => 'School Type';

  @override
  String get amountRp => 'Amount (Rp)';

  @override
  String get enterAmountRupiah => 'Enter amount in Rupiah';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get optionalPackageNotes => 'Optional package notes';

  @override
  String get goodsItems => 'Goods / Items';

  @override
  String get addItem => 'Add Item';

  @override
  String get itemsForGoodsMixed =>
      'Items are used for goods or mixed benefit packages.';

  @override
  String get noItemsYet => 'No items yet.';

  @override
  String get editItem => 'Edit item';

  @override
  String get removeItem => 'Remove item';

  @override
  String get savePackage => 'Save Package';

  @override
  String get goodsPackageNeedsItem => 'Goods package needs at least one item.';

  @override
  String get mixedPackageNeedsAmountOrItem =>
      'Mixed package needs amount or item.';

  @override
  String get itemName => 'Item Name';

  @override
  String get itemNameRequired => 'Item name is required';

  @override
  String get quantity => 'Quantity';

  @override
  String get quantityGreaterThanZero => 'Quantity must be greater than zero';

  @override
  String get unitHint => 'pcs, pack, set';

  @override
  String get estimatedValueRp => 'Estimated Value (Rp)';

  @override
  String get estimatedValueValid => 'Estimated value must be valid';

  @override
  String get saveItem => 'Save Item';

  @override
  String get categoryEducation => 'Education';

  @override
  String get categorySeasonal => 'Seasonal';

  @override
  String get categoryUniform => 'Uniform';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryEmergency => 'Emergency';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryOther => 'Other';

  @override
  String get benefitCash => 'Cash';

  @override
  String get benefitGoods => 'Goods';

  @override
  String get benefitVoucher => 'Voucher';

  @override
  String get benefitService => 'Service';

  @override
  String get benefitMixed => 'Mixed';

  @override
  String get frequencyMonthly => 'Monthly';

  @override
  String get frequencyYearly => 'Yearly';

  @override
  String get frequencySeasonal => 'Seasonal';

  @override
  String get frequencyOneTime => 'One Time';

  @override
  String get frequencyAsNeeded => 'As Needed';

  @override
  String get schoolTypeAll => 'All';

  @override
  String get schoolTypeUniversity => 'University';

  @override
  String get draft => 'Draft';

  @override
  String get targeted => 'Targeted';

  @override
  String get submitted => 'Submitted';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get distributed => 'Distributed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get assistancePeriodsTitle => 'Assistance Periods';

  @override
  String get assistancePeriodsSubtitle =>
      'Manage assistance periods, target candidates, approval, and recipients.';

  @override
  String get create => 'Create';

  @override
  String get thisMonth => 'This Month';

  @override
  String activeCount(Object count) {
    return '$count Active';
  }

  @override
  String get searchPeriodProgramMonth => 'Search period, program, month';

  @override
  String get year => 'Year';

  @override
  String get noAssistancePeriods => 'No assistance periods found';

  @override
  String get periodName => 'Period Name';

  @override
  String get target => 'Target';

  @override
  String get selected => 'Selected';

  @override
  String get approvedFinalizedPeriodCannotDelete =>
      'Approved or finalized period cannot be deleted';

  @override
  String get deletePeriod => 'Delete period';

  @override
  String get noPermissionDeletePeriods =>
      'You do not have permission to delete periods.';

  @override
  String get deleteAssistancePeriodTitle => 'Delete Assistance Period?';

  @override
  String deleteAssistancePeriodMessage(Object period) {
    return 'This will delete \"$period\" with its rules, target candidates, and recipient data. This action cannot be undone.';
  }

  @override
  String get deletePeriodButton => 'Delete Period';

  @override
  String get assistancePeriodDeleted => 'Assistance period deleted.';

  @override
  String get setup => 'Setup';

  @override
  String get open => 'Open';

  @override
  String get review => 'Review';

  @override
  String get view => 'View';

  @override
  String get finalize => 'Finalize';

  @override
  String get report => 'Report';

  @override
  String get targetCandidates => 'Target Candidates';

  @override
  String get reviewApproval => 'Review & Approval';

  @override
  String get approvalDocument => 'Approval Document';

  @override
  String get recipients => 'Recipients';

  @override
  String get remaining => 'Remaining';

  @override
  String get minimumAttendance => 'Minimum Attendance';

  @override
  String get calculation => 'Calculation';

  @override
  String get calculationRange => 'Calculation Range';

  @override
  String get periodInfo => 'Period Info';

  @override
  String get targetQuota => 'Target Quota';

  @override
  String get calculationWindow => 'Calculation Window';

  @override
  String get manualOverride => 'Manual Override';

  @override
  String get rulesUsed => 'Rules Used';

  @override
  String get quota => 'Quota';

  @override
  String get mode => 'Mode';

  @override
  String get createAssistancePeriod => 'Create Assistance Period';

  @override
  String get createPeriod => 'Create Period';

  @override
  String get creating => 'Creating...';

  @override
  String get periodInfoStep => 'Period Info';

  @override
  String get rulesQuota => 'Rules & Quota';

  @override
  String get reviewSetup => 'Review Setup';

  @override
  String get allowManualOverrideBelowAttendance =>
      'Allow Manual Override Below Attendance';

  @override
  String get periodNameRequired => 'Period name is required';

  @override
  String get addRule => 'Add Rule';

  @override
  String get allocation => 'Allocation';

  @override
  String get dateRange => 'Date Range';

  @override
  String get allowed => 'Allowed';

  @override
  String get notAllowed => 'Not allowed';

  @override
  String monthsCount(Object count) {
    return '$count months';
  }

  @override
  String get manual => 'Manual';

  @override
  String get auto => 'Auto';

  @override
  String get overAllocated => 'Over allocated';

  @override
  String get autoTarget => 'Auto Target';

  @override
  String get saveTargetPlan => 'Save Target Plan';

  @override
  String get targetPlanSaved => 'Target plan saved.';

  @override
  String get autoTargetsGenerated =>
      'Auto targets generated. Click Save Target Plan to commit.';

  @override
  String get autoTargetFailed => 'Auto Target Failed';

  @override
  String get selectStudents => 'Select Students';

  @override
  String get removeAll => 'Remove All';

  @override
  String get parameterSubtitle =>
      'Academic, teaching, assistance, and system parameters.';

  @override
  String get noPermissionViewParameters =>
      'You do not have permission to view parameters.';

  @override
  String get academicParameters => 'Academic';

  @override
  String get teachingParameters => 'Teaching';

  @override
  String get systemParameters => 'System';

  @override
  String get schools => 'Schools';

  @override
  String get curriculum => 'Curriculum';

  @override
  String get syllabus => 'Syllabus';

  @override
  String get units => 'Units';

  @override
  String get competencies => 'Competencies';

  @override
  String get strategies => 'Strategies';

  @override
  String get programs => 'Programs';

  @override
  String get rules => 'Rules';

  @override
  String get reports => 'Reports';

  @override
  String get config => 'Config';

  @override
  String get systemConfig => 'System Config';

  @override
  String get configDescription =>
      'Manage system-wide parameter settings used across the application.';

  @override
  String get reportDefinitionsDescription =>
      'Maintain dynamic report definitions used by the Reports menu.';

  @override
  String get parameterDefaultDescription =>
      'Maintain parameter data used by Edukita modules.';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving';

  @override
  String get noPermissionUpdateParameters =>
      'You do not have permission to update parameters.';

  @override
  String get systemConfigSaved => 'System config saved.';

  @override
  String get examTypeNamesUnique => 'Exam type names must be unique.';

  @override
  String get numbering => 'Numbering';

  @override
  String get numberingDescription =>
      'Default prefixes for generated codes. Existing records are not changed.';

  @override
  String get studentPrefix => 'Student Prefix';

  @override
  String get teacherPrefix => 'Teacher Prefix';

  @override
  String get reportPrefix => 'Report Prefix';

  @override
  String get attendanceStatuses => 'Attendance Statuses';

  @override
  String get attendanceStatusesDescription =>
      'Operational attendance statuses available for teaching reports and dashboard summaries.';

  @override
  String get approvalExportLabels => 'Approval & Export Labels';

  @override
  String get approvalExportLabelsDescription =>
      'Labels used in assistance approval documents and report signature areas.';

  @override
  String get assistanceApproval => 'Assistance Approval';

  @override
  String get reportSignatures => 'Report Signatures';

  @override
  String get preparedLabel => 'Prepared Label';

  @override
  String get reviewedLabel => 'Reviewed Label';

  @override
  String get approvedLabel => 'Approved Label';

  @override
  String get dateLabel => 'Date Label';

  @override
  String get examTypes => 'Exam Types';

  @override
  String get examTypesDescription =>
      'External school score types. Evidence can be required for important formal exams.';

  @override
  String get evidence => 'Evidence';

  @override
  String get evidenceRequiredTooltip =>
      'Require uploaded evidence when adding this score type';

  @override
  String get examTypeActiveTooltip =>
      'Show this exam type in score input options';

  @override
  String get reportsChooseDefinition =>
      'Choose a report definition to preview and export data.';

  @override
  String get noPermissionViewReports =>
      'You do not have permission to view reports.';

  @override
  String reportRowsLoaded(Object name, Object count) {
    return '$name | $count rows loaded';
  }

  @override
  String get refreshReports => 'Refresh reports';

  @override
  String get run => 'Run';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get availableReports => 'Available Reports';

  @override
  String get searchCodeOrName => 'Search code or name';

  @override
  String get noActiveReportSettings =>
      'No active report settings. Add reports from Parameter > System > Reports.';

  @override
  String get noReportsMatchSearch => 'No reports match your search.';

  @override
  String get selectReport => 'Select Report';

  @override
  String get selectReportMessage =>
      'Choose a report from the left panel to preview its data.';

  @override
  String get searchLoadedRows => 'Search loaded rows';

  @override
  String get noDataLoaded => 'No Data Loaded';

  @override
  String get clickRunReportPreview =>
      'Click Run to execute this report and show the preview.';

  @override
  String get noRowsMatchSearch => 'No rows match the current search';

  @override
  String get failedRunReport => 'Failed to run report';

  @override
  String get noPermissionExportReports =>
      'You do not have permission to export reports.';

  @override
  String get reportExported => 'Report exported.';

  @override
  String get failedExportReport => 'Failed to export report';

  @override
  String get reportSettings => 'Report Settings';

  @override
  String get reportSettingsSubtitle =>
      'Maintain dynamic report definitions, file names, SQL queries, and column display settings.';

  @override
  String get addReport => 'Add Report';

  @override
  String get searchReportNameCodeDescription =>
      'Search report name, code, description';

  @override
  String get noReportSettings => 'No report settings found';

  @override
  String get codeReportName => 'Code\nReport Name';

  @override
  String get fileName => 'File Name';

  @override
  String get columns => 'Columns';

  @override
  String columnsCount(Object count) {
    return '$count columns';
  }

  @override
  String columnsMissingCount(Object count, Object missing) {
    return '$count columns, $missing missing';
  }

  @override
  String get editReport => 'Edit report';

  @override
  String get deleteReportSetting => 'Delete report setting';

  @override
  String get noPermissionUpdateReportSettings =>
      'You do not have permission to update report settings.';

  @override
  String get noPermissionDeleteReportSettings =>
      'You do not have permission to delete report settings.';

  @override
  String get reportSettingActivated => 'Report setting activated.';

  @override
  String get reportSettingDeactivated => 'Report setting deactivated.';

  @override
  String get failedUpdateReport => 'Failed to update report';

  @override
  String get deleteReportSettingTitle => 'Delete Report Setting';

  @override
  String deleteReportSettingMessage(Object name) {
    return 'Delete $name? This removes the report from Parameter and the Reports menu.';
  }

  @override
  String get failedDeleteReport => 'Failed to delete report';

  @override
  String get addReportSetting => 'Add Report Setting';

  @override
  String get editReportSetting => 'Edit Report Setting';

  @override
  String get reportNameRequired => 'Report name is required';

  @override
  String get reportFileNameRequired => 'Report file name is required';

  @override
  String get reportName => 'Report Name';

  @override
  String get reportFileName => 'Report File Name';

  @override
  String get reportCode => 'Report Code';

  @override
  String get autoGenerated => 'Auto generated';

  @override
  String get descriptionHint => 'Short purpose of this report';

  @override
  String get querySql => 'Query SQL';

  @override
  String get columnSettings => 'Column Settings';

  @override
  String get detectColumns => 'Detect Columns';

  @override
  String get reportQueryRequired => 'Report query is required';

  @override
  String get readOnlySelectQuery => 'Read-only SELECT query';

  @override
  String get reportQueryHelp =>
      'Only one SELECT statement is allowed. When this field loses focus, new columns are added automatically and existing labels are preserved.';

  @override
  String configuredColumns(Object count) {
    return '$count configured columns';
  }

  @override
  String removeMissingColumns(Object count) {
    return 'Remove Missing ($count)';
  }

  @override
  String get noReportColumnsYet =>
      'No columns yet. Input a query, then leave the query field or click Detect Columns.';

  @override
  String get inputQueryFirst => 'Input query first.';

  @override
  String columnsSynchronizedAdded(Object count) {
    return 'Columns synchronized. $count new column(s) added.';
  }

  @override
  String columnsSynchronizedMissing(Object added, Object missing) {
    return 'Columns synchronized. $added added, $missing marked missing.';
  }

  @override
  String get invalidReportQuery => 'Invalid report query';

  @override
  String get failedSaveReport => 'Failed to save report';

  @override
  String get reportSettingSubject => 'report setting';

  @override
  String get field => 'Field';

  @override
  String get columnLabel => 'Label';

  @override
  String get labelRequired => 'Label is required';

  @override
  String get align => 'Align';

  @override
  String get width => 'Width';

  @override
  String get show => 'Show';

  @override
  String get missing => 'Missing';

  @override
  String get missingColumnTooltip =>
      'This configured column is not returned by the current query.';

  @override
  String get exportColumn => 'Export';

  @override
  String get exportedAt => 'Exported At';

  @override
  String get totalRows => 'Total Rows';

  @override
  String get logoutTitle => 'Logout?';

  @override
  String get logoutMessage => 'You will return to the login screen.';

  @override
  String get noPermissionCreateUsers =>
      'You do not have permission to create users.';

  @override
  String get noPermissionUpdateUsers =>
      'You do not have permission to update users.';

  @override
  String get noPermissionToggleUsers =>
      'You do not have permission to activate or deactivate users.';

  @override
  String get noPermissionViewUserManagement =>
      'You do not have permission to view user management.';

  @override
  String get userManagementSubtitleAdmin =>
      'Manage users, role permissions, teacher links, and special access.';

  @override
  String get userManagementSubtitleStandard =>
      'Manage app users, teacher links, and extra menu access.';

  @override
  String get addUser => 'Add User';

  @override
  String get usersTab => 'Users';

  @override
  String get rolesPermissions => 'Roles & Permissions';

  @override
  String get searchUsersHint => 'Search username, full name, or teacher';

  @override
  String get user => 'User';

  @override
  String get teacherLink => 'Teacher Link';

  @override
  String get extraAccess => 'Extra Access';

  @override
  String extraAccessCount(Object count) {
    return '$count menu(s)';
  }

  @override
  String get editUserTooltip => 'Edit user';

  @override
  String get activateUser => 'Activate User';

  @override
  String get deactivateUser => 'Deactivate User';

  @override
  String activateUserConfirm(Object name) {
    return 'Activate $name?';
  }

  @override
  String deactivateUserConfirm(Object name) {
    return 'Deactivate $name?';
  }

  @override
  String get rolesPermissionsSubtitle =>
      'Admin always has full access. Configure menu actions for Staff and Teacher roles.';

  @override
  String rolePermissionsUpdated(Object role) {
    return '$role permissions updated.';
  }

  @override
  String get noMenuAvailable => 'No menu available';

  @override
  String get menuColumn => 'Menu';

  @override
  String get createUser => 'Create User';

  @override
  String get editUser => 'Edit User';

  @override
  String get updateUser => 'Update User';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get leaveEmptyToKeep => 'Leave empty to keep';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 4 characters';

  @override
  String get passwordMinLengthSix => 'Password must be at least 6 characters';

  @override
  String get passwordMaxLength => 'Password must be at most 64 characters';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleStaff => 'Staff';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get teacherRequired => 'Teacher is required';

  @override
  String get extraMenuAccess => 'Extra Menu Access';

  @override
  String get noExtraMenuAccess =>
      'No extra menu access available for this role.';

  @override
  String get userCreated => 'User created.';

  @override
  String get userUpdated => 'User updated.';

  @override
  String get linkedTeacher => 'Linked teacher';

  @override
  String requiredField(Object field) {
    return '$field is required';
  }

  @override
  String fieldTooShort(Object field) {
    return '$field is too short';
  }

  @override
  String get permissionView => 'View';

  @override
  String get permissionCreate => 'Create';

  @override
  String get permissionUpdate => 'Update';

  @override
  String get permissionDelete => 'Delete';

  @override
  String get permissionExport => 'Export';

  @override
  String get permissionApprove => 'Approve';

  @override
  String get login => 'Login';

  @override
  String get foundationName => 'Foundation Name';

  @override
  String get exportFilePrefix => 'Export File Prefix';

  @override
  String get currencyCode => 'Currency Code';

  @override
  String get currencySymbol => 'Currency Symbol';

  @override
  String get defaultMinimumAttendance => 'Default Minimum Attendance';

  @override
  String get defaultDashboardRange => 'Default Dashboard Range';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get threeMonths => '3 Months';

  @override
  String get sixMonths => '6 Months';

  @override
  String get oneYear => '1 Year';

  @override
  String get storage => 'Storage';

  @override
  String get storageDescription =>
      'Current local database and uploaded document storage locations.';

  @override
  String get database => 'Database';

  @override
  String get uploads => 'Uploads';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get maintenanceDescription =>
      'Tools for local desktop operation. Backup creates a copy of the SQLite database.';

  @override
  String get backingUp => 'Backing Up';

  @override
  String get backupDatabase => 'Backup Database';

  @override
  String get clearCache => 'Clear Cache';

  @override
  String get minimize => 'Minimize';

  @override
  String get maximize => 'Maximize';

  @override
  String get restore => 'Restore';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get remove => 'Remove';

  @override
  String get clear => 'Clear';

  @override
  String get refresh => 'Refresh';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get continueLabel => 'Continue';

  @override
  String get browse => 'Browse';

  @override
  String get uploadedBy => 'Uploaded By';

  @override
  String get remarks => 'Remarks';

  @override
  String get reject => 'Reject';

  @override
  String get addSelected => 'Add Selected';

  @override
  String get optional => 'Optional';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get clearDate => 'Clear date';

  @override
  String get assessmentNote => 'Assessment Note';

  @override
  String get saveNotes => 'Save Notes';

  @override
  String get noCandidatesSelected => 'No candidates selected yet.';

  @override
  String get removeTarget => 'Remove target';

  @override
  String get removeTargetCandidateTitle => 'Remove Target Candidate?';

  @override
  String get removeAllTargetCandidatesTitle => 'Remove All Target Candidates?';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get markAsSubmitted => 'Mark as Submitted';

  @override
  String get rejectPeriod => 'Reject Period';

  @override
  String get rejectAssistancePeriodTitle => 'Reject Assistance Period?';

  @override
  String get searchRecipientOrRule => 'Search recipient or rule';

  @override
  String get cancelRecipient => 'Cancel recipient';

  @override
  String get resetStatus => 'Reset status';

  @override
  String get handledBy => 'Handled By';

  @override
  String get cancelPeriod => 'Cancel Period';

  @override
  String get cancelRecipientDistribution => 'Cancel Recipient Distribution';

  @override
  String get cancellationReason => 'Cancellation reason';

  @override
  String get cancelAssistancePeriodTitle => 'Cancel Assistance Period?';

  @override
  String get removeZeroQuotaRulesTitle => 'Remove zero quota rules?';

  @override
  String get removeContinue => 'Remove & Continue';

  @override
  String get selectAssistanceRule => 'Select Assistance Rule';

  @override
  String get addCustomRule => 'Add Custom Rule';

  @override
  String get addPeriod => 'Add Period';

  @override
  String get editPeriod => 'Edit period';

  @override
  String get noAssistanceRules => 'No assistance rules yet';

  @override
  String get noStudentAssistanceRules => 'No student assistance rules yet';

  @override
  String get deleteStudentRule => 'Delete Student Rule';

  @override
  String get deleteAllocationRule => 'Delete Allocation Rule';

  @override
  String get regenerateAssistancePlan => 'Regenerate Assistance Plan?';

  @override
  String get generate => 'Generate';

  @override
  String get saveTargetAssistance => 'Save Target Assistance';

  @override
  String get createPeriodFirst => 'Create a period first.';

  @override
  String get noRuleAllocation => 'No rule allocation yet';

  @override
  String get targetStatus => 'Target Status';

  @override
  String get ruleType => 'Rule Type';

  @override
  String get noTargetCandidates => 'No target candidates yet';

  @override
  String get exportAssistancePlan => 'Export assistance plan';

  @override
  String get downloadRecipientsHistory => 'Download recipients history';

  @override
  String get noApprovedRecipients => 'No approved recipients yet';

  @override
  String get selectPeriodFirst => 'Select a period first.';

  @override
  String get chooseFile => 'Choose File';

  @override
  String get uploading => 'Uploading...';

  @override
  String get uploadApprove => 'Upload & Approve';

  @override
  String get assistancePeriod => 'Assistance Period';

  @override
  String get month => 'Month';

  @override
  String get calculationWindowMonths => 'Calculation Window (months)';

  @override
  String get minimumAttendancePercent => 'Minimum Attendance (%)';

  @override
  String get allowManagerOverride => 'Allow manager override below attendance';

  @override
  String get ruleMaster => 'Rule Master';

  @override
  String get ruleName => 'Rule Name';

  @override
  String get priorityOrder => 'Priority Order';

  @override
  String get selectionMode => 'Selection Mode';

  @override
  String get minimumScoreOptional => 'Minimum Score (optional)';

  @override
  String get carryUnusedQuota => 'Carry unused quota to next rule';

  @override
  String get active => 'Active';

  @override
  String get scoreOverrideOptional => 'Score Override (optional)';

  @override
  String get priorityLevel => 'Priority Level';

  @override
  String get priorityReason => 'Priority Reason';

  @override
  String get specialCaseNote => 'Special Case Note';

  @override
  String get approvedAmountSupport => 'Approved Amount or Support';

  @override
  String get deleteStrategyTitle => 'Delete Strategy';

  @override
  String get deleteStrategyConfirm =>
      'Are you sure you want to delete this strategy?';

  @override
  String get noStrategiesYet => 'No strategies yet. Add a strategy.';

  @override
  String get addSchool => 'Add School';

  @override
  String get addClass => 'Add Class';

  @override
  String get deleteClass => 'Delete Class';

  @override
  String get deleteSchool => 'Delete School';

  @override
  String get searchSchoolName => 'Search school name';

  @override
  String get noClassesForSchool => 'No classes for this school.';

  @override
  String get noClassesYet => 'No classes yet. Add a class.';

  @override
  String get changeSchoolType => 'Change School Type';

  @override
  String get keepType => 'Keep Type';

  @override
  String get removeClasses => 'Remove Classes';

  @override
  String get clearClasses => 'Clear Classes';

  @override
  String get clearAll => 'Clear All';

  @override
  String get generateClassesTooltip => 'Generate all levels with section A/B/C';

  @override
  String get section => 'Section';

  @override
  String get noCurriculumsFound => 'No curriculums found';

  @override
  String get noSyllabusFound => 'No syllabus found';

  @override
  String get noSubjectsFound => 'No subjects found';

  @override
  String get noUnitsFound => 'No units found';

  @override
  String get noCompetenciesFound => 'No competencies found';

  @override
  String get noStrategiesFound => 'No strategies found';

  @override
  String get downloadSample => 'Download sample';

  @override
  String get selectVisible => 'Select Visible';

  @override
  String applySelectedCount(Object count) {
    return 'Apply ($count)';
  }

  @override
  String get saveSelected => 'Save Selected';

  @override
  String get lessonCompletion => 'Lesson completion';

  @override
  String get selectCompletion => 'Select completion';

  @override
  String get noStudentNotesYet => 'No student notes yet.';

  @override
  String get followUpNeeded => 'Follow up needed';

  @override
  String get evidenceFile => 'Evidence File';

  @override
  String get changeScoreTypeTitle => 'Change Score Type?';

  @override
  String get number => 'No';

  @override
  String get classDetails => 'Class Details';

  @override
  String get generatedClassName => 'Class Name (Auto-generated)';

  @override
  String get generatedClassHint => 'Generated from level, section, and year';

  @override
  String get sampleImplementationFile => 'Sample Implementation File';

  @override
  String get allowedDocumentTypes =>
      'Allowed: xls, xlsx, doc, docx, txt, md, pdf';

  @override
  String get deleteClassConfirm =>
      'Are you sure you want to delete this class?';

  @override
  String deleteItemTitle(Object title) {
    return 'Delete $title';
  }

  @override
  String get deleteAnyway => 'Delete Anyway';

  @override
  String deleteItemConfirm(Object subject) {
    return 'Delete this $subject?';
  }

  @override
  String deleteConnectedItemConfirm(Object subject) {
    return 'Delete this $subject? This record is connected to other data.';
  }

  @override
  String get guardians => 'Guardians';

  @override
  String get deleteGuardianTitle => 'Delete Guardian';

  @override
  String get deleteGuardianConfirm =>
      'Are you sure you want to delete this guardian?';

  @override
  String get noGuardiansYet => 'No guardians yet. Add a guardian.';

  @override
  String get phone => 'Phone';

  @override
  String get minimizeAssistanceMenu => 'Minimize assistance menu';

  @override
  String deleteRuleForStudent(Object student) {
    return 'Delete rule for $student?';
  }

  @override
  String get thisStudent => 'this student';

  @override
  String selectRuleCandidates(Object rule) {
    return 'Select $rule Candidates';
  }

  @override
  String get overrideReasonHint =>
      'Reason / override note for newly selected students';

  @override
  String get customRule => 'Custom Rule';

  @override
  String get dragToReorder => 'Drag to reorder';

  @override
  String get ready => 'Ready';

  @override
  String get rejectedPeriodAuditNotice =>
      'Rejected periods cannot continue to distribution. Target candidates will remain visible for audit.';

  @override
  String get outOfCityExample =>
      'Example: Student is out of city for two months';

  @override
  String get approvedPeriodCancellationHint =>
      'Reason why this approved assistance period is cancelled';

  @override
  String selectStudentsForRule(Object rule) {
    return 'Select Students - $rule';
  }

  @override
  String get ruleNameRequired => 'Rule name is required';

  @override
  String get classNameRequired => 'Class name is required';

  @override
  String get classNameMax40 => 'Class name must be at most 40 characters';

  @override
  String get duplicateClassYear => 'Duplicate class and year';

  @override
  String get levelRequired => 'Level is required';

  @override
  String get sectionRequired => 'Section is required';

  @override
  String get sectionOneLetter => 'Section must be one letter';

  @override
  String get yearRequired => 'Year is required';

  @override
  String get yearFourDigits => 'Year must be 4 digits';

  @override
  String classesForSchool(Object school) {
    return 'Classes - $school';
  }

  @override
  String deleteNamedItem(Object item) {
    return 'Delete $item?';
  }

  @override
  String searchItems(Object item) {
    return 'Search $item';
  }

  @override
  String get schoolsSubtitle =>
      'Manage school profiles and their class structures.';

  @override
  String get noSchoolsYet => 'No schools yet.';

  @override
  String get noSchoolsMatch => 'No schools match your search.';

  @override
  String get version => 'Version';

  @override
  String get effectiveYear => 'Effective Year';

  @override
  String get sequence => 'Sequence';

  @override
  String get sample => 'Sample';

  @override
  String get structure => 'Structure';

  @override
  String get attendanceSectionSubtitle =>
      'Search and mark attendance in the table.';

  @override
  String get assessmentSectionSubtitle =>
      'Fill scores for the selected session assessment type.';

  @override
  String get materialCovered => 'Material covered';

  @override
  String get classCondition => 'Class condition';

  @override
  String get teachingChallenges => 'Teaching challenges';

  @override
  String get followUpPlan => 'Follow up plan';

  @override
  String get studentNotesReviewSubtitle =>
      'Review social observations added from student assessment rows.';

  @override
  String get socialBehaviorRating => 'Social / behavior rating';

  @override
  String get followUpNotes => 'Follow up notes';

  @override
  String get settingsSubtitle => 'Manage preferences and application settings.';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get uiDensity => 'UI Density';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get timeFormat => 'Time Format';

  @override
  String get numberFormat => 'Number Format';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get followSystem => 'Follow System';

  @override
  String get compact => 'Compact';

  @override
  String get normal => 'Normal';

  @override
  String get comfortable => 'Comfortable';

  @override
  String get indonesian => 'Indonesian';

  @override
  String get englishUs => 'English US';

  @override
  String get rank => 'Rank';

  @override
  String get eligibility => 'Eligibility';

  @override
  String get file => 'File';

  @override
  String get uploadedAt => 'Uploaded At';

  @override
  String get distributionProof => 'Distribution Proof';

  @override
  String get pendingRecipientStatus => 'Pending Recipient Status';

  @override
  String get noRecipientsYet =>
      'No recipients yet. Upload approval document first.';

  @override
  String get noRecipientsMatch => 'No recipients match the current filter.';

  @override
  String get markPaid => 'Mark Paid';

  @override
  String get markDistributed => 'Mark Distributed';

  @override
  String get failedRemoveTargets => 'Failed to remove targets';

  @override
  String get reportNotAvailable => 'Report is not available.';

  @override
  String get rejectedPeriodNoDistribution =>
      'Rejected assistance periods do not continue to distribution.';

  @override
  String get approvalRequiredFirst => 'Approval is required first.';

  @override
  String get finalizeDistributionFailed => 'Finalize Distribution Failed';

  @override
  String get createAssistancePeriodFailed => 'Create Assistance Period Failed';

  @override
  String get failedSaveManualTargets => 'Failed to save manual targets';

  @override
  String get selectedTargets => 'Selected Targets';

  @override
  String get waitlistCount => 'Waitlist Count';

  @override
  String get ineligible => 'Ineligible';

  @override
  String get expandAssistanceMenu => 'Expand assistance menu';

  @override
  String get workflow => 'Workflow';

  @override
  String get history => 'History';

  @override
  String get fixed => 'Fixed';

  @override
  String get rolling => 'Rolling';

  @override
  String get window => 'Window';

  @override
  String get defaultLabel => 'Default';

  @override
  String get priority => 'Priority';

  @override
  String get improve => 'Improve';

  @override
  String get bonus => 'Bonus';

  @override
  String get monthYear => 'Month/Year';

  @override
  String get approvedBy => 'Approved By';

  @override
  String get document => 'Document';

  @override
  String get targetedAt => 'Targeted At';

  @override
  String get newCustomRule => 'New Custom Rule';

  @override
  String get failedUpdateCandidates => 'Failed to update candidates';

  @override
  String get all => 'All';

  @override
  String get allocated => 'Allocated';

  @override
  String get code => 'Code';

  @override
  String get change => 'Change';

  @override
  String get failed => 'Failed';

  @override
  String get createClass => 'Create Class';

  @override
  String get updateClass => 'Update Class';

  @override
  String errorWithDetails(Object details) {
    return 'Error: $details';
  }
}
