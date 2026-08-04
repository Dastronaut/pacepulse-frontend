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
      ],
    );
  }
}
