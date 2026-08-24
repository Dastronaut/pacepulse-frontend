import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/onboarding/domain/profile_draft.dart';

void main() {
  group('ProfileRules.maxHrFor', () {
    test('220 minus age', () {
      expect(ProfileRules.maxHrFor(1996, 2026), 190);
    });

    test('null birth year derives nothing', () {
      expect(ProfileRules.maxHrFor(null, 2026), isNull);
    });

    test('implausible ages derive nothing rather than a nonsense number', () {
      // Age 9 and age 101 both fall outside the plausible band, so the
      // field stays empty with its helper text instead of showing a
      // number derived from a typo.
      expect(ProfileRules.maxHrFor(2017, 2026), isNull);
      expect(ProfileRules.maxHrFor(1925, 2026), isNull);
      // The boundaries themselves are inside the band.
      expect(ProfileRules.maxHrFor(2016, 2026), 210);
      expect(ProfileRules.maxHrFor(1926, 2026), 120);
    });
  });

  group('ProfileRules.parseBirthYear', () {
    test('accepts four digits, rejects everything else', () {
      expect(ProfileRules.parseBirthYear('1996'), 1996);
      expect(ProfileRules.parseBirthYear(''), isNull);
      expect(ProfileRules.parseBirthYear('96'), isNull);
      expect(ProfileRules.parseBirthYear('19x6'), isNull);
    });
  });

  group('ProfileDraft', () {
    test('a typed max HR is never recomputed from age', () {
      const draft = ProfileDraft(birthYear: 1996, maxHrBpm: 178);
      expect(draft.effectiveMaxHr(2026), 178);
    });

    test('a null max HR derives from age', () {
      const draft = ProfileDraft(birthYear: 1996);
      expect(draft.effectiveMaxHr(2026), 190);
    });

    test('copyWith clears nullable fields only when asked', () {
      const draft = ProfileDraft(birthYear: 1996, maxHrBpm: 178);
      // Without the clear flag, omitting a field must preserve it.
      expect(draft.copyWith(name: 'Dana').maxHrBpm, 178);
      // With it, the field goes back to derived.
      expect(draft.copyWith(clearMaxHrBpm: true).maxHrBpm, isNull);
      expect(draft.copyWith(clearBirthYear: true).birthYear, isNull);
    });

    test('goal falls back to the unit system default until set', () {
      expect(const ProfileDraft().effectiveWeeklyGoal, GoalRules.metricDefault);
      expect(
        const ProfileDraft(unitSystem: UnitSystem.imperial).effectiveWeeklyGoal,
        GoalRules.imperialDefault,
      );
      expect(const ProfileDraft(weeklyGoal: 35).effectiveWeeklyGoal, 35);
    });
  });

  group('GoalRules', () {
    test('formats whole values without a decimal tail', () {
      expect(GoalRules.format(20), '20');
      expect(GoalRules.format(22.5), '22.5');
    });

    test('clamps to the unit system band', () {
      expect(GoalRules.clamp(0, UnitSystem.metric), GoalRules.metricMin);
      expect(GoalRules.clamp(999, UnitSystem.metric), GoalRules.metricMax);
      expect(GoalRules.clamp(0, UnitSystem.imperial), GoalRules.imperialMin);
    });

    test('unit labels', () {
      expect(GoalRules.unitLabel(UnitSystem.metric), 'km');
      expect(GoalRules.unitLabel(UnitSystem.imperial), 'mi');
    });
  });
}
