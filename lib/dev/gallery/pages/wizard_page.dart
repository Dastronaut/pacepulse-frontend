import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../../../features/onboarding/domain/profile_draft.dart';
import '../../../features/onboarding/presentation/widgets/wizard_step_about.dart';
import '../../../features/onboarding/presentation/widgets/wizard_step_gear.dart';
import '../../../features/onboarding/presentation/widgets/wizard_step_goal.dart';
import '../../../features/onboarding/presentation/widgets/wizard_step_units.dart';
import '../../../features/onboarding/presentation/wizard_controller.dart';
import '../../../features/permissions/domain/permission_kind.dart';
import '../../../features/permissions/presentation/permission_priming_screen.dart';
import '../gallery.dart';

const _galleryDefaults = WizardDefaults(
  unitSystem: UnitSystem.metric,
  currentYear: 2026,
);

const _seededAbout = ProfileDraft(
  name: 'Dana',
  birthYear: 1996,
  body: BodyOption.female,
);

const _seededImperial = ProfileDraft(unitSystem: UnitSystem.imperial);

class WizardGalleryPage extends StatelessWidget {
  const WizardGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GallerySection(
          title: 'PPStepper - metric default',
          child: PPStepper(
            valueLabel: GoalRules.format(GoalRules.metricDefault),
            unit: ' ${GoalRules.unitLabel(UnitSystem.metric)}',
            caption: WizardCopy.goalNudgeMetric,
            onDecrement: () {},
            onIncrement: () {},
          ),
        ),
        GallerySection(
          title: 'PPStepper - at the lower bound',
          child: PPStepper(
            valueLabel: GoalRules.format(GoalRules.metricMin),
            unit: ' ${GoalRules.unitLabel(UnitSystem.metric)}',
            caption: WizardCopy.goalNudgeMetric,
            onIncrement: () {},
          ),
        ),
        GallerySection(
          title: 'PPChoicePills - one selected',
          child: PPChoicePills(
            options: const [
              WizardCopy.bodyFemale,
              WizardCopy.bodyMale,
              WizardCopy.bodyUnspecified,
            ],
            selectedIndex: 0,
            onChanged: (_) {},
          ),
        ),
        GallerySection(
          title: 'PPChoicePills - nothing selected',
          child: PPChoicePills(
            options: const [WizardCopy.weekMonday, WizardCopy.weekSunday],
            selectedIndex: null,
            onChanged: (_) {},
          ),
        ),
        GallerySection(
          title: 'Wizard - step 1',
          child: _wizard(
            const _Frame(child: WizardStepAbout(onContinue: _noop)),
            draft: _seededAbout,
          ),
        ),
        GallerySection(
          title: 'Wizard - step 2',
          child: _wizard(
            const _Frame(child: WizardStepUnits(onContinue: _noop)),
            draft: _seededAbout,
          ),
        ),
        GallerySection(
          title: 'Wizard - step 3 metric',
          child: _wizard(
            const _Frame(child: WizardStepGoal(onContinue: _noop)),
          ),
        ),
        GallerySection(
          title: 'Wizard - step 3 imperial',
          child: _wizard(
            const _Frame(child: WizardStepGoal(onContinue: _noop)),
            draft: _seededImperial,
          ),
        ),
        GallerySection(
          title: 'Wizard - step 4 found',
          child: _wizard(const _Frame(child: _GearStep())),
        ),
        GallerySection(
          title: 'Wizard - step 4 scanning',
          child: _wizard(
            const _Frame(child: _GearStep()),
            scan: const GearScan(status: GearScanStatus.scanning, devices: []),
          ),
        ),
        GallerySection(
          title: 'Wizard - step 4 empty',
          child: _wizard(
            const _Frame(child: _GearStep()),
            scan: const GearScan(status: GearScanStatus.empty, devices: []),
          ),
        ),
        GallerySection(
          title: 'Wizard - step 4 bluetooth off',
          child: _wizard(
            const _Frame(child: _GearStep()),
            scan: const GearScan(
              status: GearScanStatus.bluetoothOff,
              devices: [],
            ),
          ),
        ),
        for (final kind in PermissionKind.values)
          GallerySection(
            title: 'Priming - ${kind.name}',
            child: _Frame(
              child: PermissionPrimingScreen(
                kind: kind,
                onAllow: _noop,
                onNotNow: _noop,
              ),
            ),
          ),
      ],
    );
  }
}

void _noop() {}

Widget _wizard(Widget child, {ProfileDraft? draft, GearScan? scan}) {
  return ProviderScope(
    overrides: [
      wizardDefaultsProvider.overrideWithValue(_galleryDefaults),
      if (draft != null)
        wizardControllerProvider.overrideWith(() => _SeededWizard(draft)),
      if (scan != null) gearScanProvider.overrideWith(() => _SeededScan(scan)),
    ].cast(),
    child: child,
  );
}

class _GearStep extends StatelessWidget {
  const _GearStep();

  @override
  Widget build(BuildContext context) =>
      WizardStepGear(onFinish: _noop, onSkip: _noop, onConnect: (_) {});
}

class _SeededWizard extends WizardController {
  _SeededWizard(this.seed);
  final ProfileDraft seed;
  @override
  WizardState build() => WizardState(draft: seed);
}

class _SeededScan extends GearScanController {
  _SeededScan(this.seed);
  final GearScan seed;
  @override
  GearScan build() => seed;
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: PPFrame.width, height: PPFrame.height, child: child);
  }
}
