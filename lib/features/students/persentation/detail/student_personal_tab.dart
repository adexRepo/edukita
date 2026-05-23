import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/persentation/detail/detail_info_pill.dart';
import 'package:edukita/features/students/persentation/detail/detail_section_card.dart';
import 'package:edukita/widgets/detail_tab_scroll.dart';
import 'package:edukita/features/students/persentation/detail/student_information_section.dart';
import 'package:flutter/material.dart';

class StudentPersonalTab extends StatelessWidget {
  const StudentPersonalTab({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return DetailTabScroll(
      children: [
        StudentInformationSection(student: student),
        DetailSectionCard(
          title: 'Physical Attributes',
          icon: Icons.accessibility_new_outlined,
          children: [
            DetailInfoPill(label: 'Height', value: _numberOrDash(student.height, 'cm')),
            DetailInfoPill(label: 'Weight', value: _numberOrDash(student.weight, 'kg')),
            DetailInfoPill(label: 'Uniform', value: _intOrDash(student.uniformSize)),
            DetailInfoPill(label: 'Pants', value: _intOrDash(student.pantsSize)),
            DetailInfoPill(label: 'Shoes', value: _intOrDash(student.shoesSize)),
          ],
        ),
      ],
    );
  }

  String _numberOrDash(double? value, String suffix) {
    if (value == null) return '-';
    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$text $suffix';
  }

  String _intOrDash(int? value) {
    if (value == null) return '-';
    return value.toString();
  }
}
