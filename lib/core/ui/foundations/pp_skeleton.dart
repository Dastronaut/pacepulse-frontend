import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import 'pp_motion_utils.dart';

/// Loading shimmer (T5). Base <-> highlight breathing at
/// [PPMotion.shimmerPeriod] with [PPMotion.pulse]. Under reduced motion
/// it holds the static base tone. Callers MUST size it identically to
/// the content it replaces (zero layout shift).
class PPSkeleton extends StatefulWidget {
  const PPSkeleton({super.key, this.width, this.height, this.radius = PPRadius.sm});

  final double? width;
  final double? height;
  final double radius;

  @override
  State<PPSkeleton> createState() => _PPSkeletonState();
}

class _PPSkeletonState extends State<PPSkeleton> with TickerProviderStateMixin {
  late AnimationController _controller;
  late ColorTween _colorTween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PPMotion.shimmerPeriod,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ppReducedMotion(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pp = Theme.of(context).extension<PPColors>()!;
    _colorTween = ColorTween(
      begin: pp.skeletonBase,
      end: pp.skeletonHighlight,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _colorTween.evaluate(
              AlwaysStoppedAnimation(_controller.value),
            ),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}
