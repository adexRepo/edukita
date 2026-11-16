import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/persentation/detail/attendance_line_chart.dart';
import 'package:edukita/features/students/persentation/detail/student_info_tile.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:flutter/material.dart';

class StudentHeaderDetail extends StatelessWidget {
  const StudentHeaderDetail({
    super.key,
    required this.student,
    this.monthlyAttendance,
  });

  final StudentDetailData student;
  final List<double?>? monthlyAttendance;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
      final info = StudentInfoTile(student: student);
      final chart = SizedBox(
        height: 300 * scale,
        child: AttendanceLineChart(monthlyAttendance: monthlyAttendance),
      );
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppRadii.panel),
        ),
        child: constraints.maxWidth / scale < 1000
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  info,
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  chart,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 320 * scale, child: info),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: chart),
                ],
              ),
      );
    },
  );
}
