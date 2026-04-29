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
  final List<String> classNames;
  final List<String> schoolNames;
  final List<String> joinAt;
  final List<double> scores;
  final List<int> ages;
  final List<String> genders;

  const StudentFilter({
    this.keyword = const [],
    this.status = const [],
    this.classNames = const [],
    this.schoolNames = const [],
    this.joinAt = const [],
    this.scores = const [],
    this.ages = const [],
    this.genders = const [],
  });

  bool get isEmpty =>
      keyword.isEmpty &&
      status.isEmpty &&
      classNames.isEmpty &&
      schoolNames.isEmpty &&
      joinAt.isEmpty &&
      scores.isEmpty &&
      ages.isEmpty &&
      genders.isEmpty;

  StudentFilter copyWith({
    List<String>? keyword,
    List<String>? status,
    List<String>? classNames,
    List<String>? schoolNames,
    List<String>? joinAt,
    List<double>? scores,
    List<int>? ages,
    List<String>? genders,
  }) {
    return StudentFilter(
      keyword: keyword ?? this.keyword,
      status: status ?? this.status,
      classNames: classNames ?? this.classNames,
      schoolNames: schoolNames ?? this.schoolNames,
      joinAt: joinAt ?? this.joinAt,
      scores: scores ?? this.scores,
      ages: ages ?? this.ages,
      genders: genders ?? this.genders,
    );
  }
}

StudentFilter buildStudentFilter(List<MultiFilterItem> items) {
  return StudentFilter(
    keyword: [
      ...items.mapString(StudentFilterCodes.name),
      ...items.mapString(StudentFilterCodes.studentId),
    ],
    status: items.mapString(StudentFilterCodes.status),
    classNames: items.mapString(StudentFilterCodes.className),
    schoolNames: items.mapString(StudentFilterCodes.schoolName),
    joinAt: items.mapString(StudentFilterCodes.joinDate),
    ages: items.mapInt(StudentFilterCodes.age),
    scores: items.mapDouble(StudentFilterCodes.score),
    genders: items
        .mapString(StudentFilterCodes.gender)
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
