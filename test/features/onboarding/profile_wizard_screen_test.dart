import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/features/onboarding/domain/profile_draft.dart';
import 'package:pacepulse/features/onboarding/presentation/profile_wizard_screen.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/wizard_progress.dart';
import 'package:pacepulse/features/onboarding/presentation/wizard_controller.dart';

const _defaults = WizardDefaults(
  unitSystem: UnitSystem.metric,
  currentYear: 2026,
);

final List<dynamic> _overrides = [
  wizardDefaultsProvider.overrideWithValue(_defaults),
];

Widget wrap({bool dark = true}) => ProviderScope(
  overrides: _overrides.cast(),
  child: MaterialApp(
    theme: ppLightTheme(),
    darkTheme: ppDarkTheme(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: const ProfileWizardScreen(),
  ),
);

void main() {
  testWidgets('opens on step 1 with no back affordance', (tester) async {
    await tester.pumpWidget(wrap());
    expect(find.text(WizardCopy.step1Title), findsOneWidget);
    // Nothing to go back to, so the slot is a spacer, not a button.
    expect(find.bySemanticsLabel(WizardCopy.back), findsNothing);
  });

  testWidgets('Continue advances and the progress bar follows', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.byKey(const Key('wizard_step1_continue')));
    await tester.pumpAndSettle();

    expect(find.text(WizardCopy.step2Title), findsOneWidget);
    expect(tester.widget<WizardProgress>(find.byType(WizardProgress)).index, 1);
    expect(find.bySemanticsLabel(WizardCopy.back), findsOneWidget);
  });

  testWidgets('back preserves what was typed on the earlier step', (
    tester,
  ) async {
    // S8: "back never loses entered data". This is the end-to-end proof;
    // the controller test proves the state layer.
    await tester.pumpWidget(wrap());
    await tester.enterText(find.byType(TextField).first, 'Dana');
    await tester.tap(find.byKey(const Key('wizard_step1_continue')));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel(WizardCopy.back));
    await tester.pumpAndSettle();

    expect(find.text('Dana'), findsOneWidget);
  });

  testWidgets('walks all four steps to Finish', (tester) async {
    await tester.pumpWidget(wrap());
    for (final key in [
      'wizard_step1_continue',
      'wizard_step2_continue',
      'wizard_step3_continue',
    ]) {
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();
    }
    expect(find.text(WizardCopy.step4Title), findsOneWidget);
    expect(find.byKey(const Key('wizard_step4_finish')), findsOneWidget);
  });

  testWidgets('steps are not swipeable — Continue is the only way forward', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text(WizardCopy.step1Title), findsOneWidget);
  });

  testWidgets('renders in light theme without exceptions', (tester) async {
    await tester.pumpWidget(wrap(dark: false));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
