import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';

Widget wrap(Widget child,
    {bool dark = true, bool reducedMotion = false, double textScale = 1.0}) {
  return MaterialApp(
    theme: ppLightTheme(),
    darkTheme: ppDarkTheme(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    builder: (context, w) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: reducedMotion,
        textScaler: TextScaler.linear(textScale),
      ),
      child: w!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  test('elevation gain/loss math', () {
    const e = [10.0, 14.0, 12.0, 20.0];
    expect(PPElevationProfile.gain(e), 12); // +4 +8
    expect(PPElevationProfile.loss(e), 2); // -2
  });

  testWidgets('chart card: series colors follow chartSeries order, '
      'horizontal grid only, curve 0.25', (tester) async {
    await tester.pumpWidget(wrap(SizedBox(
        width: 350,
        child: PPChartCard(
            title: 'Distance',
            series: const [
              [1, 3, 2, 5],
              [2, 1, 4, 3],
            ]))));
    final chart = tester.widget<LineChart>(find.byType(LineChart));
    final bars = chart.data.lineBarsData;
    expect(bars[0].color, PPColors.dark.chart1);
    expect(bars[1].color, PPColors.dark.chart2);
    expect(bars[0].barWidth, 2.5);
    expect(bars[0].isCurved, isTrue);
    expect(bars[0].curveSmoothness, 0.25);
    expect(chart.data.gridData.drawVerticalLine, isFalse);
    expect(chart.data.gridData.drawHorizontalLine, isTrue);
  });

  testWidgets('elevation profile: area fill uses chartFillAlpha',
      (tester) async {
    await tester.pumpWidget(wrap(const SizedBox(
        width: 350,
        child: PPElevationProfile(elevations: [10, 14, 12, 20]))));
    final chart = tester.widget<LineChart>(find.byType(LineChart));
    final bar = chart.data.lineBarsData.single;
    expect(bar.belowBarData.show, isTrue);
    expect(bar.belowBarData.color!.a,
        closeTo(PPColors.chartFillAlpha, 0.01));
    expect(find.textContaining('12'), findsWidgets); // gain shown
  });

  testWidgets('elevation profile: empty data does not throw and shows '
      'zeroed summary', (tester) async {
    await tester.pumpWidget(wrap(const SizedBox(
        width: 350, child: PPElevationProfile(elevations: []))));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('↗ 0 m'), findsOneWidget);
  });
}
