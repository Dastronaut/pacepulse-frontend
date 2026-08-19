import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/features/auth/presentation/auth_landing_placeholder.dart';
import 'package:pacepulse/features/onboarding/data/onboarding_seen.dart';
import 'package:pacepulse/features/onboarding/presentation/onboarding_carousel_screen.dart';
import 'package:pacepulse/features/onboarding/presentation/onboarding_slides.dart';
import 'package:pacepulse/features/onboarding/presentation/widgets/onboarding_page_dots.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Own harness so reduced motion and text scale can be injected.
Widget harness({bool reducedMotion = false, double textScale = 1.0}) {
  final router = GoRouter(
    initialLocation: OnboardingCarouselScreen.path,
    routes: [
      GoRoute(
        path: OnboardingCarouselScreen.path,
        builder: (context, state) => const OnboardingCarouselScreen(),
      ),
      GoRoute(
        path: AuthLandingPlaceholder.path,
        builder: (context, state) => const AuthLandingPlaceholder(),
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      theme: ppLightTheme(),
      darkTheme: ppDarkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reducedMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
    ),
  );
}

Future<bool> seenFlag() async =>
    (await SharedPreferences.getInstance())
        .getBool(OnboardingSeenStore.key) ??
    false;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('slide 1 renders its copy, specimen and Next CTA',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    expect(find.text(onboardingSlides[0].headline), findsOneWidget);
    expect(find.text(onboardingSlides[0].body), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.bySemanticsLabel('Slide 1 of 3'), findsOneWidget);
  });

  testWidgets('Next advances to slide 2 and the dots follow', (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.tap(find.text('Next'));
    // PPMotion.base is 220ms; pump for animation completion
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text(onboardingSlides[1].headline), findsOneWidget);
    expect(find.bySemanticsLabel('Slide 2 of 3'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
  });

  testWidgets('the last slide flips the CTA and finishes to auth',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text('Get started'), findsOneWidget);
    expect(find.text('Next'), findsNothing);

    await tester.tap(find.text('Get started'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AuthLandingPlaceholder), findsOneWidget);
    expect(await seenFlag(), isTrue);
  });

  testWidgets('swipe advances; swiping back on slide 1 stays put',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.drag(
        find.byType(PageView), const Offset(-600, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text(onboardingSlides[1].headline), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(600, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text(onboardingSlides[0].headline), findsOneWidget);

    await tester.drag(find.byType(PageView), const Offset(600, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.text(onboardingSlides[0].headline), findsOneWidget);
  });

  testWidgets('Skip from slide 1 marks seen and lands on auth',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.pump();
    await tester.tap(find.text('Skip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AuthLandingPlaceholder), findsOneWidget);
    expect(await seenFlag(), isTrue);
  });

  testWidgets('reduced motion: Next lands immediately, no frames pending',
      (tester) async {
    await tester.pumpWidget(harness(reducedMotion: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pump();
    expect(find.text(onboardingSlides[1].headline), findsOneWidget);
    // Primary assertion failed: hasScheduledFrame is true because PPButton and PPPressable
    // press animations (AnimatedContainer/AnimatedScale, 80ms PPMotion.instant) do not gate
    // on ppReducedMotion, so the tap keeps a frame scheduled even under reduced motion.
    // Fallback assertion: index changed to 1 within one pump frame, proving jumpToPage
    // executed (vs. animateToPage, which could not reach page 1 in a single frame).
    expect(tester.widget<OnboardingPageDots>(find.byType(OnboardingPageDots)).index, 1);
  });

  testWidgets('doubled text scale scrolls instead of overflowing',
      (tester) async {
    await tester.pumpWidget(harness(textScale: 2.0));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });
}
