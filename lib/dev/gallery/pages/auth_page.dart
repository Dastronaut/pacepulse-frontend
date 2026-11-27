import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../features/auth/domain/auth_validators.dart';
import '../../../features/auth/presentation/auth_landing_screen.dart';
import '../../../features/auth/presentation/reset_password_controller.dart';
import '../../../features/auth/presentation/reset_password_screen.dart';
import '../../../features/auth/presentation/sign_in_controller.dart';
import '../../../features/auth/presentation/sign_in_screen.dart';
import '../../../features/auth/presentation/sign_up_controller.dart';
import '../../../features/auth/presentation/sign_up_screen.dart';
import '../gallery.dart';

const _seededCooldownRemaining = Duration(seconds: 17);

class AuthGalleryPage extends StatelessWidget {
  const AuthGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const GallerySection(
          title: 'AuthLandingScreen',
          child: _Frame(child: AuthLandingScreen()),
        ),
        GallerySection(
          title: 'SignUpScreen - idle',
          child: _signUp(const SignUpState()),
        ),
        GallerySection(
          title: 'SignUpScreen - email taken',
          child: _signUp(const SignUpState(emailError: AuthCopy.emailTaken)),
        ),
        GallerySection(
          title: 'SignUpScreen - submitting',
          child: _signUp(const SignUpState(submitting: true)),
        ),
        GallerySection(
          title: 'SignInScreen - idle',
          child: _signIn(const SignInState()),
        ),
        GallerySection(
          title: 'SignInScreen - wrong password',
          child: _signIn(
            const SignInState(passwordError: AuthCopy.wrongPassword),
          ),
        ),
        GallerySection(
          title: 'SignInScreen - 5 failed attempts (suggest reset)',
          child: _signIn(const SignInState(failedAttempts: 5)),
        ),
        GallerySection(
          title: 'ResetPasswordScreen - idle',
          child: _resetPassword(const ResetPasswordState()),
        ),
        GallerySection(
          title: 'ResetPasswordScreen - sent, cooldown running',
          child: _resetPassword(
            const ResetPasswordState(
              sentTo: 'dana@pacepulse.app',
              cooldownRemaining: _seededCooldownRemaining,
            ),
          ),
        ),
        GallerySection(
          title:
              'ResetPasswordScreen - sent, cooldown elapsed (ghost '
              'resend)',
          child: _resetPassword(
            const ResetPasswordState(
              sentTo: 'dana@pacepulse.app',
              cooldownRemaining: Duration.zero,
            ),
          ),
        ),
      ],
    );
  }
}

Widget _signUp(SignUpState seed) => ProviderScope(
  overrides: [
    signUpControllerProvider.overrideWith(() => _SeededSignUp(seed)),
  ].cast(),
  child: const _Frame(child: SignUpScreen()),
);

Widget _signIn(SignInState seed) => ProviderScope(
  overrides: [
    signInControllerProvider.overrideWith(() => _SeededSignIn(seed)),
  ].cast(),
  child: const _Frame(child: SignInScreen()),
);

Widget _resetPassword(ResetPasswordState seed) => ProviderScope(
  overrides: [
    resetPasswordControllerProvider.overrideWith(
      () => _SeededResetPassword(seed),
    ),
  ].cast(),
  child: const _Frame(child: ResetPasswordScreen()),
);

class _Frame extends StatelessWidget {
  const _Frame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: PPFrame.width, height: PPFrame.height, child: child);
  }
}

class _SeededSignUp extends SignUpController {
  _SeededSignUp(this.seed);
  final SignUpState seed;
  @override
  SignUpState build() => seed;
}

class _SeededSignIn extends SignInController {
  _SeededSignIn(this.seed);
  final SignInState seed;
  @override
  SignInState build() => seed;
}

class _SeededResetPassword extends ResetPasswordController {
  _SeededResetPassword(this.seed);
  final ResetPasswordState seed;
  @override
  ResetPasswordState build() => seed;
}
