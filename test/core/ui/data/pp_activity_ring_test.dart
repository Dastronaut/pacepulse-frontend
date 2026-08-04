import 'dart:math' as math;

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
  test('geometry: 28-degree gate centred at 12 o\'clock', () {
    expect(PPRingGeometry.gapDegrees, 28);
    expect(PPRingGeometry.startAngle,
        closeTo(-math.pi / 2 + (28 * math.pi / 180) / 2, 1e-9));
    expect(PPRingGeometry.sweep(1),
        closeTo(2 * math.pi - 28 * math.pi / 180, 1e-9));
    expect(PPRingGeometry.sweep(0.5), closeTo(PPRingGeometry.sweep(1) / 2, 1e-9));
    expect(PPRingGeometry.sweep(1.5), PPRingGeometry.sweep(1)); // clamped
    expect(PPRingGeometry.sweep(-1), 0); // clamped
  });

  testWidgets('single ring sizes itself and centers its child',
      (tester) async {
    await tester.pumpWidget(wrap(const PPActivityRing(
      value: 0.5,
      color: Colors.orange,
      size: 170,
      thickness: 14,
      child: Text('2nd'),
    )));
    expect(tester.getSize(find.byType(PPActivityRing)), const Size(170, 170));
    expect(find.text('2nd'), findsOneWidget);
  });

  testWidgets('triad renders three rings, reduced motion settles instantly',
      (tester) async {
    await tester.pumpWidget(wrap(
        const PPActivityRings(move: 0.8, exercise: 0.5, steps: 0.3),
        reducedMotion: true));
    await tester.pump();
    expect(find.byType(PPActivityRing), findsNWidgets(3));
    expect(tester.binding.hasScheduledFrame, isFalse); // no intro anim
  });
}
