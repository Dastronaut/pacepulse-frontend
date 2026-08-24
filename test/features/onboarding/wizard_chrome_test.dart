import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/wizard_progress.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/wizard_step_scaffold.dart';

Widget wrap(Widget child, {bool dark = true}) => MaterialApp(
  theme: ppLightTheme(),
  darkTheme: ppDarkTheme(),
  themeMode: dark ? ThemeMode.dark : ThemeMode.light,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('progress fills one segment per completed step', (tester) async {
    await tester.pumpWidget(wrap(const WizardProgress(count: 4, index: 1)));
    // Index 1 = step 2 of 4, so segments 0 and 1 are filled.
    for (final (i, expected) in <(int, Color)>[
      (0, ppDarkColorScheme.primary),
      (1, ppDarkColorScheme.primary),
      (2, ppDarkColorScheme.outlineVariant),
      (3, ppDarkColorScheme.outlineVariant),
    ]) {
      final box = tester.widget<DecoratedBox>(
        find.byKey(Key('wizard_progress_segment_$i')),
      );
      expect(
        (box.decoration as BoxDecoration).color,
        expected,
        reason: 'segment $i',
      );
    }
  });

  testWidgets('progress announces overall position to a screen reader', (
    tester,
  ) async {
    // Four unlabelled bars tell a screen-reader user nothing.
    await tester.pumpWidget(wrap(const WizardProgress(count: 4, index: 1)));
    final semantics = tester.getSemantics(find.byType(WizardProgress));
    expect(semantics.label, contains('2'));
    expect(semantics.label, contains('4'));
  });

  testWidgets('step scaffold renders header, children and footer', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        const WizardStepScaffold(
          overline: 'Step 1 of 4',
          title: 'Tell us about you',
          body: 'Used only for calorie and heart-rate zone math.',
          fields: [Text('field')],
          footer: Text('footer'),
        ),
      ),
    );
    // The scaffold uppercases the overline at the call site, per the
    // convention documented in app_typography.dart ("labelSmall 11 <-
    // overline (uppercase applied at call site)").
    expect(find.text('STEP 1 OF 4'), findsOneWidget);
    expect(find.text('Tell us about you'), findsOneWidget);
    expect(find.text('field'), findsOneWidget);
    expect(find.text('footer'), findsOneWidget);
  });

  testWidgets('step scaffold scrolls rather than overflowing at 2x text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ppDarkTheme(),
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: const Scaffold(
            body: WizardStepScaffold(
              overline: 'Step 1 of 4',
              title: 'Tell us about you',
              body: 'Used only for calorie and heart-rate zone math.',
              fields: [SizedBox(height: 400), SizedBox(height: 400)],
              footer: SizedBox(height: 54),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
