// test/core/router/app_router_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pacepulse/dev/gallery/gallery.dart';
import 'package:pacepulse/features/auth/presentation/auth_landing_placeholder.dart';
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
    final ctx = tester.element(find.byType(AuthLandingPlaceholder));
    GoRouter.of(ctx).go(HomePlaceholder.path);
    await tester.pumpAndSettle();
    expect(find.byType(HomePlaceholder), findsOneWidget);
  });

  testWidgets('debug gallery button lives on the auth placeholder',
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
    final ctx = tester.element(find.byType(AuthLandingPlaceholder));
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
}
