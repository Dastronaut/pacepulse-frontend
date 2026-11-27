import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_pressable.dart';

enum PPStatTone { positive, negative, neutral }

/// Nested dashboard stat tile. Background role split: dark surfaceContainerHigh /
/// light surfaceContainer (D1-B3; human ruling 2026-08-03: spec literals with
/// documented provenance). Lives INSIDE cards.
class PPStatTile extends StatelessWidget {
  const PPStatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.sub,
    this.subTone = PPStatTone.neutral,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final String? sub;
  final PPStatTone subTone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    final tile = Container(
      key: const Key('pp_stat_tile_box'),
      padding: const EdgeInsets.all(PPSpacing.s4),
      decoration: BoxDecoration(
        color: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(PPRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PPIcon(icon, size: PPIconSize.s20, color: pp.accentText),
          const SizedBox(height: PPSpacing.s2),
          Text(label,
              style: theme.textTheme.labelMedium!
                  .copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: PPSpacing.s1),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: theme.textTheme.headlineSmall!.copyWith(
                    fontFeatures: ppTabularFigures,
                  )),
              if (unit != null) ...[
                const SizedBox(width: PPSpacing.s1),
                Text(unit!,
                    style: theme.textTheme.labelMedium!
                        .copyWith(color: pp.onSurfaceFaint)),
              ],
            ],
          ),
          if (sub != null) ...[
            const SizedBox(height: PPSpacing.s1),
            Text(
              sub!,
              key: const Key('pp_stat_tile_sub'),
              style: theme.textTheme.labelMedium!.copyWith(
                color: switch (subTone) {
                  PPStatTone.positive => pp.success,
                  PPStatTone.negative => pp.warning,
                  PPStatTone.neutral => pp.onSurfaceFaint,
                },
                fontFeatures: ppTabularFigures,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return tile;
    return PPPressable(onPressed: onTap, semanticLabel: label, child: tile);
  }
}
