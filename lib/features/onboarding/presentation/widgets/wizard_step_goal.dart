import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/profile_draft.dart';
import '../wizard_controller.dart';
import 'wizard_step_scaffold.dart';

const double _cardVPad = 28;

class WizardStepGoal extends ConsumerWidget {
  const WizardStepGoal({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(wizardControllerProvider);
    final notifier = ref.read(wizardControllerProvider.notifier);
    final units = state.draft.unitSystem;

    return WizardStepScaffold(
      overline: WizardCopy.step3Overline,
      title: WizardCopy.step3Title,
      body: WizardCopy.step3Body,
      fields: [
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: _cardVPad,
            horizontal: PPSpacing.s5,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(PPRadius.lg),
          ),
          child: PPStepper(
            valueLabel: GoalRules.format(state.draft.effectiveWeeklyGoal),
            unit: ' ${GoalRules.unitLabel(units)}',
            caption: units == UnitSystem.metric
                ? WizardCopy.goalNudgeMetric
                : WizardCopy.goalNudgeImperial,
            decrementSemanticLabel: WizardCopy.goalDecrease,
            incrementSemanticLabel: WizardCopy.goalIncrease,
            onDecrement: state.canDecrementGoal ? notifier.goalDecrement : null,
            onIncrement: state.canIncrementGoal ? notifier.goalIncrement : null,
          ),
        ),
      ],
      footer: PPButton(
        key: const Key('wizard_step3_continue'),
        label: WizardCopy.continueLabel,
        size: PPButtonSize.lg,
        fullWidth: true,
        onPressed: onContinue,
      ),
    );
  }
}
