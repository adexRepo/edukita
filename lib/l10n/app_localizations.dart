import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Edukita'**
  String get appName;

  /// No description provided for @menuDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get menuDashboard;

  /// No description provided for @menuStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get menuStudents;

  /// No description provided for @menuTeachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get menuTeachers;

  /// No description provided for @menuSyllabus.
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get menuSyllabus;

  /// No description provided for @menuStrategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get menuStrategy;

  /// No description provided for @menuSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get menuSchedule;

  /// No description provided for @menuReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get menuReports;

  /// No description provided for @menuManagement.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get menuManagement;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuTeachingActivity.
  ///
  /// In en, this message translates to:
  /// **'Teaching Activity'**
  String get menuTeachingActivity;

  /// No description provided for @menuParameter.
  ///
  /// In en, this message translates to:
  /// **'Parameter'**
  String get menuParameter;

  /// No description provided for @menuAssistancePrograms.
  ///
  /// In en, this message translates to:
  /// **'Assistance Programs'**
  String get menuAssistancePrograms;

  /// No description provided for @menuUserManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get menuUserManagement;

  /// No description provided for @menuPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get menuPreferences;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @bahasaIndonesia.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get bahasaIndonesia;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated successfully'**
  String get languageUpdated;

  /// No description provided for @rejectedBy.
  ///
  /// In en, this message translates to:
  /// **'Rejected By'**
  String get rejectedBy;

  /// No description provided for @rejectedAt.
  ///
  /// In en, this message translates to:
  /// **'Rejected At'**
  String get rejectedAt;

  /// No description provided for @rejectionReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Rejection reason is required.'**
  String get rejectionReasonRequired;

  /// No description provided for @downloadApprovalDocument.
  ///
  /// In en, this message translates to:
  /// **'Download Approval Document'**
  String get downloadApprovalDocument;

  /// No description provided for @personalization.
  ///
  /// In en, this message translates to:
  /// **'Personalization'**
  String get personalization;

  /// No description provided for @personalizationDescription.
  ///
  /// In en, this message translates to:
  /// **'User-facing preferences for language, visual density, and date or number display.'**
  String get personalizationDescription;

  /// No description provided for @generalDefaults.
  ///
  /// In en, this message translates to:
  /// **'General Defaults'**
  String get generalDefaults;

  /// No description provided for @generalDefaultsDescription.
  ///
  /// In en, this message translates to:
  /// **'These values are used as application-wide defaults for exports, currency labels, and eligibility rules.'**
  String get generalDefaultsDescription;

  /// No description provided for @technicalSettingsAdminOnly.
  ///
  /// In en, this message translates to:
  /// **'Technical settings below are visible to admin users only.'**
  String get technicalSettingsAdminOnly;

  /// No description provided for @buttonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get buttonSave;

  /// No description provided for @buttonSaveAndRefresh.
  ///
  /// In en, this message translates to:
  /// **'Save & Refresh'**
  String get buttonSaveAndRefresh;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get buttonEdit;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get buttonRemove;

  /// No description provided for @buttonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get buttonAdd;

  /// No description provided for @buttonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get buttonSearch;

  /// No description provided for @buttonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get buttonReset;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get buttonConfirm;

  /// No description provided for @buttonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get buttonBack;

  /// No description provided for @buttonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get buttonNext;

  /// No description provided for @buttonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get buttonContinue;

  /// No description provided for @buttonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get buttonSaving;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusTargeted.
  ///
  /// In en, this message translates to:
  /// **'Targeted'**
  String get statusTargeted;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusDistributed.
  ///
  /// In en, this message translates to:
  /// **'Distributed'**
  String get statusDistributed;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @attendancePresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendancePresent;

  /// No description provided for @attendanceAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceAbsent;

  /// No description provided for @attendanceSick.
  ///
  /// In en, this message translates to:
  /// **'Sick'**
  String get attendanceSick;

  /// No description provided for @attendancePermission.
  ///
  /// In en, this message translates to:
  /// **'Permission'**
  String get attendancePermission;

  /// No description provided for @attendanceLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceLate;

  /// No description provided for @studentName.
  ///
  /// In en, this message translates to:
  /// **'Student Name'**
  String get studentName;

  /// No description provided for @studentCode.
  ///
  /// In en, this message translates to:
  /// **'Student Code'**
  String get studentCode;

  /// No description provided for @teacherName.
  ///
  /// In en, this message translates to:
  /// **'Teacher Name'**
  String get teacherName;

  /// No description provided for @className.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get className;

  /// No description provided for @school.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get school;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @competency.
  ///
  /// In en, this message translates to:
  /// **'Competency'**
  String get competency;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @checkIn.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get checkIn;

  /// No description provided for @scheduleDate.
  ///
  /// In en, this message translates to:
  /// **'Schedule Date'**
  String get scheduleDate;

  /// No description provided for @scheduleCalendar.
  ///
  /// In en, this message translates to:
  /// **'Schedule Calendar'**
  String get scheduleCalendar;

  /// No description provided for @scheduleHeaderSummary.
  ///
  /// In en, this message translates to:
  /// **'{scheduleCount} teaching schedules, {eventCount} events'**
  String scheduleHeaderSummary(Object scheduleCount, Object eventCount);

  /// No description provided for @scheduleAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view schedules.'**
  String get scheduleAccessDenied;

  /// No description provided for @scheduleCreateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to create schedules.'**
  String get scheduleCreateDenied;

  /// No description provided for @scheduleUpdateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update this schedule.'**
  String get scheduleUpdateDenied;

  /// No description provided for @scheduleDeleteDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to delete this schedule.'**
  String get scheduleDeleteDenied;

  /// No description provided for @eventCreateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to create events.'**
  String get eventCreateDenied;

  /// No description provided for @eventUpdateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update events.'**
  String get eventUpdateDenied;

  /// No description provided for @eventDeleteDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to delete events.'**
  String get eventDeleteDenied;

  /// No description provided for @userNotLinkedTeacher.
  ///
  /// In en, this message translates to:
  /// **'Your user is not linked to a teacher profile.'**
  String get userNotLinkedTeacher;

  /// No description provided for @refreshSchedules.
  ///
  /// In en, this message translates to:
  /// **'Refresh schedules'**
  String get refreshSchedules;

  /// No description provided for @findScheduleHint.
  ///
  /// In en, this message translates to:
  /// **'Find schedule, event, teacher, level'**
  String get findScheduleHint;

  /// No description provided for @addScheduleOrEvent.
  ///
  /// In en, this message translates to:
  /// **'Add schedule or event'**
  String get addScheduleOrEvent;

  /// No description provided for @teachingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Teaching schedule'**
  String get teachingSchedule;

  /// No description provided for @schoolEvent.
  ///
  /// In en, this message translates to:
  /// **'School event'**
  String get schoolEvent;

  /// No description provided for @otherEvent.
  ///
  /// In en, this message translates to:
  /// **'Other event'**
  String get otherEvent;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @noSchoolEventOnDate.
  ///
  /// In en, this message translates to:
  /// **'No school event on this date.'**
  String get noSchoolEventOnDate;

  /// No description provided for @noTeacherAssigned.
  ///
  /// In en, this message translates to:
  /// **'No teacher assigned'**
  String get noTeacherAssigned;

  /// No description provided for @noMatchingSchedule.
  ///
  /// In en, this message translates to:
  /// **'No matching schedule or event.'**
  String get noMatchingSchedule;

  /// No description provided for @deleteSchedule.
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule'**
  String get deleteSchedule;

  /// No description provided for @deleteEvent.
  ///
  /// In en, this message translates to:
  /// **'Delete Event'**
  String get deleteEvent;

  /// No description provided for @deleteScheduleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteScheduleConfirm(Object name);

  /// No description provided for @deleteEventConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteEventConfirm(Object name);

  /// No description provided for @thisSchedule.
  ///
  /// In en, this message translates to:
  /// **'this schedule'**
  String get thisSchedule;

  /// No description provided for @addSchedule.
  ///
  /// In en, this message translates to:
  /// **'Add Schedule'**
  String get addSchedule;

  /// No description provided for @editSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Schedule'**
  String get editSchedule;

  /// No description provided for @addEvent.
  ///
  /// In en, this message translates to:
  /// **'Add Event'**
  String get addEvent;

  /// No description provided for @editEvent.
  ///
  /// In en, this message translates to:
  /// **'Edit Event'**
  String get editEvent;

  /// No description provided for @eventName.
  ///
  /// In en, this message translates to:
  /// **'Event Name'**
  String get eventName;

  /// No description provided for @wholeDay.
  ///
  /// In en, this message translates to:
  /// **'Whole day'**
  String get wholeDay;

  /// No description provided for @wholeDaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use when this event takes the full selected day.'**
  String get wholeDaySubtitle;

  /// No description provided for @wholeDayUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Whole day is available only for one-day events.'**
  String get wholeDayUnavailableSubtitle;

  /// No description provided for @endDateAfterStartDate.
  ///
  /// In en, this message translates to:
  /// **'End date must be after start date'**
  String get endDateAfterStartDate;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @cannotSaveSchedule.
  ///
  /// In en, this message translates to:
  /// **'Cannot Save Schedule'**
  String get cannotSaveSchedule;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get updatedAt;

  /// No description provided for @emptyData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get emptyData;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorSomethingWentWrong;

  /// No description provided for @messageDataSaved.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully'**
  String get messageDataSaved;

  /// No description provided for @messageDataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully'**
  String get messageDataUpdated;

  /// No description provided for @messageDataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Data deleted successfully'**
  String get messageDataDeleted;

  /// No description provided for @messageConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this data?'**
  String get messageConfirmDelete;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Foundation education overview and operation snapshot.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh dashboard'**
  String get dashboardRefresh;

  /// No description provided for @dashboardLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get dashboardLevel;

  /// No description provided for @dashboardSelectLevels.
  ///
  /// In en, this message translates to:
  /// **'Select Levels'**
  String get dashboardSelectLevels;

  /// No description provided for @dashboardSelectLevelsDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose one or multiple school levels.'**
  String get dashboardSelectLevelsDescription;

  /// No description provided for @dashboardAllLevels.
  ///
  /// In en, this message translates to:
  /// **'All Levels'**
  String get dashboardAllLevels;

  /// No description provided for @dashboardAllSd.
  ///
  /// In en, this message translates to:
  /// **'All SD'**
  String get dashboardAllSd;

  /// No description provided for @dashboardAllSmp.
  ///
  /// In en, this message translates to:
  /// **'All SMP'**
  String get dashboardAllSmp;

  /// No description provided for @dashboardAllSma.
  ///
  /// In en, this message translates to:
  /// **'All SMA'**
  String get dashboardAllSma;

  /// No description provided for @dashboardUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get dashboardUniversity;

  /// No description provided for @dashboardLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get dashboardLevelLabel;

  /// No description provided for @dashboardClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get dashboardClear;

  /// No description provided for @dashboardApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get dashboardApply;

  /// No description provided for @dashboardActiveStudents.
  ///
  /// In en, this message translates to:
  /// **'Active Students'**
  String get dashboardActiveStudents;

  /// No description provided for @dashboardWithGenderData.
  ///
  /// In en, this message translates to:
  /// **'with gender data'**
  String get dashboardWithGenderData;

  /// No description provided for @dashboardAverageAttendance.
  ///
  /// In en, this message translates to:
  /// **'Avg Attendance'**
  String get dashboardAverageAttendance;

  /// No description provided for @dashboardAttendanceRecords.
  ///
  /// In en, this message translates to:
  /// **'attendance records'**
  String get dashboardAttendanceRecords;

  /// No description provided for @dashboardAverageAcademic.
  ///
  /// In en, this message translates to:
  /// **'Avg Academic'**
  String get dashboardAverageAcademic;

  /// No description provided for @dashboardActiveSubjects.
  ///
  /// In en, this message translates to:
  /// **'active subjects'**
  String get dashboardActiveSubjects;

  /// No description provided for @dashboardTeachingSessions.
  ///
  /// In en, this message translates to:
  /// **'Teaching Sessions'**
  String get dashboardTeachingSessions;

  /// No description provided for @dashboardStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get dashboardStudentsTitle;

  /// No description provided for @dashboardStudentsDescription.
  ///
  /// In en, this message translates to:
  /// **'Active student composition by gender.'**
  String get dashboardStudentsDescription;

  /// No description provided for @dashboardBoys.
  ///
  /// In en, this message translates to:
  /// **'Boys'**
  String get dashboardBoys;

  /// No description provided for @dashboardGirls.
  ///
  /// In en, this message translates to:
  /// **'Girls'**
  String get dashboardGirls;

  /// No description provided for @dashboardAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get dashboardAttendanceTitle;

  /// No description provided for @dashboardRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get dashboardRecords;

  /// No description provided for @dashboardAcademicAverageScore.
  ///
  /// In en, this message translates to:
  /// **'Academic Average Score'**
  String get dashboardAcademicAverageScore;

  /// No description provided for @dashboardSubjectScoreAverage.
  ///
  /// In en, this message translates to:
  /// **'subject score average.'**
  String get dashboardSubjectScoreAverage;

  /// No description provided for @dashboardNoSubjectsYet.
  ///
  /// In en, this message translates to:
  /// **'No subjects yet.'**
  String get dashboardNoSubjectsYet;

  /// No description provided for @dashboardPreviousSubjects.
  ///
  /// In en, this message translates to:
  /// **'Previous subjects'**
  String get dashboardPreviousSubjects;

  /// No description provided for @dashboardNextSubjects.
  ///
  /// In en, this message translates to:
  /// **'Next subjects'**
  String get dashboardNextSubjects;

  /// No description provided for @dashboardSwapSubjects.
  ///
  /// In en, this message translates to:
  /// **'Swap subjects'**
  String get dashboardSwapSubjects;

  /// No description provided for @dashboardStudentProgressTrend.
  ///
  /// In en, this message translates to:
  /// **'Student Progress Trend'**
  String get dashboardStudentProgressTrend;

  /// No description provided for @dashboardProgressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance {attendance}% | Academic {academic}% | Notes {notes}%'**
  String dashboardProgressSubtitle(
    Object attendance,
    Object academic,
    Object notes,
  );

  /// No description provided for @dashboardAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get dashboardAcademic;

  /// No description provided for @dashboardTeacherNotes.
  ///
  /// In en, this message translates to:
  /// **'Teacher Notes'**
  String get dashboardTeacherNotes;

  /// No description provided for @dashboardNoProgressData.
  ///
  /// In en, this message translates to:
  /// **'No progress data is available for this filter yet.'**
  String get dashboardNoProgressData;

  /// No description provided for @dashboardSessionProgress.
  ///
  /// In en, this message translates to:
  /// **'Session Progress'**
  String get dashboardSessionProgress;

  /// No description provided for @dashboardNoTeachingSessionRange.
  ///
  /// In en, this message translates to:
  /// **'No teaching session in this range.'**
  String get dashboardNoTeachingSessionRange;

  /// No description provided for @dashboardSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get dashboardSessions;

  /// No description provided for @dashboardStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get dashboardStatusInProgress;

  /// No description provided for @dashboardUpcomingScheduleThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Schedule This Week'**
  String get dashboardUpcomingScheduleThisWeek;

  /// No description provided for @dashboardUpcomingScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Teaching schedule for the next 7 days'**
  String get dashboardUpcomingScheduleSubtitle;

  /// No description provided for @dashboardNoUpcomingSchedule.
  ///
  /// In en, this message translates to:
  /// **'No upcoming teaching schedule this week.'**
  String get dashboardNoUpcomingSchedule;

  /// No description provided for @dashboardStudentsNeedAttention.
  ///
  /// In en, this message translates to:
  /// **'Students Need Attention'**
  String get dashboardStudentsNeedAttention;

  /// No description provided for @dashboardStudentsNeedAttentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance, score, and follow-up signals'**
  String get dashboardStudentsNeedAttentionSubtitle;

  /// No description provided for @dashboardNoAttentionSignal.
  ///
  /// In en, this message translates to:
  /// **'No attention signal in this range.'**
  String get dashboardNoAttentionSignal;

  /// No description provided for @dashboardTopLearners.
  ///
  /// In en, this message translates to:
  /// **'Top Learners'**
  String get dashboardTopLearners;

  /// No description provided for @dashboardTopLearnersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Academic score and teacher notes ranking'**
  String get dashboardTopLearnersSubtitle;

  /// No description provided for @dashboardTopLearnersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Points = 65% academic average + 35% teacher note score.\nNote score is scaled from 0-5 stars to 0-100.'**
  String get dashboardTopLearnersTooltip;

  /// No description provided for @dashboardNoLearnerScore.
  ///
  /// In en, this message translates to:
  /// **'No academic or teacher note score is available yet.'**
  String get dashboardNoLearnerScore;

  /// No description provided for @dashboardPointsShort.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get dashboardPointsShort;

  /// No description provided for @dashboardRecentTeacherNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent Teacher Notes'**
  String get dashboardRecentTeacherNotes;

  /// No description provided for @dashboardNoTeacherNotes.
  ///
  /// In en, this message translates to:
  /// **'No teacher notes in this range.'**
  String get dashboardNoTeacherNotes;

  /// No description provided for @rangeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get rangeWeekly;

  /// No description provided for @rangeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rangeMonthly;

  /// No description provided for @rangeThreeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get rangeThreeMonths;

  /// No description provided for @rangeSixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get rangeSixMonths;

  /// No description provided for @rangeOneYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get rangeOneYear;

  /// No description provided for @teachingActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Teaching Activity'**
  String get teachingActivityTitle;

  /// No description provided for @teachingActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open scheduled classes, record attendance, notes, and teaching results.'**
  String get teachingActivitySubtitle;

  /// No description provided for @teachingActivityError.
  ///
  /// In en, this message translates to:
  /// **'Teaching Activity Error'**
  String get teachingActivityError;

  /// No description provided for @teachingActivityAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view teaching activities.'**
  String get teachingActivityAccessDenied;

  /// No description provided for @teachingReportAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view teaching reports.'**
  String get teachingReportAccessDenied;

  /// No description provided for @teachingActivityNotFound.
  ///
  /// In en, this message translates to:
  /// **'Teaching activity not found.'**
  String get teachingActivityNotFound;

  /// No description provided for @teachingReportNoAccess.
  ///
  /// In en, this message translates to:
  /// **'You do not have access to this teaching report.'**
  String get teachingReportNoAccess;

  /// No description provided for @backToTeachingActivity.
  ///
  /// In en, this message translates to:
  /// **'Back to Teaching Activity'**
  String get backToTeachingActivity;

  /// No description provided for @allTeachers.
  ///
  /// In en, this message translates to:
  /// **'All teachers'**
  String get allTeachers;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All levels'**
  String get allLevels;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All status'**
  String get allStatus;

  /// No description provided for @noTeachingSessionsFilter.
  ///
  /// In en, this message translates to:
  /// **'No teaching sessions for this filter.'**
  String get noTeachingSessionsFilter;

  /// No description provided for @unitMaterial.
  ///
  /// In en, this message translates to:
  /// **'Unit / Material'**
  String get unitMaterial;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @selectedDate.
  ///
  /// In en, this message translates to:
  /// **'Selected Date'**
  String get selectedDate;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @session.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get session;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @startClass.
  ///
  /// In en, this message translates to:
  /// **'Start Class'**
  String get startClass;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @viewDetail.
  ///
  /// In en, this message translates to:
  /// **'View Detail'**
  String get viewDetail;

  /// No description provided for @cancelSession.
  ///
  /// In en, this message translates to:
  /// **'Cancel Session'**
  String get cancelSession;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @replacementNeeded.
  ///
  /// In en, this message translates to:
  /// **'Replacement needed'**
  String get replacementNeeded;

  /// No description provided for @markCancelled.
  ///
  /// In en, this message translates to:
  /// **'Mark Cancelled'**
  String get markCancelled;

  /// No description provided for @teachingSessionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Teaching session cancelled.'**
  String get teachingSessionCancelled;

  /// No description provided for @teachingSessionReport.
  ///
  /// In en, this message translates to:
  /// **'Teaching Session Report'**
  String get teachingSessionReport;

  /// No description provided for @teachingReportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Teaching report completed.'**
  String get teachingReportCompleted;

  /// No description provided for @completeReport.
  ///
  /// In en, this message translates to:
  /// **'Complete Report'**
  String get completeReport;

  /// No description provided for @teachingReportReset.
  ///
  /// In en, this message translates to:
  /// **'Teaching report reset.'**
  String get teachingReportReset;

  /// No description provided for @resetReport.
  ///
  /// In en, this message translates to:
  /// **'Reset Report'**
  String get resetReport;

  /// No description provided for @sessionNotes.
  ///
  /// In en, this message translates to:
  /// **'Session Notes'**
  String get sessionNotes;

  /// No description provided for @sessionOverview.
  ///
  /// In en, this message translates to:
  /// **'Session Overview'**
  String get sessionOverview;

  /// No description provided for @sessionOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Teaching session details and completion summary.'**
  String get sessionOverviewSubtitle;

  /// No description provided for @sessionNote.
  ///
  /// In en, this message translates to:
  /// **'Session Note'**
  String get sessionNote;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @teacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacher;

  /// No description provided for @strategy.
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get strategy;

  /// No description provided for @assessment.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get assessment;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @assessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get assessments;

  /// No description provided for @studentNotes.
  ///
  /// In en, this message translates to:
  /// **'Student Notes'**
  String get studentNotes;

  /// No description provided for @completion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get completion;

  /// No description provided for @editSessionNote.
  ///
  /// In en, this message translates to:
  /// **'Edit session note'**
  String get editSessionNote;

  /// No description provided for @studentsAttendance.
  ///
  /// In en, this message translates to:
  /// **'Students & Attendance'**
  String get studentsAttendance;

  /// No description provided for @studentsAttendanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a student and mark attendance.'**
  String get studentsAttendanceSubtitle;

  /// No description provided for @searchStudentHint.
  ///
  /// In en, this message translates to:
  /// **'Search student name or number'**
  String get searchStudentHint;

  /// No description provided for @saveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Save attendance'**
  String get saveAttendance;

  /// No description provided for @allPresent.
  ///
  /// In en, this message translates to:
  /// **'All Present'**
  String get allPresent;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @noteHistory.
  ///
  /// In en, this message translates to:
  /// **'Note History'**
  String get noteHistory;

  /// No description provided for @saveReporting.
  ///
  /// In en, this message translates to:
  /// **'Save Reporting'**
  String get saveReporting;

  /// No description provided for @reporting.
  ///
  /// In en, this message translates to:
  /// **'Reporting'**
  String get reporting;

  /// No description provided for @searchStudent.
  ///
  /// In en, this message translates to:
  /// **'Search student'**
  String get searchStudent;

  /// No description provided for @studentSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Name or student no'**
  String get studentSearchHint;

  /// No description provided for @shown.
  ///
  /// In en, this message translates to:
  /// **'shown'**
  String get shown;

  /// No description provided for @noStudentsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No students match the current search.'**
  String get noStudentsMatchSearch;

  /// No description provided for @competencyScores.
  ///
  /// In en, this message translates to:
  /// **'Competency Scores'**
  String get competencyScores;

  /// No description provided for @quizNumericScoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz scores use numeric value 0-100.'**
  String get quizNumericScoreSubtitle;

  /// No description provided for @starAssessmentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Session assessment uses star rating.'**
  String get starAssessmentSubtitle;

  /// No description provided for @selectAssessmentType.
  ///
  /// In en, this message translates to:
  /// **'Select assessment type'**
  String get selectAssessmentType;

  /// No description provided for @noCompetenciesRegistered.
  ///
  /// In en, this message translates to:
  /// **'No competencies registered for this unit.'**
  String get noCompetenciesRegistered;

  /// No description provided for @attendanceNoteRequiredForStudent.
  ///
  /// In en, this message translates to:
  /// **'Attendance note is required for {student}.'**
  String attendanceNoteRequiredForStudent(Object student);

  /// No description provided for @assessmentType.
  ///
  /// In en, this message translates to:
  /// **'Assessment Type'**
  String get assessmentType;

  /// No description provided for @studentNotesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add social observation notes directly by type.'**
  String get studentNotesSubtitle;

  /// No description provided for @attendanceNote.
  ///
  /// In en, this message translates to:
  /// **'Attendance Note'**
  String get attendanceNote;

  /// No description provided for @attendanceNoteRequired.
  ///
  /// In en, this message translates to:
  /// **'Attendance note *'**
  String get attendanceNoteRequired;

  /// No description provided for @attendanceNoteRequiredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required because attendance is Permission.'**
  String get attendanceNoteRequiredSubtitle;

  /// No description provided for @attendanceNoteOptionalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional attendance note for this student.'**
  String get attendanceNoteOptionalSubtitle;

  /// No description provided for @teacherNotesHistory.
  ///
  /// In en, this message translates to:
  /// **'Teacher Notes History'**
  String get teacherNotesHistory;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @resetTeachingReport.
  ///
  /// In en, this message translates to:
  /// **'Reset Teaching Report?'**
  String get resetTeachingReport;

  /// No description provided for @resetTeachingReportMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove all attendance, competency scores, student notes, and session notes for this report.'**
  String get resetTeachingReportMessage;

  /// No description provided for @resetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All'**
  String get resetAll;

  /// No description provided for @changeAssessmentType.
  ///
  /// In en, this message translates to:
  /// **'Change Assessment Type?'**
  String get changeAssessmentType;

  /// No description provided for @changeAssessmentTypeMessage.
  ///
  /// In en, this message translates to:
  /// **'This session already has assessment rows. Changing the type will make the Assessment tab use a different score mode for future entries.'**
  String get changeAssessmentTypeMessage;

  /// No description provided for @changeType.
  ///
  /// In en, this message translates to:
  /// **'Change Type'**
  String get changeType;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get statusInProgress;

  /// No description provided for @teacherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Teacher unavailable'**
  String get teacherUnavailable;

  /// No description provided for @studentGroupUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Student group unavailable'**
  String get studentGroupUnavailable;

  /// No description provided for @publicHoliday.
  ///
  /// In en, this message translates to:
  /// **'Public holiday'**
  String get publicHoliday;

  /// No description provided for @roomUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Room unavailable'**
  String get roomUnavailable;

  /// No description provided for @weatherOrEmergency.
  ///
  /// In en, this message translates to:
  /// **'Weather or emergency'**
  String get weatherOrEmergency;

  /// No description provided for @scheduleMistake.
  ///
  /// In en, this message translates to:
  /// **'Schedule mistake'**
  String get scheduleMistake;

  /// No description provided for @administrativeReason.
  ///
  /// In en, this message translates to:
  /// **'Administrative reason'**
  String get administrativeReason;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @assessmentObservation.
  ///
  /// In en, this message translates to:
  /// **'Observation'**
  String get assessmentObservation;

  /// No description provided for @assessmentExercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get assessmentExercise;

  /// No description provided for @assessmentQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get assessmentQuiz;

  /// No description provided for @assessmentOral.
  ///
  /// In en, this message translates to:
  /// **'Oral'**
  String get assessmentOral;

  /// No description provided for @assessmentPractical.
  ///
  /// In en, this message translates to:
  /// **'Practical'**
  String get assessmentPractical;

  /// No description provided for @assessmentAssignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get assessmentAssignment;

  /// No description provided for @assessmentParticipation.
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get assessmentParticipation;

  /// No description provided for @assessmentMemorization.
  ///
  /// In en, this message translates to:
  /// **'Memorization'**
  String get assessmentMemorization;

  /// No description provided for @assessmentReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get assessmentReading;

  /// No description provided for @noteLearningProgress.
  ///
  /// In en, this message translates to:
  /// **'Learning Progress'**
  String get noteLearningProgress;

  /// No description provided for @noteBehavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get noteBehavior;

  /// No description provided for @noteAttendanceConcern.
  ///
  /// In en, this message translates to:
  /// **'Attendance Concern'**
  String get noteAttendanceConcern;

  /// No description provided for @noteNeedsSupport.
  ///
  /// In en, this message translates to:
  /// **'Needs Support'**
  String get noteNeedsSupport;

  /// No description provided for @noteAchievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get noteAchievement;

  /// No description provided for @noteParentFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Parent Follow Up'**
  String get noteParentFollowUp;

  /// No description provided for @studentDetail.
  ///
  /// In en, this message translates to:
  /// **'Student Detail'**
  String get studentDetail;

  /// No description provided for @studentAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view students.'**
  String get studentAccessDenied;

  /// No description provided for @studentCreateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to create students.'**
  String get studentCreateDenied;

  /// No description provided for @studentUpdateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update students.'**
  String get studentUpdateDenied;

  /// No description provided for @studentDeleteDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to delete students.'**
  String get studentDeleteDenied;

  /// No description provided for @teacherAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view teachers.'**
  String get teacherAccessDenied;

  /// No description provided for @teacherCreateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to create teachers.'**
  String get teacherCreateDenied;

  /// No description provided for @teacherUpdateDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update teachers.'**
  String get teacherUpdateDenied;

  /// No description provided for @teacherDeleteDenied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to delete teachers.'**
  String get teacherDeleteDenied;

  /// No description provided for @addStudent.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudent;

  /// No description provided for @addTeacher.
  ///
  /// In en, this message translates to:
  /// **'Add Teacher'**
  String get addTeacher;

  /// No description provided for @editTeacher.
  ///
  /// In en, this message translates to:
  /// **'Edit Teacher'**
  String get editTeacher;

  /// No description provided for @deleteTeacher.
  ///
  /// In en, this message translates to:
  /// **'Delete Teacher'**
  String get deleteTeacher;

  /// No description provided for @deleteTeacherConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteTeacherConfirm(Object name);

  /// No description provided for @searchTeacherName.
  ///
  /// In en, this message translates to:
  /// **'Search teacher name'**
  String get searchTeacherName;

  /// No description provided for @noTeachersYet.
  ///
  /// In en, this message translates to:
  /// **'No teachers yet. Add a teacher.'**
  String get noTeachersYet;

  /// No description provided for @noTeachersMatch.
  ///
  /// In en, this message translates to:
  /// **'No teachers match your search.'**
  String get noTeachersMatch;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get educationLevel;

  /// No description provided for @appUser.
  ///
  /// In en, this message translates to:
  /// **'App User'**
  String get appUser;

  /// No description provided for @linked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get linked;

  /// No description provided for @noUser.
  ///
  /// In en, this message translates to:
  /// **'No user'**
  String get noUser;

  /// No description provided for @createAppUser.
  ///
  /// In en, this message translates to:
  /// **'Create app user'**
  String get createAppUser;

  /// No description provided for @teacherAlreadyHasAppUser.
  ///
  /// In en, this message translates to:
  /// **'Teacher already has app user'**
  String get teacherAlreadyHasAppUser;

  /// No description provided for @editTeacherTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit teacher'**
  String get editTeacherTooltip;

  /// No description provided for @deleteTeacherTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete teacher'**
  String get deleteTeacherTooltip;

  /// No description provided for @teacherNotFound.
  ///
  /// In en, this message translates to:
  /// **'Teacher not found'**
  String get teacherNotFound;

  /// No description provided for @teacherProfile.
  ///
  /// In en, this message translates to:
  /// **'Teacher Profile'**
  String get teacherProfile;

  /// No description provided for @noSubjectsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No subjects assigned'**
  String get noSubjectsAssigned;

  /// No description provided for @teachingLoad.
  ///
  /// In en, this message translates to:
  /// **'Teaching Load'**
  String get teachingLoad;

  /// No description provided for @teachingHours.
  ///
  /// In en, this message translates to:
  /// **'Teaching Hours'**
  String get teachingHours;

  /// No description provided for @summaryInsight.
  ///
  /// In en, this message translates to:
  /// **'Summary Insight'**
  String get summaryInsight;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @detail.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get detail;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @noManagementAlerts.
  ///
  /// In en, this message translates to:
  /// **'No management alerts detected for this teacher.'**
  String get noManagementAlerts;

  /// No description provided for @impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @studentImpactSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Student Impact Snapshot'**
  String get studentImpactSnapshot;

  /// No description provided for @improved.
  ///
  /// In en, this message translates to:
  /// **'Improved'**
  String get improved;

  /// No description provided for @stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No description provided for @declined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get declined;

  /// No description provided for @up.
  ///
  /// In en, this message translates to:
  /// **'up'**
  String get up;

  /// No description provided for @same.
  ///
  /// In en, this message translates to:
  /// **'same'**
  String get same;

  /// No description provided for @down.
  ///
  /// In en, this message translates to:
  /// **'down'**
  String get down;

  /// No description provided for @needCare.
  ///
  /// In en, this message translates to:
  /// **'Need Care'**
  String get needCare;

  /// No description provided for @studentsUnderCare.
  ///
  /// In en, this message translates to:
  /// **'Students Under Care'**
  String get studentsUnderCare;

  /// No description provided for @scoreTrend.
  ///
  /// In en, this message translates to:
  /// **'Score Trend'**
  String get scoreTrend;

  /// No description provided for @followUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get followUp;

  /// No description provided for @noStudentImpactRows.
  ///
  /// In en, this message translates to:
  /// **'Student impact rows will appear after teaching assessment scores are recorded.'**
  String get noStudentImpactRows;

  /// No description provided for @assignedClassesStudents.
  ///
  /// In en, this message translates to:
  /// **'Assigned Classes & Students'**
  String get assignedClassesStudents;

  /// No description provided for @assignedClassesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Assigned classes will appear here after schedules are linked to this teacher.'**
  String get assignedClassesEmpty;

  /// No description provided for @notesActivity.
  ///
  /// In en, this message translates to:
  /// **'Notes Activity'**
  String get notesActivity;

  /// No description provided for @totalNotes.
  ///
  /// In en, this message translates to:
  /// **'Total Notes'**
  String get totalNotes;

  /// No description provided for @recentTeacherNotes.
  ///
  /// In en, this message translates to:
  /// **'Recent Teacher Notes'**
  String get recentTeacherNotes;

  /// No description provided for @noStudentSessionNotes.
  ///
  /// In en, this message translates to:
  /// **'No student session notes have been recorded by this teacher.'**
  String get noStudentSessionNotes;

  /// No description provided for @editStudent.
  ///
  /// In en, this message translates to:
  /// **'Edit Student'**
  String get editStudent;

  /// No description provided for @deleteStudent.
  ///
  /// In en, this message translates to:
  /// **'Delete Student'**
  String get deleteStudent;

  /// No description provided for @deleteStudentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteStudentConfirm(Object name);

  /// No description provided for @filterStudents.
  ///
  /// In en, this message translates to:
  /// **'Filter Students'**
  String get filterStudents;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @studentProfile.
  ///
  /// In en, this message translates to:
  /// **'Student Profile'**
  String get studentProfile;

  /// No description provided for @classSchool.
  ///
  /// In en, this message translates to:
  /// **'Class\nSchool'**
  String get classSchool;

  /// No description provided for @ageGender.
  ///
  /// In en, this message translates to:
  /// **'Age\nGender'**
  String get ageGender;

  /// No description provided for @scoreStatus.
  ///
  /// In en, this message translates to:
  /// **'Score\nStatus'**
  String get scoreStatus;

  /// No description provided for @joinDate.
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get joinDate;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @editStudentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit student'**
  String get editStudentTooltip;

  /// No description provided for @deleteStudentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete student'**
  String get deleteStudentTooltip;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// No description provided for @personalProfile.
  ///
  /// In en, this message translates to:
  /// **'Personal Profile'**
  String get personalProfile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nickName.
  ///
  /// In en, this message translates to:
  /// **'Nick Name'**
  String get nickName;

  /// No description provided for @nis.
  ///
  /// In en, this message translates to:
  /// **'NIS'**
  String get nis;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @mobileNo.
  ///
  /// In en, this message translates to:
  /// **'Mobile No'**
  String get mobileNo;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @physical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @registrationForm.
  ///
  /// In en, this message translates to:
  /// **'Registration Form'**
  String get registrationForm;

  /// No description provided for @studentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Student Photo'**
  String get studentPhoto;

  /// No description provided for @noPhotoSelected.
  ///
  /// In en, this message translates to:
  /// **'No photo selected'**
  String get noPhotoSelected;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @uploadRegistrationFormHelp.
  ///
  /// In en, this message translates to:
  /// **'Upload signed paper registration form (PDF/JPG/PNG)'**
  String get uploadRegistrationFormHelp;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @removeFile.
  ///
  /// In en, this message translates to:
  /// **'Remove file'**
  String get removeFile;

  /// No description provided for @generatedNo.
  ///
  /// In en, this message translates to:
  /// **'Generated No'**
  String get generatedNo;

  /// No description provided for @selectSchool.
  ///
  /// In en, this message translates to:
  /// **'Select school'**
  String get selectSchool;

  /// No description provided for @selectSchoolFirst.
  ///
  /// In en, this message translates to:
  /// **'Select school first'**
  String get selectSchoolFirst;

  /// No description provided for @selectClass.
  ///
  /// In en, this message translates to:
  /// **'Select class'**
  String get selectClass;

  /// No description provided for @createStudent.
  ///
  /// In en, this message translates to:
  /// **'Create Student'**
  String get createStudent;

  /// No description provided for @updateStudent.
  ///
  /// In en, this message translates to:
  /// **'Update Student'**
  String get updateStudent;

  /// No description provided for @advancedDetail.
  ///
  /// In en, this message translates to:
  /// **'Advanced Detail'**
  String get advancedDetail;

  /// No description provided for @hideAdvancedDetail.
  ///
  /// In en, this message translates to:
  /// **'Hide Advanced Detail'**
  String get hideAdvancedDetail;

  /// No description provided for @studentNumberNotReady.
  ///
  /// In en, this message translates to:
  /// **'Student number is not ready yet.'**
  String get studentNumberNotReady;

  /// No description provided for @photoSizeLimit.
  ///
  /// In en, this message translates to:
  /// **'Photo must be 20 MB or smaller.'**
  String get photoSizeLimit;

  /// No description provided for @registrationFormSizeLimit.
  ///
  /// In en, this message translates to:
  /// **'Registration form must be 20 MB or smaller.'**
  String get registrationFormSizeLimit;

  /// No description provided for @registrationFormRequired.
  ///
  /// In en, this message translates to:
  /// **'Registration form is required.'**
  String get registrationFormRequired;

  /// No description provided for @shoeSize.
  ///
  /// In en, this message translates to:
  /// **'Shoe Size'**
  String get shoeSize;

  /// No description provided for @uniformSize.
  ///
  /// In en, this message translates to:
  /// **'Uniform Size'**
  String get uniformSize;

  /// No description provided for @pantsSize.
  ///
  /// In en, this message translates to:
  /// **'Pants Size'**
  String get pantsSize;

  /// No description provided for @hobby.
  ///
  /// In en, this message translates to:
  /// **'Hobby'**
  String get hobby;

  /// No description provided for @aspiration.
  ///
  /// In en, this message translates to:
  /// **'Aspiration'**
  String get aspiration;

  /// No description provided for @citaCita.
  ///
  /// In en, this message translates to:
  /// **'Cita-cita'**
  String get citaCita;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @siblingRelation.
  ///
  /// In en, this message translates to:
  /// **'Sibling Relation'**
  String get siblingRelation;

  /// No description provided for @addSiblingRelation.
  ///
  /// In en, this message translates to:
  /// **'Add Sibling Relation'**
  String get addSiblingRelation;

  /// No description provided for @guardianParents.
  ///
  /// In en, this message translates to:
  /// **'Guardian / Parents'**
  String get guardianParents;

  /// No description provided for @addParentGuardian.
  ///
  /// In en, this message translates to:
  /// **'Add parent / guardian'**
  String get addParentGuardian;

  /// No description provided for @addGuardian.
  ///
  /// In en, this message translates to:
  /// **'Add Guardian'**
  String get addGuardian;

  /// No description provided for @editGuardian.
  ///
  /// In en, this message translates to:
  /// **'Edit Guardian'**
  String get editGuardian;

  /// No description provided for @primaryGuardian.
  ///
  /// In en, this message translates to:
  /// **'Primary Guardian'**
  String get primaryGuardian;

  /// No description provided for @notPrimary.
  ///
  /// In en, this message translates to:
  /// **'Not Primary'**
  String get notPrimary;

  /// No description provided for @parentGuardianName.
  ///
  /// In en, this message translates to:
  /// **'Parent / Guardian Name'**
  String get parentGuardianName;

  /// No description provided for @extracurricularActivity.
  ///
  /// In en, this message translates to:
  /// **'Extracurricular / Activity'**
  String get extracurricularActivity;

  /// No description provided for @addActivity.
  ///
  /// In en, this message translates to:
  /// **'Add activity'**
  String get addActivity;

  /// No description provided for @editActivity.
  ///
  /// In en, this message translates to:
  /// **'Edit Activity'**
  String get editActivity;

  /// No description provided for @activityName.
  ///
  /// In en, this message translates to:
  /// **'Activity Name'**
  String get activityName;

  /// No description provided for @studentIdNo.
  ///
  /// In en, this message translates to:
  /// **'Student ID / No'**
  String get studentIdNo;

  /// No description provided for @searchSibling.
  ///
  /// In en, this message translates to:
  /// **'Search sibling'**
  String get searchSibling;

  /// No description provided for @hobbyAspiration.
  ///
  /// In en, this message translates to:
  /// **'Hobby & Aspiration'**
  String get hobbyAspiration;

  /// No description provided for @academic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academic;

  /// No description provided for @examScores.
  ///
  /// In en, this message translates to:
  /// **'Exam Scores'**
  String get examScores;

  /// No description provided for @addScoreExam.
  ///
  /// In en, this message translates to:
  /// **'Add Score Exam'**
  String get addScoreExam;

  /// No description provided for @editScoreExam.
  ///
  /// In en, this message translates to:
  /// **'Edit Score Exam'**
  String get editScoreExam;

  /// No description provided for @examScoresDescription.
  ///
  /// In en, this message translates to:
  /// **'School scores are grouped by report/exam and can contain many subjects. Internal scores can contain many units.'**
  String get examScoresDescription;

  /// No description provided for @loadingExamScores.
  ///
  /// In en, this message translates to:
  /// **'Loading exam scores...'**
  String get loadingExamScores;

  /// No description provided for @noExamScores.
  ///
  /// In en, this message translates to:
  /// **'No internal or school exam score has been added.'**
  String get noExamScores;

  /// No description provided for @removeExamScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Exam Score?'**
  String get removeExamScoreTitle;

  /// No description provided for @removeExamScoreMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove {type} score data from this student.'**
  String removeExamScoreMessage(Object type);

  /// No description provided for @scoreAvg.
  ///
  /// In en, this message translates to:
  /// **'Score\nAvg'**
  String get scoreAvg;

  /// No description provided for @scoreAvgTooltip.
  ///
  /// In en, this message translates to:
  /// **'Avg is calculated from each item score divided by max score, then averaged for this exam.'**
  String get scoreAvgTooltip;

  /// No description provided for @internal.
  ///
  /// In en, this message translates to:
  /// **'Internal'**
  String get internal;

  /// No description provided for @examType.
  ///
  /// In en, this message translates to:
  /// **'Exam Type'**
  String get examType;

  /// No description provided for @internalType.
  ///
  /// In en, this message translates to:
  /// **'Internal Type'**
  String get internalType;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @scope.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get scope;

  /// No description provided for @academicYear.
  ///
  /// In en, this message translates to:
  /// **'Academic Year'**
  String get academicYear;

  /// No description provided for @semester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get semester;

  /// No description provided for @subjectScores.
  ///
  /// In en, this message translates to:
  /// **'Subject Scores'**
  String get subjectScores;

  /// No description provided for @unitScores.
  ///
  /// In en, this message translates to:
  /// **'Unit Scores'**
  String get unitScores;

  /// No description provided for @addSubject.
  ///
  /// In en, this message translates to:
  /// **'Add Subject'**
  String get addSubject;

  /// No description provided for @addUnit.
  ///
  /// In en, this message translates to:
  /// **'Add Unit'**
  String get addUnit;

  /// No description provided for @noSubjectScore.
  ///
  /// In en, this message translates to:
  /// **'No subject score added yet. Click Add Subject to input report scores.'**
  String get noSubjectScore;

  /// No description provided for @noUnitScore.
  ///
  /// In en, this message translates to:
  /// **'No unit score added yet. Click Add Unit to input internal scores.'**
  String get noUnitScore;

  /// No description provided for @maxScore.
  ///
  /// In en, this message translates to:
  /// **'Max Score'**
  String get maxScore;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @removeRow.
  ///
  /// In en, this message translates to:
  /// **'Remove row'**
  String get removeRow;

  /// No description provided for @downloadEvidence.
  ///
  /// In en, this message translates to:
  /// **'Download evidence'**
  String get downloadEvidence;

  /// No description provided for @removeScoreRecord.
  ///
  /// In en, this message translates to:
  /// **'Remove score record'**
  String get removeScoreRecord;

  /// No description provided for @behavior.
  ///
  /// In en, this message translates to:
  /// **'Behavior'**
  String get behavior;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @quickProfile.
  ///
  /// In en, this message translates to:
  /// **'Quick Profile'**
  String get quickProfile;

  /// No description provided for @aggregatedSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Aggregated Snapshot'**
  String get aggregatedSnapshot;

  /// No description provided for @loadingStudentSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Loading student snapshot...'**
  String get loadingStudentSnapshot;

  /// No description provided for @noStudentSnapshot.
  ///
  /// In en, this message translates to:
  /// **'No student snapshot available.'**
  String get noStudentSnapshot;

  /// No description provided for @attendanceRecords.
  ///
  /// In en, this message translates to:
  /// **'Attendance Records'**
  String get attendanceRecords;

  /// No description provided for @attendanceChartTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance {year}'**
  String attendanceChartTitle(Object year);

  /// No description provided for @monthlyAttendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Monthly attendance rate'**
  String get monthlyAttendanceRate;

  /// No description provided for @attendanceChartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Attendance will appear after teaching attendance is saved.'**
  String get attendanceChartEmpty;

  /// No description provided for @averageScore.
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScore;

  /// No description provided for @assistance.
  ///
  /// In en, this message translates to:
  /// **'Assistance'**
  String get assistance;

  /// No description provided for @needsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs Attention'**
  String get needsAttention;

  /// No description provided for @noAttentionNeeded.
  ///
  /// In en, this message translates to:
  /// **'No attention signal for this student yet.'**
  String get noAttentionNeeded;

  /// No description provided for @attendanceBelowThreshold.
  ///
  /// In en, this message translates to:
  /// **'Attendance below 75%'**
  String get attendanceBelowThreshold;

  /// No description provided for @absenceRecords.
  ///
  /// In en, this message translates to:
  /// **'{count} absence record(s)'**
  String absenceRecords(Object count);

  /// No description provided for @permissionRecords.
  ///
  /// In en, this message translates to:
  /// **'{count} permission record(s)'**
  String permissionRecords(Object count);

  /// No description provided for @recentTeacherNotesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recent teacher note(s)'**
  String recentTeacherNotesCount(Object count);

  /// No description provided for @signal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get signal;

  /// No description provided for @physicalAttributes.
  ///
  /// In en, this message translates to:
  /// **'Physical Attributes'**
  String get physicalAttributes;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @uniform.
  ///
  /// In en, this message translates to:
  /// **'Uniform'**
  String get uniform;

  /// No description provided for @pants.
  ///
  /// In en, this message translates to:
  /// **'Pants'**
  String get pants;

  /// No description provided for @shoes.
  ///
  /// In en, this message translates to:
  /// **'Shoes'**
  String get shoes;

  /// No description provided for @studentRelations.
  ///
  /// In en, this message translates to:
  /// **'Student Relations'**
  String get studentRelations;

  /// No description provided for @loadingStudentRelations.
  ///
  /// In en, this message translates to:
  /// **'Loading student relations...'**
  String get loadingStudentRelations;

  /// No description provided for @parentsGuardians.
  ///
  /// In en, this message translates to:
  /// **'Parents / Guardians'**
  String get parentsGuardians;

  /// No description provided for @loadingGuardianInformation.
  ///
  /// In en, this message translates to:
  /// **'Loading guardian information...'**
  String get loadingGuardianInformation;

  /// No description provided for @learningSummary.
  ///
  /// In en, this message translates to:
  /// **'Learning Summary'**
  String get learningSummary;

  /// No description provided for @loadingLearningSummary.
  ///
  /// In en, this message translates to:
  /// **'Loading learning summary...'**
  String get loadingLearningSummary;

  /// No description provided for @noLearningSummary.
  ///
  /// In en, this message translates to:
  /// **'No learning summary available.'**
  String get noLearningSummary;

  /// No description provided for @latest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get latest;

  /// No description provided for @competencyAverage.
  ///
  /// In en, this message translates to:
  /// **'Competency Average'**
  String get competencyAverage;

  /// No description provided for @loadingCompetencyRecords.
  ///
  /// In en, this message translates to:
  /// **'Loading competency records...'**
  String get loadingCompetencyRecords;

  /// No description provided for @teachingAttendance.
  ///
  /// In en, this message translates to:
  /// **'Teaching Attendance'**
  String get teachingAttendance;

  /// No description provided for @loadingAttendanceRecords.
  ///
  /// In en, this message translates to:
  /// **'Loading attendance records...'**
  String get loadingAttendanceRecords;

  /// No description provided for @teacherNotes.
  ///
  /// In en, this message translates to:
  /// **'Teacher Notes'**
  String get teacherNotes;

  /// No description provided for @loadingTeacherNotes.
  ///
  /// In en, this message translates to:
  /// **'Loading teacher notes...'**
  String get loadingTeacherNotes;

  /// No description provided for @noteTypeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Note Type Distribution'**
  String get noteTypeDistribution;

  /// No description provided for @loadingNoteDistribution.
  ///
  /// In en, this message translates to:
  /// **'Loading note distribution...'**
  String get loadingNoteDistribution;

  /// No description provided for @extracurricular.
  ///
  /// In en, this message translates to:
  /// **'Extracurricular'**
  String get extracurricular;

  /// No description provided for @loadingActivities.
  ///
  /// In en, this message translates to:
  /// **'Loading activities...'**
  String get loadingActivities;

  /// No description provided for @extraActivityRecords.
  ///
  /// In en, this message translates to:
  /// **'Extra Activity Records'**
  String get extraActivityRecords;

  /// No description provided for @assistanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Assistance History'**
  String get assistanceHistory;

  /// No description provided for @loadingAssistanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Loading assistance history...'**
  String get loadingAssistanceHistory;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @loadingGoals.
  ///
  /// In en, this message translates to:
  /// **'Loading goals...'**
  String get loadingGoals;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @achievement.
  ///
  /// In en, this message translates to:
  /// **'Achievement'**
  String get achievement;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @program.
  ///
  /// In en, this message translates to:
  /// **'Program'**
  String get program;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @rule.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get rule;

  /// No description provided for @benefit.
  ///
  /// In en, this message translates to:
  /// **'Benefit'**
  String get benefit;

  /// No description provided for @approvedAt.
  ///
  /// In en, this message translates to:
  /// **'Approved At'**
  String get approvedAt;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relation'**
  String get relation;

  /// No description provided for @agePosition.
  ///
  /// In en, this message translates to:
  /// **'Age Position'**
  String get agePosition;

  /// No description provided for @primary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get primary;

  /// No description provided for @mobile.
  ///
  /// In en, this message translates to:
  /// **'Mobile'**
  String get mobile;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @noTeacherNotes.
  ///
  /// In en, this message translates to:
  /// **'No teacher notes have been saved from teaching sessions.'**
  String get noTeacherNotes;

  /// No description provided for @noTeacherNoteDistribution.
  ///
  /// In en, this message translates to:
  /// **'No teacher note distribution is available.'**
  String get noTeacherNoteDistribution;

  /// No description provided for @noExtracurricularActivity.
  ///
  /// In en, this message translates to:
  /// **'No extracurricular activity has been added.'**
  String get noExtracurricularActivity;

  /// No description provided for @noExtraActivity.
  ///
  /// In en, this message translates to:
  /// **'No extra activity has been added.'**
  String get noExtraActivity;

  /// No description provided for @noAssistanceHistory.
  ///
  /// In en, this message translates to:
  /// **'No assistance recipient history is available.'**
  String get noAssistanceHistory;

  /// No description provided for @noGoals.
  ///
  /// In en, this message translates to:
  /// **'No hobby or cita-cita has been added yet.'**
  String get noGoals;

  /// No description provided for @noStudentRelations.
  ///
  /// In en, this message translates to:
  /// **'No sibling or student relation has been added yet.'**
  String get noStudentRelations;

  /// No description provided for @noGuardianInformation.
  ///
  /// In en, this message translates to:
  /// **'No parent or guardian information has been added yet.'**
  String get noGuardianInformation;

  /// No description provided for @noCompetencyScores.
  ///
  /// In en, this message translates to:
  /// **'No competency scores have been saved from teaching sessions.'**
  String get noCompetencyScores;

  /// No description provided for @noTeachingAttendance.
  ///
  /// In en, this message translates to:
  /// **'No teaching attendance has been saved for this student.'**
  String get noTeachingAttendance;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @studentNo.
  ///
  /// In en, this message translates to:
  /// **'Student No'**
  String get studentNo;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @assistanceProgramsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistance Programs'**
  String get assistanceProgramsTitle;

  /// No description provided for @assistanceProgramsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maintain reusable assistance programs, benefit types, and default support values.'**
  String get assistanceProgramsSubtitle;

  /// No description provided for @addProgram.
  ///
  /// In en, this message translates to:
  /// **'Add Program'**
  String get addProgram;

  /// No description provided for @editProgram.
  ///
  /// In en, this message translates to:
  /// **'Edit Program'**
  String get editProgram;

  /// No description provided for @searchCodeNameDescription.
  ///
  /// In en, this message translates to:
  /// **'Search code, name, description'**
  String get searchCodeNameDescription;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @noAssistancePrograms.
  ///
  /// In en, this message translates to:
  /// **'No assistance programs found'**
  String get noAssistancePrograms;

  /// No description provided for @defaultBenefit.
  ///
  /// In en, this message translates to:
  /// **'Default Benefit'**
  String get defaultBenefit;

  /// No description provided for @editProgramTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit program'**
  String get editProgramTooltip;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @noPermissionViewAssistancePrograms.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view assistance programs.'**
  String get noPermissionViewAssistancePrograms;

  /// No description provided for @noPermissionCreateAssistancePrograms.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to create assistance programs.'**
  String get noPermissionCreateAssistancePrograms;

  /// No description provided for @noPermissionUpdateAssistancePrograms.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update assistance programs.'**
  String get noPermissionUpdateAssistancePrograms;

  /// No description provided for @assistanceProgramActivated.
  ///
  /// In en, this message translates to:
  /// **'Assistance program activated.'**
  String get assistanceProgramActivated;

  /// No description provided for @assistanceProgramDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Assistance program deactivated.'**
  String get assistanceProgramDeactivated;

  /// No description provided for @failedUpdateAssistanceProgramStatus.
  ///
  /// In en, this message translates to:
  /// **'Failed to update assistance program status.'**
  String get failedUpdateAssistanceProgramStatus;

  /// No description provided for @codeRequired.
  ///
  /// In en, this message translates to:
  /// **'Code is required'**
  String get codeRequired;

  /// No description provided for @codeFormatUppercase.
  ///
  /// In en, this message translates to:
  /// **'Use uppercase letters, numbers, or underscore'**
  String get codeFormatUppercase;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @benefitType.
  ///
  /// In en, this message translates to:
  /// **'Benefit Type'**
  String get benefitType;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @defaultAmountRp.
  ///
  /// In en, this message translates to:
  /// **'Default Amount (Rp)'**
  String get defaultAmountRp;

  /// No description provided for @amountMustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'Amount must be a number'**
  String get amountMustBeNumber;

  /// No description provided for @amountCannotBeNegative.
  ///
  /// In en, this message translates to:
  /// **'Amount cannot be negative'**
  String get amountCannotBeNegative;

  /// No description provided for @defaultItemDescription.
  ///
  /// In en, this message translates to:
  /// **'Default Item Description'**
  String get defaultItemDescription;

  /// No description provided for @benefitPackages.
  ///
  /// In en, this message translates to:
  /// **'Benefit Packages'**
  String get benefitPackages;

  /// No description provided for @addPackage.
  ///
  /// In en, this message translates to:
  /// **'Add Package'**
  String get addPackage;

  /// No description provided for @usePackagesBySchoolType.
  ///
  /// In en, this message translates to:
  /// **'Use packages when benefit amount or goods differ by school type.'**
  String get usePackagesBySchoolType;

  /// No description provided for @noPackageYet.
  ///
  /// In en, this message translates to:
  /// **'No package yet. If empty, the program default amount/item is used.'**
  String get noPackageYet;

  /// No description provided for @editPackage.
  ///
  /// In en, this message translates to:
  /// **'Edit package'**
  String get editPackage;

  /// No description provided for @removePackage.
  ///
  /// In en, this message translates to:
  /// **'Remove package'**
  String get removePackage;

  /// No description provided for @addBenefitPackage.
  ///
  /// In en, this message translates to:
  /// **'Add Benefit Package'**
  String get addBenefitPackage;

  /// No description provided for @editBenefitPackage.
  ///
  /// In en, this message translates to:
  /// **'Edit Benefit Package'**
  String get editBenefitPackage;

  /// No description provided for @schoolType.
  ///
  /// In en, this message translates to:
  /// **'School Type'**
  String get schoolType;

  /// No description provided for @amountRp.
  ///
  /// In en, this message translates to:
  /// **'Amount (Rp)'**
  String get amountRp;

  /// No description provided for @enterAmountRupiah.
  ///
  /// In en, this message translates to:
  /// **'Enter amount in Rupiah'**
  String get enterAmountRupiah;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get amountRequired;

  /// No description provided for @optionalPackageNotes.
  ///
  /// In en, this message translates to:
  /// **'Optional package notes'**
  String get optionalPackageNotes;

  /// No description provided for @goodsItems.
  ///
  /// In en, this message translates to:
  /// **'Goods / Items'**
  String get goodsItems;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @itemsForGoodsMixed.
  ///
  /// In en, this message translates to:
  /// **'Items are used for goods or mixed benefit packages.'**
  String get itemsForGoodsMixed;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet.'**
  String get noItemsYet;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get editItem;

  /// No description provided for @removeItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get removeItem;

  /// No description provided for @savePackage.
  ///
  /// In en, this message translates to:
  /// **'Save Package'**
  String get savePackage;

  /// No description provided for @goodsPackageNeedsItem.
  ///
  /// In en, this message translates to:
  /// **'Goods package needs at least one item.'**
  String get goodsPackageNeedsItem;

  /// No description provided for @mixedPackageNeedsAmountOrItem.
  ///
  /// In en, this message translates to:
  /// **'Mixed package needs amount or item.'**
  String get mixedPackageNeedsAmountOrItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @itemNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Item name is required'**
  String get itemNameRequired;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @quantityGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than zero'**
  String get quantityGreaterThanZero;

  /// No description provided for @unitHint.
  ///
  /// In en, this message translates to:
  /// **'pcs, pack, set'**
  String get unitHint;

  /// No description provided for @estimatedValueRp.
  ///
  /// In en, this message translates to:
  /// **'Estimated Value (Rp)'**
  String get estimatedValueRp;

  /// No description provided for @estimatedValueValid.
  ///
  /// In en, this message translates to:
  /// **'Estimated value must be valid'**
  String get estimatedValueValid;

  /// No description provided for @saveItem.
  ///
  /// In en, this message translates to:
  /// **'Save Item'**
  String get saveItem;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categorySeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get categorySeasonal;

  /// No description provided for @categoryUniform.
  ///
  /// In en, this message translates to:
  /// **'Uniform'**
  String get categoryUniform;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryEmergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get categoryEmergency;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @benefitCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get benefitCash;

  /// No description provided for @benefitGoods.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get benefitGoods;

  /// No description provided for @benefitVoucher.
  ///
  /// In en, this message translates to:
  /// **'Voucher'**
  String get benefitVoucher;

  /// No description provided for @benefitService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get benefitService;

  /// No description provided for @benefitMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get benefitMixed;

  /// No description provided for @frequencyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get frequencyMonthly;

  /// No description provided for @frequencyYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get frequencyYearly;

  /// No description provided for @frequencySeasonal.
  ///
  /// In en, this message translates to:
  /// **'Seasonal'**
  String get frequencySeasonal;

  /// No description provided for @frequencyOneTime.
  ///
  /// In en, this message translates to:
  /// **'One Time'**
  String get frequencyOneTime;

  /// No description provided for @frequencyAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
  String get frequencyAsNeeded;

  /// No description provided for @schoolTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get schoolTypeAll;

  /// No description provided for @schoolTypeUniversity.
  ///
  /// In en, this message translates to:
  /// **'University'**
  String get schoolTypeUniversity;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @targeted.
  ///
  /// In en, this message translates to:
  /// **'Targeted'**
  String get targeted;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @distributed.
  ///
  /// In en, this message translates to:
  /// **'Distributed'**
  String get distributed;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @assistancePeriodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistance Periods'**
  String get assistancePeriodsTitle;

  /// No description provided for @assistancePeriodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage assistance periods, target candidates, approval, and recipients.'**
  String get assistancePeriodsSubtitle;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String activeCount(Object count);

  /// No description provided for @searchPeriodProgramMonth.
  ///
  /// In en, this message translates to:
  /// **'Search period, program, month'**
  String get searchPeriodProgramMonth;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @noAssistancePeriods.
  ///
  /// In en, this message translates to:
  /// **'No assistance periods found'**
  String get noAssistancePeriods;

  /// No description provided for @periodName.
  ///
  /// In en, this message translates to:
  /// **'Period Name'**
  String get periodName;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @approvedFinalizedPeriodCannotDelete.
  ///
  /// In en, this message translates to:
  /// **'Approved or finalized period cannot be deleted'**
  String get approvedFinalizedPeriodCannotDelete;

  /// No description provided for @deletePeriod.
  ///
  /// In en, this message translates to:
  /// **'Delete period'**
  String get deletePeriod;

  /// No description provided for @noPermissionDeletePeriods.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to delete periods.'**
  String get noPermissionDeletePeriods;

  /// No description provided for @deleteAssistancePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Assistance Period?'**
  String get deleteAssistancePeriodTitle;

  /// No description provided for @deleteAssistancePeriodMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete \"{period}\" with its rules, target candidates, and recipient data. This action cannot be undone.'**
  String deleteAssistancePeriodMessage(Object period);

  /// No description provided for @deletePeriodButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Period'**
  String get deletePeriodButton;

  /// No description provided for @assistancePeriodDeleted.
  ///
  /// In en, this message translates to:
  /// **'Assistance period deleted.'**
  String get assistancePeriodDeleted;

  /// No description provided for @setup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setup;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @finalize.
  ///
  /// In en, this message translates to:
  /// **'Finalize'**
  String get finalize;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @targetCandidates.
  ///
  /// In en, this message translates to:
  /// **'Target Candidates'**
  String get targetCandidates;

  /// No description provided for @reviewApproval.
  ///
  /// In en, this message translates to:
  /// **'Review & Approval'**
  String get reviewApproval;

  /// No description provided for @approvalDocument.
  ///
  /// In en, this message translates to:
  /// **'Approval Document'**
  String get approvalDocument;

  /// No description provided for @recipients.
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get recipients;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @minimumAttendance.
  ///
  /// In en, this message translates to:
  /// **'Minimum Attendance'**
  String get minimumAttendance;

  /// No description provided for @calculation.
  ///
  /// In en, this message translates to:
  /// **'Calculation'**
  String get calculation;

  /// No description provided for @calculationRange.
  ///
  /// In en, this message translates to:
  /// **'Calculation Range'**
  String get calculationRange;

  /// No description provided for @periodInfo.
  ///
  /// In en, this message translates to:
  /// **'Period Info'**
  String get periodInfo;

  /// No description provided for @targetQuota.
  ///
  /// In en, this message translates to:
  /// **'Target Quota'**
  String get targetQuota;

  /// No description provided for @calculationWindow.
  ///
  /// In en, this message translates to:
  /// **'Calculation Window'**
  String get calculationWindow;

  /// No description provided for @manualOverride.
  ///
  /// In en, this message translates to:
  /// **'Manual Override'**
  String get manualOverride;

  /// No description provided for @rulesUsed.
  ///
  /// In en, this message translates to:
  /// **'Rules Used'**
  String get rulesUsed;

  /// No description provided for @quota.
  ///
  /// In en, this message translates to:
  /// **'Quota'**
  String get quota;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @createAssistancePeriod.
  ///
  /// In en, this message translates to:
  /// **'Create Assistance Period'**
  String get createAssistancePeriod;

  /// No description provided for @createPeriod.
  ///
  /// In en, this message translates to:
  /// **'Create Period'**
  String get createPeriod;

  /// No description provided for @creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get creating;

  /// No description provided for @periodInfoStep.
  ///
  /// In en, this message translates to:
  /// **'Period Info'**
  String get periodInfoStep;

  /// No description provided for @rulesQuota.
  ///
  /// In en, this message translates to:
  /// **'Rules & Quota'**
  String get rulesQuota;

  /// No description provided for @reviewSetup.
  ///
  /// In en, this message translates to:
  /// **'Review Setup'**
  String get reviewSetup;

  /// No description provided for @allowManualOverrideBelowAttendance.
  ///
  /// In en, this message translates to:
  /// **'Allow Manual Override Below Attendance'**
  String get allowManualOverrideBelowAttendance;

  /// No description provided for @periodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Period name is required'**
  String get periodNameRequired;

  /// No description provided for @addRule.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get addRule;

  /// No description provided for @allocation.
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get allocation;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @allowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get allowed;

  /// No description provided for @notAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get notAllowed;

  /// No description provided for @monthsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String monthsCount(Object count);

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @overAllocated.
  ///
  /// In en, this message translates to:
  /// **'Over allocated'**
  String get overAllocated;

  /// No description provided for @autoTarget.
  ///
  /// In en, this message translates to:
  /// **'Auto Target'**
  String get autoTarget;

  /// No description provided for @saveTargetPlan.
  ///
  /// In en, this message translates to:
  /// **'Save Target Plan'**
  String get saveTargetPlan;

  /// No description provided for @targetPlanSaved.
  ///
  /// In en, this message translates to:
  /// **'Target plan saved.'**
  String get targetPlanSaved;

  /// No description provided for @autoTargetsGenerated.
  ///
  /// In en, this message translates to:
  /// **'Auto targets generated. Click Save Target Plan to commit.'**
  String get autoTargetsGenerated;

  /// No description provided for @autoTargetFailed.
  ///
  /// In en, this message translates to:
  /// **'Auto Target Failed'**
  String get autoTargetFailed;

  /// No description provided for @selectStudents.
  ///
  /// In en, this message translates to:
  /// **'Select Students'**
  String get selectStudents;

  /// No description provided for @removeAll.
  ///
  /// In en, this message translates to:
  /// **'Remove All'**
  String get removeAll;

  /// No description provided for @parameterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Academic, teaching, assistance, and system parameters.'**
  String get parameterSubtitle;

  /// No description provided for @noPermissionViewParameters.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view parameters.'**
  String get noPermissionViewParameters;

  /// No description provided for @academicParameters.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get academicParameters;

  /// No description provided for @teachingParameters.
  ///
  /// In en, this message translates to:
  /// **'Teaching'**
  String get teachingParameters;

  /// No description provided for @systemParameters.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemParameters;

  /// No description provided for @schools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get schools;

  /// No description provided for @curriculum.
  ///
  /// In en, this message translates to:
  /// **'Curriculum'**
  String get curriculum;

  /// No description provided for @syllabus.
  ///
  /// In en, this message translates to:
  /// **'Syllabus'**
  String get syllabus;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @competencies.
  ///
  /// In en, this message translates to:
  /// **'Competencies'**
  String get competencies;

  /// No description provided for @strategies.
  ///
  /// In en, this message translates to:
  /// **'Strategies'**
  String get strategies;

  /// No description provided for @programs.
  ///
  /// In en, this message translates to:
  /// **'Programs'**
  String get programs;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get config;

  /// No description provided for @systemConfig.
  ///
  /// In en, this message translates to:
  /// **'System Config'**
  String get systemConfig;

  /// No description provided for @configDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage system-wide parameter settings used across the application.'**
  String get configDescription;

  /// No description provided for @reportDefinitionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintain dynamic report definitions used by the Reports menu.'**
  String get reportDefinitionsDescription;

  /// No description provided for @parameterDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintain parameter data used by Edukita modules.'**
  String get parameterDefaultDescription;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @noPermissionUpdateParameters.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update parameters.'**
  String get noPermissionUpdateParameters;

  /// No description provided for @systemConfigSaved.
  ///
  /// In en, this message translates to:
  /// **'System config saved.'**
  String get systemConfigSaved;

  /// No description provided for @examTypeNamesUnique.
  ///
  /// In en, this message translates to:
  /// **'Exam type names must be unique.'**
  String get examTypeNamesUnique;

  /// No description provided for @numbering.
  ///
  /// In en, this message translates to:
  /// **'Numbering'**
  String get numbering;

  /// No description provided for @numberingDescription.
  ///
  /// In en, this message translates to:
  /// **'Default prefixes for generated codes. Existing records are not changed.'**
  String get numberingDescription;

  /// No description provided for @studentPrefix.
  ///
  /// In en, this message translates to:
  /// **'Student Prefix'**
  String get studentPrefix;

  /// No description provided for @teacherPrefix.
  ///
  /// In en, this message translates to:
  /// **'Teacher Prefix'**
  String get teacherPrefix;

  /// No description provided for @reportPrefix.
  ///
  /// In en, this message translates to:
  /// **'Report Prefix'**
  String get reportPrefix;

  /// No description provided for @attendanceStatuses.
  ///
  /// In en, this message translates to:
  /// **'Attendance Statuses'**
  String get attendanceStatuses;

  /// No description provided for @attendanceStatusesDescription.
  ///
  /// In en, this message translates to:
  /// **'Operational attendance statuses available for teaching reports and dashboard summaries.'**
  String get attendanceStatusesDescription;

  /// No description provided for @approvalExportLabels.
  ///
  /// In en, this message translates to:
  /// **'Approval & Export Labels'**
  String get approvalExportLabels;

  /// No description provided for @approvalExportLabelsDescription.
  ///
  /// In en, this message translates to:
  /// **'Labels used in assistance approval documents and report signature areas.'**
  String get approvalExportLabelsDescription;

  /// No description provided for @assistanceApproval.
  ///
  /// In en, this message translates to:
  /// **'Assistance Approval'**
  String get assistanceApproval;

  /// No description provided for @reportSignatures.
  ///
  /// In en, this message translates to:
  /// **'Report Signatures'**
  String get reportSignatures;

  /// No description provided for @preparedLabel.
  ///
  /// In en, this message translates to:
  /// **'Prepared Label'**
  String get preparedLabel;

  /// No description provided for @reviewedLabel.
  ///
  /// In en, this message translates to:
  /// **'Reviewed Label'**
  String get reviewedLabel;

  /// No description provided for @approvedLabel.
  ///
  /// In en, this message translates to:
  /// **'Approved Label'**
  String get approvedLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Label'**
  String get dateLabel;

  /// No description provided for @examTypes.
  ///
  /// In en, this message translates to:
  /// **'Exam Types'**
  String get examTypes;

  /// No description provided for @examTypesDescription.
  ///
  /// In en, this message translates to:
  /// **'External school score types. Evidence can be required for important formal exams.'**
  String get examTypesDescription;

  /// No description provided for @evidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get evidence;

  /// No description provided for @evidenceRequiredTooltip.
  ///
  /// In en, this message translates to:
  /// **'Require uploaded evidence when adding this score type'**
  String get evidenceRequiredTooltip;

  /// No description provided for @examTypeActiveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Show this exam type in score input options'**
  String get examTypeActiveTooltip;

  /// No description provided for @reportsChooseDefinition.
  ///
  /// In en, this message translates to:
  /// **'Choose a report definition to preview and export data.'**
  String get reportsChooseDefinition;

  /// No description provided for @noPermissionViewReports.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view reports.'**
  String get noPermissionViewReports;

  /// No description provided for @reportRowsLoaded.
  ///
  /// In en, this message translates to:
  /// **'{name} | {count} rows loaded'**
  String reportRowsLoaded(Object name, Object count);

  /// No description provided for @refreshReports.
  ///
  /// In en, this message translates to:
  /// **'Refresh reports'**
  String get refreshReports;

  /// No description provided for @run.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get run;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @availableReports.
  ///
  /// In en, this message translates to:
  /// **'Available Reports'**
  String get availableReports;

  /// No description provided for @searchCodeOrName.
  ///
  /// In en, this message translates to:
  /// **'Search code or name'**
  String get searchCodeOrName;

  /// No description provided for @noActiveReportSettings.
  ///
  /// In en, this message translates to:
  /// **'No active report settings. Add reports from Parameter > System > Reports.'**
  String get noActiveReportSettings;

  /// No description provided for @noReportsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No reports match your search.'**
  String get noReportsMatchSearch;

  /// No description provided for @selectReport.
  ///
  /// In en, this message translates to:
  /// **'Select Report'**
  String get selectReport;

  /// No description provided for @selectReportMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose a report from the left panel to preview its data.'**
  String get selectReportMessage;

  /// No description provided for @searchLoadedRows.
  ///
  /// In en, this message translates to:
  /// **'Search loaded rows'**
  String get searchLoadedRows;

  /// No description provided for @noDataLoaded.
  ///
  /// In en, this message translates to:
  /// **'No Data Loaded'**
  String get noDataLoaded;

  /// No description provided for @clickRunReportPreview.
  ///
  /// In en, this message translates to:
  /// **'Click Run to execute this report and show the preview.'**
  String get clickRunReportPreview;

  /// No description provided for @noRowsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No rows match the current search'**
  String get noRowsMatchSearch;

  /// No description provided for @failedRunReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to run report'**
  String get failedRunReport;

  /// No description provided for @noPermissionExportReports.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to export reports.'**
  String get noPermissionExportReports;

  /// No description provided for @reportExported.
  ///
  /// In en, this message translates to:
  /// **'Report exported.'**
  String get reportExported;

  /// No description provided for @failedExportReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to export report'**
  String get failedExportReport;

  /// No description provided for @reportSettings.
  ///
  /// In en, this message translates to:
  /// **'Report Settings'**
  String get reportSettings;

  /// No description provided for @reportSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Maintain dynamic report definitions, file names, SQL queries, and column display settings.'**
  String get reportSettingsSubtitle;

  /// No description provided for @addReport.
  ///
  /// In en, this message translates to:
  /// **'Add Report'**
  String get addReport;

  /// No description provided for @searchReportNameCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Search report name, code, description'**
  String get searchReportNameCodeDescription;

  /// No description provided for @noReportSettings.
  ///
  /// In en, this message translates to:
  /// **'No report settings found'**
  String get noReportSettings;

  /// No description provided for @codeReportName.
  ///
  /// In en, this message translates to:
  /// **'Code\nReport Name'**
  String get codeReportName;

  /// No description provided for @fileName.
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// No description provided for @columns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get columns;

  /// No description provided for @columnsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} columns'**
  String columnsCount(Object count);

  /// No description provided for @columnsMissingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} columns, {missing} missing'**
  String columnsMissingCount(Object count, Object missing);

  /// No description provided for @editReport.
  ///
  /// In en, this message translates to:
  /// **'Edit report'**
  String get editReport;

  /// No description provided for @deleteReportSetting.
  ///
  /// In en, this message translates to:
  /// **'Delete report setting'**
  String get deleteReportSetting;

  /// No description provided for @noPermissionUpdateReportSettings.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update report settings.'**
  String get noPermissionUpdateReportSettings;

  /// No description provided for @noPermissionDeleteReportSettings.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to delete report settings.'**
  String get noPermissionDeleteReportSettings;

  /// No description provided for @reportSettingActivated.
  ///
  /// In en, this message translates to:
  /// **'Report setting activated.'**
  String get reportSettingActivated;

  /// No description provided for @reportSettingDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Report setting deactivated.'**
  String get reportSettingDeactivated;

  /// No description provided for @failedUpdateReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to update report'**
  String get failedUpdateReport;

  /// No description provided for @deleteReportSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Report Setting'**
  String get deleteReportSettingTitle;

  /// No description provided for @deleteReportSettingMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This removes the report from Parameter and the Reports menu.'**
  String deleteReportSettingMessage(Object name);

  /// No description provided for @failedDeleteReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete report'**
  String get failedDeleteReport;

  /// No description provided for @addReportSetting.
  ///
  /// In en, this message translates to:
  /// **'Add Report Setting'**
  String get addReportSetting;

  /// No description provided for @editReportSetting.
  ///
  /// In en, this message translates to:
  /// **'Edit Report Setting'**
  String get editReportSetting;

  /// No description provided for @reportNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Report name is required'**
  String get reportNameRequired;

  /// No description provided for @reportFileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Report file name is required'**
  String get reportFileNameRequired;

  /// No description provided for @reportName.
  ///
  /// In en, this message translates to:
  /// **'Report Name'**
  String get reportName;

  /// No description provided for @reportFileName.
  ///
  /// In en, this message translates to:
  /// **'Report File Name'**
  String get reportFileName;

  /// No description provided for @reportCode.
  ///
  /// In en, this message translates to:
  /// **'Report Code'**
  String get reportCode;

  /// No description provided for @autoGenerated.
  ///
  /// In en, this message translates to:
  /// **'Auto generated'**
  String get autoGenerated;

  /// No description provided for @descriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Short purpose of this report'**
  String get descriptionHint;

  /// No description provided for @querySql.
  ///
  /// In en, this message translates to:
  /// **'Query SQL'**
  String get querySql;

  /// No description provided for @columnSettings.
  ///
  /// In en, this message translates to:
  /// **'Column Settings'**
  String get columnSettings;

  /// No description provided for @detectColumns.
  ///
  /// In en, this message translates to:
  /// **'Detect Columns'**
  String get detectColumns;

  /// No description provided for @reportQueryRequired.
  ///
  /// In en, this message translates to:
  /// **'Report query is required'**
  String get reportQueryRequired;

  /// No description provided for @readOnlySelectQuery.
  ///
  /// In en, this message translates to:
  /// **'Read-only SELECT query'**
  String get readOnlySelectQuery;

  /// No description provided for @reportQueryHelp.
  ///
  /// In en, this message translates to:
  /// **'Only one SELECT statement is allowed. When this field loses focus, new columns are added automatically and existing labels are preserved.'**
  String get reportQueryHelp;

  /// No description provided for @configuredColumns.
  ///
  /// In en, this message translates to:
  /// **'{count} configured columns'**
  String configuredColumns(Object count);

  /// No description provided for @removeMissingColumns.
  ///
  /// In en, this message translates to:
  /// **'Remove Missing ({count})'**
  String removeMissingColumns(Object count);

  /// No description provided for @noReportColumnsYet.
  ///
  /// In en, this message translates to:
  /// **'No columns yet. Input a query, then leave the query field or click Detect Columns.'**
  String get noReportColumnsYet;

  /// No description provided for @inputQueryFirst.
  ///
  /// In en, this message translates to:
  /// **'Input query first.'**
  String get inputQueryFirst;

  /// No description provided for @columnsSynchronizedAdded.
  ///
  /// In en, this message translates to:
  /// **'Columns synchronized. {count} new column(s) added.'**
  String columnsSynchronizedAdded(Object count);

  /// No description provided for @columnsSynchronizedMissing.
  ///
  /// In en, this message translates to:
  /// **'Columns synchronized. {added} added, {missing} marked missing.'**
  String columnsSynchronizedMissing(Object added, Object missing);

  /// No description provided for @invalidReportQuery.
  ///
  /// In en, this message translates to:
  /// **'Invalid report query'**
  String get invalidReportQuery;

  /// No description provided for @failedSaveReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to save report'**
  String get failedSaveReport;

  /// No description provided for @reportSettingSubject.
  ///
  /// In en, this message translates to:
  /// **'report setting'**
  String get reportSettingSubject;

  /// No description provided for @field.
  ///
  /// In en, this message translates to:
  /// **'Field'**
  String get field;

  /// No description provided for @columnLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get columnLabel;

  /// No description provided for @labelRequired.
  ///
  /// In en, this message translates to:
  /// **'Label is required'**
  String get labelRequired;

  /// No description provided for @align.
  ///
  /// In en, this message translates to:
  /// **'Align'**
  String get align;

  /// No description provided for @width.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get width;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get missing;

  /// No description provided for @missingColumnTooltip.
  ///
  /// In en, this message translates to:
  /// **'This configured column is not returned by the current query.'**
  String get missingColumnTooltip;

  /// No description provided for @exportColumn.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportColumn;

  /// No description provided for @exportedAt.
  ///
  /// In en, this message translates to:
  /// **'Exported At'**
  String get exportedAt;

  /// No description provided for @totalRows.
  ///
  /// In en, this message translates to:
  /// **'Total Rows'**
  String get totalRows;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will return to the login screen.'**
  String get logoutMessage;

  /// No description provided for @noPermissionCreateUsers.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to create users.'**
  String get noPermissionCreateUsers;

  /// No description provided for @noPermissionUpdateUsers.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to update users.'**
  String get noPermissionUpdateUsers;

  /// No description provided for @noPermissionToggleUsers.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to activate or deactivate users.'**
  String get noPermissionToggleUsers;

  /// No description provided for @noPermissionViewUserManagement.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view user management.'**
  String get noPermissionViewUserManagement;

  /// No description provided for @userManagementSubtitleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Manage users, role permissions, teacher links, and special access.'**
  String get userManagementSubtitleAdmin;

  /// No description provided for @userManagementSubtitleStandard.
  ///
  /// In en, this message translates to:
  /// **'Manage app users, teacher links, and extra menu access.'**
  String get userManagementSubtitleStandard;

  /// No description provided for @addUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUser;

  /// No description provided for @usersTab.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get usersTab;

  /// No description provided for @rolesPermissions.
  ///
  /// In en, this message translates to:
  /// **'Roles & Permissions'**
  String get rolesPermissions;

  /// No description provided for @searchUsersHint.
  ///
  /// In en, this message translates to:
  /// **'Search username, full name, or teacher'**
  String get searchUsersHint;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @teacherLink.
  ///
  /// In en, this message translates to:
  /// **'Teacher Link'**
  String get teacherLink;

  /// No description provided for @extraAccess.
  ///
  /// In en, this message translates to:
  /// **'Extra Access'**
  String get extraAccess;

  /// No description provided for @extraAccessCount.
  ///
  /// In en, this message translates to:
  /// **'{count} menu(s)'**
  String extraAccessCount(Object count);

  /// No description provided for @editUserTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get editUserTooltip;

  /// No description provided for @activateUser.
  ///
  /// In en, this message translates to:
  /// **'Activate User'**
  String get activateUser;

  /// No description provided for @deactivateUser.
  ///
  /// In en, this message translates to:
  /// **'Deactivate User'**
  String get deactivateUser;

  /// No description provided for @activateUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Activate {name}?'**
  String activateUserConfirm(Object name);

  /// No description provided for @deactivateUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Deactivate {name}?'**
  String deactivateUserConfirm(Object name);

  /// No description provided for @rolesPermissionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Admin always has full access. Configure menu actions for Staff and Teacher roles.'**
  String get rolesPermissionsSubtitle;

  /// No description provided for @rolePermissionsUpdated.
  ///
  /// In en, this message translates to:
  /// **'{role} permissions updated.'**
  String rolePermissionsUpdated(Object role);

  /// No description provided for @noMenuAvailable.
  ///
  /// In en, this message translates to:
  /// **'No menu available'**
  String get noMenuAvailable;

  /// No description provided for @menuColumn.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuColumn;

  /// No description provided for @createUser.
  ///
  /// In en, this message translates to:
  /// **'Create User'**
  String get createUser;

  /// No description provided for @editUser.
  ///
  /// In en, this message translates to:
  /// **'Edit User'**
  String get editUser;

  /// No description provided for @updateUser.
  ///
  /// In en, this message translates to:
  /// **'Update User'**
  String get updateUser;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @leaveEmptyToKeep.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to keep'**
  String get leaveEmptyToKeep;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 4 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordMinLengthSix.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLengthSix;

  /// No description provided for @passwordMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at most 64 characters'**
  String get passwordMaxLength;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get roleStaff;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleTeacher;

  /// No description provided for @teacherRequired.
  ///
  /// In en, this message translates to:
  /// **'Teacher is required'**
  String get teacherRequired;

  /// No description provided for @extraMenuAccess.
  ///
  /// In en, this message translates to:
  /// **'Extra Menu Access'**
  String get extraMenuAccess;

  /// No description provided for @noExtraMenuAccess.
  ///
  /// In en, this message translates to:
  /// **'No extra menu access available for this role.'**
  String get noExtraMenuAccess;

  /// No description provided for @userCreated.
  ///
  /// In en, this message translates to:
  /// **'User created.'**
  String get userCreated;

  /// No description provided for @userUpdated.
  ///
  /// In en, this message translates to:
  /// **'User updated.'**
  String get userUpdated;

  /// No description provided for @linkedTeacher.
  ///
  /// In en, this message translates to:
  /// **'Linked teacher'**
  String get linkedTeacher;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String requiredField(Object field);

  /// No description provided for @fieldTooShort.
  ///
  /// In en, this message translates to:
  /// **'{field} is too short'**
  String fieldTooShort(Object field);

  /// No description provided for @permissionView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get permissionView;

  /// No description provided for @permissionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get permissionCreate;

  /// No description provided for @permissionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get permissionUpdate;

  /// No description provided for @permissionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get permissionDelete;

  /// No description provided for @permissionExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get permissionExport;

  /// No description provided for @permissionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get permissionApprove;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @foundationName.
  ///
  /// In en, this message translates to:
  /// **'Foundation Name'**
  String get foundationName;

  /// No description provided for @exportFilePrefix.
  ///
  /// In en, this message translates to:
  /// **'Export File Prefix'**
  String get exportFilePrefix;

  /// No description provided for @currencyCode.
  ///
  /// In en, this message translates to:
  /// **'Currency Code'**
  String get currencyCode;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'Currency Symbol'**
  String get currencySymbol;

  /// No description provided for @defaultMinimumAttendance.
  ///
  /// In en, this message translates to:
  /// **'Default Minimum Attendance'**
  String get defaultMinimumAttendance;

  /// No description provided for @defaultDashboardRange.
  ///
  /// In en, this message translates to:
  /// **'Default Dashboard Range'**
  String get defaultDashboardRange;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get threeMonths;

  /// No description provided for @sixMonths.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get sixMonths;

  /// No description provided for @oneYear.
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get oneYear;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storageDescription.
  ///
  /// In en, this message translates to:
  /// **'Current local database and uploaded document storage locations.'**
  String get storageDescription;

  /// No description provided for @database.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// No description provided for @uploads.
  ///
  /// In en, this message translates to:
  /// **'Uploads'**
  String get uploads;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @maintenanceDescription.
  ///
  /// In en, this message translates to:
  /// **'Tools for local desktop operation. Backup creates a copy of the SQLite database.'**
  String get maintenanceDescription;

  /// No description provided for @backingUp.
  ///
  /// In en, this message translates to:
  /// **'Backing Up'**
  String get backingUp;

  /// No description provided for @backupDatabase.
  ///
  /// In en, this message translates to:
  /// **'Backup Database'**
  String get backupDatabase;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCache;

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @maximize.
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get maximize;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// No description provided for @uploadedBy.
  ///
  /// In en, this message translates to:
  /// **'Uploaded By'**
  String get uploadedBy;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add Selected'**
  String get addSelected;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @chooseDate.
  ///
  /// In en, this message translates to:
  /// **'Choose date'**
  String get chooseDate;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDate;

  /// No description provided for @assessmentNote.
  ///
  /// In en, this message translates to:
  /// **'Assessment Note'**
  String get assessmentNote;

  /// No description provided for @saveNotes.
  ///
  /// In en, this message translates to:
  /// **'Save Notes'**
  String get saveNotes;

  /// No description provided for @noCandidatesSelected.
  ///
  /// In en, this message translates to:
  /// **'No candidates selected yet.'**
  String get noCandidatesSelected;

  /// No description provided for @removeTarget.
  ///
  /// In en, this message translates to:
  /// **'Remove target'**
  String get removeTarget;

  /// No description provided for @removeTargetCandidateTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Target Candidate?'**
  String get removeTargetCandidateTitle;

  /// No description provided for @removeAllTargetCandidatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove All Target Candidates?'**
  String get removeAllTargetCandidatesTitle;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @markAsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Submitted'**
  String get markAsSubmitted;

  /// No description provided for @rejectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Reject Period'**
  String get rejectPeriod;

  /// No description provided for @rejectAssistancePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Assistance Period?'**
  String get rejectAssistancePeriodTitle;

  /// No description provided for @searchRecipientOrRule.
  ///
  /// In en, this message translates to:
  /// **'Search recipient or rule'**
  String get searchRecipientOrRule;

  /// No description provided for @cancelRecipient.
  ///
  /// In en, this message translates to:
  /// **'Cancel recipient'**
  String get cancelRecipient;

  /// No description provided for @resetStatus.
  ///
  /// In en, this message translates to:
  /// **'Reset status'**
  String get resetStatus;

  /// No description provided for @handledBy.
  ///
  /// In en, this message translates to:
  /// **'Handled By'**
  String get handledBy;

  /// No description provided for @cancelPeriod.
  ///
  /// In en, this message translates to:
  /// **'Cancel Period'**
  String get cancelPeriod;

  /// No description provided for @cancelRecipientDistribution.
  ///
  /// In en, this message translates to:
  /// **'Cancel Recipient Distribution'**
  String get cancelRecipientDistribution;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancellationReason;

  /// No description provided for @cancelAssistancePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Assistance Period?'**
  String get cancelAssistancePeriodTitle;

  /// No description provided for @removeZeroQuotaRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove zero quota rules?'**
  String get removeZeroQuotaRulesTitle;

  /// No description provided for @removeContinue.
  ///
  /// In en, this message translates to:
  /// **'Remove & Continue'**
  String get removeContinue;

  /// No description provided for @selectAssistanceRule.
  ///
  /// In en, this message translates to:
  /// **'Select Assistance Rule'**
  String get selectAssistanceRule;

  /// No description provided for @addCustomRule.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Rule'**
  String get addCustomRule;

  /// No description provided for @addPeriod.
  ///
  /// In en, this message translates to:
  /// **'Add Period'**
  String get addPeriod;

  /// No description provided for @editPeriod.
  ///
  /// In en, this message translates to:
  /// **'Edit period'**
  String get editPeriod;

  /// No description provided for @noAssistanceRules.
  ///
  /// In en, this message translates to:
  /// **'No assistance rules yet'**
  String get noAssistanceRules;

  /// No description provided for @noStudentAssistanceRules.
  ///
  /// In en, this message translates to:
  /// **'No student assistance rules yet'**
  String get noStudentAssistanceRules;

  /// No description provided for @deleteStudentRule.
  ///
  /// In en, this message translates to:
  /// **'Delete Student Rule'**
  String get deleteStudentRule;

  /// No description provided for @deleteAllocationRule.
  ///
  /// In en, this message translates to:
  /// **'Delete Allocation Rule'**
  String get deleteAllocationRule;

  /// No description provided for @regenerateAssistancePlan.
  ///
  /// In en, this message translates to:
  /// **'Regenerate Assistance Plan?'**
  String get regenerateAssistancePlan;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @saveTargetAssistance.
  ///
  /// In en, this message translates to:
  /// **'Save Target Assistance'**
  String get saveTargetAssistance;

  /// No description provided for @createPeriodFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a period first.'**
  String get createPeriodFirst;

  /// No description provided for @noRuleAllocation.
  ///
  /// In en, this message translates to:
  /// **'No rule allocation yet'**
  String get noRuleAllocation;

  /// No description provided for @targetStatus.
  ///
  /// In en, this message translates to:
  /// **'Target Status'**
  String get targetStatus;

  /// No description provided for @ruleType.
  ///
  /// In en, this message translates to:
  /// **'Rule Type'**
  String get ruleType;

  /// No description provided for @noTargetCandidates.
  ///
  /// In en, this message translates to:
  /// **'No target candidates yet'**
  String get noTargetCandidates;

  /// No description provided for @exportAssistancePlan.
  ///
  /// In en, this message translates to:
  /// **'Export assistance plan'**
  String get exportAssistancePlan;

  /// No description provided for @downloadRecipientsHistory.
  ///
  /// In en, this message translates to:
  /// **'Download recipients history'**
  String get downloadRecipientsHistory;

  /// No description provided for @noApprovedRecipients.
  ///
  /// In en, this message translates to:
  /// **'No approved recipients yet'**
  String get noApprovedRecipients;

  /// No description provided for @selectPeriodFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a period first.'**
  String get selectPeriodFirst;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get chooseFile;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploading;

  /// No description provided for @uploadApprove.
  ///
  /// In en, this message translates to:
  /// **'Upload & Approve'**
  String get uploadApprove;

  /// No description provided for @assistancePeriod.
  ///
  /// In en, this message translates to:
  /// **'Assistance Period'**
  String get assistancePeriod;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @calculationWindowMonths.
  ///
  /// In en, this message translates to:
  /// **'Calculation Window (months)'**
  String get calculationWindowMonths;

  /// No description provided for @minimumAttendancePercent.
  ///
  /// In en, this message translates to:
  /// **'Minimum Attendance (%)'**
  String get minimumAttendancePercent;

  /// No description provided for @allowManagerOverride.
  ///
  /// In en, this message translates to:
  /// **'Allow manager override below attendance'**
  String get allowManagerOverride;

  /// No description provided for @ruleMaster.
  ///
  /// In en, this message translates to:
  /// **'Rule Master'**
  String get ruleMaster;

  /// No description provided for @ruleName.
  ///
  /// In en, this message translates to:
  /// **'Rule Name'**
  String get ruleName;

  /// No description provided for @priorityOrder.
  ///
  /// In en, this message translates to:
  /// **'Priority Order'**
  String get priorityOrder;

  /// No description provided for @selectionMode.
  ///
  /// In en, this message translates to:
  /// **'Selection Mode'**
  String get selectionMode;

  /// No description provided for @minimumScoreOptional.
  ///
  /// In en, this message translates to:
  /// **'Minimum Score (optional)'**
  String get minimumScoreOptional;

  /// No description provided for @carryUnusedQuota.
  ///
  /// In en, this message translates to:
  /// **'Carry unused quota to next rule'**
  String get carryUnusedQuota;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @scoreOverrideOptional.
  ///
  /// In en, this message translates to:
  /// **'Score Override (optional)'**
  String get scoreOverrideOptional;

  /// No description provided for @priorityLevel.
  ///
  /// In en, this message translates to:
  /// **'Priority Level'**
  String get priorityLevel;

  /// No description provided for @priorityReason.
  ///
  /// In en, this message translates to:
  /// **'Priority Reason'**
  String get priorityReason;

  /// No description provided for @specialCaseNote.
  ///
  /// In en, this message translates to:
  /// **'Special Case Note'**
  String get specialCaseNote;

  /// No description provided for @approvedAmountSupport.
  ///
  /// In en, this message translates to:
  /// **'Approved Amount or Support'**
  String get approvedAmountSupport;

  /// No description provided for @deleteStrategyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Strategy'**
  String get deleteStrategyTitle;

  /// No description provided for @deleteStrategyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this strategy?'**
  String get deleteStrategyConfirm;

  /// No description provided for @noStrategiesYet.
  ///
  /// In en, this message translates to:
  /// **'No strategies yet. Add a strategy.'**
  String get noStrategiesYet;

  /// No description provided for @addSchool.
  ///
  /// In en, this message translates to:
  /// **'Add School'**
  String get addSchool;

  /// No description provided for @addClass.
  ///
  /// In en, this message translates to:
  /// **'Add Class'**
  String get addClass;

  /// No description provided for @deleteClass.
  ///
  /// In en, this message translates to:
  /// **'Delete Class'**
  String get deleteClass;

  /// No description provided for @deleteSchool.
  ///
  /// In en, this message translates to:
  /// **'Delete School'**
  String get deleteSchool;

  /// No description provided for @searchSchoolName.
  ///
  /// In en, this message translates to:
  /// **'Search school name'**
  String get searchSchoolName;

  /// No description provided for @noClassesForSchool.
  ///
  /// In en, this message translates to:
  /// **'No classes for this school.'**
  String get noClassesForSchool;

  /// No description provided for @noClassesYet.
  ///
  /// In en, this message translates to:
  /// **'No classes yet. Add a class.'**
  String get noClassesYet;

  /// No description provided for @changeSchoolType.
  ///
  /// In en, this message translates to:
  /// **'Change School Type'**
  String get changeSchoolType;

  /// No description provided for @keepType.
  ///
  /// In en, this message translates to:
  /// **'Keep Type'**
  String get keepType;

  /// No description provided for @removeClasses.
  ///
  /// In en, this message translates to:
  /// **'Remove Classes'**
  String get removeClasses;

  /// No description provided for @clearClasses.
  ///
  /// In en, this message translates to:
  /// **'Clear Classes'**
  String get clearClasses;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @generateClassesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Generate all levels with section A/B/C'**
  String get generateClassesTooltip;

  /// No description provided for @section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get section;

  /// No description provided for @noCurriculumsFound.
  ///
  /// In en, this message translates to:
  /// **'No curriculums found'**
  String get noCurriculumsFound;

  /// No description provided for @noSyllabusFound.
  ///
  /// In en, this message translates to:
  /// **'No syllabus found'**
  String get noSyllabusFound;

  /// No description provided for @noSubjectsFound.
  ///
  /// In en, this message translates to:
  /// **'No subjects found'**
  String get noSubjectsFound;

  /// No description provided for @noUnitsFound.
  ///
  /// In en, this message translates to:
  /// **'No units found'**
  String get noUnitsFound;

  /// No description provided for @noCompetenciesFound.
  ///
  /// In en, this message translates to:
  /// **'No competencies found'**
  String get noCompetenciesFound;

  /// No description provided for @noStrategiesFound.
  ///
  /// In en, this message translates to:
  /// **'No strategies found'**
  String get noStrategiesFound;

  /// No description provided for @downloadSample.
  ///
  /// In en, this message translates to:
  /// **'Download sample'**
  String get downloadSample;

  /// No description provided for @selectVisible.
  ///
  /// In en, this message translates to:
  /// **'Select Visible'**
  String get selectVisible;

  /// No description provided for @applySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'Apply ({count})'**
  String applySelectedCount(Object count);

  /// No description provided for @saveSelected.
  ///
  /// In en, this message translates to:
  /// **'Save Selected'**
  String get saveSelected;

  /// No description provided for @lessonCompletion.
  ///
  /// In en, this message translates to:
  /// **'Lesson completion'**
  String get lessonCompletion;

  /// No description provided for @selectCompletion.
  ///
  /// In en, this message translates to:
  /// **'Select completion'**
  String get selectCompletion;

  /// No description provided for @noStudentNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No student notes yet.'**
  String get noStudentNotesYet;

  /// No description provided for @followUpNeeded.
  ///
  /// In en, this message translates to:
  /// **'Follow up needed'**
  String get followUpNeeded;

  /// No description provided for @evidenceFile.
  ///
  /// In en, this message translates to:
  /// **'Evidence File'**
  String get evidenceFile;

  /// No description provided for @changeScoreTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change Score Type?'**
  String get changeScoreTypeTitle;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get number;

  /// No description provided for @classDetails.
  ///
  /// In en, this message translates to:
  /// **'Class Details'**
  String get classDetails;

  /// No description provided for @generatedClassName.
  ///
  /// In en, this message translates to:
  /// **'Class Name (Auto-generated)'**
  String get generatedClassName;

  /// No description provided for @generatedClassHint.
  ///
  /// In en, this message translates to:
  /// **'Generated from level, section, and year'**
  String get generatedClassHint;

  /// No description provided for @sampleImplementationFile.
  ///
  /// In en, this message translates to:
  /// **'Sample Implementation File'**
  String get sampleImplementationFile;

  /// No description provided for @allowedDocumentTypes.
  ///
  /// In en, this message translates to:
  /// **'Allowed: xls, xlsx, doc, docx, txt, md, pdf'**
  String get allowedDocumentTypes;

  /// No description provided for @deleteClassConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this class?'**
  String get deleteClassConfirm;

  /// No description provided for @deleteItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {title}'**
  String deleteItemTitle(Object title);

  /// No description provided for @deleteAnyway.
  ///
  /// In en, this message translates to:
  /// **'Delete Anyway'**
  String get deleteAnyway;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this {subject}?'**
  String deleteItemConfirm(Object subject);

  /// No description provided for @deleteConnectedItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this {subject}? This record is connected to other data.'**
  String deleteConnectedItemConfirm(Object subject);

  /// No description provided for @guardians.
  ///
  /// In en, this message translates to:
  /// **'Guardians'**
  String get guardians;

  /// No description provided for @deleteGuardianTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Guardian'**
  String get deleteGuardianTitle;

  /// No description provided for @deleteGuardianConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this guardian?'**
  String get deleteGuardianConfirm;

  /// No description provided for @noGuardiansYet.
  ///
  /// In en, this message translates to:
  /// **'No guardians yet. Add a guardian.'**
  String get noGuardiansYet;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @minimizeAssistanceMenu.
  ///
  /// In en, this message translates to:
  /// **'Minimize assistance menu'**
  String get minimizeAssistanceMenu;

  /// No description provided for @deleteRuleForStudent.
  ///
  /// In en, this message translates to:
  /// **'Delete rule for {student}?'**
  String deleteRuleForStudent(Object student);

  /// No description provided for @thisStudent.
  ///
  /// In en, this message translates to:
  /// **'this student'**
  String get thisStudent;

  /// No description provided for @selectRuleCandidates.
  ///
  /// In en, this message translates to:
  /// **'Select {rule} Candidates'**
  String selectRuleCandidates(Object rule);

  /// No description provided for @overrideReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason / override note for newly selected students'**
  String get overrideReasonHint;

  /// No description provided for @customRule.
  ///
  /// In en, this message translates to:
  /// **'Custom Rule'**
  String get customRule;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @rejectedPeriodAuditNotice.
  ///
  /// In en, this message translates to:
  /// **'Rejected periods cannot continue to distribution. Target candidates will remain visible for audit.'**
  String get rejectedPeriodAuditNotice;

  /// No description provided for @outOfCityExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Student is out of city for two months'**
  String get outOfCityExample;

  /// No description provided for @approvedPeriodCancellationHint.
  ///
  /// In en, this message translates to:
  /// **'Reason why this approved assistance period is cancelled'**
  String get approvedPeriodCancellationHint;

  /// No description provided for @selectStudentsForRule.
  ///
  /// In en, this message translates to:
  /// **'Select Students - {rule}'**
  String selectStudentsForRule(Object rule);

  /// No description provided for @ruleNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Rule name is required'**
  String get ruleNameRequired;

  /// No description provided for @classNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Class name is required'**
  String get classNameRequired;

  /// No description provided for @classNameMax40.
  ///
  /// In en, this message translates to:
  /// **'Class name must be at most 40 characters'**
  String get classNameMax40;

  /// No description provided for @duplicateClassYear.
  ///
  /// In en, this message translates to:
  /// **'Duplicate class and year'**
  String get duplicateClassYear;

  /// No description provided for @levelRequired.
  ///
  /// In en, this message translates to:
  /// **'Level is required'**
  String get levelRequired;

  /// No description provided for @sectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Section is required'**
  String get sectionRequired;

  /// No description provided for @sectionOneLetter.
  ///
  /// In en, this message translates to:
  /// **'Section must be one letter'**
  String get sectionOneLetter;

  /// No description provided for @yearRequired.
  ///
  /// In en, this message translates to:
  /// **'Year is required'**
  String get yearRequired;

  /// No description provided for @yearFourDigits.
  ///
  /// In en, this message translates to:
  /// **'Year must be 4 digits'**
  String get yearFourDigits;

  /// No description provided for @classesForSchool.
  ///
  /// In en, this message translates to:
  /// **'Classes - {school}'**
  String classesForSchool(Object school);

  /// No description provided for @deleteNamedItem.
  ///
  /// In en, this message translates to:
  /// **'Delete {item}?'**
  String deleteNamedItem(Object item);

  /// No description provided for @searchItems.
  ///
  /// In en, this message translates to:
  /// **'Search {item}'**
  String searchItems(Object item);

  /// No description provided for @schoolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage school profiles and their class structures.'**
  String get schoolsSubtitle;

  /// No description provided for @noSchoolsYet.
  ///
  /// In en, this message translates to:
  /// **'No schools yet.'**
  String get noSchoolsYet;

  /// No description provided for @noSchoolsMatch.
  ///
  /// In en, this message translates to:
  /// **'No schools match your search.'**
  String get noSchoolsMatch;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @effectiveYear.
  ///
  /// In en, this message translates to:
  /// **'Effective Year'**
  String get effectiveYear;

  /// No description provided for @sequence.
  ///
  /// In en, this message translates to:
  /// **'Sequence'**
  String get sequence;

  /// No description provided for @sample.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get sample;

  /// No description provided for @structure.
  ///
  /// In en, this message translates to:
  /// **'Structure'**
  String get structure;

  /// No description provided for @attendanceSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Search and mark attendance in the table.'**
  String get attendanceSectionSubtitle;

  /// No description provided for @assessmentSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fill scores for the selected session assessment type.'**
  String get assessmentSectionSubtitle;

  /// No description provided for @materialCovered.
  ///
  /// In en, this message translates to:
  /// **'Material covered'**
  String get materialCovered;

  /// No description provided for @classCondition.
  ///
  /// In en, this message translates to:
  /// **'Class condition'**
  String get classCondition;

  /// No description provided for @teachingChallenges.
  ///
  /// In en, this message translates to:
  /// **'Teaching challenges'**
  String get teachingChallenges;

  /// No description provided for @followUpPlan.
  ///
  /// In en, this message translates to:
  /// **'Follow up plan'**
  String get followUpPlan;

  /// No description provided for @studentNotesReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review social observations added from student assessment rows.'**
  String get studentNotesReviewSubtitle;

  /// No description provided for @socialBehaviorRating.
  ///
  /// In en, this message translates to:
  /// **'Social / behavior rating'**
  String get socialBehaviorRating;

  /// No description provided for @followUpNotes.
  ///
  /// In en, this message translates to:
  /// **'Follow up notes'**
  String get followUpNotes;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage preferences and application settings.'**
  String get settingsSubtitle;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @uiDensity.
  ///
  /// In en, this message translates to:
  /// **'UI Density'**
  String get uiDensity;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time Format'**
  String get timeFormat;

  /// No description provided for @numberFormat.
  ///
  /// In en, this message translates to:
  /// **'Number Format'**
  String get numberFormat;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @compact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get compact;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @comfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable'**
  String get comfortable;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesian;

  /// No description provided for @englishUs.
  ///
  /// In en, this message translates to:
  /// **'English US'**
  String get englishUs;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @eligibility.
  ///
  /// In en, this message translates to:
  /// **'Eligibility'**
  String get eligibility;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @uploadedAt.
  ///
  /// In en, this message translates to:
  /// **'Uploaded At'**
  String get uploadedAt;

  /// No description provided for @distributionProof.
  ///
  /// In en, this message translates to:
  /// **'Distribution Proof'**
  String get distributionProof;

  /// No description provided for @pendingRecipientStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending Recipient Status'**
  String get pendingRecipientStatus;

  /// No description provided for @noRecipientsYet.
  ///
  /// In en, this message translates to:
  /// **'No recipients yet. Upload approval document first.'**
  String get noRecipientsYet;

  /// No description provided for @noRecipientsMatch.
  ///
  /// In en, this message translates to:
  /// **'No recipients match the current filter.'**
  String get noRecipientsMatch;

  /// No description provided for @markPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark Paid'**
  String get markPaid;

  /// No description provided for @markDistributed.
  ///
  /// In en, this message translates to:
  /// **'Mark Distributed'**
  String get markDistributed;

  /// No description provided for @failedRemoveTargets.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove targets'**
  String get failedRemoveTargets;

  /// No description provided for @reportNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Report is not available.'**
  String get reportNotAvailable;

  /// No description provided for @rejectedPeriodNoDistribution.
  ///
  /// In en, this message translates to:
  /// **'Rejected assistance periods do not continue to distribution.'**
  String get rejectedPeriodNoDistribution;

  /// No description provided for @approvalRequiredFirst.
  ///
  /// In en, this message translates to:
  /// **'Approval is required first.'**
  String get approvalRequiredFirst;

  /// No description provided for @finalizeDistributionFailed.
  ///
  /// In en, this message translates to:
  /// **'Finalize Distribution Failed'**
  String get finalizeDistributionFailed;

  /// No description provided for @createAssistancePeriodFailed.
  ///
  /// In en, this message translates to:
  /// **'Create Assistance Period Failed'**
  String get createAssistancePeriodFailed;

  /// No description provided for @failedSaveManualTargets.
  ///
  /// In en, this message translates to:
  /// **'Failed to save manual targets'**
  String get failedSaveManualTargets;

  /// No description provided for @selectedTargets.
  ///
  /// In en, this message translates to:
  /// **'Selected Targets'**
  String get selectedTargets;

  /// No description provided for @waitlistCount.
  ///
  /// In en, this message translates to:
  /// **'Waitlist Count'**
  String get waitlistCount;

  /// No description provided for @ineligible.
  ///
  /// In en, this message translates to:
  /// **'Ineligible'**
  String get ineligible;

  /// No description provided for @expandAssistanceMenu.
  ///
  /// In en, this message translates to:
  /// **'Expand assistance menu'**
  String get expandAssistanceMenu;

  /// No description provided for @workflow.
  ///
  /// In en, this message translates to:
  /// **'Workflow'**
  String get workflow;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @fixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get fixed;

  /// No description provided for @rolling.
  ///
  /// In en, this message translates to:
  /// **'Rolling'**
  String get rolling;

  /// No description provided for @window.
  ///
  /// In en, this message translates to:
  /// **'Window'**
  String get window;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @improve.
  ///
  /// In en, this message translates to:
  /// **'Improve'**
  String get improve;

  /// No description provided for @bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// No description provided for @monthYear.
  ///
  /// In en, this message translates to:
  /// **'Month/Year'**
  String get monthYear;

  /// No description provided for @approvedBy.
  ///
  /// In en, this message translates to:
  /// **'Approved By'**
  String get approvedBy;

  /// No description provided for @document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get document;

  /// No description provided for @targetedAt.
  ///
  /// In en, this message translates to:
  /// **'Targeted At'**
  String get targetedAt;

  /// No description provided for @newCustomRule.
  ///
  /// In en, this message translates to:
  /// **'New Custom Rule'**
  String get newCustomRule;

  /// No description provided for @failedUpdateCandidates.
  ///
  /// In en, this message translates to:
  /// **'Failed to update candidates'**
  String get failedUpdateCandidates;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allocated.
  ///
  /// In en, this message translates to:
  /// **'Allocated'**
  String get allocated;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @createClass.
  ///
  /// In en, this message translates to:
  /// **'Create Class'**
  String get createClass;

  /// No description provided for @updateClass.
  ///
  /// In en, this message translates to:
  /// **'Update Class'**
  String get updateClass;

  /// No description provided for @approvalDocumentTitle.
  ///
  /// In en, this message translates to:
  /// **'Approval Document'**
  String get approvalDocumentTitle;

  /// No description provided for @approvalDocumentUploadedDescription.
  ///
  /// In en, this message translates to:
  /// **'Signed approval document has been uploaded. Targets are now official recipients.'**
  String get approvalDocumentUploadedDescription;

  /// No description provided for @assistancePeriodLocked.
  ///
  /// In en, this message translates to:
  /// **'This assistance period is locked.'**
  String get assistancePeriodLocked;

  /// No description provided for @approvalDocumentUploadDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload the signed approval document to approve this period and create recipients.'**
  String get approvalDocumentUploadDescription;

  /// No description provided for @uploadedDocument.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Document'**
  String get uploadedDocument;

  /// No description provided for @approvalDecision.
  ///
  /// In en, this message translates to:
  /// **'Approval Decision'**
  String get approvalDecision;

  /// No description provided for @chooseApprovalDocument.
  ///
  /// In en, this message translates to:
  /// **'Choose approval document'**
  String get chooseApprovalDocument;

  /// No description provided for @uploadApprovePeriod.
  ///
  /// In en, this message translates to:
  /// **'Upload & Approve Period'**
  String get uploadApprovePeriod;

  /// No description provided for @noApprovePeriodPermission.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to approve periods.'**
  String get noApprovePeriodPermission;

  /// No description provided for @assistancePeriodRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Assistance period rejected.'**
  String get assistancePeriodRejectedSuccess;

  /// No description provided for @rejectAssistancePeriodFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to reject assistance period'**
  String get rejectAssistancePeriodFailed;

  /// No description provided for @approvalDocumentUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Approval document uploaded. Period approved.'**
  String get approvalDocumentUploadedSuccess;

  /// No description provided for @uploadApprovePeriodFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload and approve period'**
  String get uploadApprovePeriodFailed;

  /// No description provided for @approvalRequiredDistributionMessage.
  ///
  /// In en, this message translates to:
  /// **'Upload the signed approval document in Review & Approval before managing distribution.'**
  String get approvalRequiredDistributionMessage;

  /// No description provided for @bulkRecipientActions.
  ///
  /// In en, this message translates to:
  /// **'Bulk recipient actions'**
  String get bulkRecipientActions;

  /// No description provided for @markAllPaidDistributed.
  ///
  /// In en, this message translates to:
  /// **'Mark All Paid / Distributed'**
  String get markAllPaidDistributed;

  /// No description provided for @cancelAll.
  ///
  /// In en, this message translates to:
  /// **'Cancel All'**
  String get cancelAll;

  /// No description provided for @bulkAction.
  ///
  /// In en, this message translates to:
  /// **'Bulk Action'**
  String get bulkAction;

  /// No description provided for @reportFinalized.
  ///
  /// In en, this message translates to:
  /// **'Report & Finalized'**
  String get reportFinalized;

  /// No description provided for @assistancePeriodFinalizedMessage.
  ///
  /// In en, this message translates to:
  /// **'This assistance period has been finalized.'**
  String get assistancePeriodFinalizedMessage;

  /// No description provided for @distributionFinalizeInstruction.
  ///
  /// In en, this message translates to:
  /// **'Fill each recipient status and upload the signed distribution list before finalizing.'**
  String get distributionFinalizeInstruction;

  /// No description provided for @finalizeActions.
  ///
  /// In en, this message translates to:
  /// **'Finalize actions'**
  String get finalizeActions;

  /// No description provided for @finalizeDistribution.
  ///
  /// In en, this message translates to:
  /// **'Finalize Distribution'**
  String get finalizeDistribution;

  /// No description provided for @finalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing...'**
  String get finalizing;

  /// No description provided for @finalizeAction.
  ///
  /// In en, this message translates to:
  /// **'Finalize Action'**
  String get finalizeAction;

  /// No description provided for @distributionEvidence.
  ///
  /// In en, this message translates to:
  /// **'Distribution Evidence'**
  String get distributionEvidence;

  /// No description provided for @documentCountOfFive.
  ///
  /// In en, this message translates to:
  /// **'{count} / 5 documents'**
  String documentCountOfFive(Object count);

  /// No description provided for @chooseEvidence.
  ///
  /// In en, this message translates to:
  /// **'Choose Evidence'**
  String get chooseEvidence;

  /// No description provided for @uploadEvidence.
  ///
  /// In en, this message translates to:
  /// **'Upload Evidence'**
  String get uploadEvidence;

  /// No description provided for @evidenceFileRemarks.
  ///
  /// In en, this message translates to:
  /// **'Evidence file remarks'**
  String get evidenceFileRemarks;

  /// No description provided for @evidenceFileRemarksHint.
  ///
  /// In en, this message translates to:
  /// **'Describe this distribution evidence file'**
  String get evidenceFileRemarksHint;

  /// No description provided for @maximumDistributionEvidence.
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 distribution evidence documents uploaded.'**
  String get maximumDistributionEvidence;

  /// No description provided for @distributionEvidenceDocuments.
  ///
  /// In en, this message translates to:
  /// **'Distribution Evidence Documents'**
  String get distributionEvidenceDocuments;

  /// No description provided for @noDistributionEvidence.
  ///
  /// In en, this message translates to:
  /// **'No distribution evidence document uploaded.'**
  String get noDistributionEvidence;

  /// No description provided for @deleteEvidence.
  ///
  /// In en, this message translates to:
  /// **'Delete evidence'**
  String get deleteEvidence;

  /// No description provided for @distributionEvidenceUploaded.
  ///
  /// In en, this message translates to:
  /// **'Distribution evidence uploaded.'**
  String get distributionEvidenceUploaded;

  /// No description provided for @uploadDistributionEvidenceFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload distribution evidence failed'**
  String get uploadDistributionEvidenceFailed;

  /// No description provided for @deleteDistributionEvidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Distribution Evidence?'**
  String get deleteDistributionEvidenceTitle;

  /// No description provided for @deleteDistributionEvidenceMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{fileName}\"? This also removes the stored file.'**
  String deleteDistributionEvidenceMessage(Object fileName);

  /// No description provided for @distributionEvidenceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Distribution evidence deleted.'**
  String get distributionEvidenceDeleted;

  /// No description provided for @deleteDistributionEvidenceFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete distribution evidence failed'**
  String get deleteDistributionEvidenceFailed;

  /// No description provided for @markAllRecipientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark All Recipients?'**
  String get markAllRecipientsTitle;

  /// No description provided for @markAllRecipientsMessage.
  ///
  /// In en, this message translates to:
  /// **'Cash benefits will be marked as Paid. Goods and other benefits will be marked as Distributed.'**
  String get markAllRecipientsMessage;

  /// No description provided for @markAll.
  ///
  /// In en, this message translates to:
  /// **'Mark All'**
  String get markAll;

  /// No description provided for @allRecipientStatusesUpdated.
  ///
  /// In en, this message translates to:
  /// **'All recipient statuses updated.'**
  String get allRecipientStatusesUpdated;

  /// No description provided for @updateAllRecipientsFailed.
  ///
  /// In en, this message translates to:
  /// **'Update all recipients failed'**
  String get updateAllRecipientsFailed;

  /// No description provided for @cancelAllRecipientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel All Recipients?'**
  String get cancelAllRecipientsTitle;

  /// No description provided for @cancelAllRecipientsHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why all recipient distributions are cancelled.'**
  String get cancelAllRecipientsHint;

  /// No description provided for @cancellationReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason is required.'**
  String get cancellationReasonRequired;

  /// No description provided for @allRecipientsCancelled.
  ///
  /// In en, this message translates to:
  /// **'All recipients cancelled.'**
  String get allRecipientsCancelled;

  /// No description provided for @cancelAllRecipientsFailed.
  ///
  /// In en, this message translates to:
  /// **'Cancel all recipients failed'**
  String get cancelAllRecipientsFailed;

  /// No description provided for @resetAllRecipientStatusesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset All Recipient Statuses?'**
  String get resetAllRecipientStatusesTitle;

  /// No description provided for @resetAllRecipientStatusesMessage.
  ///
  /// In en, this message translates to:
  /// **'All recipient statuses will return to Approved and cancellation reasons will be cleared.'**
  String get resetAllRecipientStatusesMessage;

  /// No description provided for @allRecipientStatusesReset.
  ///
  /// In en, this message translates to:
  /// **'All recipient statuses reset.'**
  String get allRecipientStatusesReset;

  /// No description provided for @resetAllRecipientsFailed.
  ///
  /// In en, this message translates to:
  /// **'Reset all recipients failed'**
  String get resetAllRecipientsFailed;

  /// No description provided for @recipientStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recipient status updated.'**
  String get recipientStatusUpdated;

  /// No description provided for @assistancePeriodFinalizedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Assistance period finalized as distributed.'**
  String get assistancePeriodFinalizedSuccess;

  /// No description provided for @assistancePeriodCancelledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Assistance period cancelled.'**
  String get assistancePeriodCancelledSuccess;

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String errorWithDetails(Object details);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
