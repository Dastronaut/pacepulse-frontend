import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../gallery.dart';

class NavigationGalleryPage extends StatelessWidget {
  const NavigationGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    int navIndex = 0;
    bool navLive = true;
    bool scrolledUnder = false;

    return ListView(
      children: [
        GallerySection(
          title: 'PPBottomNavBar',
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PPButton(
                  label: navLive ? 'Hide live badge' : 'Show live badge',
                  size: PPButtonSize.sm,
                  variant: PPButtonVariant.secondary,
                  onPressed: () => setState(() => navLive = !navLive),
                ),
                const SizedBox(height: PPSpacing.s3),
                PPBottomNavBar(
                  index: navIndex,
                  onChanged: (i) => setState(() => navIndex = i),
                  challengesLive: navLive,
                ),
              ],
            ),
          ),
        ),
        GallerySection(
          title: 'PPAppBar - standard',
          child: PPAppBar.standard(
            title: 'Settings',
            onBack: () {},
            trailing: const PPAvatar(initials: 'JD', size: PPAvatarSize.s32),
          ),
        ),
        const GallerySection(
          title: 'PPAppBar - large',
          child: PPAppBar.large(title: 'Challenges'),
        ),
        GallerySection(
          title: 'PPAppBar - live',
          child: PPAppBar.live(title: 'Saturday 5K', onClose: () {}),
        ),
        GallerySection(
          title: 'PPAppBar - scrolledUnder',
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PPButton(
                  label: scrolledUnder
                      ? 'Reset to transparent'
                      : 'Simulate scrolled content',
                  size: PPButtonSize.sm,
                  variant: PPButtonVariant.secondary,
                  onPressed: () =>
                      setState(() => scrolledUnder = !scrolledUnder),
                ),
                const SizedBox(height: PPSpacing.s3),
                PPAppBar.standard(
                  title: 'History',
                  onBack: () {},
                  scrolledUnder: scrolledUnder,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
