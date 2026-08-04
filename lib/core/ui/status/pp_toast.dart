import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';

enum PPToastKind { success, error }

/// Floating toast (D1-E3): bottom offset 84 (64px nav bar + 20px gap),
/// PPRadius.md, shadow2, auto-dismiss 4s, swipe to dismiss — design
/// geometry with no CSS custom property (human ruling 2026-08-03: spec
/// literals with documented provenance).
///
/// Dark uses the elevated surface (surfaceContainerHighest bg / onSurface
/// text / accentText action). Light theme deliberately INVERTS: raw
/// PPPalette.slate bg / PPPalette.mist text / raw PPPalette.ember action,
/// with success/error icon colors pulled from the dark palette
/// (PPColors.dark.success / ppDarkColorScheme.error) — those semantics
/// read correctly on a slate surface. This is a documented design
/// exception, not an accident — it keeps the toast legible when it
/// floats over a white card stack.
void showPPToast(
  BuildContext context, {
  required String message,
  PPToastKind kind = PPToastKind.success,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  Timer? timer;

  void close() {
    timer?.cancel();
    if (entry.mounted) entry.remove();
  }

  entry = OverlayEntry(
    builder: (context) => _PPToast(
      message: message,
      kind: kind,
      actionLabel: actionLabel,
      onAction: onAction == null
          ? null
          : () {
              onAction();
              close();
            },
      onDismissed: close,
    ),
  );
  overlay.insert(entry);
  timer = Timer(duration, close);
}

class _PPToast extends StatelessWidget {
  const _PPToast({
    required this.message,
    required this.kind,
    required this.actionLabel,
    required this.onAction,
    required this.onDismissed,
  });

  final String message;
  final PPToastKind kind;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    final bg = dark ? scheme.surfaceContainerHighest : PPPalette.slate;
    final fg = dark ? scheme.onSurface : PPPalette.mist;
    final action = dark ? pp.accentText : PPPalette.ember;
    // Semantic icons: on the dark/inverse surface the dark palette reads.
    // Success comes from PPColors.dark (no ColorScheme counterpart); error
    // comes from ppDarkColorScheme.error — PPColors has no `error` field.
    final iconColor = kind == PPToastKind.success
        ? PPColors.dark.success
        : ppDarkColorScheme.error;
    final icon =
        kind == PPToastKind.success ? PPIcons.check : PPIcons.triangleAlert;

    return Positioned(
      left: PPSpacing.padScreen,
      right: PPSpacing.padScreen,
      bottom: 84 + MediaQuery.viewPaddingOf(context).bottom,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: PPMotion.base,
        curve: PPMotion.decelerate,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(
              offset: Offset(0, (1 - t) * 12), child: child),
        ),
        child: Dismissible(
          key: const Key('pp_toast_dismissible'),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => onDismissed(),
          child: Material(
            color: Colors.transparent,
            child: Container(
              key: const Key('pp_toast_box'),
              padding: const EdgeInsets.symmetric(
                  vertical: PPSpacing.s3, horizontal: PPSpacing.s4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(PPRadius.md),
                boxShadow: pp.shadow2,
              ),
              child: Row(
                children: [
                  PPIcon(icon, size: PPIconSize.s20, color: iconColor),
                  const SizedBox(width: PPSpacing.s3),
                  Expanded(
                    child: Text(message,
                        style: theme.textTheme.bodySmall!
                            .copyWith(color: fg)),
                  ),
                  if (actionLabel != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onAction,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: PPSpacing.s2),
                        child: Text(
                          actionLabel!,
                          style: theme.textTheme.labelLarge!
                              .copyWith(color: action),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
