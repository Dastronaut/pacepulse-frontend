import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_live_dot.dart';
import '../foundations/pp_live_pulse.dart';
import 'pp_avatar.dart';

/// Live race leaderboard row. Provenance: D1-B9 (row 64, rank col 22, 4px progress bar) + human ruling 2026-08-03: spec literals with documented provenance.
/// The row is DUMB: reorder animation, delta visibility timing (4s) and overtake pulse triggers
/// are the consumer's responsibility.
class PPLeaderboardRow extends StatelessWidget {
  const PPLeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.pace,
    required this.progress,
    this.avatarInitials,
    this.isSelf = false,
    this.rankDelta = 0,
    this.isDropped = false,
    this.selfPulseToken,
    this.selfDeltaLabel,
  });

  final int rank;
  final String name;
  final String pace;
  final double progress;
  final String? avatarInitials;
  final bool isSelf;
  final int rankDelta;
  final bool isDropped;
  final Object? selfPulseToken;
  final String? selfDeltaLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;

    Widget row = Container(
      key: const Key('pp_leader_row_box'),
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(
          horizontal: PPSpacing.s3, vertical: PPSpacing.s2),
      decoration: BoxDecoration(
        color: isSelf ? scheme.primaryContainer : null,
        borderRadius:
            isSelf ? BorderRadius.circular(PPRadius.md) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('$rank',
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                )),
          ),
          if (rankDelta != 0) ...[
            const SizedBox(width: PPSpacing.s1),
            Text(
              rankDelta > 0 ? '▲$rankDelta' : '▼${rankDelta.abs()}',
              style: theme.textTheme.labelMedium!.copyWith(
                  color: rankDelta > 0 ? pp.success : scheme.error),
            ),
          ],
          const SizedBox(width: PPSpacing.s3),
          PPAvatar(initials: avatarInitials ?? (name.isEmpty ? '?' : name.substring(0, 1))),
          const SizedBox(width: PPSpacing.s3),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Flexible(
                    child: Text(name,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (isSelf && selfDeltaLabel != null) ...[
                    const SizedBox(width: PPSpacing.s2),
                    Text(selfDeltaLabel!,
                        style: PPTextStyles.monoS.copyWith(
                            fontSize: 11,
                            color: scheme.onPrimaryContainer)),
                  ],
                ]),
                if (isDropped)
                  Text('reconnecting…',
                      style: theme.textTheme.labelMedium!
                          .copyWith(color: pp.onSurfaceFaint))
                else ...[
                  const SizedBox(height: PPSpacing.s1),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(PPRadius.pill),
                    child: SizedBox(
                      height: 4,
                      child: ColoredBox(
                        color: pp.ringTrack,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: progress.clamp(0.0, 1.0),
                            heightFactor: 1,
                            child: ColoredBox(color: scheme.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: PPSpacing.s3),
          Text(isDropped ? '—' : pace, style: PPTextStyles.monoM),
          const SizedBox(width: PPSpacing.s2),
          if (isDropped)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: pp.onSurfaceFaint, shape: BoxShape.circle),
            )
          else
            const PPLiveDot(),
        ],
      ),
    );

    if (isDropped) {
      row = Opacity(
          key: const Key('pp_leader_row_opacity'), opacity: 0.55, child: row);
    }
    if (isSelf) {
      row = PPLivePulse(pulseToken: selfPulseToken, child: row);
    }
    return row;
  }
}
