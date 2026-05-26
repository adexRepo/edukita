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
}

class StudentFilter {
  final List<String> keyword;
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
  final List<String> keywordNot;

  const StudentFilter({
    this.keyword = const [],
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
    this.keywordNot = const [],
  });

  bool get isEmpty =>
      keyword.isEmpty &&
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
      keywordNot.isEmpty;

  StudentFilter copyWith({
    List<String>? keyword,
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
    List<String>? keywordNot,
  }) {
    return StudentFilter(
      keyword: keyword ?? this.keyword,
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
      keywordNot: keywordNot ?? this.keywordNot,
    );
  }
}

StudentFilter buildStudentFilter(List<MultiFilterItem> items) {
  return StudentFilter(
    keyword: [
      ...items.mapStringByOperator(
        StudentFilterCodes.name,
        FilterOperator.isEqual,
      ),
      ...items.mapStringByOperator(
        StudentFilterCodes.name,
        FilterOperator.contains,
      ),
      ...items.mapStringByOperator(
        StudentFilterCodes.studentId,
        FilterOperator.isEqual,
      ),
      ...items.mapStringByOperator(
        StudentFilterCodes.studentId,
        FilterOperator.contains,
      ),
    ],
    keywordNot: [
      ...items.mapStringByOperator(
        StudentFilterCodes.name,
        FilterOperator.isNot,
      ),
      ...items.mapStringByOperator(
        StudentFilterCodes.studentId,
        FilterOperator.isNot,
      ),
    ],
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
    options: ["active", "inactive", "graduated"],
  ),

  // ✅ DATE PICKER
  FilterField(
    code: StudentFilterCodes.joinDate.name,
    label: "Join Date",
    inputType: FilterInputType.date,
  ),
];
