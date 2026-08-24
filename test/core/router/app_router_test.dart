// test/core/router/app_router_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pacepulse/dev/gallery/gallery.dart';
import 'package:pacepulse/features/auth/domain/auth_validators.dart';
import 'package:pacepulse/features/auth/presentation/auth_landing_screen.dart';
import 'package:pacepulse/features/auth/presentation/reset_password_screen.dart';
import 'package:pacepulse/features/auth/presentation/sign_in_screen.dart';
import 'package:pacepulse/features/auth/presentation/sign_up_screen.dart';
import 'package:pacepulse/features/home/presentation/home_placeholder.dart';
import 'package:pacepulse/features/onboarding/data/onboarding_seen.dart';
import 'package:pacepulse/features/onboarding/presentation/onboarding_carousel_screen.dart';
import 'package:pacepulse/features/onboarding/presentation/splash_screen.dart';
import 'package:pacepulse/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('app boots into the splash, then lands on the carousel',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PacePulseApp()));
    expect(find.byType(SplashScreen), findsOneWidget);
    // First run: no session, carousel not seen → lands on carousel.
    // pumpAndSettle would hang due to PPLivePulse loop; use explicit pumps.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(OnboardingCarouselScreen), findsOneWidget);
  });

  testWidgets('router navigates to the home placeholder', (tester) async {
    // Seed seen=true so splash routes to auth, not carousel.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWith((ref) async => true),
      ],
      child: const PacePulseApp(),
    ));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(AuthLandingScreen));
    GoRouter.of(ctx).go(HomePlaceholder.path);
    await tester.pumpAndSettle();
    expect(find.byType(HomePlaceholder), findsOneWidget);
  });

  testWidgets('router resolves the nested sign-up route to SignUpScreen',
      (tester) async {
    // Seed seen=true so splash routes to auth, not carousel.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWith((ref) async => true),
      ],
      child: const PacePulseApp(),
    ));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(AuthLandingScreen));
    // Regression guard: /auth/sign-up is nested under /auth with a
    // relative child path ('sign-up', not '/auth/sign-up') — getting that
    // wrong produces a route that silently never matches.
    GoRouter.of(ctx).go(SignUpScreen.path);
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('router resolves the nested sign-in route to SignInScreen',
      (tester) async {
    // Seed seen=true so splash routes to auth, not carousel.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWith((ref) async => true),
      ],
      child: const PacePulseApp(),
    ));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(AuthLandingScreen));
    // Regression guard: /auth/sign-in is nested under /auth with a
    // relative child path ('sign-in', not '/auth/sign-in') — getting that
    // wrong produces a route that silently never matches.
    GoRouter.of(ctx).go(SignInScreen.path);
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
  });

  testWidgets(
      'router resolves the nested reset-password route to '
      'ResetPasswordScreen', (tester) async {
    // Seed seen=true so splash routes to auth, not carousel.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWith((ref) async => true),
      ],
      child: const PacePulseApp(),
    ));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(AuthLandingScreen));
    // Regression guard: /auth/reset-password is nested under /auth with a
    // relative child path ('reset-password', not '/auth/reset-password')
    // — getting that wrong produces a route that silently never matches.
    GoRouter.of(ctx).go(ResetPasswordScreen.path);
    await tester.pumpAndSettle();
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
  });

  testWidgets('debug gallery button lives on the auth landing screen',
      (tester) async {
    // Seed seen=true so splash routes to auth, not carousel.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWith((ref) async => true),
      ],
      child: const PacePulseApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Open component gallery'), findsOneWidget);
  });

  testWidgets('router registers the onboarding carousel', (tester) async {
    // Seed seen=true so splash routes to auth, not carousel.
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWith((ref) async => true),
      ],
      child: const PacePulseApp(),
    ));
    await tester.pumpAndSettle();
    final ctx = tester.element(find.byType(AuthLandingScreen));
    GoRouter.of(ctx).go(OnboardingCarouselScreen.path);
    // Navigation to carousel; pumpAndSettle would hang due to looping animation.
    // Use explicit pumps instead.
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byType(OnboardingCarouselScreen), findsOneWidget);
  });

  testWidgets('the debug gallery is reachable through the router',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [onboardingSeenProvider.overrideWith((ref) async => true)],
      child: const PacePulseApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open component gallery'));
    await tester.pumpAndSettle();
    expect(find.byType(GalleryScreen), findsOneWidget);
  });

  testWidgets('gallery registers an Auth page', (tester) async {
    expect(galleryPages.containsKey('Auth'), isTrue);
  });

  // FIX 11 — every other router test calls `GoRouter.of(ctx).go(...)`
  // directly, so nothing here ever tapped a real affordance or a back
  // chevron. That blind spot is exactly why sign-in → reset shipped as
  // `go`: as siblings under /auth, `go` rebuilds the stack as
  // [landing, reset], and reset's back chevron then returns to the
  // LANDING instead of the sign-in form the user came from.
  testWidgets(
      'tapping forgot-password pushes reset, and back returns to sign-in',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onboardingSeenProvider.overrideWith((ref) async => true),
      ],
      child: const PacePulseApp(),
    ));
    await tester.pumpAndSettle();

    // Reach sign-in by tapping the landing's affordance, not by go().
    await tester.tap(find.byKey(const Key('pp_auth_sign_in_link')));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);

    await tester.tap(find.text(AuthCopy.forgotPassword));
    await tester.pumpAndSettle();
    expect(find.byType(ResetPasswordScreen), findsOneWidget);

    // The back chevron must pop to sign-in — not to the landing.
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    expect(find.byType(AuthLandingScreen), findsNothing);
  });
}
