import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'pp_motion_utils.dart';

/// 8px live indicator dot: opacity 1<->0.55 + scale 1<->0.82 over
/// [PPMotion.liveDotPeriod]. Reduced motion: static full dot.
///
/// The 8px dot and 0.55/0.82 pulse factors come from the design system's
/// motion spec (pp-live-dot keyframes, D1 sheet) — design-specified geometry
/// with no CSS custom property (human ruling 2026-08-03: spec literals with
/// documented provenance).
class PPLiveDot extends StatefulWidget {
  const PPLiveDot({super.key, this.size = 8});

  final double size;

  @override
  State<PPLiveDot> createState() => _PPLiveDotState();
}

class _PPLiveDotState extends State<PPLiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: PPMotion.liveDotPeriod ~/ 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ppReducedMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
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
    final dot = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(color: pp.live, shape: BoxShape.circle),
    );
    if (ppReducedMotion(context)) return dot;
    final curved = CurvedAnimation(parent: _c, curve: PPMotion.pulse);
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.55).animate(curved),
      child: ScaleTransition(
        scale: Tween(begin: 1.0, end: 0.82).animate(curved),
        child: dot,
      ),
    );
  }
}
