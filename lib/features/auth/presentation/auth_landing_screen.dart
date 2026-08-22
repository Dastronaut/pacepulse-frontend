import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/ui/ui.dart';
import '../../../dev/gallery/gallery.dart';
import '../domain/auth_validators.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import 'widgets/social_auth_button.dart';

const _ringSize = 110.0;
const _ringThickness = 13.0;
const _pillGap = 10.0;
const _screenBottomPad = 28.0;

class AuthLandingScreen extends StatelessWidget {
  const AuthLandingScreen({super.key});

  static const path = '/auth';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pp = theme.extension<PPColors>()!;
    final dark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PPActivityRing(
                      value: 1,
                      color: dark ? scheme.primary : pp.ringMove,
                      size: _ringSize,
                      thickness: _ringThickness,
                    ),
                    const SizedBox(height: PPSpacing.s5),
                    Text(
                      AuthCopy.landingHeadline,
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: PPSpacing.s2),
                    Text(
                      AuthCopy.landingSubhead,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: PPSpacing.padScreen,
                right: PPSpacing.padScreen,
                bottom: _screenBottomPad,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TODO(auth-slice): wire Sign in with Apple.
                  const SocialAuthButton.apple(onPressed: null),
                  const SizedBox(height: _pillGap),
                  // TODO(auth-slice): wire Google Sign-In.
                  const SocialAuthButton.google(onPressed: null),
                  const SizedBox(height: _pillGap),
                  PPButton(
                    label: AuthCopy.signUpWithEmail,
                    size: PPButtonSize.lg,
                    fullWidth: true,
                    onPressed: () => context.go(SignUpScreen.path),
                  ),
                  const SizedBox(height: _pillGap),
                  Center(
                    child: SizedBox(
                      key: const Key('pp_auth_sign_in_link'),
                      height: PPSpacing.tapMin,
                      child: TextButton(
                        onPressed: () => context.go(SignInScreen.path),
                        child: Text.rich(
                          TextSpan(
                            text: AuthCopy.alreadyHaveAccount,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: AuthCopy.signIn,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: pp.accentText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: PPSpacing.s1),
                  Text(
                    AuthCopy.legal,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: pp.onSurfaceFaint,
                    ),
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: PPSpacing.s4),
                    TextButton(
                      onPressed: () => context.push(GalleryScreen.path),
                      child: const Text('Open component gallery'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
