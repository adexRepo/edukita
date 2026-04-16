String? nullIfEmpty(String value) {
  final v = value.trim();
  return v.isEmpty ? null : v;
}
