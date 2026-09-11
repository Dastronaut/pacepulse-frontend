import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pacepulse/core/network/connectivity.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/home/data/stub_home_repository.dart';
import 'package:pacepulse/features/home/domain/home_copy.dart';
import 'package:pacepulse/features/home/domain/home_repository.dart';
import 'package:pacepulse/features/home/domain/home_summary.dart';
import 'package:pacepulse/features/home/presentation/home_screen.dart';
import 'package:pacepulse/features/home/presentation/widgets/home_skeleton.dart';
import 'package:pacepulse/features/home/presentation/widgets/quick_start.dart';
import 'package:pacepulse/features/home/presentation/widgets/rings_card.dart';
import 'package:pacepulse/features/home/presentation/widgets/stats_row.dart';

/// Succeeds on its first call and throws [nextThrows] on any later call —
/// lets a test drive "first load succeeds, then refresh fails" through the
/// real repository/controller path instead of a test-only hook on the
/// controller.
class _FlakyRepository implements HomeRepository {
  _FlakyRepository(this._summary);

  final HomeSummary _summary;
  var calls = 0;
  Object? nextThrows;

  @override
  Future<HomeSummary> load() async {
    await Future<void>.delayed(Duration.zero);
    calls++;
    if (calls > 1 && nextThrows != null) {
      final error = nextThrows!;
      nextThrows = null;
      throw error;
    }
    return _summary;
  }
}

Future<ProviderContainer> pumpHome(
  WidgetTester tester, {
  HomeRepository repo = const StubHomeRepository(latency: Duration.zero),
  Stream<bool>? connectivity,
  Brightness brightness = Brightness.dark,
}) async {
  // The default 800x600 test surface has no cache extent beyond the
  // viewport on this SDK (verified empirically), so content below y=600
  // never mounts. HomeSkeleton alone is 580 tall, pushing QuickStart past
  // that line. A tall surface keeps every rendering's chrome reachable
  // without scrolling, matching how the assertions read.
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer.test(
    overrides: <dynamic>[
      homeRepositoryProvider.overrideWithValue(repo),
      if (connectivity != null)
        connectivityProvider.overrideWith((ref) => connectivity),
    ].cast(),
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: brightness == Brightness.dark ? ppDarkTheme() : ppLightTheme(),
        routerConfig: GoRouter(
          initialLocation: HomeScreen.path,
          routes: [
            GoRoute(
              path: HomeScreen.path,
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(path: '/history', builder: (_, _) => const SizedBox()),
            GoRoute(path: '/profile', builder: (_, _) => const SizedBox()),
            GoRoute(
              path: '/permission/:kind',
              builder: (_, _) => const Text('primer'),
            ),
          ],
        ),
      ),
    ),
  );
  // An explicit zero duration (vs. bare pump()) is what actually fires a
  // zero-latency stub's Timer under fake_async; a bare pump() only flushes
  // microtasks and leaves that timer pending.
  await tester.pump(Duration.zero);
  return container;
}

