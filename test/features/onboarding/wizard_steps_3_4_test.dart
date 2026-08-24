import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/onboarding/domain/profile_draft.dart';
import 'package:pacepulse/features/onboarding/presentation/wizard_controller.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/wizard_step_gear.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/wizard_step_goal.dart';

const _defaults = WizardDefaults(
  unitSystem: UnitSystem.metric,
  currentYear: 2026,
);

class _SeededGearScan extends GearScanController {
  _SeededGearScan(this._seed);
  final GearScan _seed;
  @override
  GearScan build() => _seed;
}

Widget wrap(Widget child, {bool dark = true, GearScan? scan}) {
  final List<dynamic> overrides = [
    wizardDefaultsProvider.overrideWithValue(_defaults),
    if (scan != null)
      gearScanProvider.overrideWith(() => _SeededGearScan(scan)),
  ];
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: ppLightTheme(),
      darkTheme: ppDarkTheme(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(body: child),
    ),
  );
}

/// PPStepper renders a `Text.rich`, whose `data` is null — `find.text` never
/// matches it. Read the numeral and the full "20 km" string by key.
String goalValue(WidgetTester tester) =>
    (tester.widget<Text>(find.byKey(const Key('pp_stepper_value'))).textSpan!
            as TextSpan)
        .text!;

String goalPlain(WidgetTester tester) => tester
    .widget<Text>(find.byKey(const Key('pp_stepper_value')))
    .textSpan!
    .toPlainText();

void main() {
  group('step 3 — weekly goal', () {
    testWidgets('renders the metric default, unit and nudge', (tester) async {
      await tester.pumpWidget(wrap(WizardStepGoal(onContinue: () {})));
      expect(find.text(WizardCopy.step3Title), findsOneWidget);
      expect(goalValue(tester), '20');
      expect(goalPlain(tester), '20 km');
      expect(find.text(WizardCopy.goalNudgeMetric), findsOneWidget);
    });

    testWidgets('plus and minus move the goal by the metric step', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(WizardStepGoal(onContinue: () {})));
      await tester.tap(find.byKey(const Key('pp_stepper_plus')));
      await tester.pump();
      expect(goalValue(tester), '22.5');
      await tester.tap(find.byKey(const Key('pp_stepper_minus')));
      await tester.pump();
      expect(goalValue(tester), '20');
    });

    testWidgets('imperial swaps unit, default and nudge together', (
      tester,
    ) async {
      late WidgetRef captured;
      await tester.pumpWidget(
        wrap(
          Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return WizardStepGoal(onContinue: () {});
            },
          ),
        ),
      );
      captured
          .read(wizardControllerProvider.notifier)
          .unitSystemChanged(UnitSystem.imperial);
      await tester.pump();
      expect(goalValue(tester), '12');
      expect(goalPlain(tester), '12 mi');
      expect(find.text(WizardCopy.goalNudgeImperial), findsOneWidget);
    });

    testWidgets('the minus control disables at the lower bound', (
      tester,
    ) async {
      late WidgetRef captured;
      await tester.pumpWidget(
        wrap(
          Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return WizardStepGoal(onContinue: () {});
            },
          ),
        ),
      );
      final notifier = captured.read(wizardControllerProvider.notifier);
      for (var i = 0; i < 200; i++) {
        notifier.goalDecrement();
      }
      await tester.pump();
      final stepper = tester.widget<PPStepper>(find.byType(PPStepper));
      expect(stepper.onDecrement, isNull);
      expect(stepper.onIncrement, isNotNull);
    });
  });

  group('step 4 — gear', () {
    testWidgets('found: renders a tile per device and reports Connect', (
      tester,
    ) async {
      GearDevice? connected;
      await tester.pumpWidget(
        wrap(
          WizardStepGear(
            onFinish: () {},
            onSkip: () {},
            onConnect: (d) => connected = d,
          ),
        ),
      );
      expect(find.byType(PPDeviceTile), findsNWidgets(2));
      expect(find.text('Polar H10'), findsOneWidget);

      await tester.tap(find.text('Connect').first);
      expect(connected?.name, 'Polar H10');
    });

    testWidgets('scanning: spinner in the header with the scanning copy', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          WizardStepGear(onFinish: () {}, onSkip: () {}, onConnect: (_) {}),
          scan: const GearScan(status: GearScanStatus.scanning, devices: []),
        ),
      );
      expect(find.byType(PPSpinner), findsOneWidget);
      expect(find.text(WizardCopy.step4Scanning), findsOneWidget);
    });

    testWidgets('empty: an empty state, not a wall', (tester) async {
      await tester.pumpWidget(
        wrap(
          WizardStepGear(onFinish: () {}, onSkip: () {}, onConnect: (_) {}),
          scan: const GearScan(status: GearScanStatus.empty, devices: []),
        ),
      );
      expect(find.byType(PPEmptyState), findsOneWidget);
      // Gear is never a wall — both exits stay available in every state.
      expect(find.byKey(const Key('wizard_step4_finish')), findsOneWidget);
      expect(find.byKey(const Key('wizard_step4_skip')), findsOneWidget);
    });

    testWidgets('bluetooth off: an error state with a retry', (tester) async {
      await tester.pumpWidget(
        wrap(
          WizardStepGear(onFinish: () {}, onSkip: () {}, onConnect: (_) {}),
          scan: const GearScan(
            status: GearScanStatus.bluetoothOff,
            devices: [],
          ),
        ),
      );
      expect(find.byType(PPErrorState), findsOneWidget);
      expect(find.text(WizardCopy.gearErrorTitle), findsOneWidget);
    });

    testWidgets('Finish and Skip both report out', (tester) async {
      var finished = false;
      var skipped = false;
      await tester.pumpWidget(
        wrap(
          WizardStepGear(
            onFinish: () => finished = true,
            onSkip: () => skipped = true,
            onConnect: (_) {},
          ),
        ),
      );
      await tester.tap(find.byKey(const Key('wizard_step4_finish')));
      await tester.tap(find.byKey(const Key('wizard_step4_skip')));
      expect(finished, isTrue);
      expect(skipped, isTrue);
    });
  });

  testWidgets('both steps render in light theme without exceptions', (
    tester,
  ) async {
    for (final step in <Widget>[
      WizardStepGoal(onContinue: () {}),
      WizardStepGear(onFinish: () {}, onSkip: () {}, onConnect: (_) {}),
    ]) {
      await tester.pumpWidget(wrap(step, dark: false));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
