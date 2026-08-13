import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'pp_chip.dart';

/// Reserved 320x50 banner slot (D1-E6). The slot is ALWAYS reserved on
/// the free tier — zero layout shift while loading or when no fill.
/// Premium removes the widget at build time (monetization feature's
/// flavor switch — out of scope here); never collapse at runtime.
/// Total outer height 66px (50 + 8×2 vertical padding per spec literal;
/// human ruling 2026-08-03: documented provenance). Dashed border with
/// 5px dash / 4px gap, hairline stroke (spec literals from D1 sheet).
class PPBannerAdSlot extends StatelessWidget {
  const PPBannerAdSlot({super.key, this.ad});

  /// The loaded ad widget (e.g. AdMob banner); null renders placeholder.
  final Widget? ad;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 66,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: PPSpacing.s2),
        child: Center(
          child: SizedBox(
            key: const Key('pp_ad_inner'),
            width: 320,
            height: 50,
            child: ad ??
                CustomPaint(
                  painter: _DashedBorderPainter(color: scheme.outline),
                  child: Container(
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(PPRadius.xs),
                    ),
                    child: const Center(
                        child: PPChip(label: 'Ad', shape: PPChipShape.tag)),
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = PPBorders.hairline
      ..color = color;
    final rrect = RRect.fromRectAndRadius(
        Offset.zero & size, const Radius.circular(PPRadius.xs));
    final path = Path()..addRRect(rrect);
    const dash = 5.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}
