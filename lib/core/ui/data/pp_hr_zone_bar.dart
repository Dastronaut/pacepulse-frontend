import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Stacked HR zone bar (D1-B6): 5 bands, widths = share of time in
/// zone with a 4px minimum so empty zones stay visible; 2px gaps; pill
/// ends on the container. Active zone: taller + full opacity.
///
/// Geometry specs: min band 4px, gap 2px (D1-B6), heights 12→16 when active (D1-B6),
/// legend text 11px (D1-B6); human ruling 2026-08-03 confirms these are final.
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
    final usable = totalWidth - gap * (fractions.length - 1);
    final raw = [for (final f in fractions) usable * f];
    // Clamp small bands up to minBand, take the excess from the rest.
    final clamped = List<double>.from(raw);
    var deficit = 0.0;
    var flexible = 0.0;
    for (var i = 0; i < clamped.length; i++) {
      if (clamped[i] < minBand) {
        deficit += minBand - clamped[i];
        clamped[i] = minBand;
      } else {
        flexible += clamped[i] - minBand;
      }
    }
    if (deficit > 0 && flexible > 0) {
      for (var i = 0; i < clamped.length; i++) {
        if (clamped[i] > minBand) {
          clamped[i] -= deficit * ((clamped[i] - minBand) / flexible);
        }
      }
    }
    return clamped;
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
