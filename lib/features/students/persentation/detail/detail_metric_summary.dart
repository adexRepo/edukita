import 'package:edukita/features/students/data/student_detail_data.dart';
import 'package:edukita/features/students/persentation/detail/detail_metric_card.dart';
import 'package:flutter/material.dart';

class DetailMetricSummary extends StatelessWidget {
  const DetailMetricSummary({super.key, required this.student});

  final StudentDetailData student;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 680;
        final cards = [
          DetailMetricCard(
            label: 'Class',
            value: student.className,
            icon: Icons.class_outlined,
          ),
          DetailMetricCard(
            label: 'School',
            value: student.schoolName,
            icon: Icons.account_balance_outlined,
          ),
          DetailMetricCard(
            label: 'Status',
            value: student.status.name.toUpperCase(),
            icon: Icons.verified_user_outlined,
          ),
          DetailMetricCard(
            label: 'Age',
            value: '${student.age} years',
            icon: Icons.cake_outlined,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: cards
                .map(
                  (card) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return Row(
          children: cards
              .map(
                (card) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: card,
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
