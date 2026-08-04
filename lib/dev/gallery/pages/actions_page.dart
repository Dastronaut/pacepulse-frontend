import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../gallery.dart';

class ActionsGalleryPage extends StatelessWidget {
  const ActionsGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GallerySection(
          title: 'PPButton variants',
          child: Wrap(spacing: PPSpacing.s3, runSpacing: PPSpacing.s3,
              children: [
                PPButton(label: 'Start run', onPressed: () {}),
                PPButton(
                    label: 'Later',
                    variant: PPButtonVariant.secondary,
                    onPressed: () {}),
                PPButton(
                    label: 'Skip',
                    variant: PPButtonVariant.ghost,
                    onPressed: () {}),
                PPButton(
                    label: 'Delete',
                    variant: PPButtonVariant.danger,
                    onPressed: () {}),
              ]),
        ),
        GallerySection(
          title: 'Sizes / disabled / loading',
          child: Wrap(spacing: PPSpacing.s3, runSpacing: PPSpacing.s3,
              children: [
                PPButton(
                    label: 'Small', size: PPButtonSize.sm, onPressed: () {}),
                PPButton(
                    label: 'Large', size: PPButtonSize.lg, onPressed: () {}),
                const PPButton(label: 'Disabled', onPressed: null),
                PPButton(label: 'Saving', loading: true, onPressed: () {}),
              ]),
        ),
        GallerySection(
          title: 'PPIconButton',
          child: Wrap(spacing: PPSpacing.s3, runSpacing: PPSpacing.s3,
              children: [
                PPIconButton(
                    icon: PPIcons.share2,
                    style: PPIconButtonStyle.quiet,
                    onPressed: () {}),
                PPIconButton(
                    icon: PPIcons.plus,
                    style: PPIconButtonStyle.tonal,
                    onPressed: () {}),
                PPIconButton(
                    icon: PPIcons.play,
                    style: PPIconButtonStyle.filled,
                    onPressed: () {}),
              ]),
        ),
        GallerySection(
          title: 'PPStartFab',
          child: Wrap(spacing: PPSpacing.s3, runSpacing: PPSpacing.s3,
              children: [
                PPStartFab(onPressed: () {}),
                PPStartFab(onPressed: () {}, extendedLabel: 'Start workout'),
              ]),
        ),
        GallerySection(
          title: 'PPSegmentedControl',
          child: Column(
            spacing: PPSpacing.s3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Normal (Run/Ride/Gym)',
                  style: Theme.of(context).textTheme.labelSmall),
              SizedBox(
                width: 300,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    int index = 0;
                    return PPSegmentedControl(
                      segments: const ['Run', 'Ride', 'Gym'],
                      selectedIndex: index,
                      onChanged: (i) => setState(() => index = i),
                    );
                  },
                ),
              ),
              SizedBox(height: PPSpacing.s4),
              Text('Small (W/M/6M/Y)',
                  style: Theme.of(context).textTheme.labelSmall),
              SizedBox(
                width: 300,
                child: StatefulBuilder(
                  builder: (context, setState) {
                    int index = 0;
                    return PPSegmentedControl(
                      segments: const ['W', 'M', '6M', 'Y'],
                      selectedIndex: index,
                      onChanged: (i) => setState(() => index = i),
                      small: true,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
