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
  testWidgets('illustration reserves exact specced dims', (tester) async {
    await tester.pumpWidget(wrap(const PPIllustration(
        name: 'empty_workouts', size: PPIllustrationSize.onboarding)));
    expect(tester.getSize(find.byType(PPIllustration)),
        const Size(280, 220));
  });

  testWidgets('empty state: constrained 280, primary CTA fires',
      (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrap(PPEmptyState(
      title: 'No workouts yet',
      body: 'Your first run shows up here.',
      actionLabel: 'Start a run',
      onAction: () => taps++,
    )));
    final constrained = tester.widget<ConstrainedBox>(
        find.byKey(const Key('pp_state_constraint')));
    expect(constrained.constraints.maxWidth, 280);
    final button = tester.widget<PPButton>(find.byType(PPButton));
    expect(button.variant, PPButtonVariant.primary);
    await tester.tap(find.text('Start a run'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('error state: error icon + secondary retry', (tester) async {
    await tester.pumpWidget(wrap(PPErrorState(
      title: "Couldn't load history",
      body: 'Check your connection and try again.',
      onRetry: () {},
    )));
    final icon = tester.widget<Icon>(find.byType(Icon).first);
    expect(icon.color, ppDarkColorScheme.error);
    expect(icon.size, 32);
    final button = tester.widget<PPButton>(find.byType(PPButton));
    expect(button.variant, PPButtonVariant.secondary);
  });

  testWidgets('no overflow at 1.3x text scale', (tester) async {
    await tester.pumpWidget(wrap(
        PPEmptyState(
            title: 'No challenges yet',
            body: 'Start a race or wait for an invite.',
            actionLabel: 'Create challenge',
            onAction: () {}),
        textScale: 1.3));
    expect(tester.takeException(), isNull);
  });
}
