import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_pressable.dart';

enum PPIconButtonStyle { quiet, tonal, filled }

/// 44x44 round icon button (D1-A4). quiet = transparent/accent icon;
/// tonal = surface step fill; filled = Ember/onPrimary. Quiet gains the
/// tonal fill while pressed.
///
/// Geometry: 44×44 circle (44px = PPSpacing.tapMin per D1-A4, human 2026-08-03).
class PPIconButton extends StatefulWidget {
  const PPIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.style = PPIconButtonStyle.quiet,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final PPIconButtonStyle style;
  final String? semanticLabel;

  @override
  State<PPIconButton> createState() => _PPIconButtonState();
}

class _PPIconButtonState extends State<PPIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final enabled = widget.onPressed != null;
    final dark = theme.brightness == Brightness.dark;

    Color? bg;
    Color fg;
    List<BoxShadow>? shadow;
    switch (widget.style) {
      case PPIconButtonStyle.quiet:
        bg = _pressed ? scheme.surfaceContainerHigh : null;
        fg = enabled ? pp.accentText : pp.onSurfaceDisabled;
      case PPIconButtonStyle.tonal:
        bg = scheme.surfaceContainerHigh;
        fg = enabled ? scheme.onSurface : pp.onSurfaceDisabled;
        if (!dark) shadow = pp.shadow1;
      case PPIconButtonStyle.filled:
        bg = scheme.primary;
        fg = scheme.onPrimary;
    }

    return PPPressable(
      enabled: enabled,
      onPressed: widget.onPressed,
      onHighlightChanged: (v) => setState(() => _pressed = v),
      semanticLabel: widget.semanticLabel,
      child: AnimatedContainer(
        key: const Key('pp_icon_button_box'),
        duration: PPMotion.instant,
        width: PPSpacing.tapMin,
        height: PPSpacing.tapMin,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: shadow,
        ),
        child: Center(child: PPIcon(widget.icon, color: fg)),
      ),
    );
  }
}
