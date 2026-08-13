import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_live_dot.dart';

enum PPMetricFace { display, mono }

/// Live-workout hero numeral block. Mono face value scaled to 72 w700, unit 24
/// w600, live dot 10 (D1-B2; human ruling 2026-08-03: spec literals with
/// documented provenance). Metrics sit straight on the canvas — no card.
/// Every digit is tabular.
class PPMetricDisplay extends StatelessWidget {
  const PPMetricDisplay({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.sub,
    this.face = PPMetricFace.display,
    this.live = false,
    this.accent = false,
  });

  final String label;
  final String value;
  final String? unit;
  final String? sub;
  final PPMetricFace face;
  final bool live;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final valueColor = accent ? pp.accentText : theme.colorScheme.onSurface;
    final valueStyle = face == PPMetricFace.display
        ? theme.textTheme.displayLarge!.copyWith(color: valueColor)
        : PPTextStyles.monoXl.copyWith(
            fontSize: 72, height: 0.95, color: valueColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (live) ...[
              const PPLiveDot(size: 10),
              const SizedBox(width: PPSpacing.s2),
            ],
            Text(label.toUpperCase(),
                style: theme.textTheme.labelSmall!
                    .copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: PPSpacing.s1),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
                child: Text(value,
                    style: valueStyle, overflow: TextOverflow.fade)),
            if (unit != null) ...[
              const SizedBox(width: PPSpacing.s2),
              Text(unit!,
                  style: theme.textTheme.titleLarge!.copyWith(
                      fontSize: 24,
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
        if (sub != null) ...[
          const SizedBox(height: PPSpacing.s1),
          Text(sub!,
              style: PPTextStyles.monoS
                  .copyWith(color: pp.onSurfaceFaint)),
        ],
      ],
    );
  }
}
