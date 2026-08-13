import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_pressable.dart';

/// Start-workout FAB (D1-A5): 64px circle (or extended pill, h 54).
/// shadow2 in BOTH themes — the sanctioned dark-mode shadow exception
/// for floating UI. Place 20px above the bottom nav.
///
/// Geometry: 64×64 circle (PPSpacing.s10=64px per D1-A5, human 2026-08-03);
/// extended: h 54, icon 24, label 19px, h-pad 26px.
class PPStartFab extends StatelessWidget {
  const PPStartFab({
    super.key,
    required this.onPressed,
    this.icon = PPIcons.play,
    this.extendedLabel,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String? extendedLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final extended = extendedLabel != null;

    return PPPressable(
      onPressed: onPressed,
      semanticLabel: extendedLabel ?? 'Start workout',
      child: Container(
        key: const Key('pp_fab_box'),
        width: extended ? null : PPSpacing.s10,
        height: extended ? 54 : PPSpacing.s10,
        padding:
            extended ? const EdgeInsets.symmetric(horizontal: 26) : null,
        decoration: BoxDecoration(
          color: scheme.primary,
          shape: extended ? BoxShape.rectangle : BoxShape.circle,
          borderRadius:
              extended ? BorderRadius.circular(PPRadius.pill) : null,
          boxShadow: pp.shadow2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PPIcon(icon,
                size: extended ? PPIconSize.s24 : PPIconSize.s28,
                color: scheme.onPrimary),
            if (extended) ...[
              const SizedBox(width: PPSpacing.gapInline),
              Text(
                extendedLabel!,
                style: theme.textTheme.labelLarge!
                    .copyWith(color: scheme.onPrimary, fontSize: 19),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
