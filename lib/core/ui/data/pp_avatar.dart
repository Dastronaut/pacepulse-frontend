import 'package:flutter/material.dart';

import '../../theme/theme.dart';

enum PPAvatarSize {
  s48(48),
  s40(40),
  s32(32),
  s24(24);

  const PPAvatarSize(this.dp);
  final double dp;
}

/// Round avatar (D1-B11): initials or photo; premium = 2px Ember ring.
/// Geometry: 48/40/32/24 dp; dark: surfaceContainerHighest bg, light: surfaceContainer + hairline.
/// Provenance: D1-B11 + human ruling 2026-08-03.
class PPAvatar extends StatelessWidget {
  const PPAvatar({
    super.key,
    this.initials,
    this.image,
    this.size = PPAvatarSize.s40,
    this.premium = false,
  });

  final String? initials;
  final ImageProvider? image;
  final PPAvatarSize size;
  final bool premium;

  TextStyle _initialsStyle(ThemeData theme) {
    final base = switch (size) {
      PPAvatarSize.s48 => theme.textTheme.bodyMedium!,
      PPAvatarSize.s40 => theme.textTheme.bodySmall!,
      _ => theme.textTheme.labelMedium!,
    };
    return base.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.onSurfaceVariant);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      key: initials != null ? Key('pp_avatar_$initials') : null,
      width: size.dp,
      height: size.dp,
      decoration: BoxDecoration(
        color:
            dark ? scheme.surfaceContainerHighest : scheme.surfaceContainer,
        shape: BoxShape.circle,
        image: image != null
            ? DecorationImage(image: image!, fit: BoxFit.cover)
            : null,
        border: premium
            ? Border.all(color: scheme.primary, width: PPBorders.strong)
            : dark
                ? null
                : Border.all(
                    color: scheme.outlineVariant,
                    width: PPBorders.hairline),
      ),
      child: image == null && initials != null
          ? Center(child: Text(initials!, style: _initialsStyle(theme)))
          : null,
    );
  }
}

/// Overlapping avatar row with "+N" overflow (D1-B11).
/// Geometry: −8 px overlap, 2px surface ring; sizes 48/40/32/24 dp.
/// Provenance: D1-B11 + human ruling 2026-08-03.
class PPAvatarStack extends StatelessWidget {
  const PPAvatarStack({
    super.key,
    required this.initials,
    this.overflow = 0,
    this.size = PPAvatarSize.s32,
    this.ringColor,
  });

  final List<String> initials;
  final int overflow;
  final PPAvatarSize size;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ring = ringColor ?? scheme.surfaceContainerLow;
    final items = <Widget>[
      for (final i in initials) PPAvatar(initials: i, size: size),
      if (overflow > 0)
        Container(
          width: size.dp,
          height: size.dp,
          decoration: BoxDecoration(
              color: scheme.primaryContainer, shape: BoxShape.circle),
          child: Center(
            child: Text('+$overflow',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimaryContainer)),
          ),
        ),
    ];

    return SizedBox(
      height: size.dp + 4,
      width:
          (size.dp + 4) + (items.length - 1) * (size.dp - 8),
      child: Stack(
        children: [
          for (var i = 0; i < items.length; i++)
            Positioned(
              left: i * (size.dp - 8),
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration:
                    BoxDecoration(color: ring, shape: BoxShape.circle),
                child: items[i],
              ),
            ),
        ],
      ),
    );
  }
}
