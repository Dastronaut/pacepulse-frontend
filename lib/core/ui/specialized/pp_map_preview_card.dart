import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_pressable.dart';

/// Route preview card (D1-F1: map area 140, polyline 4px, endpoint dots r4 —
/// human ruling 2026-08-03: spec literals with documented provenance).
/// The map area is the mockups' hatch placeholder until the styled Google Maps
/// basemaps land (D3) — the polyline/dot treatment is final.
class PPMapPreviewCard extends StatelessWidget {
  const PPMapPreviewCard({
    super.key,
    required this.route,
    this.height = 140,
    this.statsLine,
    this.onTap,
  });

  /// Normalized 0..1 route points (x right, y down).
  final List<Offset> route;
  final double height;
  final String? statsLine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    final card = ClipRRect(
      borderRadius: BorderRadius.circular(PPRadius.lg),
      child: DecoratedBox(
        decoration:
            BoxDecoration(color: scheme.surfaceContainerLow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: const Key('pp_map_area'),
              height: height,
              child: CustomPaint(
                painter: _MapPlaceholderPainter(
                  hatch: dark
                      ? scheme.outlineVariant
                      : PPPalette.steelLightTrack,
                  surface: scheme.surfaceContainer,
                  routeColor: scheme.primary,
                  start: pp.success,
                  end: scheme.error,
                  route: route,
                ),
              ),
            ),
            if (statsLine != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: PPSpacing.s3, horizontal: PPSpacing.s4),
                child: Text(statsLine!,
                    style: PPTextStyles.monoS
                        .copyWith(color: scheme.onSurfaceVariant)),
              ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return PPPressable(
        onPressed: onTap, semanticLabel: 'Route preview', child: card);
  }
}

class _MapPlaceholderPainter extends CustomPainter {
  _MapPlaceholderPainter({
    required this.hatch,
    required this.surface,
    required this.routeColor,
    required this.start,
    required this.end,
    required this.route,
  });

  final Color hatch;
  final Color surface;
  final Color routeColor;
  final Color start;
  final Color end;
  final List<Offset> route;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = surface);
    final stripe = Paint()
      ..color = hatch
      ..strokeWidth = 1;
    for (var x = -size.height; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0),
          stripe);
    }
    if (route.length < 2) return;
    final points = [
      for (final p in route) Offset(p.dx * size.width, p.dy * size.height),
    ];
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = routeColor,
    );
    canvas.drawCircle(points.first, 4, Paint()..color = start);
    canvas.drawCircle(points.last, 4, Paint()..color = end);
  }

  @override
  bool shouldRepaint(_MapPlaceholderPainter old) =>
      old.route != route || old.hatch != hatch;
}
