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
  testWidgets('PPLiveDot pulses opacity when motion allowed', (tester) async {
    await tester.pumpWidget(wrap(const PPLiveDot()));
    final o1 = tester.widget<FadeTransition>(find.descendant(
      of: find.byType(PPLiveDot),
      matching: find.byType(FadeTransition),
    ));
    final v1 = o1.opacity.value;
    await tester.pump(const Duration(milliseconds: 600));
    final v2 = tester
        .widget<FadeTransition>(find.descendant(
          of: find.byType(PPLiveDot),
          matching: find.byType(FadeTransition),
        ))
        .opacity
        .value;
    expect(v1 == v2, isFalse);
  });

  testWidgets('PPLiveDot reduced motion: no FadeTransition, static dot',
      (tester) async {
    await tester.pumpWidget(wrap(const PPLiveDot(), reducedMotion: true));
    await tester.pump(const Duration(seconds: 2));
    expect(
      find.descendant(
        of: find.byType(PPLiveDot),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
  });

  testWidgets('PPLivePulse one-shot: animates once per token change',
      (tester) async {
    Object token = 1;
    late StateSetter setOuter;
    await tester.pumpWidget(wrap(StatefulBuilder(builder: (context, set) {
      setOuter = set;
      return PPLivePulse(
        pulseToken: token,
        child: const SizedBox(width: 20, height: 20),
      );
    })));
    await tester.pump(const Duration(milliseconds: 3200));
    // Settled after one cycle: no scheduled frames left.
    expect(tester.binding.hasScheduledFrame, isFalse);
    setOuter(() => token = 2);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue); // cycle running again
    await tester.pumpAndSettle();
  });

  testWidgets('PPLivePulse reduced motion: static ring via CustomPaint,'
      ' no frames scheduled', (tester) async {
    await tester.pumpWidget(wrap(
      const PPLivePulse(loop: true, child: SizedBox(width: 20, height: 20)),
      reducedMotion: true,
    ));
    await tester.pump(const Duration(seconds: 2));
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(
      find.descendant(
          of: find.byType(PPLivePulse), matching: find.byType(CustomPaint)),
      findsOneWidget,
    );
  });
}
