import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/activity.dart';
import '../../domain/home_copy.dart';

const double _tileHeight = 72;

class QuickStart extends StatelessWidget {
  const QuickStart({super.key, required this.onStart});

  final ValueChanged<ActivityType> onStart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
          child: Text(HomeCopy.quickStart, style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: PPSpacing.gapStack),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
          child: Row(
            children: [
              Expanded(
                child: _Tile(
                  tileKey: const Key('home_quick_start_run'),
                  icon: PPIcons.route,
                  label: HomeCopy.run,
                  onTap: () => onStart(ActivityType.run),
                ),
              ),
              const SizedBox(width: PPSpacing.s3),
              Expanded(
                child: _Tile(
                  tileKey: const Key('home_quick_start_ride'),
                  icon: PPIcons.bike,
                  label: HomeCopy.ride,
                  onTap: () => onStart(ActivityType.ride),
                ),
              ),
              const SizedBox(width: PPSpacing.s3),
              Expanded(
                child: _Tile(
                  tileKey: const Key('home_quick_start_gym'),
                  icon: PPIcons.dumbbell,
                  label: HomeCopy.gym,
                  onTap: () => onStart(ActivityType.gym),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.tileKey,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Key tileKey;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return PPPressable(
      key: tileKey,
      onPressed: onTap,
      semanticLabel: label,
      child: Container(
        height: _tileHeight,
        decoration: BoxDecoration(
          color: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(PPRadius.md),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PPIcon(icon, size: PPIconSize.s24, color: pp.accentText),
            const SizedBox(height: PPSpacing.s1),
            Text(label, style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
