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
  testWidgets('card shows PR chip when flagged; whole card taps',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PPWorkoutCard(
      icon: PPIcons.footprints,
      title: 'Morning run',
      meta: 'Today · 06:24',
      stats: '5.21 km · 28:41 · 5:31 /km',
      showPr: true,
      onTap: () => taps++,
    )));
    expect(find.byType(PPChip), findsOneWidget);
    await tester.tap(find.text('Morning run'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('pressed card swaps bg to surfaceContainerHigh',
      (tester) async {
    await tester.pumpWidget(wrap(PPWorkoutCard(
      icon: PPIcons.bike,
      title: 'Evening ride',
      meta: 'Yesterday',
      stats: '18.4 km',
      onTap: () {},
    )));
    final g = await tester
        .startGesture(tester.getCenter(find.byType(PPWorkoutCard)));
    await tester.pump(const Duration(milliseconds: 100));
    final deco = tester
        .widget<AnimatedContainer>(find.byKey(const Key('pp_workout_card_box')))
        .decoration! as BoxDecoration;
    expect(deco.color, ppDarkColorScheme.surfaceContainerHigh);
    await g.up();
    await tester.pumpAndSettle();
  });

  testWidgets('progress bar fills to value; goalHit turns success',
      (tester) async {
    await tester.pumpWidget(wrap(const SizedBox(
        width: 200,
        child: PPProgressBar(value: 0.5, goalHit: true))));
    await tester.pumpAndSettle();
    final frac = tester.widget<AnimatedFractionallySizedBox>(
        find.byType(AnimatedFractionallySizedBox));
    expect(frac.widthFactor, 0.5);
    final fill = tester
        .widget<DecoratedBox>(find.byKey(const Key('pp_progress_fill')))
        .decoration as BoxDecoration;
    expect(fill.color, PPColors.dark.success);
  });
}
