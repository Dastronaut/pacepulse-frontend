import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_pressable.dart';

enum _RowKind { toggle, value, plain }

/// Settings list card (D1-C2): clipped lg card with inset hairlines.
/// D1-C2: divider inset 54 = icon 24 + gap 14 + pad 16 (human ruling 2026-08-03: spec literals with documented provenance).
class PPSettingsGroup extends StatelessWidget {
  const PPSettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PPRadius.lg),
        boxShadow: dark ? null : pp.shadow1,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PPRadius.lg),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Padding(
                    key: const Key('pp_settings_divider'),
                    padding: const EdgeInsets.only(left: 54),
                    child: Divider(
                        height: PPBorders.hairline,
                        thickness: PPBorders.hairline,
                        color: theme.colorScheme.outlineVariant),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// One settings row: toggle / value+chevron / plain. Height 56.
/// D1-C2: row 56, toggle 52×32 knob 24 inset 4 (human ruling 2026-08-03: spec literals with documented provenance).
class PPSettingsRow extends StatelessWidget {
  const PPSettingsRow.toggle({
    super.key,
    required this.icon,
    required this.title,
    required bool value,
    required ValueChanged<bool> onChanged,
  })  : _kind = _RowKind.toggle,
        // ignore: prefer_initializing_formals
        _value = value,
        // ignore: prefer_initializing_formals
        _onChanged = onChanged,
        valueLabel = null,
        onTap = null;

  const PPSettingsRow.value({
    super.key,
    required this.icon,
    required this.title,
    String? value,
    this.onTap,
  })  : _kind = _RowKind.value,
        _value = false,
        _onChanged = null,
        valueLabel = value;

  const PPSettingsRow.plain({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  })  : _kind = _RowKind.plain,
        _value = false,
        _onChanged = null,
        valueLabel = null;

  final IconData icon;
  final String title;
  final String? valueLabel;
  final VoidCallback? onTap;
  final _RowKind _kind;
  final bool _value;
  final ValueChanged<bool>? _onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;

    final row = SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: PPSpacing.s4),
        child: Row(
          children: [
            PPIcon(icon, color: scheme.onSurfaceVariant),
            const SizedBox(width: 14),
            Expanded(
                child: Text(title, style: theme.textTheme.bodyMedium)),
            switch (_kind) {
              _RowKind.toggle => _PPToggle(value: _value),
              _RowKind.value => Row(mainAxisSize: MainAxisSize.min, children: [
                  if (valueLabel != null)
                    Text(valueLabel!,
                        style: theme.textTheme.bodySmall!
                            .copyWith(color: pp.onSurfaceFaint)),
                  const SizedBox(width: PPSpacing.s2),
                  PPIcon(PPIcons.chevronRight,
                      size: PPIconSize.s20, color: pp.onSurfaceFaint),
                ]),
              _RowKind.plain => PPIcon(PPIcons.chevronRight,
                  size: PPIconSize.s20, color: pp.onSurfaceFaint),
            },
          ],
        ),
      ),
    );

    final action = _kind == _RowKind.toggle
        ? () => _onChanged!(!_value)
        : onTap;
    if (action == null) return row;

    final pressable = PPPressable(
        onPressed: action, semanticLabel: title, child: row);

    // Wrap toggle with Semantics to announce switch state to screen readers
    if (_kind == _RowKind.toggle) {
      return Semantics(
        toggled: _value,
        child: pressable,
      );
    }
    return pressable;
  }
}

/// D1-C2: 52×32 pill, 24px knob inset 4 (human ruling 2026-08-03: spec literals with documented provenance).
class _PPToggle extends StatelessWidget {
  const _PPToggle({required this.value});

  final bool value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      key: const Key('pp_toggle_track'),
      duration: PPMotion.fast,
      curve: PPMotion.standard,
      width: 52,
      height: 32,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: value ? scheme.primary : scheme.outline,
        borderRadius: BorderRadius.circular(PPRadius.pill),
      ),
      child: AnimatedAlign(
        duration: PPMotion.fast,
        curve: PPMotion.standard,
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: value ? scheme.onPrimary : scheme.onSurfaceVariant,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
