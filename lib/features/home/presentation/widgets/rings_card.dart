import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/daily_rings.dart';
import '../../domain/home_copy.dart';

const double _ringSize = 168;

String ppGroupDigits(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

class RingsCard extends StatelessWidget {
  const RingsCard({super.key, required this.rings, this.onTap});

  final DailyRings rings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    final card = Container(
      key: const Key('home_rings_card'),
      padding: const EdgeInsets.all(PPSpacing.padCard),
      decoration: BoxDecoration(
        color: dark ? scheme.surfaceContainer : scheme.surface,
        borderRadius: BorderRadius.circular(PPRadius.lg),
        border: dark
            ? null
            : Border.all(color: scheme.outlineVariant, width: PPBorders.hairline),
      ),
      child: Row(
        children: [
          PPActivityRings(
            move: rings.moveProgress,
            exercise: rings.exerciseProgress,
            steps: rings.stepsProgress,
            size: _ringSize,
          ),
          const SizedBox(width: PPSpacing.s5),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Legend(
                  color: pp.ringMove,
                  label: HomeCopy.move,
                  value: '${rings.moveKcal}',
                  goal: '/${rings.moveGoalKcal} ${HomeCopy.kcal}',
                ),
                const SizedBox(height: PPSpacing.s3),
                _Legend(
                  color: pp.ringExercise,
                  label: HomeCopy.exercise,
                  value: '${rings.exerciseMin}',
                  goal: '/${rings.exerciseGoalMin} ${HomeCopy.min}',
                ),
                const SizedBox(height: PPSpacing.s3),
                _Legend(
                  color: pp.ringSteps,
                  label: HomeCopy.steps,
                  valueKey: const Key('home_steps_value'),
                  value: rings.hasSteps
                      ? ppGroupDigits(rings.steps!)
                      : HomeCopy.noSteps,
                  goal: '/${ppGroupDigits(rings.stepsGoal)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return PPPressable(onPressed: onTap, child: card);
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
    required this.goal,
    this.valueKey,
  });

  final Color color;
  final String label;
  final String value;
  final String goal;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: PPSpacing.s2,
              height: PPSpacing.s2,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: PPSpacing.gapInline),
            Text(
              label,
              style: theme.textTheme.labelMedium!
                  .copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              key: valueKey,
              style: theme.textTheme.headlineSmall!
                  .copyWith(fontFeatures: ppTabularFigures),
            ),
            const SizedBox(width: PPSpacing.s1),
            Text(
              goal,
              style: theme.textTheme.labelMedium!.copyWith(
                color: pp.onSurfaceFaint,
                fontFeatures: ppTabularFigures,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
