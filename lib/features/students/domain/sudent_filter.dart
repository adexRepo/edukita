import 'package:edukita/core/helper/com_enum.dart';
import 'package:edukita/core/helper/extensions.dart';
import 'package:edukita/widgets/multi_filter.dart';

enum StudentFilterCodes {
  name,
  studentId,
  className,
  schoolName,
  age,
  gender,
  status,
  score,
  joinDate,
  duafaStatus,
  teachingLocation,
  profileStatus,
}

class StudentFilter {
  final List<String> namesEqual;
  final List<String> namesContains;
  final List<String> namesNot;
  final List<String> studentIdsEqual;
  final List<String> studentIdsContains;
  final List<String> studentIdsNot;
  final List<String> status;
  final List<String> statusNot;
  final List<String> classNames;
  final List<String> classNamesNot;
  final List<String> schoolNames;
  final List<String> schoolNamesNot;
  final List<String> joinAt;
  final List<String> joinAtNot;
  final List<double> scores;
  final List<double> scoresNot;
  final List<int> ages;
  final List<int> agesNot;
  final List<String> genders;
  final List<String> gendersNot;
  final List<String> duafaStatuses;
  final List<String> duafaStatusesNot;
  final List<String> teachingLocations;
  final List<String> teachingLocationsNot;
  final List<String> profileStatuses;
  final List<String> profileStatusesNot;

  const StudentFilter({
    this.namesEqual = const [],
    this.namesContains = const [],
    this.namesNot = const [],
    this.studentIdsEqual = const [],
    this.studentIdsContains = const [],
    this.studentIdsNot = const [],
    this.status = const [],
    this.statusNot = const [],
    this.classNames = const [],
    this.classNamesNot = const [],
    this.schoolNames = const [],
    this.schoolNamesNot = const [],
    this.joinAt = const [],
    this.joinAtNot = const [],
    this.scores = const [],
    this.scoresNot = const [],
    this.ages = const [],
    this.agesNot = const [],
    this.genders = const [],
    this.gendersNot = const [],
    this.duafaStatuses = const [],
    this.duafaStatusesNot = const [],
    this.teachingLocations = const [],
    this.teachingLocationsNot = const [],
    this.profileStatuses = const [],
    this.profileStatusesNot = const [],
  });

  bool get isEmpty =>
      namesEqual.isEmpty &&
      namesContains.isEmpty &&
      namesNot.isEmpty &&
      studentIdsEqual.isEmpty &&
      studentIdsContains.isEmpty &&
      studentIdsNot.isEmpty &&
      status.isEmpty &&
      statusNot.isEmpty &&
      classNames.isEmpty &&
      classNamesNot.isEmpty &&
      schoolNames.isEmpty &&
      schoolNamesNot.isEmpty &&
      joinAt.isEmpty &&
      joinAtNot.isEmpty &&
      scores.isEmpty &&
      scoresNot.isEmpty &&
      ages.isEmpty &&
      agesNot.isEmpty &&
      genders.isEmpty &&
      gendersNot.isEmpty &&
      duafaStatuses.isEmpty &&
      duafaStatusesNot.isEmpty &&
      teachingLocations.isEmpty &&
      teachingLocationsNot.isEmpty &&
      profileStatuses.isEmpty &&
      profileStatusesNot.isEmpty;

