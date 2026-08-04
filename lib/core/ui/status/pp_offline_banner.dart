import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';

/// Offline strip (D1-E4): sits under the app bar, factual tone, never
/// alarmist. Full-width, no radius. Show/hide animation belongs to the
/// consumer (e.g. AnimatedSwitcher / slide at screen level). Height
/// 44px (tapMin token) + dashed bottom hairline in light mode only (D1
/// spec literal; human ruling 2026-08-03: documented provenance).
class PPOfflineBanner extends StatelessWidget {
  const PPOfflineBanner(
      {super.key, this.message = "You're offline — showing saved data"});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      height: PPSpacing.tapMin,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
      decoration: BoxDecoration(
        color: dark ? scheme.surfaceContainerHighest : scheme.surface,
        border: dark
            ? null
            : Border(
                bottom: BorderSide(
                    color: scheme.outlineVariant,
                    width: PPBorders.hairline)),
      ),
      child: Row(
        children: [
          PPIcon(PPIcons.wifiOff, size: PPIconSize.s20, color: pp.warning),
          const SizedBox(width: PPSpacing.s3),
          Expanded(
            child: Text(message,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
