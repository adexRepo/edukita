import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/utils/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AttendanceLineChart extends StatelessWidget {
  AttendanceLineChart({super.key});

  final int year = DateTime.now().year;

  final List<double> monthlyAttendance = const [
    92,
    88,
    95,
    90,
    93,
    86,
    89,
    94,
    91,
    96,
    90,
    93,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 18, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Attendance $year',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Monthly attendance rate',
                style: TextStyle(
                  color: AppColors.primary.darken(),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              _chartData(),
              duration: const Duration(milliseconds: 250),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _chartData() {
    return LineChartData(
      minX: 0,
      maxX: 11,
      minY: 80,
      maxY: 100,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.blueGrey,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          maxContentWidth: 80,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final month = _monthName(spot.x.toInt());
              return LineTooltipItem(
                '$month\n${spot.y.toStringAsFixed(0)}%',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList();
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 10,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            interval: 2,
            getTitlesWidget: _bottomTitle,
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 10,
        getDrawingHorizontalLine: (_) => FlLine(
          color: AppColors.border.withValues(alpha: 0.7),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
            monthlyAttendance.length,
            (index) => FlSpot(index.toDouble(), monthlyAttendance[index]),
          ),
          isCurved: true,
          curveSmoothness: 0.25,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 2.5,
                color: AppColors.primary,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  Widget _bottomTitle(double value, TitleMeta meta) {
    final monthIndex = value.toInt();
    if (monthIndex < 0 || monthIndex > 11 || monthIndex.isOdd) {
      return const SizedBox.shrink();
    }

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(
        _monthName(monthIndex),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _monthName(int index) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final safeIndex = index.clamp(0, months.length - 1).toInt();
    return months[safeIndex];
  }
}
