import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';

// Geometry per D1-E5 (D3 illustration briefs), human ruling 2026-08-03:
// - onboarding canvas: 280×220
// - empty canvas: 96×96
// - ring gap: 28°

enum PPIllustrationSize {
  onboarding(Size(280, 220)),
  empty(Size(96, 96));

  const PPIllustrationSize(this.dimensions);
  final Size dimensions;
}

enum PPIllustrationAccent { ember, warning }

/// Placeholder reserving the EXACT specced canvas until the real
/// theme-aware SVGs are commissioned (D3 briefs). Start-gate ring
/// outline + accent dot + asset name. Swapping in real art must not
/// change any layout.
class PPIllustration extends StatelessWidget {
  const PPIllustration({
    super.key,
    required this.name,
    this.size = PPIllustrationSize.empty,
    this.accent = PPIllustrationAccent.ember,
  });

  final String name;
  final PPIllustrationSize size;
  final PPIllustrationAccent accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final accentColor = accent == PPIllustrationAccent.ember
        ? theme.colorScheme.primary
        : pp.warning;
    return SizedBox.fromSize(
      size: size.dimensions,
      child: CustomPaint(
        painter: _RingMotifPainter(
            line: pp.onSurfaceFaint, accent: accentColor),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(name,
              style: theme.textTheme.labelMedium!
                  .copyWith(color: pp.onSurfaceFaint)),
        ),
      ),
    );
  }
}

class _RingMotifPainter extends CustomPainter {
  _RingMotifPainter({required this.line, required this.accent});
  final Color line;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide * 0.32;
    final center = size.center(Offset.zero) - const Offset(0, 6);
    // Ring gap: 28° per D1-E5
    const gap = 28 * math.pi / 180;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = line;
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        -math.pi / 2 + gap / 2, 2 * math.pi - gap, false, paint);
    // Accent dot at the start gate.
    final dotAngle = -math.pi / 2 + gap / 2;
    canvas.drawCircle(
      center + Offset(r * math.cos(dotAngle), r * math.sin(dotAngle)),
      4,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(_RingMotifPainter old) =>
      old.line != line || old.accent != accent;
}
