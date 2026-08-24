import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pacepulse/core/config/app_info.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/auth/data/session.dart';
import 'package:pacepulse/features/auth/presentation/auth_landing_screen.dart';
import 'package:pacepulse/features/home/presentation/home_placeholder.dart';
import 'package:pacepulse/features/onboarding/data/onboarding_seen.dart';
import 'package:pacepulse/features/onboarding/presentation/onboarding_carousel_screen.dart';
import 'package:pacepulse/features/onboarding/presentation/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Own harness (not PacePulseApp) so reduced motion can be injected via
/// the app-level builder and providers overridden per test.
/// Note: overrides is intentionally untyped (raw List) because Override is not
/// exported from flutter_riverpod's public API.
Widget harness({bool reducedMotion = false, List overrides = const []}) {
  final router = GoRouter(
    initialLocation: SplashScreen.path,
    routes: [
      GoRoute(
          path: SplashScreen.path,
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: AuthLandingScreen.path,
          builder: (context, state) => const AuthLandingScreen()),
      GoRoute(
          path: HomePlaceholder.path,
          builder: (context, state) => const HomePlaceholder()),
      GoRoute(
          path: OnboardingCarouselScreen.path,
          builder: (context, state) => const OnboardingCarouselScreen()),
    ],
  );
  return ProviderScope(
    // Riverpod retries a failed provider by default, which schedules a Timer
    // that outlives tests exercising the throwing overrides below and fails
    // them with a pending-timer error at teardown. No provider here fails
    // outside those tests, so disabling retry is a no-op for everything else.
    retry: (_, _) => null,
    overrides: overrides.cast(),
    child: MaterialApp.router(
      theme: ppLightTheme(),
      darkTheme: ppDarkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: reducedMotion),
        child: child!,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('renders ring, wordmark, version', (tester) async {
    await tester.pumpWidget(harness());
    expect(find.byType(PPActivityRing), findsOneWidget);
    expect(find.text('PacePulse'), findsOneWidget);
    expect(find.text(PPAppInfo.versionLabel), findsOneWidget);
    // Navigation to carousel; pumpAndSettle would hang due to looping animation.
    // Pump past splash draw-in and async reads.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('first run routes to the onboarding carousel',
      (tester) async {
    await tester.pumpWidget(harness());
    // Navigation to carousel; pumpAndSettle would hang due to looping animation.
    // Pump past splash draw-in and async reads.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(OnboardingCarouselScreen), findsOneWidget);
  });

  testWidgets('1.5s cap forces navigation when the session never resolves',
      (tester) async {
    final never = Completer<bool>();
    await tester.pumpWidget(harness(
      overrides: [sessionProvider.overrideWith((ref) => never.future)],
    ));
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.byType(AuthLandingScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.byType(AuthLandingScreen), findsOneWidget);
    // Guard: the widget is disposed by the cap navigation above. When the
    // still-pending session future finally resolves, _start()'s post-await
    // ref.read must not run on the disposed ConsumerState.
    never.complete(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a seen carousel routes straight to auth', (tester) async {
    await tester.pumpWidget(harness(
      overrides: [onboardingSeenProvider.overrideWith((ref) async => true)],
    ));
    await tester.pumpAndSettle();
    expect(find.byType(AuthLandingScreen), findsOneWidget);
    expect(find.byType(OnboardingCarouselScreen), findsNothing);
  });

  testWidgets('an existing session skips the carousel entirely',
      (tester) async {
    await tester.pumpWidget(harness(
      overrides: [sessionProvider.overrideWith((ref) async => true)],
    ));
    await tester.pumpAndSettle();
    expect(find.byType(HomePlaceholder), findsOneWidget);
  });

  testWidgets('reduced motion: ring is complete immediately, still navigates',
      (tester) async {
    await tester.pumpWidget(harness(reducedMotion: true));
    await tester.pump(); // post-frame _start has set the static value
    final ring =
        tester.widget<PPActivityRing>(find.byType(PPActivityRing));
    expect(ring.value, 1.0);
    // Navigation to carousel; pumpAndSettle would hang due to looping animation.
    // Pump past async reads.
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(OnboardingCarouselScreen), findsOneWidget);
  });

  testWidgets(
      'a thrown Exception falls open immediately, without waiting for the cap',
      (tester) async {
    await tester.pumpWidget(harness(
      overrides: [
        sessionProvider.overrideWith((ref) async => throw Exception('boom')),
      ],
    ));
    // Navigation to carousel; pumpAndSettle would hang due to looping animation.
    // Pump past draw-in and the async reads, well short of the 1.5s cap.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(OnboardingCarouselScreen), findsOneWidget);
    expect(find.byType(AuthLandingScreen), findsNothing);
  });

  testWidgets(
      'a thrown Error escapes uncaught; the 1.5s cap rescues navigation',
      (tester) async {
    // The StateError escapes _falseOnError uncaught, so `.wait` rejects
    // _start()'s own Future with a ParallelWaitError — and because _start()
    // is fire-and-forget (called from addPostFrameCallback, never awaited),
    // that becomes a genuinely unhandled Future error. flutter_test fails a
    // test outright the instant that happens, so this test runs the pump
    // sequence inside its own runZonedGuarded to intercept the error before
    // the framework's zone does — same trick you'd reach for testing any
    // fire-and-forget callback that's expected to throw.
    //
    // Everything inside the zone only records plain values, never calls
    // expect(): a zone's onError takes over a body's own error completion,
    // so a TestFailure thrown in here (from a failing expect) would route to
    // onError instead of rejecting the awaited body future below — the test
    // would hang instead of failing cleanly. Asserting on the recorded
    // values after the zone closes keeps a real regression a fast failure.
    final escaped = <Object>[];
    var carouselAfterReads = false;
    var authBeforeCap = false;
    var authAfterFirstCheckpoint = false;
    var authAfterCap = false;
    await runZonedGuarded(() async {
      await tester.pumpWidget(harness(
        overrides: [
          sessionProvider.overrideWith((ref) async => throw StateError('boom')),
        ],
      ));
      // Same checkpoint as the Exception case above: the read has already
      // rejected by now, but the escaped StateError means _start() never
      // reached _go() — neither destination shows up yet.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 50));
      carouselAfterReads =
          find.byType(OnboardingCarouselScreen).evaluate().isNotEmpty;
      authBeforeCap =
          find.byType(AuthLandingScreen).evaluate().isNotEmpty;
      // Only the 1.5s cap can move the app off the splash screen now.
      await tester.pump(const Duration(milliseconds: 750));
      authAfterFirstCheckpoint =
          find.byType(AuthLandingScreen).evaluate().isNotEmpty;
      await tester.pump(const Duration(milliseconds: 200));
      // Bare pumpAndSettle would hang if this ever mis-routed to the
      // carousel instead (PPLivePulse loops); settle the route transition
      // with bounded pumps, as the router tests do.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      authAfterCap = find.byType(AuthLandingScreen).evaluate().isNotEmpty;
    }, (error, stack) => escaped.add(error));
    expect(carouselAfterReads, isFalse);
    expect(authBeforeCap, isFalse);
    expect(authAfterFirstCheckpoint, isFalse);
    expect(authAfterCap, isTrue);
    // `.wait` packages the escaped StateError into a ParallelWaitError; check
    // that's genuinely what got away, rather than just swallowing anything.
    expect(escaped, hasLength(1));
    expect(escaped.single, isA<ParallelWaitError>());
  });
}
