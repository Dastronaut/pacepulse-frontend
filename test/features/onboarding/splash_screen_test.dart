import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pacepulse/core/config/app_info.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/auth/data/session.dart';
import 'package:pacepulse/features/auth/presentation/auth_landing_placeholder.dart';
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
          path: AuthLandingPlaceholder.path,
          builder: (context, state) => const AuthLandingPlaceholder()),
      GoRoute(
          path: HomePlaceholder.path,
          builder: (context, state) => const HomePlaceholder()),
      GoRoute(
          path: OnboardingCarouselScreen.path,
          builder: (context, state) => const OnboardingCarouselScreen()),
    ],
  );
  return ProviderScope(
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
    expect(find.byType(AuthLandingPlaceholder), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.byType(AuthLandingPlaceholder), findsOneWidget);
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
    expect(find.byType(AuthLandingPlaceholder), findsOneWidget);
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
}
