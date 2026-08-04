import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_pressable.dart';
import '../foundations/pp_spinner.dart';

enum PPButtonVariant { primary, secondary, ghost, danger }

/// Height / horizontal padding / label size per size step (D1-A2). These
/// are design-specified geometry with no CSS custom property (human
/// ruling 2026-08-03: spec literals with documented provenance — see
/// pp_pressable.dart:6-11).
enum PPButtonSize {
  sm(36, 16, 14),
  md(44, 22, 16),
  lg(54, 30, 19);

  const PPButtonSize(this.height, this.hPad, this.fontSize);
  final double height;
  final double hPad;
  final double fontSize;
}

/// Pill action button per D1-A1/A2/A3. Custom-built (no Material
/// button): scale press + fill swap, no ripple.
///
/// The +0.01em label tracking (applied per size step below) is
/// design-specified geometry with no CSS custom property (human ruling
/// 2026-08-03: spec literals with documented provenance — see
/// pp_pressable.dart:6-11).
class PPButton extends StatefulWidget {
  const PPButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PPButtonVariant.primary,
    this.size = PPButtonSize.md,
    this.loading = false,
    this.fullWidth = false,
    this.leadingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final PPButtonVariant variant;
  final PPButtonSize size;
  final bool loading;
  final bool fullWidth;
  final IconData? leadingIcon;

  @override
  State<PPButton> createState() => _PPButtonState();
}

class _PPButtonState extends State<PPButton> {
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    Color? bg;
    Color fg;
    BoxBorder? border;
    switch (widget.variant) {
      case PPButtonVariant.primary:
        bg = !_enabled && !widget.loading
            ? scheme.primary.withValues(alpha: dark ? 0.30 : 0.45)
            : _pressed
                ? PPPalette.emberPressed
                : scheme.primary;
        fg = _enabled || widget.loading
            ? scheme.onPrimary
            : scheme.onPrimary.withValues(alpha: dark ? 0.55 : 0.45);
      case PPButtonVariant.secondary:
        bg = _pressed ? scheme.surfaceContainerHigh : null;
        fg = _enabled ? scheme.onSurface : pp.onSurfaceDisabled;
        border = Border.all(
            color: _enabled ? scheme.outline : scheme.outlineVariant,
            width: PPBorders.regular);
      case PPButtonVariant.ghost:
        bg = _pressed ? scheme.primaryContainer : null;
        fg = _enabled ? pp.accentText : pp.onSurfaceDisabled;
      case PPButtonVariant.danger:
        bg = !_enabled && !widget.loading
            ? pp.errorDisabled
            : scheme.error;
        fg = _enabled || widget.loading
            ? scheme.onError
            : scheme.onError.withValues(alpha: dark ? 0.55 : 0.45);
    }

    final label = Text(
      widget.label,
      style: theme.textTheme.labelLarge!.copyWith(
        color: fg,
        fontSize: widget.size.fontSize,
        letterSpacing: widget.size.fontSize * 0.01,
      ),
    );

    final content = widget.loading
        ? PPSpinner(color: fg)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leadingIcon != null) ...[
                PPIcon(widget.leadingIcon!,
                    size: PPIconSize.s20, color: fg),
                const SizedBox(width: PPSpacing.gapInline),
              ],
              label,
            ],
          );

    return Focus(
      onFocusChange: (f) => setState(() => _focused = f),
      child: Container(
        decoration: ShapeDecoration(
          shape: StadiumBorder(
            side: _focused
                ? BorderSide(color: pp.accentText, width: 3)
                : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: PPPressable(
          enabled: _enabled,
          onPressed: widget.onPressed,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          semanticLabel: widget.label,
          child: AnimatedContainer(
            key: const Key('pp_button_box'),
            duration: PPMotion.instant,
            curve: PPMotion.standard,
            height: widget.size.height,
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: widget.size.hPad),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(PPRadius.pill),
              border: border,
            ),
            child: Center(widthFactor: 1, child: content),
          ),
        ),
      ),
    );
  }
}
