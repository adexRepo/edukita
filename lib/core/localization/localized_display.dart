import 'package:edukita/core/localization/localization_extension.dart';
import 'package:flutter/widgets.dart';

String translateStudentStatus(BuildContext context, String status) {
  return switch (_normalize(status)) {
    'ACTIVE' => context.l10n.statusActive,
    'INACTIVE' => context.l10n.statusInactive,
    _ => status,
  };
}

String translateGender(BuildContext context, String gender) {
  return switch (_normalize(gender)) {
    'MALE' => context.l10n.genderMale,
    'FEMALE' => context.l10n.genderFemale,
    _ => gender,
  };
}

String translateAttendanceStatus(BuildContext context, String status) {
  return switch (_normalize(status)) {
    'PRESENT' => context.l10n.attendancePresent,
    'ABSENT' => context.l10n.attendanceAbsent,
    'SICK' => context.l10n.attendanceSick,
    'PERMISSION' => context.l10n.attendancePermission,
    'LATE' => context.l10n.attendanceLate,
    _ => status,
  };
}

String _normalize(String value) {
  return value.trim().replaceAll('-', '_').replaceAll(' ', '_').toUpperCase();
}
