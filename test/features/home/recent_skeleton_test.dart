import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/home/domain/activity.dart';
import 'package:pacepulse/features/home/domain/activity_format.dart';
import 'package:pacepulse/features/home/domain/daily_rings.dart';
import 'package:pacepulse/features/home/domain/home_copy.dart';
import 'package:pacepulse/features/home/presentation/widgets/home_skeleton.dart';
import 'package:pacepulse/features/home/presentation/widgets/recent_section.dart';
import 'package:pacepulse/features/home/presentation/widgets/rings_card.dart';

Widget wrap(Widget child, {Brightness brightness = Brightness.dark}) =>
    MaterialApp(
      theme: brightness == Brightness.dark ? ppDarkTheme() : ppLightTheme(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

final _now = DateTime(2026, 6, 12, 9, 41);

final _run = Activity(
  id: 'a1',
  type: ActivityType.run,
  title: 'Morning run',
  startedAt: DateTime(2026, 6, 12, 7, 12),
  distanceM: 5210,
  durationS: 1721,
  avgPaceSPerKm: 331,
  calories: 412,
  isPr: true,
  syncedAt: DateTime(2026, 6, 12, 7, 45),
);

final _gym = Activity(
  id: 'a2',
  type: ActivityType.gym,
  title: 'Gym session',
  startedAt: DateTime(2026, 6, 11, 18, 30),
  durationS: 2700,
  calories: 312,
  syncedAt: DateTime(2026, 6, 11, 19, 20),
);

void main() {
  group('ActivityFormat', () {
    test('a run reads distance, duration and pace', () {
      expect(ActivityFormat.stats(_run), '5.21 km · 28:41 · 5:31 /km');
    });

    test('a gym session reads duration and calories', () {
      expect(ActivityFormat.stats(_gym), '45 min · 312 kcal');
    });

    test('meta is the relative day when synced', () {
      expect(ActivityFormat.meta(_gym, _now), 'yesterday');
    });

    test('meta becomes the unsynced marker when it has never synced', () {
      final pending = Activity(
        id: 'a3',
        type: ActivityType.run,
        title: 'Morning run',
        startedAt: DateTime(2026, 6, 12, 7, 12),
      );
      expect(ActivityFormat.meta(pending, _now), HomeCopy.notSynced);
    });
  });

  group('RecentSection', () {
    testWidgets('workouts render with a View all affordance', (tester) async {
      Activity? opened;
      var viewedAll = false;

      await tester.pumpWidget(wrap(RecentSection(
        recent: [_run, _gym],
        now: _now,
        onViewAll: () => viewedAll = true,
        onOpen: (a) => opened = a,
        onStartFirst: () {},
      )));

      expect(find.text(HomeCopy.recent), findsOneWidget);
      expect(find.text('Morning run'), findsOneWidget);
      expect(find.text('5.21 km · 28:41 · 5:31 /km'), findsOneWidget);
      expect(find.byType(PPWorkoutCard), findsNWidgets(2));

      await tester.tap(find.byKey(const Key('home_view_all')));
      expect(viewedAll, isTrue);

      await tester.tap(find.text('Morning run'));
      expect(opened, _run);
    });

    testWidgets('an empty list invites the first workout and hides View all',
        (tester) async {
      var started = false;
      await tester.pumpWidget(wrap(RecentSection(
        recent: const [],
        now: _now,
        onViewAll: () {},
        onOpen: (_) {},
        onStartFirst: () => started = true,
      )));

      expect(find.byKey(const Key('home_view_all')), findsNothing);
      expect(find.byKey(const Key('home_recent_empty')), findsOneWidget);
      expect(find.text(HomeCopy.emptyTitle), findsOneWidget);

      await tester.tap(find.text(HomeCopy.emptyAction));
      expect(started, isTrue);
    });
  });

  group('HomeSkeleton', () {
    testWidgets('renders skeleton blocks without settling', (tester) async {
      await tester.pumpWidget(wrap(const HomeSkeleton()));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const Key('home_skeleton')), findsOneWidget);
      expect(find.byType(PPSkeleton), findsWidgets);
    });

    testWidgets('renders in the light theme', (tester) async {
      await tester.pumpWidget(
          wrap(const HomeSkeleton(), brightness: Brightness.light));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the rings block matches the loaded RingsCard geometry',
        (tester) async {
      await tester.pumpWidget(wrap(const HomeSkeleton()));
      await tester.pump(const Duration(milliseconds: 100));
      final skeletonSize =
          tester.getSize(find.byKey(const Key('home_skeleton_rings')));

      await tester.pumpWidget(wrap(const Padding(
        padding: EdgeInsets.symmetric(horizontal: PPSpacing.padScreen),
        child: RingsCard(
          rings: DailyRings(moveKcal: 486, exerciseMin: 22, steps: 8214),
        ),
      )));
      await tester.pump(PPMotion.deliberate);
      final loadedSize =
          tester.getSize(find.byKey(const Key('home_rings_card')));

      // Layout shift on load is the thing this pins — dimensions must
      // agree within a sub-pixel tolerance.
      expect(skeletonSize.width, closeTo(loadedSize.width, 1));
      expect(skeletonSize.height, closeTo(loadedSize.height, 1));
    });
  });
}
