import 'package:path/path.dart' as p;

String generatedFileName(String fileName, {DateTime? now}) {
  final timestamp = _timestamp(now ?? DateTime.now());
  final extension = p.extension(fileName);
  final baseName = extension.isEmpty
      ? fileName
      : fileName.substring(0, fileName.length - extension.length);
  final safeBaseName = baseName.trim().isEmpty ? 'file' : baseName.trim();
  return '$safeBaseName-$timestamp$extension';
}

String _timestamp(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final second = value.second.toString().padLeft(2, '0');
  return '${year}${month}${day}-${hour}${minute}${second}';
}
