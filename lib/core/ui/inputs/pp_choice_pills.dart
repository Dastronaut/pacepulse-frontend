import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_pressable.dart';

const double _pillHeight = 36;
const double _pillHPad = 16;

class PPChoicePills extends StatelessWidget {
  const PPChoicePills({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> options;

  final int? selectedIndex;

  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: PPSpacing.s2,
      runSpacing: PPSpacing.s2,
      children: [
        for (var i = 0; i < options.length; i++)
          _Pill(
            key: Key('pp_choice_pill_$i'),
            label: options[i],
            selected: i == selectedIndex,
            onPressed: () => onChanged(i),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final borderWidth = selected ? 0.0 : PPBorders.regular;

    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      child: PPPressable(
        onPressed: onPressed,
        semanticLabel: label,
        child: SizedBox(
          height: PPSpacing.tapMin,
          child: Center(
            child: Container(
              height: _pillHeight,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: _pillHPad - borderWidth,
              ),
              decoration: BoxDecoration(
                color: selected ? scheme.primary : null,
                borderRadius: BorderRadius.circular(PPRadius.pill),
                border: selected
                    ? null
                    : Border.all(
                        color: scheme.outline,
                        width: PPBorders.regular,
                      ),
              ),
              child: Text(
                label,
                style: theme.textTheme.bodySmall!.copyWith(
                  color: selected ? scheme.onPrimary : scheme.onSurface,
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
