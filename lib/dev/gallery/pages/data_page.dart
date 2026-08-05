import 'package:flutter/material.dart';

import '../../../core/ui/ui.dart';
import '../gallery.dart';

class DataGalleryPage extends StatelessWidget {
  const DataGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        const GallerySection(
          title: 'PPActivityRings',
          child: PPActivityRings(
            move: 0.8,
            exercise: 0.5,
            steps: 0.3,
            child: Text('82%'),
          ),
        ),
        GallerySection(
          title: 'PPActivityRing (single)',
          child: PPActivityRing(
            value: 1,
            size: 170,
            thickness: 14,
            color: colorScheme.primary,
            child: const Text('2nd'),
          ),
        ),
        const GallerySection(
          title: 'PPMetricDisplay (display)',
          child: PPMetricDisplay(
            label: 'Distance',
            value: '4.62',
            unit: 'km',
          ),
        ),
        const GallerySection(
          title: 'PPMetricDisplay (mono)',
          child: PPMetricDisplay(
            label: 'Time',
            value: '28:41',
            face: PPMetricFace.mono,
          ),
        ),
        const GallerySection(
          title: 'PPMetricDisplay (live)',
          child: PPMetricDisplay(
            label: 'Heart rate',
            value: '152',
            unit: 'bpm',
            live: true,
          ),
        ),
        const GallerySection(
          title: 'PPMetricDisplay (accent)',
          child: PPMetricDisplay(
            label: 'Elevation',
            value: '1256',
            unit: 'm',
            accent: true,
          ),
        ),
        GallerySection(
          title: 'PPStatTile',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PPStatTile(
                icon: PPIcons.flame,
                label: 'Calories',
                value: '486',
              ),
              const SizedBox(width: 16),
              const PPStatTile(
                icon: PPIcons.route,
                label: 'Distance',
                value: '5.2',
                unit: 'km',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
