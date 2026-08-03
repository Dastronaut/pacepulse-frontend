import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'pp_motion_utils.dart';

/// Expanding pulse ring behind [child] (the CSS pp-live-pulse,
/// painted because Flutter can't animate a box-shadow ring the same
/// way). loop=true repeats forever; changing [pulseToken] plays exactly
/// one cycle. Reduced motion: static 2px liveRing ring.
class PPLivePulse extends StatefulWidget {
  const PPLivePulse({
    super.key,
    required this.child,
    this.loop = false,
    this.pulseToken,
  });

  final Widget child;
  final bool loop;
  final Object? pulseToken;

  @override
  State<PPLivePulse> createState() => _PPLivePulseState();
}

class _PPLivePulseState extends State<PPLivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: PPMotion.livePulsePeriod,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(PPLivePulse old) {
    super.didUpdateWidget(old);
    if (widget.pulseToken != old.pulseToken && widget.pulseToken != null) {
      if (!ppReducedMotion(context)) _c.forward(from: 0);
    }
    _sync();
  }

  void _sync() {
    if (ppReducedMotion(context)) {
      _c.stop();
    } else if (widget.loop && !_c.isAnimating) {
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
    final pp = Theme.of(context).extension<PPColors>()!;
    final reduced = ppReducedMotion(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => CustomPaint(
        painter: _PulsePainter(
          progress: reduced ? null : (_c.isAnimating || _c.value > 0 ? _c.value : null),
          staticRing: reduced,
          glow: pp.liveGlow,
          ring: pp.liveRing,
          curve: PPMotion.pulse,
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({
    required this.progress,
    required this.staticRing,
    required this.glow,
    required this.ring,
    required this.curve,
  });

  final double? progress; // null = nothing animated to draw
  final bool staticRing;
  final Color glow;
  final Color ring;
  final Curve curve;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final baseR = size.shortestSide / 2;
    if (staticRing) {
      canvas.drawCircle(
        center,
        baseR + 2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ring,
      );
      return;
    }
    final p = progress;
    if (p == null) return;
    final t = curve.transform(p);
    final spread = 10.0 * t;
    canvas.drawCircle(
      center,
      baseR + spread,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = glow.withValues(alpha: (1 - t) * (glow.a)),
    );
  }

  @override
  bool shouldRepaint(_PulsePainter old) =>
      old.progress != progress || old.staticRing != staticRing;
}
