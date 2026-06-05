import 'package:edukita/core/localization/localization_extension.dart';
import 'package:edukita/theme/app_theme.dart';
import 'package:edukita/utils/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AttendanceLineChart extends StatelessWidget {
  const AttendanceLineChart({
    super.key,
    this.monthlyAttendance,
    this.emptyMessage,
  });

  final List<double?>? monthlyAttendance;
  final String? emptyMessage;

  int get year => DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final values = _values;
    final spots = _spots(values);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 18, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.attendanceChartTitle(year),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  context.l10n.monthlyAttendanceRate,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: AppColors.primary.darken(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      emptyMessage ?? context.l10n.attendanceChartEmpty,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  )
                : LineChart(
                    _chartData(spots),
                    duration: const Duration(milliseconds: 250),
                  ),
          ),
        ],
      ),
    );
  }

  List<double?> get _values {
    final source = monthlyAttendance;
    if (source == null || source.isEmpty) {
      return List<double?>.filled(12, null);
    }
    return List<double?>.generate(
      12,
      (index) => index < source.length ? source[index] : null,
    );
  }

  List<FlSpot> _spots(List<double?> values) {
    final spots = <FlSpot>[];
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value == null) continue;
      spots.add(FlSpot(index.toDouble(), value.clamp(0, 100).toDouble()));
    }
    return spots;
  }

  LineChartData _chartData(List<FlSpot> spots) {
    return LineChartData(
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 100,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.blueGrey,
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          maxContentWidth: 80,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final month = _monthName(spot.x.toInt());
              return LineTooltipItem(
                '$month\n${spot.y.toStringAsFixed(0)}%',
                const TextStyle(
                  color: AppColors.white,
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
          spots: spots,
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
                strokeColor: AppColors.white,
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
