import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../actions/pp_icon_button.dart';
import '../foundations/pp_icon.dart';
import '../status/pp_chip.dart';

enum _AppBarVariant { standard, large, live }

/// App bar variants (D1-D2): `.standard` (centred h3 title, 44px back),
/// `.large` (bottom-left h1 title), `.live` (LIVE chip + left title +
/// trailing X).
///
/// Heights are design-specified with no CSS custom property (human ruling
/// 2026-08-03: spec literals with documented provenance), both from D1-D2:
///   • standard / live: 56.
///   • large: 96.
/// Transparent over the canvas until [scrolledUnder], then `surface` bg +
/// hairline border (dark) / [PPColors.shadow1] (light).
class PPAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PPAppBar.standard({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.scrolledUnder = false,
  }) : _variant = _AppBarVariant.standard,
       onClose = null;

  const PPAppBar.large({
    super.key,
    required this.title,
    this.trailing,
    this.scrolledUnder = false,
  }) : _variant = _AppBarVariant.large,
       onBack = null,
       onClose = null;

  const PPAppBar.live({
    super.key,
    required this.title,
    this.onClose,
    this.scrolledUnder = false,
  }) : _variant = _AppBarVariant.live,
       onBack = null,
       trailing = null;

  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onClose;
  final Widget? trailing;
  final bool scrolledUnder;
  final _AppBarVariant _variant;

  @override
  Size get preferredSize =>
      Size.fromHeight(_variant == _AppBarVariant.large ? 96 : 56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    return AnimatedContainer(
      key: const Key('pp_app_bar_box'),
      duration: PPMotion.fast,
      height: preferredSize.height + topInset,
      padding: EdgeInsets.only(
        top: topInset,
        left: PPSpacing.s2,
        right: PPSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: scrolledUnder ? scheme.surface : null,
        border: scrolledUnder && dark
            ? Border(
                bottom: BorderSide(
                  color: scheme.outlineVariant,
                  width: PPBorders.hairline,
                ),
              )
            : null,
        boxShadow: scrolledUnder && !dark ? pp.shadow1 : null,
      ),
      child: switch (_variant) {
        _AppBarVariant.standard => Row(
          children: [
            if (onBack != null)
              PPIconButton(
                icon: PPIcons.chevronLeft,
                onPressed: onBack,
                semanticLabel: 'Back',
              )
            else
              const SizedBox(width: PPSpacing.tapMin),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            trailing ?? const SizedBox(width: PPSpacing.tapMin),
          ],
        ),
        _AppBarVariant.large => Padding(
          padding: const EdgeInsets.symmetric(horizontal: PPSpacing.s3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: PPSpacing.s3),
                  child: Text(title, style: theme.textTheme.headlineLarge),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: PPSpacing.s3),
                  child: trailing!,
                ),
            ],
          ),
        ),
        _AppBarVariant.live => Row(
          children: [
            const SizedBox(width: PPSpacing.s2),
            const PPChip(label: 'Live', variant: PPChipVariant.live),
            const SizedBox(width: PPSpacing.s3),
            Expanded(child: Text(title, style: theme.textTheme.headlineSmall)),
            PPIconButton(
              icon: PPIcons.x,
              onPressed: onClose,
              semanticLabel: 'Close',
            ),
          ],
        ),
      },
    );
  }
}
