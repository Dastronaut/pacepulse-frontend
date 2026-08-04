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
  testWidgets('counts 3-2-1 with ticks then fires go + onFinished',
      (tester) async {
    var ticks = 0, go = 0, finished = 0;
    await tester.pumpWidget(wrap(PPCountdownOverlay(
      overline: 'Starting run',
      caption: '5.00 km goal',
      hapticTick: () => ticks++,
      hapticGo: () => go++,
      onFinished: () => finished++,
    )));
    expect(find.text('3'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('2'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    expect(ticks, 3);
    expect(go, 1);
    expect(finished, 1);
  });

  testWidgets('numeral is raw Ember even in light theme', (tester) async {
    await tester.pumpWidget(wrap(
        PPCountdownOverlay(overline: 'Starting run', onFinished: () {}),
        dark: false));
    final numeral = tester.widget<Text>(find.text('3'));
    expect(numeral.style!.color, PPPalette.ember);
    expect(numeral.style!.fontSize, 160);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('cancel fires onCancelled and stops the count',
      (tester) async {
    var cancelled = 0, finished = 0;
    await tester.pumpWidget(wrap(PPCountdownOverlay(
      overline: 'Starting run',
      onCancelled: () => cancelled++,
      onFinished: () => finished++,
    )));
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(cancelled, 1);
    expect(finished, 0);
  });

  testWidgets('reduced motion: no ScaleTransition anywhere',
      (tester) async {
    await tester.pumpWidget(wrap(
        PPCountdownOverlay(overline: 'Starting run', onFinished: () {}),
        reducedMotion: true));
    // Scoped to the overlay's own subtree: Scaffold unconditionally mounts
    // a ScaleTransition for its (absent) FloatingActionButton slot
    // (_FloatingActionButtonTransition, material/scaffold.dart), which an
    // unscoped byType query would also catch — that's harness/framework
    // noise from wrap(), not anything PPCountdownOverlay renders.
    expect(
      find.descendant(
          of: find.byType(PPCountdownOverlay),
          matching: find.byType(ScaleTransition)),
      findsNothing,
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
