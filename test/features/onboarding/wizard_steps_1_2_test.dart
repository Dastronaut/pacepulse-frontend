import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/features/onboarding/domain/profile_draft.dart';
import 'package:pacepulse/features/onboarding/presentation/wizard_controller.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/wizard_step_about.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/wizard_step_units.dart';

const _defaults = WizardDefaults(
  unitSystem: UnitSystem.metric,
  currentYear: 2026,
);

// `Override` is not exported from flutter_riverpod's public API, so the
// list is declared bare and cast at the call site.
final List<dynamic> _overrides = [
  wizardDefaultsProvider.overrideWithValue(_defaults),
];

Widget wrap(Widget child, {bool dark = true}) => ProviderScope(
  overrides: _overrides.cast(),
  child: MaterialApp(
    theme: ppLightTheme(),
    darkTheme: ppDarkTheme(),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    home: Scaffold(body: child),
  ),
);

void main() {
  group('step 1 — about you', () {
    testWidgets('renders the handoff copy verbatim', (tester) async {
      await tester.pumpWidget(wrap(WizardStepAbout(onContinue: () {})));
      expect(find.text(WizardCopy.step1Title), findsOneWidget);
      expect(find.text(WizardCopy.step1Body), findsOneWidget);
      expect(find.text(WizardCopy.nameLabel), findsOneWidget);
      expect(find.text(WizardCopy.birthYearLabel), findsOneWidget);
      expect(find.text(WizardCopy.bodyLabel), findsOneWidget);
      expect(find.text(WizardCopy.bodyUnspecified), findsOneWidget);
    });

    testWidgets('Continue is never gated — every field is optional', (
      tester,
    ) async {
      var advanced = false;
      await tester.pumpWidget(
        wrap(WizardStepAbout(onContinue: () => advanced = true)),
      );
      await tester.tap(find.byKey(const Key('wizard_step1_continue')));
      expect(advanced, isTrue);
    });

    testWidgets('typing feeds the controller', (tester) async {
      late WidgetRef captured;
      await tester.pumpWidget(
        wrap(
          Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return WizardStepAbout(onContinue: () {});
            },
          ),
        ),
      );

      // Tree order: Name is the first field, Birth year the second.
      await tester.enterText(find.byType(TextField).at(0), 'Dana');
      await tester.enterText(find.byType(TextField).at(1), '1996');
      await tester.tap(find.text(WizardCopy.bodyFemale));
      await tester.pump();

      final draft = captured.read(wizardControllerProvider).draft;
      expect(draft.name, 'Dana');
      expect(draft.birthYear, 1996);
      expect(draft.body, BodyOption.female);
    });

    testWidgets('the birth year field uses tabular figures', (tester) async {
      await tester.pumpWidget(wrap(WizardStepAbout(onContinue: () {})));
      final fields = tester.widgetList<TextField>(find.byType(TextField));
      // Name is proportional, birth year is tabular.
      expect(fields.first.style!.fontFeatures, isNull);
      expect(fields.last.style!.fontFeatures, ppTabularFigures);
    });
  });

  group('step 2 — units & measures', () {
    testWidgets('renders the handoff copy verbatim', (tester) async {
      await tester.pumpWidget(wrap(WizardStepUnits(onContinue: () {})));
      expect(find.text(WizardCopy.step2Title), findsOneWidget);
      expect(find.text(WizardCopy.step2Body), findsOneWidget);
      expect(find.text(WizardCopy.unitsMetric), findsOneWidget);
      expect(find.text(WizardCopy.weekMonday), findsOneWidget);
      expect(find.text(WizardCopy.maxHrLabel), findsOneWidget);
      expect(find.text(WizardCopy.maxHrUnit), findsOneWidget);
      expect(find.text(WizardCopy.maxHrHelper), findsOneWidget);
    });

    testWidgets('max HR pre-fills from a birth year entered in step 1', (
      tester,
    ) async {
      late WidgetRef captured;
      await tester.pumpWidget(
        wrap(
          Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return WizardStepUnits(onContinue: () {});
            },
          ),
        ),
      );
      captured.read(wizardControllerProvider.notifier).birthYearChanged('1996');
      await tester.pump();
      expect(find.text('190'), findsOneWidget);
    });

    testWidgets('a typed max HR is not overwritten by a later estimate', (
      tester,
    ) async {
      // The field is live while step 1 is still editable behind it, so the
      // sync must stop the moment the user takes ownership.
      late WidgetRef captured;
      await tester.pumpWidget(
        wrap(
          Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return WizardStepUnits(onContinue: () {});
            },
          ),
        ),
      );
      final notifier = captured.read(wizardControllerProvider.notifier);
      notifier.birthYearChanged('1996');
      await tester.pump();
      expect(find.text('190'), findsOneWidget);

      // Drive through the field as a user would: enterText updates the
      // TextEditingController *and* fires onChanged. Calling the notifier
      // directly would prove nothing, because the displayed text would
      // never have been the typed value in the first place.
      await tester.enterText(find.byType(TextField), '178');
      await tester.pump();

      // Unfocus so the focus guard is not what saves us — this has to pass
      // on the maxHrBpm "user owns it now" guard alone.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pump();

      notifier.birthYearChanged('1980');
      await tester.pump();

      expect(find.text('178'), findsOneWidget);
      expect(find.text('174'), findsNothing);
    });

    testWidgets('switching units reports to the controller', (tester) async {
      late WidgetRef captured;
      await tester.pumpWidget(
        wrap(
          Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return WizardStepUnits(onContinue: () {});
            },
          ),
        ),
      );
      await tester.tap(find.text(WizardCopy.unitsImperial));
      await tester.pump();
      expect(
        captured.read(wizardControllerProvider).draft.unitSystem,
        UnitSystem.imperial,
      );
    });
  });

  testWidgets('both steps render in light theme without exceptions', (
    tester,
  ) async {
    for (final step in <Widget>[
      WizardStepAbout(onContinue: () {}),
      WizardStepUnits(onContinue: () {}),
    ]) {
      await tester.pumpWidget(wrap(step, dark: false));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
