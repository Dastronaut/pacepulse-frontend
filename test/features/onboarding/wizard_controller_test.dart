import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/onboarding/domain/profile_draft.dart';
import 'package:pacepulse/features/onboarding/presentation/wizard_controller.dart';

const _defaults = WizardDefaults(
  unitSystem: UnitSystem.metric,
  currentYear: 2026,
);

ProviderContainer _container({WizardDefaults defaults = _defaults}) {
  return ProviderContainer.test(
    overrides: [wizardDefaultsProvider.overrideWithValue(defaults)],
  );
}

void main() {
  test('seeds the unit system from the injected defaults', () {
    final c = _container(
      defaults: const WizardDefaults(
        unitSystem: UnitSystem.imperial,
        currentYear: 2026,
      ),
    );
    expect(
      c.read(wizardControllerProvider).draft.unitSystem,
      UnitSystem.imperial,
    );
  });

  test('stepping forward and back never loses entered data', () {
    // S8: "back never loses entered data". This is the requirement that
    // makes the provider keep-alive rather than autoDispose.
    final c = _container();
    final n = c.read(wizardControllerProvider.notifier);
    n.nameChanged('Dana');
    n.birthYearChanged('1996');
    n.bodyChanged(BodyOption.female);
    n.next();
    n.weekStartChanged(WeekStart.sunday);
    n.next();
    n.back();
    n.back();

    final draft = c.read(wizardControllerProvider).draft;
    expect(c.read(wizardControllerProvider).step, 0);
    expect(draft.name, 'Dana');
    expect(draft.birthYear, 1996);
    expect(draft.body, BodyOption.female);
    expect(draft.weekStart, WeekStart.sunday);
  });

  test('back at step 0 and next at the last step are no-ops', () {
    final c = _container();
    final n = c.read(wizardControllerProvider.notifier);
    n.back();
    expect(c.read(wizardControllerProvider).step, 0);
    for (var i = 0; i < 10; i++) {
      n.next();
    }
    expect(c.read(wizardControllerProvider).step, WizardState.lastStep);
  });

  test('max HR derives from birth year until the user types one', () {
    final c = _container();
    final n = c.read(wizardControllerProvider.notifier);
    n.birthYearChanged('1996');
    expect(c.read(wizardControllerProvider).draft.effectiveMaxHr(2026), 190);

    n.maxHrChanged('178');
    expect(c.read(wizardControllerProvider).draft.effectiveMaxHr(2026), 178);

    // The typed value survives a later birth-year change: recomputing it
    // would silently overwrite a number the user knows and we do not.
    n.birthYearChanged('1980');
    expect(c.read(wizardControllerProvider).draft.effectiveMaxHr(2026), 178);

    // Clearing the field returns it to the estimate.
    n.maxHrChanged('');
    expect(c.read(wizardControllerProvider).draft.effectiveMaxHr(2026), 174);
  });

  test('goal steps by the unit system increment and clamps at both bounds', () {
    final c = _container();
    final n = c.read(wizardControllerProvider.notifier);
    expect(c.read(wizardControllerProvider).draft.effectiveWeeklyGoal, 20);

    n.goalIncrement();
    expect(c.read(wizardControllerProvider).draft.effectiveWeeklyGoal, 22.5);

    for (var i = 0; i < 200; i++) {
      n.goalDecrement();
    }
    expect(
      c.read(wizardControllerProvider).draft.effectiveWeeklyGoal,
      GoalRules.metricMin,
    );
    expect(c.read(wizardControllerProvider).canDecrementGoal, isFalse);
    expect(c.read(wizardControllerProvider).canIncrementGoal, isTrue);
  });

  test('switching units re-seeds the goal instead of carrying a magnitude', () {
    // 30 km is not 30 mi. Carrying the raw number across would silently
    // change what the user asked for by 60%.
    final c = _container();
    final n = c.read(wizardControllerProvider.notifier);
    n.goalIncrement();
    n.goalIncrement();
    expect(c.read(wizardControllerProvider).draft.effectiveWeeklyGoal, 25);

    n.unitSystemChanged(UnitSystem.imperial);
    expect(
      c.read(wizardControllerProvider).draft.effectiveWeeklyGoal,
      GoalRules.imperialDefault,
    );
  });

  test('a partial birth year clears rather than half-parsing', () {
    final c = _container();
    final n = c.read(wizardControllerProvider.notifier);
    n.birthYearChanged('1996');
    n.birthYearChanged('199');
    expect(c.read(wizardControllerProvider).draft.birthYear, isNull);
  });

  test('gear scan starts with the stub devices and rescans', () {
    final c = _container();
    expect(c.read(gearScanProvider).status, GearScanStatus.found);
    expect(c.read(gearScanProvider).devices, hasLength(2));
    c.read(gearScanProvider.notifier).rescan();
    expect(c.read(gearScanProvider).status, GearScanStatus.found);
  });
}
