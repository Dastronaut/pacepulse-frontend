import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../gallery.dart';

class FoundationsGalleryPage extends StatelessWidget {
  const FoundationsGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GallerySection(
          title: 'Icons 20/24/28',
          child: Wrap(
            spacing: PPSpacing.s3,
            runSpacing: PPSpacing.s3,
            children: [
              for (final icon in PPIcons.all) PPIcon(icon),
            ],
          ),
        ),
        GallerySection(
          title: 'Skeleton',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              PPSkeleton(width: 200, height: 16),
              SizedBox(height: PPSpacing.s2),
              PPSkeleton(width: 120, height: 16),
            ],
          ),
        ),
        GallerySection(
          title: 'Live dot + pulse',
          child: Row(
            children: const [
              PPLiveDot(),
              SizedBox(width: PPSpacing.s6),
              PPLivePulse(
                loop: true,
                child: CircleAvatar(radius: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
