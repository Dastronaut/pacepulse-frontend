import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

const double _segmentHeight = 4;

class WizardProgress extends StatelessWidget {
  const WizardProgress({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      container: true,
      label: 'Step ${index + 1} of $count',
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: PPSpacing.s1),
            Expanded(
              child: DecoratedBox(
                key: Key('wizard_progress_segment_$i'),
                decoration: BoxDecoration(
                  color: i <= index ? scheme.primary : scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(PPRadius.pill),
                ),
                child: const SizedBox(height: _segmentHeight),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
