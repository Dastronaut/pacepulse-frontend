import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../actions/pp_segmented_control.dart';

/// Trend chart card (D1-B5; human ruling 2026-08-03: spec literals with
/// documented provenance). fl_chart line only; series take pp.chartSeries
/// in order; horizontal gridlines only (no vertical); geometry is
/// design-specced with no CSS custom property: 2.5px round-cap strokes,
/// isCurved with curveSmoothness 0.25, bottom-axis labels in monoS at a
/// dedicated 10px size (axis mono 10). Kit renders up to 5 series (length
/// of pp.chartSeries); callers keep to <=2 so the chart stays legendless.
class PPChartCard extends StatelessWidget {
  const PPChartCard({
    super.key,
    required this.title,
    required this.series,
    this.periods,
    this.selectedPeriod = 0,
    this.onPeriodChanged,
    this.height = 160,
  });

  final String title;
  final List<List<double>> series;
  final List<String>? periods;
  final int selectedPeriod;
  final ValueChanged<int>? onPeriodChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(PPSpacing.padCard),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(PPRadius.lg),
        boxShadow: dark ? null : pp.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              if (periods != null)
                PPSegmentedControl(
                  segments: periods!,
                  selectedIndex: selectedPeriod,
                  onChanged: onPeriodChanged ?? (_) {},
                  small: true,
                ),
            ],
          ),
          const SizedBox(height: PPSpacing.s4),
          SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  drawVerticalLine: false,
                  drawHorizontalLine: true,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: pp.chartGrid, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) => Text(
                        v.toInt().toString(),
                        style: PPTextStyles.monoS
                            .copyWith(fontSize: 10, color: pp.chartAxis),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  for (var i = 0; i < series.length; i++)
                    LineChartBarData(
                      spots: [
                        for (var x = 0; x < series[i].length; x++)
                          FlSpot(x.toDouble(), series[i][x]),
                      ],
                      color: pp.chartSeries[i % pp.chartSeries.length],
                      barWidth: 2.5,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
