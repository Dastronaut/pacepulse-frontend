import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';

// Flow 5 S2–S4 geometry with no CSS custom property (ruling 2026-08-17,
// convention per pp_button.dart:9-12):
// - slide 1 canvas 280×220, route stroke 5, hatch band 8px at 45° (perpendicular
//   period 16px — the painter steps along the 45° line, so its x-step is the
//   perpendicular period divided by sin45°, i.e. _hatchPeriod * sqrt2),
//   start dot r6, live end dot r7, polyline points as drawn
// - slide 2 specimen card width 300, interior gap 10
// - slide 3 chip gap 10
// - slide 3 activity ring size 150, thickness 14 (Flow 5 S4)
const _canvas = Size(280, 220);
const _routeStroke = 5.0;
const _hatchBandWidth = 8.0;
const _hatchPeriod = 16.0;
const _startDotRadius = 6.0;
const _liveDotRadius = 7.0;
const _streakRingSize = 150.0;
const _streakRingThickness = 14.0;
const _routePoints = <Offset>[
  Offset(36, 180),
  Offset(76, 128),
  Offset(124, 148),
  Offset(176, 84),
  Offset(224, 104),
  Offset(252, 48),
];
const _cardWidth = 300.0;
const _tightGap = 10.0;

/// Slide 1 — a real GPS route on the specced onboarding canvas.
/// Placeholder for commissioned D3 art: swapping that in replaces this
/// widget and changes no layout.
class GpsRouteSpecimen extends StatelessWidget {
  const GpsRouteSpecimen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;
    final end = _routePoints.last;
    return SizedBox.fromSize(
      size: _canvas,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PPRadius.lg),
          border: dark
              ? null
              : Border.all(
                  color: scheme.outlineVariant,
                  width: PPBorders.hairline,
                ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(PPRadius.lg),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _RoutePainter(
                    hatchLow: dark ? scheme.surfaceContainer : scheme.surface,
                    hatchHigh: dark
                        ? scheme.surfaceContainerHigh
                        : scheme.surfaceContainer,
                    route: scheme.primary,
                    start: pp.success,
                  ),
                ),
              ),
              Positioned(
                left: end.dx - _liveDotRadius,
                top: end.dy - _liveDotRadius,
                child: PPLivePulse(
                  loop: true,
                  child: Container(
                    width: _liveDotRadius * 2,
                    height: _liveDotRadius * 2,
                    decoration: BoxDecoration(
                      color: dark ? scheme.primary : pp.live,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({
    required this.hatchLow,
    required this.hatchHigh,
    required this.route,
    required this.start,
  });

  final Color hatchLow;
  final Color hatchHigh;
  final Color route;
  final Color start;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = hatchLow);
    // 45° hatch: 8px bands, matching the mock's repeating gradient.
    final band = Paint()
      ..color = hatchHigh
      ..strokeWidth = _hatchBandWidth
      ..style = PaintingStyle.stroke;
    for (
      var x = -size.height;
      x < size.width + size.height;
      x += _hatchPeriod * math.sqrt2
    ) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), band);
    }
    final path = Path()..moveTo(_routePoints.first.dx, _routePoints.first.dy);
    for (final p in _routePoints.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _routeStroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = route,
    );
    canvas.drawCircle(
      _routePoints.first,
      _startDotRadius,
      Paint()..color = start,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) =>
      old.hatchLow != hatchLow ||
      old.hatchHigh != hatchHigh ||
      old.route != route ||
      old.start != start;
}

/// Slide 2 — the signature feature demoing itself with real kit rows.
class LiveLeaderboardSpecimen extends StatelessWidget {
  const LiveLeaderboardSpecimen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;
    return Container(
      width: _cardWidth,
      padding: const EdgeInsets.all(PPSpacing.s4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(PPRadius.lg),
        boxShadow: dark ? null : pp.shadow1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: const [
          PPChip(label: 'Live', variant: PPChipVariant.live),
          SizedBox(height: _tightGap),
          PPLeaderboardRow(
            rank: 1,
            name: 'Marta K.',
            pace: '5:04',
            progress: 0.62,
            avatarInitials: 'MK',
          ),
          SizedBox(height: _tightGap),
          PPLeaderboardRow(
            rank: 2,
            name: 'You',
            pace: '5:08',
            progress: 0.58,
            avatarInitials: 'DN',
            isSelf: true,
            selfDeltaLabel: '+0:04',
          ),
        ],
      ),
    );
  }
}

/// Slide 3 — the reward loop in one image: ring + streak + PR.
class StreakRingSpecimen extends StatelessWidget {
  const StreakRingSpecimen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PPActivityRing(
          value: 0.82,
          color: pp.ringMove,
          size: _streakRingSize,
          thickness: _streakRingThickness,
          child: Text.rich(
            TextSpan(
              text: '82',
              style: theme.textTheme.displayMedium,
              children: [
                TextSpan(
                  text: '%',
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: PPSpacing.s4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            PPChip(label: '12 days', variant: PPChipVariant.streak),
            SizedBox(width: _tightGap),
            PPChip(label: 'PR · 5K', variant: PPChipVariant.pr),
          ],
        ),
      ],
    );
  }
}
