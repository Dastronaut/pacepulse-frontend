import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/profile_draft.dart';
import '../wizard_controller.dart';
import 'wizard_field_label.dart';
import 'wizard_step_scaffold.dart';

class WizardStepUnits extends ConsumerStatefulWidget {
  const WizardStepUnits({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  ConsumerState<WizardStepUnits> createState() => _WizardStepUnitsState();
}

class _WizardStepUnitsState extends ConsumerState<WizardStepUnits> {
  late final TextEditingController _maxHr;
  final _maxHrFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final year = ref.read(wizardDefaultsProvider).currentYear;
    final draft = ref.read(wizardControllerProvider).draft;
    _maxHr = TextEditingController(
      text: draft.effectiveMaxHr(year)?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _maxHr.dispose();
    _maxHrFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final draft = ref.watch(wizardControllerProvider).draft;
    final notifier = ref.read(wizardControllerProvider.notifier);
    final year = ref.watch(wizardDefaultsProvider).currentYear;

    ref.listen(wizardControllerProvider, (_, next) {
      if (next.draft.maxHrBpm != null || _maxHrFocus.hasFocus) return;
      final text = next.draft.effectiveMaxHr(year)?.toString() ?? '';
      if (_maxHr.text != text) _maxHr.text = text;
    });

    return WizardStepScaffold(
      overline: WizardCopy.step2Overline,
      title: WizardCopy.step2Title,
      body: WizardCopy.step2Body,
      fields: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardFieldLabel(text: WizardCopy.unitsLabel),
            const SizedBox(height: PPSpacing.s2),
            PPSegmentedControl(
              segments: const [
                WizardCopy.unitsMetric,
                WizardCopy.unitsImperial,
              ],
              selectedIndex: draft.unitSystem.index,
              onChanged: (i) =>
                  notifier.unitSystemChanged(UnitSystem.values[i]),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardFieldLabel(text: WizardCopy.weekStartLabel),
            const SizedBox(height: PPSpacing.s2),
            PPChoicePills(
              options: const [WizardCopy.weekMonday, WizardCopy.weekSunday],
              selectedIndex: draft.weekStart.index,
              onChanged: (i) => notifier.weekStartChanged(WeekStart.values[i]),
            ),
          ],
        ),
        PPTextField(
          label: WizardCopy.maxHrLabel,
          controller: _maxHr,
          focusNode: _maxHrFocus,
          keyboardType: TextInputType.number,
          tabularFigures: true,
          helperText: WizardCopy.maxHrHelper,
          textInputAction: TextInputAction.done,
          onChanged: notifier.maxHrChanged,
          trailing: Text(
            WizardCopy.maxHrUnit,
            style: theme.textTheme.labelMedium!.copyWith(
              color: pp.onSurfaceFaint,
            ),
          ),
        ),
      ],
      footer: PPButton(
        key: const Key('wizard_step2_continue'),
        label: WizardCopy.continueLabel,
        size: PPButtonSize.lg,
        fullWidth: true,
        onPressed: widget.onContinue,
      ),
    );
  }
}
