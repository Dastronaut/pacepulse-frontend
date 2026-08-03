import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../theme/theme.dart';

/// Universal press affordance from the design system's interaction spec
/// (D1 sheet: "Press: scale 0.97, --duration-instant + --ease-standard",
/// no ripple). The 0.97 scale factor is design-specified geometry with no
/// CSS custom property (human ruling 2026-08-03: spec literals with
/// documented provenance). Guarantees a >=44px hit target via
/// [PPTapTarget].
class PPPressable extends StatefulWidget {
  const PPPressable({
    super.key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<PPPressable> createState() => _PPPressableState();
}

class _PPPressableState extends State<PPPressable> {
  bool _down = false;

  bool get _interactive =>
      widget.enabled && (widget.onPressed != null || widget.onLongPress != null);

  @override
  Widget build(BuildContext context) {
    return PPTapTarget(
      child: Semantics(
        button: _interactive,
        enabled: widget.enabled,
        label: widget.semanticLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _interactive ? (_) => setState(() => _down = true) : null,
          onTapCancel:
              _interactive ? () => setState(() => _down = false) : null,
          onTapUp: _interactive ? (_) => setState(() => _down = false) : null,
          onTap: widget.enabled ? widget.onPressed : null,
          onLongPress: widget.enabled ? widget.onLongPress : null,
          child: AnimatedScale(
            scale: _down ? 0.97 : 1.0,
            duration: PPMotion.instant,
            curve: PPMotion.standard,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Inflates the hit-test area to at least [minSize] square without
/// affecting layout — small visuals (chips, dots) stay small but remain
/// tappable per the 44px rule.
///
/// Must be the outermost render object of the subtree it protects: Flutter's
/// default [RenderBox.hitTest] gates descent into children by its own
/// [RenderBox.size] before any child hit test runs, so a custom hit-test
/// override buried under other proxy boxes (e.g. a `Semantics` or
/// `GestureDetector` ancestor) would never be reached for points outside
/// that ancestor's (equally small) size. Putting the inflated hit test at
/// the top — with the same clamp-to-center forwarding trick Material's
/// `_RenderInputPadding` (used by `IconButton`) uses for out-of-bounds
/// points — is the only place a wider catch area can take effect without
/// growing the actual layout box.
class PPTapTarget extends SingleChildRenderObjectWidget {
  const PPTapTarget({
    super.key,
    this.minSize = PPSpacing.tapMin,
    required Widget super.child,
  });

  final double minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderPPTapTarget(minSize);

  @override
  void updateRenderObject(BuildContext context, RenderPPTapTarget renderObject) {
    renderObject.minSize = minSize;
  }
}

class RenderPPTapTarget extends RenderProxyBox {
  RenderPPTapTarget(this._minSize);

  double _minSize;
  double get minSize => _minSize;
  set minSize(double value) {
    if (value != _minSize) {
      _minSize = value;
      markNeedsLayout();
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position)) {
      return super.hitTest(result, position: position);
    }
    final expanded = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width < _minSize ? _minSize : size.width,
      height: size.height < _minSize ? _minSize : size.height,
    );
    if (!expanded.contains(position)) return false;
    // Point is in the inflated zone but outside the actual box: clamp it to
    // the box's center and forward, the way Material's _RenderInputPadding
    // does — the child subtree (Semantics > GestureDetector > ...) then
    // sees a position inside its own bounds.
    final center = size.center(Offset.zero);
    return result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (BoxHitTestResult result, Offset position) =>
          super.hitTest(result, position: center),
    );
  }
}
