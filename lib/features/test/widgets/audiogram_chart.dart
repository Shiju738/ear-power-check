import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../models/hearing_test_models.dart';

/// An animated audiogram: hearing threshold (dB HL) per frequency for each ear.
///
/// The Y axis is visually inverted (better hearing — lower dB — sits at the
/// top), matching clinical audiograms. Internally we plot `kMaxDbHl - db` so
/// fl_chart keeps an increasing axis, and convert back for the labels.
class AudiogramChart extends StatelessWidget {
  const AudiogramChart({super.key, required this.result});
  final HearingTestResult result;

  double _toY(double db) => kMaxDbHl - db;

  List<FlSpot> _spots(Ear ear) {
    final data = result.forEar(ear);
    return [
      for (var i = 0; i < data.length; i++)
        FlSpot(i.toDouble(), _toY(data[i].thresholdDbHl)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final gridColor = onSurface.withValues(alpha: 0.08);
    final labelStyle = TextStyle(
      color: onSurface.withValues(alpha: 0.6),
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    return AspectRatio(
      aspectRatio: 1.4,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (kTestFrequencies.length - 1).toDouble(),
          minY: 0,
          maxY: kMaxDbHl - kMinDbHl,
          lineTouchData: const LineTouchData(enabled: true),
          gridData: FlGridData(
            drawVerticalLine: true,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
            getDrawingVerticalLine: (_) =>
                FlLine(color: gridColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 38,
                getTitlesWidget: (value, _) {
                  final db = (kMaxDbHl - value).round();
                  return Text('$db', style: labelStyle);
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (value, _) {
                  final i = value.round();
                  if (i < 0 || i >= kTestFrequencies.length) {
                    return const SizedBox.shrink();
                  }
                  final hz = kTestFrequencies[i];
                  final label = hz >= 1000 ? '${hz ~/ 1000}k' : '$hz';
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(label, style: labelStyle),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            _bar(_spots(Ear.left), AppColors.leftEar),
            _bar(_spots(Ear.right), AppColors.rightEar),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 700.ms).slideY(
          begin: 0.1,
          end: 0,
          curve: Curves.easeOutCubic,
        );
  }

  LineChartBarData _bar(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.25,
      color: color,
      barWidth: 3.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
          radius: 4,
          color: Colors.white,
          strokeWidth: 2.5,
          strokeColor: color,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}
