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
import '../../features/onboarding/presentation/profile_wizard_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/permissions/domain/permission_kind.dart';
import '../../features/permissions/presentation/permission_priming_screen.dart';

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
      ),
      GoRoute(
        path: ProfileWizardScreen.path,
        builder: (context, state) => const ProfileWizardScreen(),
      ),
      GoRoute(
        path: PermissionPrimingScreen.path,
        // A route parameter is untrusted input: an unknown kind sends the
        // user Home rather than throwing on a stale deep link.
        redirect: (context, state) =>
            permissionKindFromName(state.pathParameters['kind']) == null
            ? HomePlaceholder.path
            : null,
        builder: (context, state) => PermissionPrimingScreen(
          kind: permissionKindFromName(state.pathParameters['kind'])!,
          // TODO(permissions-slice): call permission_handler here once the
          // dependency is approved. Both actions dismiss the primer either
          // way — "Not now" is a real choice, not a dead end.
          onAllow: () => context.pop(),
          onNotNow: () => context.pop(),
        ),
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
