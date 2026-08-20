import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dev/gallery/gallery.dart';
import '../../features/auth/presentation/auth_landing_placeholder.dart';
import '../../features/home/presentation/home_placeholder.dart';
import '../../features/onboarding/presentation/onboarding_carousel_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: SplashScreen.path,
    routes: [
      GoRoute(
        path: SplashScreen.path,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: OnboardingCarouselScreen.path,
        builder: (context, state) => const OnboardingCarouselScreen(),
      ),
      GoRoute(
        path: AuthLandingPlaceholder.path,
        builder: (context, state) => const AuthLandingPlaceholder(),
      ),
      GoRoute(
        path: HomePlaceholder.path,
        builder: (context, state) => const HomePlaceholder(),
      ),
      if (kDebugMode)
        GoRoute(
          path: GalleryScreen.path,
          builder: (context, state) => const GalleryScreen(),
        ),
    ],
  );
});
