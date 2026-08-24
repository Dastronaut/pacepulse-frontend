import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dev/gallery/gallery.dart';
import '../../features/auth/presentation/auth_landing_screen.dart';
import '../../features/auth/presentation/reset_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/home/presentation/home_placeholder.dart';
import '../../features/onboarding/presentation/onboarding_carousel_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_landing_placeholder.dart';
import '../../features/home/presentation/home_placeholder.dart';
import '../../features/onboarding/presentation/splash_screen.dart';

/// App navigation skeleton — every flow registers its routes here.
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
        path: AuthLandingScreen.path,
        builder: (context, state) => const AuthLandingScreen(),
        routes: [
          GoRoute(
            path: 'sign-up',
            builder: (context, state) => const SignUpScreen(),
          ),
          GoRoute(
            path: 'sign-in',
            builder: (context, state) => const SignInScreen(),
          ),
          GoRoute(
            path: 'reset-password',
            builder: (context, state) => const ResetPasswordScreen(),
          ),
        ],
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
