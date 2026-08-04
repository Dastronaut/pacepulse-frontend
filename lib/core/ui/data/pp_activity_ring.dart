import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_motion_utils.dart';

/// Start-gate ring math (D1-B1, human ruling 2026-08-03). Gap 28 degrees
/// centred at 12 o'clock; sweep clockwise from -90deg + gap/2.
abstract final class PPRingGeometry {
  static const double gapDegrees = 28;
  static double get gapRadians => gapDegrees * math.pi / 180;
  static double get startAngle => -math.pi / 2 + gapRadians / 2;
  static double sweep(double value) =>
      (2 * math.pi - gapRadians) * value.clamp(0.0, 1.0);
}

/// One start-gate ring. Round caps, track under value arc, nestable via
/// [child] (the triad nests ring-in-ring; center stat is innermost).
class PPActivityRing extends StatelessWidget {
  const PPActivityRing({
    super.key,
    required this.value,
    required this.color,
    this.size = 200,
    this.thickness = 16,
    this.child,
  });

  final double value;
  final Color color;
  final double size;
  final double thickness;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final pp = Theme.of(context).extension<PPColors>()!;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
            value: value,
            color: color,
            track: pp.ringTrack,
            thickness: thickness),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.value,
    required this.color,
    required this.track,
    required this.thickness,
  });

  final double value;
  final Color color;
  final Color track;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - thickness) / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, PPRingGeometry.startAngle,
        PPRingGeometry.sweep(1), false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(rect, PPRingGeometry.startAngle,
          PPRingGeometry.sweep(value), false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.track != track ||
      old.thickness != thickness;
}

/// The dashboard triad: move/exercise/steps at 200/156/112, stroke 16
/// (8px inter-ring gap). Values animate in over [PPMotion.deliberate]
/// with [PPMotion.energetic]; [celebrateToken] change pulses 1->1.08->1.
class PPActivityRings extends StatefulWidget {
  const PPActivityRings({
    super.key,
    required this.move,
    required this.exercise,
    required this.steps,
    this.size = 200,
    this.child,
    this.celebrateToken,
  });

  final double move;
  final double exercise;
  final double steps;
  final double size;
  final Widget? child;
  final Object? celebrateToken;

  @override
  State<PPActivityRings> createState() => _PPActivityRingsState();
}

class _PPActivityRingsState extends State<PPActivityRings>
    with TickerProviderStateMixin {
  late final AnimationController _intro =
      AnimationController(vsync: this, duration: PPMotion.deliberate);
  late final AnimationController _celebrate =
      AnimationController(vsync: this, duration: PPMotion.deliberate);
  bool _introStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_introStarted) return;
    _introStarted = true;
    if (ppReducedMotion(context)) {
      _intro.value = 1;
    } else {
      _intro.forward();
    }
  }

  @override
  void didUpdateWidget(PPActivityRings old) {
    super.didUpdateWidget(old);
    if (widget.celebrateToken != old.celebrateToken &&
        widget.celebrateToken != null &&
        !ppReducedMotion(context)) {
      _celebrate.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _celebrate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pp = Theme.of(context).extension<PPColors>()!;
    final t =
        CurvedAnimation(parent: _intro, curve: PPMotion.energetic);
    final pulse = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 60),
    ]).animate(_celebrate);
    final scale = widget.size / 200; // proportional nesting

    return AnimatedBuilder(
      animation: Listenable.merge([t, pulse]),
      builder: (context, _) => Transform.scale(
        scale: pulse.value,
        child: PPActivityRing(
          value: widget.move * t.value,
          color: pp.ringMove,
          size: widget.size,
          thickness: 16 * scale,
          child: PPActivityRing(
            value: widget.exercise * t.value,
            color: pp.ringExercise,
            size: 156 * scale,
            thickness: 16 * scale,
            child: PPActivityRing(
              value: widget.steps * t.value,
              color: pp.ringSteps,
              size: 112 * scale,
              thickness: 16 * scale,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
