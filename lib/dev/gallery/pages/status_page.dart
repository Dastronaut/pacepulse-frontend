import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../gallery.dart';

class StatusGalleryPage extends StatelessWidget {
  const StatusGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        GallerySection(
          title: 'PPChip variants',
          child: Wrap(spacing: PPSpacing.s3, runSpacing: PPSpacing.s3,
              children: [
                PPChip(label: 'Live', variant: PPChipVariant.live),
                PPChip(label: 'PR · 5K', variant: PPChipVariant.pr),
                PPChip(label: '12', variant: PPChipVariant.streak),
                PPChip(label: 'Premium', variant: PPChipVariant.premium),
                PPChip(label: 'Ready', variant: PPChipVariant.success),
                PPChip(label: 'Failed', variant: PPChipVariant.error),
                PPChip(label: 'Ad', shape: PPChipShape.tag),
              ]),
        ),
      ],
    );
  }
}
