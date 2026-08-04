import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../gallery.dart';

class StatusGalleryPage extends StatelessWidget {
  const StatusGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const GallerySection(
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
        GallerySection(
          title: 'PPToast',
          child: Wrap(spacing: PPSpacing.s3, runSpacing: PPSpacing.s3,
              children: [
                PPButton(
                  label: 'Show success',
                  onPressed: () => showPPToast(
                    context,
                    message: 'Workout saved',
                    actionLabel: 'View',
                    onAction: () {},
                  ),
                ),
                PPButton(
                  label: 'Show error',
                  variant: PPButtonVariant.danger,
                  onPressed: () => showPPToast(
                    context,
                    kind: PPToastKind.error,
                    message: 'Sync failed — retry later',
                  ),
                ),
              ]),
        ),
        const GallerySection(
          title: 'PPOfflineBanner',
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            PPOfflineBanner(),
            SizedBox(height: PPSpacing.s3),
            PPOfflineBanner(message: 'Reconnecting...'),
          ]),
        ),
        const GallerySection(
          title: 'PPBannerAdSlot',
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            PPBannerAdSlot(),
            SizedBox(height: PPSpacing.s3),
            PPBannerAdSlot(
              ad: ColoredBox(color: Color(0xFF3FD98B)),
            ),
          ]),
        ),
        const GallerySection(
          title: 'PPIllustration',
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Onboarding - Ember'),
            SizedBox(height: PPSpacing.s2),
            PPIllustration(
              name: 'welcome',
              size: PPIllustrationSize.onboarding,
              accent: PPIllustrationAccent.ember,
            ),
            SizedBox(height: PPSpacing.s4),
            Text('Onboarding - Warning'),
            SizedBox(height: PPSpacing.s2),
            PPIllustration(
              name: 'alert',
              size: PPIllustrationSize.onboarding,
              accent: PPIllustrationAccent.warning,
            ),
            SizedBox(height: PPSpacing.s4),
            Text('Empty - Ember'),
            SizedBox(height: PPSpacing.s2),
            PPIllustration(
              name: 'empty_workouts',
              size: PPIllustrationSize.empty,
              accent: PPIllustrationAccent.ember,
            ),
            SizedBox(height: PPSpacing.s4),
            Text('Empty - Warning'),
            SizedBox(height: PPSpacing.s2),
            PPIllustration(
              name: 'no_data',
              size: PPIllustrationSize.empty,
              accent: PPIllustrationAccent.warning,
            ),
          ]),
        ),
        GallerySection(
          title: 'Empty / error states',
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Empty State'),
            const SizedBox(height: PPSpacing.s2),
            PPEmptyState(
              title: 'No workouts yet',
              body: 'Your first run shows up here.',
              actionLabel: 'Start a run',
              onAction: () {},
            ),
            const SizedBox(height: PPSpacing.s4),
            const Text('Error State'),
            const SizedBox(height: PPSpacing.s2),
            PPErrorState(
              title: "Couldn't load history",
              body: 'Check your connection and try again.',
              onRetry: () {},
            ),
          ]),
        ),
      ],
    );
  }
}
