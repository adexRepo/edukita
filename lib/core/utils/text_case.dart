class TextCase {
  TextCase._();

  static String titleWords(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return '';

    final words = text
        .replaceAll(RegExp(r'[_\-]+'), ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);

    return words.map(_capitalize).join(' ');
  }

  static String _capitalize(String word) {
    final lower = word.toLowerCase();
    return '${lower[0].toUpperCase()}${lower.substring(1)}';
  }
}

extension TextCaseX on String {
  String get titleWords => TextCase.titleWords(this);
}
