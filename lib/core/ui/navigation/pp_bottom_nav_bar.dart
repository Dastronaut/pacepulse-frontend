import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_live_dot.dart';

/// The app's four fixed destinations (D1-D1): Home / History / Challenges
/// / Profile — order and icon set are fixed, no per-user reordering.
///
/// Geometry is design-specified with no CSS custom property (human ruling
/// 2026-08-03: spec literals with documented provenance), all from D1-D1:
///   • Bar height 64 + bottom safe area.
///   • Live badge over the zap icon: offset top -2, right -4.
///   • Item label: 11px (labelSmall's size, restated explicitly here).
/// Active item uses [PPColors.accentText]; idle uses
/// [PPColors.onSurfaceFaint]. Each destination's tap area spans the full
/// bar height via `Expanded` + an opaque [GestureDetector] (no min-size
/// affordance needed — items are already far larger than the 44px rule).
class PPBottomNavBar extends StatelessWidget {
  const PPBottomNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    this.challengesLive = false,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final bool challengesLive;

  static const _items = [
    (PPIcons.house, 'Home'),
    (PPIcons.clock, 'History'),
    (PPIcons.zap, 'Challenges'),
    (PPIcons.user, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: dark
            ? Border(
                top: BorderSide(
                    color: scheme.outlineVariant,
                    width: PPBorders.hairline))
            : null,
        boxShadow: dark ? null : pp.shadow2,
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: _NavItem(
                      icon: _items[i].$1,
                      label: _items[i].$2,
                      active: i == index,
                      liveBadge: challengesLive && i == 2,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.liveBadge,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool liveBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final color = active ? pp.accentText : pp.onSurfaceFaint;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            PPIcon(icon, color: color),
            if (liveBadge)
              const Positioned(top: -2, right: -4, child: PPLiveDot()),
          ],
        ),
        const SizedBox(height: 4),
        Text(label,
            style: theme.textTheme.labelSmall!.copyWith(
                fontSize: 11,
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                color: color)),
      ],
    );
  }
}
