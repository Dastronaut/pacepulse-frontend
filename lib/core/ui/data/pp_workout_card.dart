import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_pressable.dart';
import '../status/pp_chip.dart';

/// Recent-workout list card (D1-B4). The WHOLE card is the tap target.
class PPWorkoutCard extends StatefulWidget {
  const PPWorkoutCard({
    super.key,
    required this.icon,
    required this.title,
    required this.meta,
    required this.stats,
    this.showPr = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String meta;
  final String stats;
  final bool showPr;
  final VoidCallback? onTap;

  @override
  State<PPWorkoutCard> createState() => _PPWorkoutCardState();
}

class _PPWorkoutCardState extends State<PPWorkoutCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return PPPressable(
      enabled: widget.onTap != null,
      onPressed: widget.onTap,
      onHighlightChanged: (v) => setState(() => _pressed = v),
      semanticLabel: widget.title,
      child: AnimatedContainer(
        key: const Key('pp_workout_card_box'),
        duration: PPMotion.instant,
        padding: const EdgeInsets.all(PPSpacing.s4),
        decoration: BoxDecoration(
          color: _pressed
              ? scheme.surfaceContainerHigh
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(PPRadius.lg),
          boxShadow: dark ? null : pp.shadow1,
        ),
        child: Row(
          children: [
            Container(
              width: PPSpacing.tapMin,
              height: PPSpacing.tapMin,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(PPRadius.md),
              ),
              child: Center(
                child: PPIcon(widget.icon,
                    color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: PPSpacing.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(widget.title,
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (widget.showPr) ...[
                      const SizedBox(width: PPSpacing.s2),
                      const PPChip(label: 'PR'),
                    ],
                  ]),
                  Text(widget.meta,
                      style: theme.textTheme.labelMedium!
                          .copyWith(color: pp.onSurfaceFaint)),
                  const SizedBox(height: PPSpacing.s1),
                  Text(widget.stats,
                      style: PPTextStyles.monoS
                          .copyWith(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            PPIcon(PPIcons.chevronRight,
                size: PPIconSize.s20, color: pp.onSurfaceFaint),
          ],
        ),
      ),
    );
  }
}
