import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../foundations/pp_pressable.dart';

/// Paywall plan selector (D1-F3). Selection grows the border 1 -> 2px;
/// the padding shrinks 16 -> 15 so content never jumps.
class PPPaywallPlanCard extends StatelessWidget {
  const PPPaywallPlanCard({
    super.key,
    required this.plan,
    required this.price,
    required this.billedNote,
    this.bestValue = false,
    required this.selected,
    required this.onSelected,
  });

  final String plan;
  final String price;
  final String billedNote;
  final bool bestValue;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;

    return PPPressable(
      onPressed: onSelected,
      semanticLabel: '$plan plan',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            key: const Key('pp_plan_box'),
            width: double.infinity,
            padding: EdgeInsets.all(selected ? 15 : 16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(PPRadius.lg),
              border: Border.all(
                color: selected ? scheme.primary : scheme.outline,
                width:
                    selected ? PPBorders.strong : PPBorders.hairline,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan, style: theme.textTheme.titleMedium),
                      const SizedBox(height: PPSpacing.s1),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(price,
                              style: theme.textTheme.headlineMedium!
                                  .copyWith(fontFeatures: const [
                                FontFeature.tabularFigures()
                              ])),
                          Text('/mo',
                              style: theme.textTheme.labelMedium!
                                  .copyWith(color: pp.onSurfaceFaint)),
                        ],
                      ),
                      Text(billedNote,
                          style: theme.textTheme.labelMedium!
                              .copyWith(color: pp.onSurfaceFaint)),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? scheme.primary : null,
                    border: selected
                        ? null
                        : Border.all(
                            color: scheme.outline,
                            width: PPBorders.strong),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: scheme.onPrimary,
                                shape: BoxShape.circle),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
          if (bestValue)
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 2, horizontal: 8),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(PPRadius.pill),
                ),
                child: Text(
                  'BEST VALUE',
                  style: theme.textTheme.labelSmall!.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: scheme.onPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
