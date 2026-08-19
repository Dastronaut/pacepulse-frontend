// test/features/onboarding/onboarding_specimens_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/onboarding_page_dots.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/onboarding_specimens.dart';

Widget host(Widget child, {bool reducedMotion = false, ThemeData? theme}) =>
    MaterialApp(
      theme: theme ?? ppDarkTheme(),
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(disableAnimations: reducedMotion),
          child: Center(child: child),
        ),
      ),
    );

void main() {
  testWidgets('gps route specimen keeps the specced 280x220 canvas',
      (tester) async {
    await tester.pumpWidget(host(const GpsRouteSpecimen()));
    expect(tester.getSize(find.byType(GpsRouteSpecimen)),
        const Size(280, 220));
    // The sheet annotation is not product copy.
    expect(find.text('illo: gps route'), findsNothing);
    // Live end dot present.
    expect(find.byType(PPLivePulse), findsOneWidget);
  });

  testWidgets('leaderboard specimen shows the live chip and both rows',
      (tester) async {
    await tester.pumpWidget(host(const LiveLeaderboardSpecimen()));
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.byType(PPLeaderboardRow), findsNWidgets(2));
    expect(find.text('Marta K.'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('+0:04'), findsOneWidget);
    expect(find.text('5:04'), findsOneWidget);
    expect(find.text('5:08'), findsOneWidget);
  });

  testWidgets('streak specimen shows the ring at 82% plus both chips',
      (tester) async {
    await tester.pumpWidget(host(const StreakRingSpecimen()));
    final ring = tester.widget<PPActivityRing>(find.byType(PPActivityRing));
    expect(ring.value, 0.82);
    expect(ring.size, 150);
    expect(ring.thickness, 14);
    expect(find.text('12 DAYS'), findsOneWidget);
    expect(find.text('PR · 5K'), findsOneWidget);
  });

  testWidgets(
      'light theme: specimens render clean and slide-1 hatch uses the light pair',
      (tester) async {
    final theme = ppLightTheme();
    final scheme = theme.colorScheme;

    await tester.pumpWidget(host(const GpsRouteSpecimen(), theme: theme));
    expect(tester.takeException(), isNull);
    // Pin the actual bug: the painter must carry the LIGHT gradient stops
    // (surface -> surfaceContainer), not the dark pair (surfaceContainer ->
    // surfaceContainerHigh) that shipped before Fix 2.
    final customPaint = tester.widget<CustomPaint>(find.descendant(
      of: find.byType(GpsRouteSpecimen),
      matching: find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter?.runtimeType.toString() == '_RoutePainter'),
    ));
    final painter = customPaint.painter as dynamic;
    expect(painter.hatchLow, scheme.surface);
    expect(painter.hatchHigh, scheme.surfaceContainer);

    await tester.pumpWidget(host(const LiveLeaderboardSpecimen(), theme: theme));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(host(const StreakRingSpecimen(), theme: theme));
    expect(tester.takeException(), isNull);
  });

  testWidgets('dots: active pill is 24x8, idle dots are 8x8', (tester) async {
    await tester.pumpWidget(
        host(const OnboardingPageDots(count: 3, index: 1)));
    await tester.pumpAndSettle();
    // Keys are per-index: siblings must not share a key.
    expect(tester.getSize(find.byKey(const Key('pp_onboarding_dot_0'))),
        const Size(8, 8));
    expect(tester.getSize(find.byKey(const Key('pp_onboarding_dot_1'))),
        const Size(24, 8));
    expect(tester.getSize(find.byKey(const Key('pp_onboarding_dot_2'))),
        const Size(8, 8));
  });

  testWidgets('dots announce the slide position for screen readers',
      (tester) async {
    await tester.pumpWidget(
        host(const OnboardingPageDots(count: 3, index: 1)));
    expect(find.bySemanticsLabel('Slide 2 of 3'), findsOneWidget);
  });

  testWidgets('dots: reduced motion snaps instead of tweening',
      (tester) async {
    await tester.pumpWidget(host(
        const OnboardingPageDots(count: 3, index: 0),
        reducedMotion: true));
    final container = tester.widget<AnimatedContainer>(
        find.byKey(const Key('pp_onboarding_dot_0')));
    expect(container.duration, Duration.zero);
  });
}
