import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';

/// Offline strip (D1-E4): full-width 44px (PPSpacing.tapMin), no radius,
/// factual tone. Light theme adds a SOLID bottom hairline
/// (outlineVariant); dark uses the elevated surface step. Sizing and
/// colors come entirely from existing tokens — no new spec literals in
/// this widget.
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
