class StudentFilter {
  final List<String>? keyword;
  final List<String>? status;
  final List<String>? classNames;
  final List<String>? schoolNames;
  final List<String>? joinAt;

  const StudentFilter({
    this.keyword,
    this.status,
    this.classNames,
    this.schoolNames,
    this.joinAt,
  });
}
