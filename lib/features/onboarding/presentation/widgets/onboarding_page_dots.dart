import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/ui/ui.dart';

/// Carousel position indicator (Flow 5 S2 carousel rules: active = 24px
/// Ember pill, idle 8px --outline, transition --duration-base
/// --ease-standard). Feature-scoped on purpose — the Component Library
/// sheet has no page-indicator component.
class OnboardingPageDots extends StatelessWidget {
  const OnboardingPageDots({
    super.key,
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final duration = ppReducedMotion(context) ? Duration.zero : PPMotion.base;
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Slide ${index + 1} of $count',
      child: ExcludeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) const SizedBox(width: PPSpacing.gapInline),
              AnimatedContainer(
                // Per-index: sibling widgets must not share a key.
                key: Key('pp_onboarding_dot_$i'),
                duration: duration,
                curve: PPMotion.standard,
                width: i == index ? PPSpacing.s6 : PPSpacing.s2,
                height: PPSpacing.s2,
                decoration: BoxDecoration(
                  color: i == index ? scheme.primary : scheme.outline,
                  borderRadius: BorderRadius.circular(PPRadius.pill),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
