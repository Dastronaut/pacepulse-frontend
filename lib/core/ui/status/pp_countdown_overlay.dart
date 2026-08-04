import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/theme.dart';
import '../foundations/pp_motion_utils.dart';

/// Full-screen 3-2-1 countdown (D1-E2 / Flow 2 S5). The scrim is
/// scheme.scrim — DARK in both themes — so the numeral stays raw Ember
/// (PPPalette.ember) everywhere; light-mode accentText would be wrong
/// here. Reduced motion: crossfade only.
class PPCountdownOverlay extends StatefulWidget {
  const PPCountdownOverlay({
    super.key,
    required this.overline,
    this.caption,
    required this.onFinished,
    this.onCancelled,
    this.hapticTick,
    this.hapticGo,
  });

  final String overline;
  final String? caption;
  final VoidCallback onFinished;
  final VoidCallback? onCancelled;
  final VoidCallback? hapticTick;
  final VoidCallback? hapticGo;

  static Future<void> show(
    BuildContext context, {
    required String overline,
    String? caption,
    required VoidCallback onFinished,
    VoidCallback? onCancelled,
  }) {
    return Navigator.of(context).push(PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      transitionDuration: PPMotion.base,
      pageBuilder: (context, animation, secondaryAnimation) =>
          PPCountdownOverlay(
        overline: overline,
        caption: caption,
        onFinished: () {
          Navigator.of(context).pop();
          onFinished();
        },
        onCancelled: () {
          Navigator.of(context).pop();
          onCancelled?.call();
        },
      ),
    ));
  }

  @override
  State<PPCountdownOverlay> createState() => _PPCountdownOverlayState();
}

class _PPCountdownOverlayState extends State<PPCountdownOverlay>
    with SingleTickerProviderStateMixin {
  static const _numerals = ['3', '2', '1'];
  int _index = 0;
  bool _done = false;
  Timer? _beatTimer;

  // Drives only the per-numeral pop/fade visual (TweenSequence below);
  // numeral pacing is a plain Timer (see _scheduleNext), not this
  // controller's AnimationStatus. A ticker's first tick after start()
  // always reports elapsed zero (it establishes its own baseline on
  // that tick rather than back-dating to when forward() was called), so
  // gating "3"->"2"->"1" advances on AnimationStatus.completed needs two
  // 1s pumps per beat instead of one in widget tests — Timer, driven by
  // the same fake clock, doesn't have that warm-up frame and fires
  // exactly at the requested elapsed duration.
  late final AnimationController _beat =
      AnimationController(vsync: this, duration: PPMotion.countdownBeat);

  @override
  void initState() {
    super.initState();
    _tick();
    _beat.forward();
    _scheduleNext();
  }

  void _scheduleNext() {
    _beatTimer = Timer(PPMotion.countdownBeat, _advance);
  }

  void _advance() {
    if (_done) return;
    if (_index < _numerals.length - 1) {
      setState(() => _index++);
      _tick();
      _beat.forward(from: 0);
      _scheduleNext();
    } else {
      _done = true;
      (widget.hapticGo ?? HapticFeedback.heavyImpact).call();
      widget.onFinished();
    }
  }

  void _tick() => (widget.hapticTick ?? HapticFeedback.lightImpact).call();

  @override
  void dispose() {
    _beatTimer?.cancel();
    _beat.dispose();
    super.dispose();
  }

  void _cancel() {
    if (_done) return;
    _done = true;
    _beatTimer?.cancel();
    _beat.stop();
    widget.onCancelled?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reduced = ppReducedMotion(context);

    final numeral = Text(
      _numerals[_index],
      key: ValueKey(_index),
      style: PPTextStyles.countdown.copyWith(color: PPPalette.ember),
    );

    Widget animated;
    if (reduced) {
      animated = AnimatedSwitcher(duration: PPMotion.fast, child: numeral);
    } else {
      // Per-numeral pop: 1.6x -> 1.0x on entry (energetic overshoot),
      // held, then fades out to 0.7x. Scale factors + the 1s beat are
      // D1-specced geometry with no CSS custom property (Flow 2 S5 /
      // D1-E2 + human ruling 2026-08-03: spec literals with documented
      // provenance).
      final scale = TweenSequence<double>([
        TweenSequenceItem(
            tween: Tween(begin: 1.6, end: 1.0)
                .chain(CurveTween(curve: PPMotion.energetic)),
            weight: 20),
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.7), weight: 20),
      ]).animate(_beat);
      final opacity = TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
      ]).animate(_beat);
      animated = FadeTransition(
        opacity: opacity,
        child: ScaleTransition(scale: scale, child: numeral),
      );
    }

    return Material(
      color: theme.colorScheme.scrim,
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.overline.toUpperCase(),
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: PPPalette.mist)),
                  const SizedBox(height: PPSpacing.s4),
                  animated,
                  if (widget.caption != null) ...[
                    const SizedBox(height: PPSpacing.s4),
                    Text(widget.caption!,
                        style: theme.textTheme.labelMedium!
                            .copyWith(color: PPPalette.steel)),
                  ],
                ],
              ),
            ),
            // Cancel bottom offset (D1-specced, Flow 2 S5 / D1-E2 + human
            // ruling 2026-08-03).
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: _CancelButton(onPressed: _cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deliberately not PPPressable/PPButton: [AnimatedScale] (the press
/// affordance both are built on) always mounts a ScaleTransition — even
/// at rest, even under reduced motion, since it has no
/// `ppReducedMotion` awareness of its own — which the reduced-motion
/// contract above forbids. The ghost PPButton's `accentText` is also
/// ember-strong in light theme, which reads as too-dark against the
/// always-dark scrim (see class doc). A minimal stadium-hairline
/// pressable — explicit Mist label, opacity-only press feedback — is the
/// fix for both (Flow 2 S5 / D1-E2 + human ruling 2026-08-03). Border
/// approximates the design's steel-24%-alpha hairline via
/// `ppDarkColorScheme.outline`, which is that value already, in both
/// themes — matching the scrim's fixed darkness rather than the active
/// theme's outline.
class _CancelButton extends StatefulWidget {
  const _CancelButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      label: 'Cancel',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapCancel: () => _setPressed(false),
        onTapUp: (_) => _setPressed(false),
        onTap: widget.onPressed,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.6 : 1.0,
          duration: PPMotion.instant,
          curve: PPMotion.standard,
          child: Container(
            constraints: const BoxConstraints(minHeight: PPSpacing.tapMin),
            padding: const EdgeInsets.symmetric(
                horizontal: PPSpacing.s6, vertical: PPSpacing.s2),
            decoration: ShapeDecoration(
              shape: StadiumBorder(
                side: BorderSide(
                  color: ppDarkColorScheme.outline,
                  width: PPBorders.hairline,
                ),
              ),
            ),
            child: Center(
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge!
                    .copyWith(color: PPPalette.mist),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
