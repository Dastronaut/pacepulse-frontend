import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Elevation area chart (D1-B7; human ruling 2026-08-03: spec literals
/// with documented provenance). chart2 line at 2px over a fill area held
/// at PPColors.chartFillAlpha; the y-range is padded +/-10% of the
/// elevation span (elevation +/-10% y-pad) so the profile never touches
/// the plot edges; gain/loss summary renders in monoS.
class PPElevationProfile extends StatelessWidget {
  const PPElevationProfile(
      {super.key, required this.elevations, this.height = 120});

  final List<double> elevations;
  final double height;

  static double gain(List<double> e) {
    var g = 0.0;
    for (var i = 1; i < e.length; i++) {
      if (e[i] > e[i - 1]) g += e[i] - e[i - 1];
    }
    return g;
  }

  static double loss(List<double> e) {
    var l = 0.0;
    for (var i = 1; i < e.length; i++) {
      if (e[i] < e[i - 1]) l += e[i - 1] - e[i];
    }
    return l;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final minE = elevations.reduce((a, b) => a < b ? a : b);
    final maxE = elevations.reduce((a, b) => a > b ? a : b);
    final pad = (maxE - minE) * 0.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              minY: minE - pad,
              maxY: maxE + pad,
              gridData: FlGridData(
                drawVerticalLine: false,
                drawHorizontalLine: true,
                horizontalInterval: (maxE - minE).clamp(1, double.infinity),
                getDrawingHorizontalLine: (_) =>
                    FlLine(color: pp.chartGrid, strokeWidth: 1),
              ),
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(),
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                bottomTitles: AxisTitles(),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (var i = 0; i < elevations.length; i++)
                      FlSpot(i.toDouble(), elevations[i]),
                  ],
                  color: pp.chart2,
                  barWidth: 2,
                  isCurved: true,
                  curveSmoothness: 0.25,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color:
                        pp.chart2.withValues(alpha: PPColors.chartFillAlpha),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PPSpacing.s2),
        Text(
          '↗ ${gain(elevations).round()} m   ↘ ${loss(elevations).round()} m',
          style: PPTextStyles.monoS
              .copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
