import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_icon.dart';
import '../foundations/pp_pressable.dart';

const double _unitFontSize = 22;
const double _captionGap = 14;

class PPStepper extends StatelessWidget {
  const PPStepper({
    super.key,
    required this.valueLabel,
    required this.unit,
    this.onDecrement,
    this.onIncrement,
    this.caption,
    this.decrementSemanticLabel = 'Decrease',
    this.incrementSemanticLabel = 'Increase',
  });

  final String valueLabel;
  final String unit;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final String? caption;
  final String decrementSemanticLabel;
  final String incrementSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Circle(
              key: const Key('pp_stepper_minus'),
              icon: PPIcons.minus,
              onPressed: onDecrement,
              semanticLabel: decrementSemanticLabel,
            ),
            const SizedBox(width: PPSpacing.s5),
            Text.rich(
              key: const Key('pp_stepper_value'),
              TextSpan(
                text: valueLabel,
                children: [
                  TextSpan(
                    text: unit,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontSize: _unitFontSize,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              style: theme.textTheme.displayMedium!.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(width: PPSpacing.s5),
            _Circle(
              key: const Key('pp_stepper_plus'),
              icon: PPIcons.plus,
              onPressed: onIncrement,
              semanticLabel: incrementSemanticLabel,
            ),
          ],
        ),
        if (caption != null) ...[
          const SizedBox(height: _captionGap),
          Text(
            caption!,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium!.copyWith(
              color: pp.onSurfaceFaint,
            ),
          ),
        ],
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final enabled = onPressed != null;

    return PPPressable(
      enabled: enabled,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      child: Container(
        width: PPSpacing.tapMin,
        height: PPSpacing.tapMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
          border: dark
              ? null
              : Border.all(
                  color: scheme.outlineVariant,
                  width: PPBorders.hairline,
                ),
        ),
        child: PPIcon(
          icon,
          size: PPIconSize.s20,
          color: enabled
              ? scheme.onSurface
              : theme.extension<PPColors>()!.onSurfaceDisabled,
        ),
      ),
    );
  }
}
