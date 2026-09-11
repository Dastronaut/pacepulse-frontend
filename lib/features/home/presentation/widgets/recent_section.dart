import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/activity.dart';
import '../../domain/activity_format.dart';
import '../../domain/home_copy.dart';

class RecentSection extends StatelessWidget {
  const RecentSection({
    super.key,
    required this.recent,
    required this.now,
    required this.onViewAll,
    required this.onOpen,
    required this.onStartFirst,
  });

  final List<Activity> recent;
  final DateTime now;
  final VoidCallback onViewAll;
  final ValueChanged<Activity> onOpen;
  final VoidCallback onStartFirst;

  IconData _icon(ActivityType type) => switch (type) {
        ActivityType.run => PPIcons.route,
        ActivityType.ride => PPIcons.bike,
        ActivityType.walk => PPIcons.footprints,
        ActivityType.gym => PPIcons.dumbbell,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
          child: Row(
            key: const Key('home_recent_header'),
            children: [
              Expanded(
                child: Text(HomeCopy.recent,
                    style: theme.textTheme.titleMedium),
              ),
              if (recent.isNotEmpty)
                PPPressable(
                  key: const Key('home_view_all'),
                  onPressed: onViewAll,
                  semanticLabel: HomeCopy.viewAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: PPSpacing.s3, horizontal: PPSpacing.s2),
                    child: Text(
                      HomeCopy.viewAll,
                      style: theme.textTheme.labelLarge!.copyWith(
                        color: theme.extension<PPColors>()!.accentText,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: PPSpacing.gapStack),
        if (recent.isEmpty)
          Padding(
            key: const Key('home_recent_empty'),
            padding: const EdgeInsets.symmetric(
                horizontal: PPSpacing.padScreen),
            child: PPEmptyState(
              title: HomeCopy.emptyTitle,
              body: HomeCopy.emptyBody,
              actionLabel: HomeCopy.emptyAction,
              onAction: onStartFirst,
            ),
          )
        else
          for (final activity in recent)
            Padding(
              padding: const EdgeInsets.only(
                left: PPSpacing.padScreen,
                right: PPSpacing.padScreen,
                bottom: PPSpacing.gapStack,
              ),
              child: PPWorkoutCard(
                icon: _icon(activity.type),
                title: activity.title,
                meta: ActivityFormat.meta(activity, now),
                stats: ActivityFormat.stats(activity),
                showPr: activity.isPr,
                onTap: () => onOpen(activity),
              ),
            ),
      ],
    );
  }
}
