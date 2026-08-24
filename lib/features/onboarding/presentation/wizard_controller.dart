import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/profile_draft.dart';

class WizardDefaults {
  const WizardDefaults({required this.unitSystem, required this.currentYear});

  final UnitSystem unitSystem;
  final int currentYear;
}

final wizardDefaultsProvider = Provider<WizardDefaults>((ref) {
  const imperialCountries = {'US', 'LR', 'MM', 'GB'};
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  return WizardDefaults(
    unitSystem: imperialCountries.contains(locale.countryCode)
        ? UnitSystem.imperial
        : UnitSystem.metric,
    currentYear: DateTime.now().year,
  );
});

class WizardState {
  const WizardState({required this.draft, this.step = 0});

  final ProfileDraft draft;
  final int step;

  static const int lastStep = 3;

  bool get isLast => step == lastStep;

  bool get canIncrementGoal =>
      draft.effectiveWeeklyGoal < GoalRules.maxFor(draft.unitSystem);

  bool get canDecrementGoal =>
      draft.effectiveWeeklyGoal > GoalRules.minFor(draft.unitSystem);

  WizardState copyWith({ProfileDraft? draft, int? step}) =>
      WizardState(draft: draft ?? this.draft, step: step ?? this.step);
}

class WizardController extends Notifier<WizardState> {
  @override
  WizardState build() => WizardState(
    draft: ProfileDraft(
      unitSystem: ref.watch(wizardDefaultsProvider).unitSystem,
    ),
  );

  void _draft(ProfileDraft next) => state = state.copyWith(draft: next);

  void nameChanged(String value) => _draft(state.draft.copyWith(name: value));

  void birthYearChanged(String raw) {
    final year = ProfileRules.parseBirthYear(raw);
    _draft(
      year == null
          ? state.draft.copyWith(clearBirthYear: true)
          : state.draft.copyWith(birthYear: year),
    );
  }

  void bodyChanged(BodyOption value) =>
      _draft(state.draft.copyWith(body: value));

  void weekStartChanged(WeekStart value) =>
      _draft(state.draft.copyWith(weekStart: value));

  void unitSystemChanged(UnitSystem value) {
    if (value == state.draft.unitSystem) return;
    _draft(state.draft.copyWith(unitSystem: value, clearWeeklyGoal: true));
  }

  void maxHrChanged(String raw) {
    final bpm = int.tryParse(raw.trim());
    _draft(
      bpm == null
          ? state.draft.copyWith(clearMaxHrBpm: true)
          : state.draft.copyWith(maxHrBpm: bpm),
    );
  }

  void goalIncrement() => _setGoal(state.draft.effectiveWeeklyGoal + _goalStep);

  void goalDecrement() => _setGoal(state.draft.effectiveWeeklyGoal - _goalStep);

  double get _goalStep => GoalRules.step(state.draft.unitSystem);

  void _setGoal(double value) => _draft(
    state.draft.copyWith(
      weeklyGoal: GoalRules.clamp(value, state.draft.unitSystem),
    ),
  );

  void next() {
    if (state.isLast) return;
    state = state.copyWith(step: state.step + 1);
  }

  void back() {
    if (state.step == 0) return;
    state = state.copyWith(step: state.step - 1);
  }

  /// TODO(wizard-slice): hand `state.draft` to the profile service here.
  /// Nothing is persisted this slice by design — see decision 1 of
  /// docs/superpowers/specs/2026-08-22-profile-wizard-permission-priming-design.md
  void finish() {}
}

final wizardControllerProvider =
    NotifierProvider<WizardController, WizardState>(WizardController.new);

// ---------------------------------------------------------------------------
// Step 4 gear scan — stubbed.
// ---------------------------------------------------------------------------

enum GearScanStatus { scanning, found, empty, bluetoothOff }

class GearDevice {
  const GearDevice({required this.name, required this.rssiDbm});

  final String name;
  final int rssiDbm;
}

class GearScan {
  const GearScan({
    this.status = GearScanStatus.found,
    this.devices = stubDevices,
  });

  final GearScanStatus status;
  final List<GearDevice> devices;

  static const List<GearDevice> stubDevices = [
    GearDevice(name: 'Polar H10', rssiDbm: -58),
    GearDevice(name: 'Garmin HRM-Pro', rssiDbm: -84),
  ];
}

class GearScanController extends Notifier<GearScan> {
  @override
  GearScan build() {
    // TODO(wizard-slice): start the real BLE scan here; it will begin in
    // GearScanStatus.scanning and settle into found/empty.
    return const GearScan();
  }

  void rescan() => state = const GearScan();
}

final gearScanProvider =
    NotifierProvider.autoDispose<GearScanController, GearScan>(
      GearScanController.new,
    );
