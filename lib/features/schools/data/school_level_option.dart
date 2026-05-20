import 'package:edukita/features/schools/data/school_model.dart';

class SchoolLevelOption {
  const SchoolLevelOption(this.level);

  final int level;

  String get label => schoolLevelLabel(level);

  static const values = [
    SchoolLevelOption(0),
    SchoolLevelOption(1),
    SchoolLevelOption(2),
    SchoolLevelOption(3),
    SchoolLevelOption(4),
    SchoolLevelOption(5),
    SchoolLevelOption(6),
    SchoolLevelOption(7),
    SchoolLevelOption(8),
    SchoolLevelOption(9),
    SchoolLevelOption(10),
    SchoolLevelOption(11),
    SchoolLevelOption(12),
    SchoolLevelOption(13),
  ];

  static SchoolLevelOption? fromLevel(int? level) {
    if (level == null) return null;
    for (final option in values) {
      if (option.level == level) return option;
    }
    return null;
  }
}

String schoolLevelLabel(int? level) {
  if (level == null) return '-';
  if (level == 0) return 'TK/PAUD';
  if (level == 13) return 'University';

  final type = switch (SchoolType.fromLevel(level)) {
    SchoolType.sd => 'SD',
    SchoolType.smp => 'SMP',
    SchoolType.sma || SchoolType.smk => 'SMA',
    _ => 'Level',
  };

  return '$type - Level $level';
}
