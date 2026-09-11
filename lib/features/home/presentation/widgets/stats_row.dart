import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/home_copy.dart';
import '../../domain/home_summary.dart';

class StatsRow extends StatelessWidget {
  const StatsRow({super.key, required this.summary, this.onConnectHealth});

  final HomeSummary summary;
  final VoidCallback? onConnectHealth;

  @override
  Widget build(BuildContext context) {
    if (!summary.hasStats) return const SizedBox.shrink();

    final week = summary.week;
    final hr = summary.restingHr;

    return Padding(
      key: const Key('home_stats_row'),
      padding: const EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (week != null)
              Expanded(
                child: PPStatTile(
                  key: const Key('home_week_tile'),
                  icon: PPIcons.route,
                  label: HomeCopy.thisWeek,
                  value: week.distanceKm.toStringAsFixed(1),
                  unit: HomeCopy.km,
                  sub: week.label,
                  subTone: switch (week.direction) {
                    TrendDirection.up => PPStatTone.positive,
                    TrendDirection.down => PPStatTone.negative,
                    TrendDirection.steady => PPStatTone.neutral,
                  },
                ),
              ),
            if (week != null) const SizedBox(width: PPSpacing.s3),
            Expanded(
              child: hr == null
                  ? _ConnectHealthTile(onTap: onConnectHealth)
                  : PPStatTile(
                      key: const Key('home_hr_tile'),
                      icon: PPIcons.heartPulse,
                      label: HomeCopy.restingHr,
                      value: '${hr.bpm}',
                      unit: HomeCopy.bpm,
                      sub: hr.label,
                      subTone: switch (hr.direction) {
                        TrendDirection.up => PPStatTone.negative,
                        TrendDirection.down => PPStatTone.positive,
                        TrendDirection.steady => PPStatTone.neutral,
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectHealthTile extends StatelessWidget {
  const _ConnectHealthTile({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return PPPressable(
      key: const Key('home_connect_health'),
      onPressed: onTap,
      semanticLabel: HomeCopy.connectHealth,
      child: Container(
        padding: const EdgeInsets.all(PPSpacing.s4),
        decoration: BoxDecoration(
          color: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(PPRadius.md),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PPIcon(
              PPIcons.heartPulse,
              size: PPIconSize.s20,
              color: pp.accentText,
            ),
            const SizedBox(height: PPSpacing.s2),
            Text(
              HomeCopy.restingHr,
              style: theme.textTheme.labelMedium!.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: PPSpacing.s1),
            Text(
              HomeCopy.connectHealth,
              style: theme.textTheme.bodySmall!.copyWith(color: pp.accentText),
            ),
          ],
        ),
      ),
    );
  }
}
