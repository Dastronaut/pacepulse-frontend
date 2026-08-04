import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'pp_motion_utils.dart';

/// Loading spinner (T1): 2.5px round-cap arc rotating once per
/// [PPMotion.spin], linear. Reduced motion: static arc.
///
/// The 2.5px stroke width and ~213° sweep are design-specified geometry
/// with no CSS custom property on the D1 sheet (human ruling 2026-08-03:
/// spec literals with documented provenance — see pp_pressable.dart:6-11).
class PPSpinner extends StatefulWidget {
  const PPSpinner({super.key, this.size = 18, this.color});

  final double size;
  final Color? color;

  @override
  State<PPSpinner> createState() => _PPSpinnerState();
}

class _PPSpinnerState extends State<PPSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: PPMotion.spin);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ppReducedMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.onPrimary;
    return RotationTransition(
      turns: _c,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _ArcPainter(color),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = color;
    final rect = Offset.zero & size;
    // dash 26 of C≈44 (r=7) ≈ 213°.
    canvas.drawArc(rect.deflate(1.25), -math.pi / 2,
        213 * math.pi / 180, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
