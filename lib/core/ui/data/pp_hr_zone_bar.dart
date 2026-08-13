import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Stacked HR zone bar (D1-B6): 5 bands, widths = share of time in
/// zone with a 4px minimum so empty zones stay visible; 2px gaps; pill
/// ends on the container. Active zone: taller + full opacity.
///
/// Geometry specs: min band 4px, gap 2px (D1-B6), heights 12→16 when active (D1-B6),
/// legend text 11px (D1-B6); human ruling 2026-08-03 confirms these are final.
///
/// bandWidths: fractions are normalized as weights (bar always fills width, no shrinkage);
/// floors (minBand) guaranteed whenever they physically fit; equal-split fallback otherwise.
class PPHRZoneBar extends StatelessWidget {
  const PPHRZoneBar({
    super.key,
    required this.fractions,
    this.activeZone,
    this.height = 12,
    this.legendTimes,
  }) : assert(fractions.length == 5);

  final List<double> fractions;
  final int? activeZone; // 1-based
  final double height;
  final List<String>? legendTimes;

  static List<double> bandWidths({
    required List<double> fractions,
    required double totalWidth,
    double minBand = 4,
    double gap = 2,
  }) {
    final n = fractions.length;
    final usable = totalWidth - gap * (n - 1);
    // Degenerate width: floors can't fit — equal split, never negative.
    if (usable <= minBand * n) {
      final w = (usable / n).clamp(0.0, double.infinity);
      return List.filled(n, w);
    }
    // Treat fractions as weights; all-zero -> equal weights (full-width bar).
    final sum = fractions.fold(0.0, (a, b) => a + b);
    final weights = sum > 0
        ? [for (final f in fractions) f / sum]
        : List.filled(n, 1 / n);
    // Lock under-floor bands at minBand; redistribute the rest by weight.
    final widths = List<double>.filled(n, 0);
    final locked = List<bool>.filled(n, false);
    for (var pass = 0; pass < n; pass++) {
      final lockedWidth =
          [for (var i = 0; i < n; i++) if (locked[i]) minBand]
              .fold(0.0, (a, b) => a + b);
      final freeWidth = usable - lockedWidth;
      final freeWeight =
          [for (var i = 0; i < n; i++) if (!locked[i]) weights[i]]
              .fold(0.0, (a, b) => a + b);
      var changed = false;
      for (var i = 0; i < n; i++) {
        if (locked[i]) {
          widths[i] = minBand;
          continue;
        }
        widths[i] = freeWeight > 0
            ? freeWidth * (weights[i] / freeWeight)
            : freeWidth / (n - locked.where((l) => l).length);
        if (widths[i] < minBand) {
          locked[i] = true;
          changed = true;
        }
      }
      if (!changed) break;
    }
    for (var i = 0; i < n; i++) {
      if (widths[i] < minBand) widths[i] = minBand;
    }
    return widths;
  }

  @override
  Widget build(BuildContext context) {
    final pp = Theme.of(context).extension<PPColors>()!;
    final activeH = height + 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: activeH,
          child: LayoutBuilder(builder: (context, constraints) {
            final widths = bandWidths(
                fractions: fractions, totalWidth: constraints.maxWidth);
            return ClipRRect(
              borderRadius: BorderRadius.circular(PPRadius.pill),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < 5; i++) ...[
                    if (i > 0) const SizedBox(width: 2),
                    Opacity(
                      opacity:
                          activeZone == null || activeZone == i + 1 ? 1 : 0.5,
                      child: Container(
                        key: const Key('pp_zone_band'),
                        width: widths[i],
                        constraints: BoxConstraints.tightFor(
                            height:
                                activeZone == i + 1 ? activeH : height),
                        decoration: BoxDecoration(
                          color: pp.hrZones[i],
                          borderRadius: BorderRadius.circular(PPRadius.xs),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
        if (legendTimes != null) ...[
          const SizedBox(height: PPSpacing.s2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 5; i++)
                Text('Z${i + 1} ${legendTimes![i]}',
                    style: PPTextStyles.monoS.copyWith(
                        fontSize: 11,
                        color: activeZone == i + 1
                            ? Theme.of(context).colorScheme.onSurface
                            : pp.hrZones[i])),
            ],
          ),
        ],
      ],
    );
  }
}
