import 'package:edukita/features/management/data/guardian_model.dart';

class StudentAdvancedFormData {
  const StudentAdvancedFormData({
    this.health = const StudentHealthFormData(),
    this.relations = const [],
    this.activities = const [],
    this.registrationForm = const StudentDocumentFormData(
      documentType: StudentDocumentTypeOptions.registrationForm,
    ),
    this.hobby,
    this.aspiration,
  });

  final StudentHealthFormData health;
  final List<StudentRelationFormData> relations;
  final List<StudentActivityFormData> activities;
  final StudentDocumentFormData registrationForm;
  final String? hobby;
  final String? aspiration;

  bool get hasData {
    return health.hasData ||
        relations.any((relation) => relation.hasData) ||
        activities.any((activity) => activity.hasData) ||
        registrationForm.hasFile ||
        _hasText(hobby) ||
        _hasText(aspiration);
  }
}

class StudentDocumentFormData {
  const StudentDocumentFormData({
    this.id,
    this.documentType,
    this.fileName,
    this.filePath,
    this.sourcePath,
    this.uploadedAt,
  });

  final String? id;
  final String? documentType;
  final String? fileName;
  final String? filePath;
  final String? sourcePath;
  final String? uploadedAt;

  bool get hasFile {
    return _hasText(sourcePath) || _hasText(filePath);
  }
}

class StudentDocumentTypeOptions {
  StudentDocumentTypeOptions._();

  static const registrationForm = 'REGISTRATION_FORM';
}

class StudentHealthFormData {
  const StudentHealthFormData({
    this.id,
    this.bloodType,
    this.allergies,
    this.medicalNotes,
    this.disabilities,
    this.updatedAt,
  });

  final String? id;
  final String? bloodType;
  final String? allergies;
  final String? medicalNotes;
  final String? disabilities;
  final String? updatedAt;

  bool get hasData {
    return [bloodType, allergies, medicalNotes, disabilities].any(_hasText);
  }
}

class StudentRelationFormData {
  const StudentRelationFormData({
    this.id,
    this.relatedStudentId,
    this.relatedStudentNo,
    this.relatedStudentName,
    this.relationType,
    this.agePosition,
  });

  final String? id;
  final String? relatedStudentId;
  final String? relatedStudentNo;
  final String? relatedStudentName;
  final String? relationType;
  final String? agePosition;

  bool get hasData {
    return [relatedStudentId, relatedStudentNo].any(_hasText);
  }
}

class StudentActivityFormData {
  const StudentActivityFormData({
    this.id,
    this.activityId,
    this.name,
    this.type,
    this.role,
    this.achievement,
    this.startDate,
    this.endDate,
  });

  final String? id;
  final String? activityId;
  final String? name;
  final String? type;
  final String? role;
  final String? achievement;
  final String? startDate;
  final String? endDate;

  bool get hasData {
    return [name, role, achievement, startDate, endDate].any(_hasText);
  }
}

class StudentSiblingLookupResult {
  const StudentSiblingLookupResult({
    required this.studentId,
    this.studentNo,
    this.fullName,
    this.guardians = const [],
  });

  final String studentId;
  final String? studentNo;
  final String? fullName;
  final List<StudentGuardianFormData> guardians;
}

class StudentRelationOptions {
  StudentRelationOptions._();

  static const relationTypes = ['BROTHER', 'SISTER'];
  static const agePositions = ['OLDER', 'YOUNGER'];
}

class StudentActivityTypeOptions {
  StudentActivityTypeOptions._();

  static const _legacySchoolExtracurricular = 'SCHOOL_EXTRACURRICULAR';
  static const _legacyOtherActivity = 'OTHER_ACTIVITY';

  static const schoolExtracurricular = 'School Extracurricular';
  static const otherActivity = 'Other Activity';

  static const values = [
    schoolExtracurricular,
    'Tahfidz',
    'Pramuka',
    'Futsal',
    'Martial Arts',
    'Arts',
    'Robotics Club',
    'Language Club',
    'Community Service',
    'Competition',
    otherActivity,
  ];

  static String normalize(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return schoolExtracurricular;

    final upper = text.toUpperCase();
    if (upper == _legacySchoolExtracurricular) {
      return schoolExtracurricular;
    }
    if (upper == _legacyOtherActivity) {
      return otherActivity;
    }
    return text;
  }

  static bool isSchoolExtracurricular(String? value) {
    return normalize(value).toLowerCase() ==
        schoolExtracurricular.toLowerCase();
  }

  static bool isOtherActivity(String? value) {
    return normalize(value).toLowerCase() == otherActivity.toLowerCase();
  }
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
