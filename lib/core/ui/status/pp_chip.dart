import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_live_dot.dart';
import '../foundations/pp_pressable.dart';

enum PPChipVariant { live, pr, streak, premium, success, error }

enum PPChipShape { pill, tag }

/// Status pill (D1-E1): overline type tracked +0.14em, pad 5/12, 14px
/// leading icon slot, streak label mono 12 w700 — all design-specified
/// geometry from the D1 sheet with no CSS custom property (human ruling
/// 2026-08-03: spec literals with documented provenance).
class PPChip extends StatelessWidget {
  const PPChip({
    super.key,
    required this.label,
    this.variant = PPChipVariant.pr,
    this.shape = PPChipShape.pill,
    this.onTap,
  });

  final String label;
  final PPChipVariant variant;
  final PPChipShape shape;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    Color? bg;
    Color fg;
    BoxBorder? border;
    Widget? leading;
    TextStyle style = theme.textTheme.labelSmall!;
    switch (variant) {
      case PPChipVariant.live:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
        leading = const PPLiveDot();
      case PPChipVariant.pr:
        bg = scheme.primaryContainer;
        fg = scheme.onPrimaryContainer;
      case PPChipVariant.streak:
        bg = dark ? scheme.surfaceContainerHigh : scheme.surface;
        fg = scheme.onSurface;
        if (!dark) {
          border = Border.all(
              color: scheme.outlineVariant, width: PPBorders.hairline);
        }
        leading = PPIcon(PPIcons.flame,
            size: PPIconSize.s20, color: pp.accentText);
        style = PPTextStyles.monoS.copyWith(fontSize: 12,
            fontWeight: FontWeight.w700);
      case PPChipVariant.premium:
        fg = scheme.onSurface;
        border =
            Border.all(color: scheme.outline, width: PPBorders.hairline);
        leading = PPIcon(PPIcons.crown,
            size: PPIconSize.s20, color: pp.accentText);
      case PPChipVariant.success:
        bg = pp.successContainer;
        fg = pp.onSuccessContainer;
      case PPChipVariant.error:
        bg = scheme.errorContainer;
        fg = scheme.onErrorContainer;
    }

    final chip = Container(
      key: const Key('pp_chip_box'),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        border: border,
        borderRadius: BorderRadius.circular(
            shape == PPChipShape.pill ? PPRadius.pill : PPRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            SizedBox(height: 14, width: 14, child: FittedBox(child: leading)),
            const SizedBox(width: 6),
          ],
          Text(label.toUpperCase(), style: style.copyWith(color: fg)),
        ],
      ),
    );

    if (onTap == null) return chip;
    return PPPressable(onPressed: onTap, semanticLabel: label, child: chip);
  }
}