  StudentFilter copyWith({
    List<String>? namesEqual,
    List<String>? namesContains,
    List<String>? namesNot,
    List<String>? studentIdsEqual,
    List<String>? studentIdsContains,
    List<String>? studentIdsNot,
    List<String>? status,
    List<String>? statusNot,
    List<String>? classNames,
    List<String>? classNamesNot,
    List<String>? schoolNames,
    List<String>? schoolNamesNot,
    List<String>? joinAt,
    List<String>? joinAtNot,
    List<double>? scores,
    List<double>? scoresNot,
    List<int>? ages,
    List<int>? agesNot,
    List<String>? genders,
    List<String>? gendersNot,
    List<String>? duafaStatuses,
    List<String>? duafaStatusesNot,
    List<String>? teachingLocations,
    List<String>? teachingLocationsNot,
    List<String>? profileStatuses,
    List<String>? profileStatusesNot,
  }) {
    return StudentFilter(
      namesEqual: namesEqual ?? this.namesEqual,
      namesContains: namesContains ?? this.namesContains,
      namesNot: namesNot ?? this.namesNot,
      studentIdsEqual: studentIdsEqual ?? this.studentIdsEqual,
      studentIdsContains: studentIdsContains ?? this.studentIdsContains,
      studentIdsNot: studentIdsNot ?? this.studentIdsNot,
      status: status ?? this.status,
      statusNot: statusNot ?? this.statusNot,
      classNames: classNames ?? this.classNames,
      classNamesNot: classNamesNot ?? this.classNamesNot,
      schoolNames: schoolNames ?? this.schoolNames,
      schoolNamesNot: schoolNamesNot ?? this.schoolNamesNot,
      joinAt: joinAt ?? this.joinAt,
      joinAtNot: joinAtNot ?? this.joinAtNot,
      scores: scores ?? this.scores,
      scoresNot: scoresNot ?? this.scoresNot,
      ages: ages ?? this.ages,
      agesNot: agesNot ?? this.agesNot,
      genders: genders ?? this.genders,
      gendersNot: gendersNot ?? this.gendersNot,
      duafaStatuses: duafaStatuses ?? this.duafaStatuses,
      duafaStatusesNot: duafaStatusesNot ?? this.duafaStatusesNot,
      teachingLocations: teachingLocations ?? this.teachingLocations,
      teachingLocationsNot: teachingLocationsNot ?? this.teachingLocationsNot,
      profileStatuses: profileStatuses ?? this.profileStatuses,
      profileStatusesNot: profileStatusesNot ?? this.profileStatusesNot,
    );
  }
}

StudentFilter buildStudentFilter(List<MultiFilterItem> items) {
  return StudentFilter(
    namesEqual: items.mapStringByOperator(
      StudentFilterCodes.name,
      FilterOperator.isEqual,
    ),
    namesContains: items.mapStringByOperator(
      StudentFilterCodes.name,
      FilterOperator.contains,
    ),
    namesNot: items.mapStringByOperator(
      StudentFilterCodes.name,
      FilterOperator.isNot,
    ),
    studentIdsEqual: items.mapStringByOperator(
      StudentFilterCodes.studentId,
      FilterOperator.isEqual,
    ),
    studentIdsContains: items.mapStringByOperator(
      StudentFilterCodes.studentId,
      FilterOperator.contains,
    ),
    studentIdsNot: items.mapStringByOperator(
      StudentFilterCodes.studentId,
      FilterOperator.isNot,
    ),
    status: items.mapStringByOperator(
      StudentFilterCodes.status,
      FilterOperator.isEqual,
    ),
    statusNot: items.mapStringByOperator(
      StudentFilterCodes.status,
      FilterOperator.isNot,
    ),
    classNames: items.mapStringByOperator(
      StudentFilterCodes.className,
      FilterOperator.isEqual,
    ),
    classNamesNot: items.mapStringByOperator(
      StudentFilterCodes.className,
      FilterOperator.isNot,
    ),
    schoolNames: items.mapStringByOperator(
      StudentFilterCodes.schoolName,
      FilterOperator.isEqual,
    ),
    schoolNamesNot: items.mapStringByOperator(
      StudentFilterCodes.schoolName,
      FilterOperator.isNot,
    ),
    joinAt: items.mapStringByOperator(
      StudentFilterCodes.joinDate,
      FilterOperator.isEqual,
    ),
    joinAtNot: items.mapStringByOperator(
      StudentFilterCodes.joinDate,
      FilterOperator.isNot,
    ),
    ages: items.mapIntByOperator(StudentFilterCodes.age, FilterOperator.isEqual),
    agesNot: items.mapIntByOperator(StudentFilterCodes.age, FilterOperator.isNot),
    scores: items.mapDoubleByOperator(
      StudentFilterCodes.score,
      FilterOperator.isEqual,
    ),
    scoresNot: items.mapDoubleByOperator(
      StudentFilterCodes.score,
      FilterOperator.isNot,
    ),
    genders: items
        .mapStringByOperator(StudentFilterCodes.gender, FilterOperator.isEqual)
        .map((value) => value.toLowerCase())
        .toList(),
    gendersNot: items
        .mapStringByOperator(StudentFilterCodes.gender, FilterOperator.isNot)
        .map((value) => value.toLowerCase())
        .toList(),
    duafaStatuses: items.mapStringByOperator(
      StudentFilterCodes.duafaStatus,
      FilterOperator.isEqual,
    ),
    duafaStatusesNot: items.mapStringByOperator(
      StudentFilterCodes.duafaStatus,
      FilterOperator.isNot,
    ),
    teachingLocations: items.mapStringByOperator(
      StudentFilterCodes.teachingLocation,
      FilterOperator.isEqual,
    ),
    teachingLocationsNot: items.mapStringByOperator(
      StudentFilterCodes.teachingLocation,
      FilterOperator.isNot,
    ),
    profileStatuses: items.mapStringByOperator(
      StudentFilterCodes.profileStatus,
      FilterOperator.isEqual,
    ),
    profileStatusesNot: items.mapStringByOperator(
      StudentFilterCodes.profileStatus,
      FilterOperator.isNot,
    ),
  );
}