void main() {
  testWidgets('the loading rendering is the skeleton, with chrome alive',
      (tester) async {
    await pumpHome(tester,
        repo: const StubHomeRepository(latency: Duration(seconds: 1)));

    expect(find.byType(HomeSkeleton), findsOneWidget);
    expect(find.byType(QuickStart), findsOneWidget);
    expect(find.byKey(const Key('home_fab')), findsOneWidget);
    expect(find.text(HomeCopy.title), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump(PPMotion.deliberate);
    expect(find.byType(HomeSkeleton), findsNothing);
  });

  testWidgets('the default rendering shows every section', (tester) async {
    await pumpHome(tester);
    await tester.pump(PPMotion.deliberate);
    // AnimatedSwitcher's outgoing entry is only actually dropped from the
    // tree on the frame after its animation status reports complete, so a
    // bounded settle pump is needed after any transition-inducing pump.
    await tester.pump();

    expect(find.byType(RingsCard), findsOneWidget);
    expect(find.byType(StatsRow), findsOneWidget);
    expect(find.byType(QuickStart), findsOneWidget);
    expect(find.byType(PPWorkoutCard), findsNWidgets(2));
    expect(find.byKey(const Key('home_streak_chip')), findsOneWidget);
  });

  testWidgets('first launch hides the streak chip and the stats row',
      (tester) async {
    await pumpHome(tester,
        repo: StubHomeRepository(
            latency: Duration.zero, summary: StubHomeFixtures.firstLaunch));
    await tester.pump(PPMotion.deliberate);

    expect(find.byKey(const Key('home_streak_chip')), findsNothing);
    expect(find.byKey(const Key('home_stats_row')), findsNothing);
    expect(find.byKey(const Key('home_recent_empty')), findsOneWidget);
    expect(find.byKey(const Key('home_fab')), findsOneWidget);
  });

  testWidgets('a failed load shows the error state but keeps quick start',
      (tester) async {
    await pumpHome(tester,
        repo: StubHomeRepository(
            latency: Duration.zero, failWith: StateError('boom')));
    await tester.pump(PPMotion.deliberate);
    await tester.pump();

    expect(find.byType(PPErrorState), findsOneWidget);
    expect(find.text(HomeCopy.errorTitle), findsOneWidget);
    expect(find.byType(QuickStart), findsOneWidget);
    expect(find.byKey(const Key('home_fab')), findsOneWidget);
  });

  testWidgets('offline shows the banner and pushes content down',
      (tester) async {
    final connectivity = StreamController<bool>.broadcast();
    addTearDown(connectivity.close);

    await pumpHome(tester, connectivity: connectivity.stream);
    connectivity.add(true);
    await tester.pump();
    await tester.pump(PPMotion.deliberate);

    final onlineTop = tester.getTopLeft(find.byType(RingsCard)).dy;
    expect(find.byType(PPOfflineBanner), findsNothing);

    connectivity.add(false);
    await tester.pump();
    await tester.pump(PPMotion.base);

    expect(find.byType(PPOfflineBanner), findsOneWidget);
    expect(find.text(HomeCopy.offlineBanner), findsOneWidget);
    expect(tester.getTopLeft(find.byType(RingsCard)).dy,
        greaterThan(onlineTop),
        reason: 'the banner must push content, not overlay it');
  });

  testWidgets('coming back online raises a toast', (tester) async {
    final connectivity = StreamController<bool>.broadcast();
    addTearDown(connectivity.close);

    await pumpHome(tester, connectivity: connectivity.stream);
    connectivity.add(false);
    await tester.pump();
    connectivity.add(true);
    await tester.pump();

    expect(find.text(HomeCopy.backOnline), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('pull to refresh reloads', (tester) async {
    final repo = _FlakyRepository(StubHomeFixtures.populated);
    await pumpHome(tester, repo: repo);
    await tester.pump(PPMotion.deliberate);
    expect(repo.calls, 1);

    // fling()/drag() gesture simulation on this ListView proved
    // unreliable in this exact composition — RefreshIndicator's public
    // test hook triggers a pull programmatically instead.
    tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pump(Duration.zero);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(Duration.zero);

    expect(repo.calls, 2, reason: 'the repository must be reloaded');
    expect(find.byType(RingsCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a failed refresh keeps the data and says so', (tester) async {
    final repo = _FlakyRepository(StubHomeFixtures.populated);
    await pumpHome(tester, repo: repo);
    await tester.pump(PPMotion.deliberate);
    await tester.pump();

    repo.nextThrows = StateError('refresh failed');

    // Same RefreshIndicator test hook as above.
    tester
        .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
        .show();
    await tester.pump(Duration.zero);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(Duration.zero);

    expect(find.byType(RingsCard), findsOneWidget,
        reason: 'a failed refresh must not blank the dashboard');
    expect(find.text(HomeCopy.refreshFailed), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Connect Health routes to the health primer', (tester) async {
    await pumpHome(tester,
        repo: StubHomeRepository(
            latency: Duration.zero, summary: StubHomeFixtures.healthDeclined));
    await tester.pump(PPMotion.deliberate);

    await tester.tap(find.byKey(const Key('home_connect_health')));
    await tester.pumpAndSettle();

    expect(find.text('primer'), findsOneWidget);
  });

  testWidgets('the default rendering survives the light theme', (tester) async {
    await pumpHome(tester, brightness: Brightness.light);
    await tester.pump(PPMotion.deliberate);
    expect(tester.takeException(), isNull);
  });
}
