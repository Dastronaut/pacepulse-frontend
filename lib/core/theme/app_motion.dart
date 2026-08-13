import 'package:flutter/animation.dart';

/// PacePulse · Motion tokens (generated from design-tokens/motion.css,
/// including the approved T1 addition).
///
/// Snappy standard transitions; overshoot reserved for celebration
/// moments (ring fill, PR, challenge win). Every hero animation must
/// ship a reduced-motion alternative — check
/// `MediaQuery.disableAnimationsOf(context)` and fall back to the
/// static treatment (e.g. solid ring instead of pulse).
abstract final class PPMotion {
  // Durations (state flips → celebrations)
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 140);
  static const base = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 360);
  static const deliberate = Duration(milliseconds: 560);

  /// T1 — loading spinner rotation period (linear).
  static const spin = Duration(milliseconds: 900);

  // Easing
  static const standard = Cubic(0.2, 0, 0, 1);
  static const decelerate = Cubic(0, 0, 0, 1);
  static const accelerate = Cubic(0.3, 0, 1, 1);

  /// Overshoot — celebrations only (ring celebrate, PR burst).
  static const energetic = Cubic(0.34, 1.56, 0.64, 1);

  /// Breathing curve for the live pulse loop.
  static const pulse = Cubic(0.4, 0, 0.6, 1);

  // Hero loop timings (from the CSS keyframe definitions)
  static const livePulsePeriod = Duration(milliseconds: 1600);
  static const liveDotPeriod = Duration(milliseconds: 1200);

  /// T5 — skeleton shimmer period (base ↔ highlight breathing).
  static const shimmerPeriod = Duration(milliseconds: 1400);

  /// One 3-2-1 countdown numeral (pop in → hold → out), per Flow 2.
  static const countdownBeat = Duration(milliseconds: 1000);
}
