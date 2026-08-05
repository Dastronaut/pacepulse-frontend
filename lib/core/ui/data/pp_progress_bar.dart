import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// 8px pill progress (D1-B10). Fill animates slow/decelerate; goal hit
/// flips fill (and value text, if given) to success.
class PPProgressBar extends StatelessWidget {
  const PPProgressBar({
    super.key,
    required this.value,
    this.label,
    this.valueLabel,
    this.goalHit = false,
  });

  final double value;
  final String? label;
  final String? valueLabel;
  final bool goalHit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final fill = goalHit ? pp.success : theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || valueLabel != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(label ?? '', style: theme.textTheme.labelMedium),
              Text(valueLabel ?? '',
                  style: PPTextStyles.monoS.copyWith(
                      color: goalHit
                          ? pp.success
                          : theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: PPSpacing.s2),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(PPRadius.pill),
          child: SizedBox(
            height: PPSpacing.s2,
            child: ColoredBox(
              color: pp.ringTrack,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedFractionallySizedBox(
                  duration: PPMotion.slow,
                  curve: PPMotion.decelerate,
                  widthFactor: value.clamp(0.0, 1.0),
                  heightFactor: 1,
                  child: DecoratedBox(
                    key: const Key('pp_progress_fill'),
                    decoration: BoxDecoration(
                      color: fill,
                      borderRadius: BorderRadius.circular(PPRadius.pill),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
