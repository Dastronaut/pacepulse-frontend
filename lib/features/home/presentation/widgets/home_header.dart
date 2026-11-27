import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/home_copy.dart';
import '../../domain/home_summary.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.summary,
    required this.offline,
    this.now,
    this.showWelcome,
    this.showAvatar = true,
    this.onStreakTap,
    this.onAvatarTap,
  });

  final HomeSummary summary;
  final bool offline;
  final DateTime? now;

  final bool? showWelcome;
  final bool showAvatar;
  final VoidCallback? onStreakTap;
  final VoidCallback? onAvatarTap;

  String _caption() {
    if (showWelcome ?? summary.isFirstLaunch) {
      return '${HomeCopy.welcome}, ${summary.displayName}';
    }
    final line = HomeDateFormat.dayLine(summary.date);
    final syncedAt = summary.lastSyncedAt;
    if (!offline || syncedAt == null) return line;
    final age = (now ?? DateTime.now()).difference(syncedAt);
    return '$line · ${HomeDateFormat.syncedAgo(age)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final streak = summary.streak;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _caption(),
                  key: const Key('home_caption'),
                  style: theme.textTheme.labelMedium!
                      .copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: PPSpacing.s1),
                Text(HomeCopy.title, style: theme.textTheme.headlineLarge),
              ],
            ),
          ),
          if (streak != null) ...[
            PPChip(
              key: const Key('home_streak_chip'),
              label: '${streak.days}',
              variant: PPChipVariant.streak,
              onTap: onStreakTap,
            ),
            const SizedBox(width: PPSpacing.s3),
          ],
          if (showAvatar)
            PPPressable(
              key: const Key('home_avatar'),
              onPressed: onAvatarTap,
              semanticLabel: summary.displayName,
              child:
                  PPAvatar(initials: summary.initials, size: PPAvatarSize.s40),
            ),
        ],
      ),
    );
  }
}
