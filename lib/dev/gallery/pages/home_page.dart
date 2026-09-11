import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../../../features/home/data/stub_home_repository.dart';
import '../../../features/home/domain/home_copy.dart';
import '../../../features/home/presentation/widgets/home_header.dart';
import '../../../features/home/presentation/widgets/home_skeleton.dart';
import '../../../features/home/presentation/widgets/quick_start.dart';
import '../../../features/home/presentation/widgets/recent_section.dart';
import '../../../features/home/presentation/widgets/rings_card.dart';
import '../../../features/home/presentation/widgets/stats_row.dart';
import '../gallery.dart';

final _now = DateTime(2026, 6, 11, 9, 41);

class HomeGalleryPage extends StatelessWidget {
  const HomeGalleryPage({super.key});

  static const sectionTitles = <String>[
    'Header - default',
    'Header - first launch',
    'Header - offline',
    'Rings - populated',
    'Rings - health declined',
    'Rings - empty',
    'Stats - up',
    'Stats - health declined',
    'Quick start',
    'Recent - populated',
    'Recent - empty',
    'Skeleton',
    'Error',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        GallerySection(
          title: sectionTitles[0],
          child: _Frame(
            child: HomeHeader(
              summary: StubHomeFixtures.populated,
              offline: false,
              now: _now,
            ),
          ),
        ),
        GallerySection(
          title: sectionTitles[1],
          child: _Frame(
            child: HomeHeader(
              summary: StubHomeFixtures.firstLaunch,
              offline: false,
              now: _now,
            ),
          ),
        ),
        GallerySection(
          title: sectionTitles[2],
          child: _Frame(
            child: HomeHeader(
              summary: StubHomeFixtures.offlineCached,
              offline: true,
              now: _now,
            ),
          ),
        ),
        GallerySection(
          title: sectionTitles[3],
          child: _Frame(child: RingsCard(rings: StubHomeFixtures.populated.rings)),
        ),
        GallerySection(
          title: sectionTitles[4],
          child: _Frame(
            child: RingsCard(rings: StubHomeFixtures.healthDeclined.rings),
          ),
        ),
        GallerySection(
          title: sectionTitles[5],
          child: _Frame(child: RingsCard(rings: StubHomeFixtures.firstLaunch.rings)),
        ),
        GallerySection(
          title: sectionTitles[6],
          child: _Frame(child: StatsRow(summary: StubHomeFixtures.populated)),
        ),
        GallerySection(
          title: sectionTitles[7],
          child: _Frame(
            child: StatsRow(summary: StubHomeFixtures.healthDeclined),
          ),
        ),
        GallerySection(
          title: sectionTitles[8],
          child: _Frame(child: QuickStart(onStart: (_) {})),
        ),
        GallerySection(
          title: sectionTitles[9],
          child: _Frame(
            child: RecentSection(
              recent: StubHomeFixtures.populated.recent,
              now: _now,
              onViewAll: () {},
              onOpen: (_) {},
              onStartFirst: () {},
            ),
          ),
        ),
        GallerySection(
          title: sectionTitles[10],
          child: _Frame(
            child: RecentSection(
              recent: StubHomeFixtures.firstLaunch.recent,
              now: _now,
              onViewAll: () {},
              onOpen: (_) {},
              onStartFirst: () {},
            ),
          ),
        ),
        GallerySection(
          title: sectionTitles[11],
          child: _Frame(child: const HomeSkeleton()),
        ),
        GallerySection(
          title: sectionTitles[12],
          child: _Frame(
            child: PPErrorState(
              title: HomeCopy.errorTitle,
              body: HomeCopy.errorBody,
              onRetry: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: PPFrame.width, child: child);
}
