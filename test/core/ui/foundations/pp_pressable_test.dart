import 'dart:ui' show Tristate;

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
  testWidgets('fires onPressed and scales to 0.97 while held',
      (tester) async {
    var pressed = 0;
    await tester.pumpWidget(wrap(PPPressable(
      onPressed: () => pressed++,
      child: const SizedBox(width: 60, height: 60),
    )));
    final gesture =
        await tester.startGesture(tester.getCenter(find.byType(PPPressable)));
    await tester.pump(const Duration(milliseconds: 100));
    final scale =
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
    expect(scale, 0.97);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(pressed, 1);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1.0);
  });

  testWidgets('disabled: no callback, no scale', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(wrap(PPPressable(
      enabled: false,
      onPressed: () => pressed++,
      child: const SizedBox(width: 60, height: 60),
    )));
    await tester.tap(find.byType(PPPressable));
    await tester.pumpAndSettle();
    expect(pressed, 0);
  });

  testWidgets(
      'disabled PPPressable still exposes button:true, enabled:false (Material convention)',
      (tester) async {
    await tester.pumpWidget(wrap(PPPressable(
      enabled: false,
      onPressed: () {},
      child: const SizedBox(width: 60, height: 60),
    )));
    // PPTapTarget is deliberately the outermost render object of
    // PPPressable (see its class doc) and carries no semantics config of
    // its own, so getSemantics(find.byType(PPPressable)) walks *up* past
    // the real merged node and lands on an ancestor (e.g. the Scaffold's
    // route-scope node) instead. button/enabled/label actually merge at
    // the GestureDetector below it, so scope the finder there.
    final semantics = tester.getSemantics(find.descendant(
      of: find.byType(PPPressable),
      matching: find.byType(GestureDetector),
    ));
    final flags = semantics.flagsCollection;
    expect(flags.isButton, isTrue);
    // Tristate.isFalse (not .none) proves the enabled-state is reported
    // at all — i.e. the node still carries a "disabled" role rather than
    // dropping enabled-state entirely (SemanticsFlag.hasFlag's old
    // hasEnabledState + isEnabled pair is now this single tri-state field).
    expect(flags.isEnabled, Tristate.isFalse);
  });

  testWidgets('PPTapTarget accepts taps outside a small child',
      (tester) async {
    var pressed = 0;
    await tester.pumpWidget(wrap(PPPressable(
      onPressed: () => pressed++,
      child: const SizedBox(width: 10, height: 10),
    )));
    // 18px from center of a 10px child = outside visual, inside 44px target.
    await tester.tapAt(
        tester.getCenter(find.byType(PPPressable)) + const Offset(18, 0));
    await tester.pumpAndSettle();
    expect(pressed, 1);
  });
}
