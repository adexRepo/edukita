class StudentFilter {
  final String? keyword; // for student_no / nis / name
  final String? status;
  final String? className;
  final String? schoolName;
  final String? joinAt;

  const StudentFilter({
    this.keyword,
    this.status,
    this.className,
    this.schoolName,
    this.joinAt,
  });
}
