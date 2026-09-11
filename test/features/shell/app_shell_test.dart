import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pacepulse/core/router/app_router.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/home/data/stub_home_repository.dart';
import 'package:pacepulse/features/home/presentation/home_screen.dart';
import 'package:pacepulse/features/onboarding/presentation/splash_screen.dart';
import 'package:pacepulse/features/shell/presentation/app_shell.dart';
import 'package:pacepulse/features/shell/presentation/tab_placeholder.dart';

Future<GoRouter> pumpApp(WidgetTester tester) async {
  // HomeScreen (Task 9) now does a real async load; a zero-latency stub
  // plus an explicit zero-duration pump fires that Future deterministically
  // instead of leaving a Timer pending at teardown.
  final container = ProviderContainer.test(
    overrides: [
      homeRepositoryProvider
          .overrideWithValue(const StubHomeRepository(latency: Duration.zero)),
    ],
  );
  addTearDown(container.dispose);
  final router = container.read(appRouterProvider);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: ppDarkTheme(), routerConfig: router),
    ),
  );
  await tester.pump(Duration.zero);
  return router;
}

void main() {
  testWidgets('the four tabs are reachable and the nav bar tracks them',
      (tester) async {
    final router = await pumpApp(tester);

    router.go(HomeScreen.path);
    await tester.pump(Duration.zero);
    expect(find.byType(PPBottomNavBar), findsOneWidget);
    expect(tester.widget<PPBottomNavBar>(find.byType(PPBottomNavBar)).index, 0);

    router.go(HistoryScreen.path);
    await tester.pump(Duration.zero);
    expect(tester.widget<PPBottomNavBar>(find.byType(PPBottomNavBar)).index, 1);

    router.go(ChallengesScreen.path);
    await tester.pump(Duration.zero);
    expect(tester.widget<PPBottomNavBar>(find.byType(PPBottomNavBar)).index, 2);

    router.go(ProfileScreen.path);
    await tester.pump(Duration.zero);
    expect(tester.widget<PPBottomNavBar>(find.byType(PPBottomNavBar)).index, 3);
  });

  testWidgets(
      'tapping the nav bar switches branch and keeps the backgrounded '
      'branch alive offstage', (tester) async {
    final router = await pumpApp(tester);
    router.go(HomeScreen.path);
    await tester.pump(Duration.zero);

    await tester.tap(find.text('History'));
    await tester.pump(Duration.zero);
    expect(find.byType(TabPlaceholder), findsOneWidget);
    expect(tester.widget<PPBottomNavBar>(find.byType(PPBottomNavBar)).index, 1);
    expect(find.text('History — coming'), findsOneWidget);

    await tester.tap(find.text('Challenges'));
    await tester.pump(Duration.zero);
    expect(tester.widget<PPBottomNavBar>(find.byType(PPBottomNavBar)).index, 2);
    expect(find.text('Challenges — coming'), findsOneWidget);

    // Proof this is IndexedStack preservation, not a Navigator that
    // disposes the old route: History is gone from the onstage tree...
    expect(find.text('History — coming'), findsNothing);
    // ...but is still mounted, just offstage. A non-preserving shell
    // (e.g. a plain Navigator swapping pages) would fail this line too.
    expect(
      find.text('History — coming', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('full-screen routes show no nav bar', (tester) async {
    final router = await pumpApp(tester);

    for (final path in [SplashScreen.path, '/auth', '/wizard']) {
      router.go(path);
      await tester.pump(Duration.zero);
      expect(find.byType(PPBottomNavBar), findsNothing, reason: path);
    }
  });

  testWidgets('re-tapping the active tab resets that branch to its root',
      (tester) async {
    // A router built the same way AppShell builds the real one, but with
    // a nested child route on branch A so there is somewhere deeper than
    // root to reset from — the production branches are all single-route,
    // so this is the only way to exercise `initialLocation: true`.
    final router = GoRouter(
      initialLocation: '/a',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/a',
                builder: (context, state) => const TabPlaceholder(title: 'A'),
                routes: [
                  GoRoute(
                    path: 'deep',
                    builder: (context, state) =>
                        const TabPlaceholder(title: 'Deep'),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/b',
                builder: (context, state) => const TabPlaceholder(title: 'B'),
              ),
            ]),
          ],
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(theme: ppDarkTheme(), routerConfig: router),
    );
    await tester.pump(Duration.zero);

    router.push('/a/deep');
    await tester.pump(Duration.zero);
    expect(find.text('Deep — coming'), findsOneWidget);

    // Branch A (index 0, labelled "Home" by the fixed nav bar) is already
    // active — tapping it again must pop that branch back to its root.
    await tester.tap(find.text('Home'));
    await tester.pump(Duration.zero);

    expect(find.text('Deep — coming'), findsNothing);
    expect(find.text('A — coming'), findsOneWidget);
  });
}