final List<FilterField> studentFilterFields = [
  FilterField(
    code: StudentFilterCodes.name.name,
    label: "Name",
    inputType: FilterInputType.text,
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return "Name cannot be empty";
      }
      if (value.length < 2) {
        return "Name too short";
      }
      return null;
    },
  ),

  FilterField(
    code: StudentFilterCodes.studentId.name,
    label: "Student ID",
    inputType: FilterInputType.text,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Student ID is required";
      }
      final regex = RegExp(r'^[A-Za-z0-9\-]+$');
      if (!regex.hasMatch(value)) {
        return "Invalid Student ID format";
      }
      return null;
    },
  ),

  FilterField(
    code: StudentFilterCodes.className.name,
    label: "Class",
    inputType: FilterInputType.text,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Class is required";
      }
      return null;
    },
  ),

  FilterField(
    code: StudentFilterCodes.schoolName.name,
    label: "School",
    inputType: FilterInputType.text,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "School cannot be empty";
      }
      return null;
    },
  ),

  FilterField(
    code: StudentFilterCodes.age.name,
    label: "Age",
    inputType: FilterInputType.number,
    validator: (value) {
      if (value == null || value.isEmpty) return null;

      final age = int.tryParse(value);
      if (age == null) return "Age must be a number";
      if (age < 1 || age > 120) return "Age must be between 1–120";
      return null;
    },
  ),

  // ✅ DROPDOWN
  FilterField(
    code: StudentFilterCodes.gender.name,
    label: "Gender",
    inputType: FilterInputType.dropdown,
    options: [Gender.male.name, Gender.female.name],
  ),

  FilterField(
    code: StudentFilterCodes.score.name,
    label: "Score",
    inputType: FilterInputType.number,
    validator: (value) {
      if (value == null || value.isEmpty) return null;

      final score = double.tryParse(value);
      if (score == null) return "Score must be numeric";
      if (score < 0 || score > 100) return "Score must be 0–100";
      return null;
    },
  ),

  // ✅ DROPDOWN
  FilterField(
    code: StudentFilterCodes.status.name,
    label: "Status",
    inputType: FilterInputType.dropdown,
    options: ["active", "warning", "inactive"],
  ),

  // ✅ DATE PICKER
  FilterField(
    code: StudentFilterCodes.duafaStatus.name,
    label: "Status Dhuafa",
    inputType: FilterInputType.dropdown,
    options: ["Dhuafa", "Yatim", "Piatu", "Yatim Piatu"],
  ),

  FilterField(
    code: StudentFilterCodes.teachingLocation.name,
    label: "Student Location",
    inputType: FilterInputType.dropdown,
  ),

  FilterField(
    code: StudentFilterCodes.profileStatus.name,
    label: "Profile Status",
    inputType: FilterInputType.dropdown,
    options: ["complete", "quick_registered"],
  ),

  FilterField(
    code: StudentFilterCodes.joinDate.name,
    label: "Join Date",
    inputType: FilterInputType.date,
  ),
];
