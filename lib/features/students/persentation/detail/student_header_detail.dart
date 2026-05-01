import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/persentation/detail/attendance_line_chart.dart';
import 'package:edukita/features/students/persentation/detail/student_info_tile.dart';
import 'package:flutter/material.dart';

class StudentHeaderDetail extends StatelessWidget {
  const StudentHeaderDetail({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isNarrow = availableWidth < 520;
        final isMedium = availableWidth < 920;
        final cardHeight = (availableWidth * 0.24)
            .clamp(190.0, 260.0)
            .toDouble();
        final studentFlex = isMedium ? 2 : 1;
        final chartFlex = isMedium ? 4 : 3;

        return Container(
          decoration: boxDecoration,
          width: double.infinity,
          height: isNarrow ? 430 : cardHeight,
          child: isNarrow
              ? Column(
                  children: [
                    SizedBox(
                      height: 165,
                      child: StudentInfoTile(student: student),
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    Expanded(child: AttendanceLineChart()),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: studentFlex,
                      child: StudentInfoTile(student: student),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: Color(0xFFE5E7EB),
                    ),
                    Expanded(flex: chartFlex, child: AttendanceLineChart()),
                  ],
                ),
        );
      },
    );
  }
}
