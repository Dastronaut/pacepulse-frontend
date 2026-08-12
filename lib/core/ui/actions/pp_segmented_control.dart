import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Pill segmented control (D1-A6). Max 4 equal-width segments; the
/// selected thumb slides at [PPMotion.base]/[PPMotion.standard]. Dark
/// thumb = surfaceContainerHighest; light thumb = surface + shadow1 and
/// the container gains a hairline.
///
/// Geometry literals per D1 (2026-08-03): container pad 4 (normal) / 3 (small),
/// small item pad 3 vert / 10 horiz; normal control h 44, small control h 44 (tap
/// rule) with visual pill 28 (caption + pads, per ChartCard) centered inside —
/// D1 sheet + human ruling. All segments span full height for tappable 44px area.
class PPSegmentedControl extends StatelessWidget {
  const PPSegmentedControl({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
    this.small = false,
  }) : assert(segments.length >= 2 && segments.length <= 4);

  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;
    final pad = small ? 3.0 : PPSpacing.s1;
    final n = segments.length;
    // Alignment x for the thumb: -1..1 across n slots.
    final x = n == 1 ? 0.0 : -1 + 2 * (selectedIndex / (n - 1));

    final labelStyle = small
        ? theme.textTheme.labelMedium!
        : theme.textTheme.bodySmall!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Thumb is confined to the padded/visual slot width, not the outer
        // control width — using the outer width let the thumb bleed ~2-3px
        // into neighboring segments at the edges (final-review finding #1).
        final innerWidth = constraints.maxWidth - 2 * pad;
        final w = innerWidth / n;

        // For normal variant: outer 44px SizedBox holds two stacked layers —
        // (a) the padded visual pill (bg + sliding thumb, sized from the
        // inner/padded width above) and (b) a full-height Row of opaque
        // GestureDetectors with NO padding, so the entire 44px is tappable
        // (final-review finding #1: the old single-Container layout put the
        // detectors inside the 4px padding, shrinking the hit area to 36px).
        if (!small) {
          return SizedBox(
            height: PPSpacing.tapMin,
            child: Stack(
              children: [
                Container(
                  height: PPSpacing.tapMin,
                  padding: EdgeInsets.all(pad),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(PPRadius.pill),
                    border: dark
                        ? null
                        : Border.all(
                            color: scheme.outlineVariant,
                            width: PPBorders.hairline,
                          ),
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        alignment: Alignment(x, 0),
                        duration: PPMotion.base,
                        curve: PPMotion.standard,
                        child: Container(
                          key: const Key('pp_segmented_thumb'),
                          width: w,
                          decoration: BoxDecoration(
                            color: dark
                                ? scheme.surfaceContainerHighest
                                : scheme.surface,
                            borderRadius: BorderRadius.circular(PPRadius.pill),
                            boxShadow: dark ? null : pp.shadow1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  key: const Key('pp_segmented_overlay'),
                  children: [
                    for (var i = 0; i < n; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                            child: Text(
                              segments[i],
                              style: labelStyle.copyWith(
                                color: i == selectedIndex
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant,
                                fontWeight: i == selectedIndex
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }

        // Small variant: 44px layout with 28px visual pill centered
        return SizedBox(
          height: PPSpacing.tapMin,
          child: Stack(
            children: [
              // Background: visual pill (28px) centered
              Align(
                child: Container(
                  height: 28,
                  padding: EdgeInsets.all(pad),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(PPRadius.pill),
                    border: dark
                        ? null
                        : Border.all(
                            color: scheme.outlineVariant,
                            width: PPBorders.hairline,
                          ),
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        alignment: Alignment(x, 0),
                        duration: PPMotion.base,
                        curve: PPMotion.standard,
                        child: Container(
                          key: const Key('pp_segmented_thumb'),
                          width: w,
                          decoration: BoxDecoration(
                            color: dark
                                ? scheme.surfaceContainerHighest
                                : scheme.surface,
                            borderRadius: BorderRadius.circular(PPRadius.pill),
                            boxShadow: dark ? null : pp.shadow1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Foreground: segments row (full 44px height)
              Row(
                key: const Key('pp_segmented_overlay'),
                children: [
                  for (var i = 0; i < n; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged(i),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 3,
                              horizontal: 10,
                            ),
                            child: Text(
                              segments[i],
                              style: labelStyle.copyWith(
                                color: i == selectedIndex
                                    ? scheme.onSurface
                                    : scheme.onSurfaceVariant,
                                fontWeight: i == selectedIndex
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
