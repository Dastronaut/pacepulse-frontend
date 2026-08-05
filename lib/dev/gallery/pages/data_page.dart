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
        const GallerySection(
          title: 'PPWorkoutCard',
          child: PPWorkoutCard(
            icon: PPIcons.footprints,
            title: 'Morning run',
            meta: 'Today · 06:24',
            stats: '5.21 km · 28:41 · 5:31 /km',
            showPr: false,
          ),
        ),
        const GallerySection(
          title: 'PPWorkoutCard (with PR)',
          child: PPWorkoutCard(
            icon: PPIcons.bike,
            title: 'Evening ride',
            meta: 'Yesterday · 19:10',
            stats: '18.4 km · 54:20 · 2:56 /km',
            showPr: true,
          ),
        ),
        const GallerySection(
          title: 'PPProgressBar (0.62)',
          child: SizedBox(
            width: 200,
            child: PPProgressBar(
              value: 0.62,
              label: 'Distance',
              valueLabel: '6.2 km',
            ),
          ),
        ),
        const GallerySection(
          title: 'PPProgressBar (goal hit 1.0)',
          child: SizedBox(
            width: 200,
            child: PPProgressBar(
              value: 1.0,
              label: 'Calories',
              valueLabel: '500 kcal',
              goalHit: true,
            ),
          ),
        ),
      ],
    );
  }
}
