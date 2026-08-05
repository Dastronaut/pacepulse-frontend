import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../gallery.dart';

class SpecializedGalleryPage extends StatelessWidget {
  const SpecializedGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const GallerySection(
          title: 'PPMapPreviewCard',
          child: SizedBox(
            width: double.infinity,
            child: PPMapPreviewCard(
              route: [
                Offset(0.1, 0.8),
                Offset(0.3, 0.5),
                Offset(0.6, 0.4),
                Offset(0.9, 0.6),
              ],
              statsLine: '5.21 km · 28:41 · 5:31 /km',
            ),
          ),
        ),
        GallerySection(
          title: 'PPDeviceTile - states',
          child: Column(
            spacing: PPSpacing.s3,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PPDeviceTile(
                name: 'Polar H10',
                rssiDbm: -85,
                batteryPct: 92,
                onConnect: () {},
              ),
              const PPDeviceTile(
                name: 'Wahoo TICKR',
                rssiDbm: -60,
                batteryPct: 78,
                state: PPDeviceState.connecting,
              ),
              const PPDeviceTile(
                name: 'Garmin HRM-Pro',
                rssiDbm: -55,
                batteryPct: 85,
                state: PPDeviceState.connected,
              ),
            ],
          ),
        ),
        GallerySection(
          title: 'PPPaywallPlanCard - selection',
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              spacing: PPSpacing.s3,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PPPaywallPlanCard(
                  plan: 'Yearly',
                  price: '\$4.99',
                  billedNote: 'Billed \$59.88 yearly',
                  bestValue: true,
                  selected: true,
                  onSelected: () {},
                ),
                PPPaywallPlanCard(
                  plan: 'Monthly',
                  price: '\$7.99',
                  billedNote: 'Billed monthly',
                  selected: false,
                  onSelected: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
