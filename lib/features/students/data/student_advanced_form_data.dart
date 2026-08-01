import 'package:edukita/features/management/data/guardian_model.dart';

class StudentAdvancedFormData {
  const StudentAdvancedFormData({
    this.health = const StudentHealthFormData(),
    this.relations = const [],
    this.activities = const [],
    this.registrationForm = const StudentDocumentFormData(
      documentType: StudentDocumentTypeOptions.registrationForm,
    ),
    this.householdProfile = const StudentHouseholdProfileFormData(),
    this.hobby,
    this.aspiration,
  });

  final StudentHealthFormData health;
  final List<StudentRelationFormData> relations;
  final List<StudentActivityFormData> activities;
  final StudentDocumentFormData registrationForm;
  final StudentHouseholdProfileFormData householdProfile;
  final String? hobby;
  final String? aspiration;

  bool get hasData {
    return health.hasData ||
        relations.any((relation) => relation.hasData) ||
        activities.any((activity) => activity.hasData) ||
        registrationForm.hasFile ||
        householdProfile.hasData ||
        _hasText(hobby) ||
        _hasText(aspiration);
  }

  StudentAdvancedFormData copyWith({
    StudentHealthFormData? health,
    List<StudentRelationFormData>? relations,
    List<StudentActivityFormData>? activities,
    StudentDocumentFormData? registrationForm,
    StudentHouseholdProfileFormData? householdProfile,
    String? hobby,
    String? aspiration,
  }) {
    return StudentAdvancedFormData(
      health: health ?? this.health,
      relations: relations ?? this.relations,
      activities: activities ?? this.activities,
      registrationForm: registrationForm ?? this.registrationForm,
      householdProfile: householdProfile ?? this.householdProfile,
      hobby: hobby ?? this.hobby,
      aspiration: aspiration ?? this.aspiration,
    );
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

  StudentDocumentFormData copyWith({
    String? id,
    String? documentType,
    String? fileName,
    String? filePath,
    String? sourcePath,
    String? uploadedAt,
    bool clearSourcePath = false,
  }) {
    return StudentDocumentFormData(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      sourcePath: clearSourcePath ? null : sourcePath ?? this.sourcePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

class StudentHouseholdProfileFormData {
  const StudentHouseholdProfileFormData({
    this.id,
    this.homeAddress,
    this.dailySchoolTransportCost,
    this.fatherIncome,
    this.motherIncome,
    this.housingStatus,
    this.householdMemberCount,
    this.educationArrears,
    this.academicAchievement,
    this.nonAcademicAchievement,
  });

  final String? id;
  final String? homeAddress;
  final double? dailySchoolTransportCost;
  final double? fatherIncome;
  final double? motherIncome;
  final String? housingStatus;
  final int? householdMemberCount;
  final double? educationArrears;
  final String? academicAchievement;
  final String? nonAcademicAchievement;

  bool get hasData {
    return _hasText(homeAddress) ||
        dailySchoolTransportCost != null ||
        fatherIncome != null ||
        motherIncome != null ||
        _hasText(housingStatus) ||
        householdMemberCount != null ||
        educationArrears != null ||
        _hasText(academicAchievement) ||
        _hasText(nonAcademicAchievement);
  }
}

class StudentHousingStatusOptions {
  StudentHousingStatusOptions._();

  static const owned = 'OWNED';
  static const rented = 'RENTED';
  static const stayingWithFamily = 'STAYING_WITH_FAMILY';
  static const other = 'OTHER';

  static const values = [owned, rented, stayingWithFamily, other];

  static String label(String value) {
    return switch (value) {
      owned => 'Owned',
      rented => 'Rented',
      stayingWithFamily => 'Staying with family',
      _ => 'Other',
    };
  }
}

class StudentDocumentTypeOptions {
  StudentDocumentTypeOptions._();

  static const registrationForm = 'REGISTRATION_FORM';
  static const studentStoryReport = 'STUDENT_STORY_REPORT';
}

class StudentGeneratedReportFile {
  const StudentGeneratedReportFile({
    required this.id,
    required this.fileName,
    required this.filePath,
    this.fileType,
    this.fileSize = 0,
    this.generatedBy,
    required this.generatedAt,
    this.remarks,
  });

  final String id;
  final String fileName;
  final String filePath;
  final String? fileType;
  final int fileSize;
  final String? generatedBy;
  final String generatedAt;
  final String? remarks;

  String get versionNote {
    final note = _extractRemarkValue('note');
    if (note == null || note.isEmpty) return '-';
    return note;
  }

  String get completenessSnapshot {
    final value = _extractRemarkValue('completeness');
    if (value == null || value.isEmpty) return '-';
    return value;
  }

  String? _extractRemarkValue(String key) {
    final source = remarks;
    if (source == null || source.trim().isEmpty) return null;
    final prefix = '$key=';
    for (final part in source.split('|')) {
      final trimmed = part.trim();
      if (trimmed.startsWith(prefix)) {
        return trimmed.substring(prefix.length).trim();
      }
    }
    return null;
  }

  factory StudentGeneratedReportFile.fromMap(Map<String, Object?> map) {
    return StudentGeneratedReportFile(
      id: map['id']?.toString() ?? '',
      fileName:
          map['original_file_name']?.toString() ??
          map['stored_file_name']?.toString() ??
          'student-story.pdf',
      filePath: map['file_path']?.toString() ?? '',
      fileType: map['file_type']?.toString(),
      fileSize: (map['file_size'] as num?)?.toInt() ?? 0,
      generatedBy: map['uploaded_by']?.toString(),
      generatedAt: map['uploaded_at']?.toString() ?? '',
      remarks: map['remarks']?.toString(),
    );
  }
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
