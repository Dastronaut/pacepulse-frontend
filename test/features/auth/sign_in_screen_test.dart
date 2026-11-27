import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/auth/domain/auth_validators.dart';
import 'package:pacepulse/features/auth/presentation/sign_in_controller.dart';
import 'package:pacepulse/features/auth/presentation/sign_in_screen.dart';

Widget harness({List overrides = const []}) => ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(theme: ppDarkTheme(), home: const SignInScreen()),
    );

class _Seeded extends SignInController {
  _Seeded(this.seed);
  final SignInState seed;
  @override
  SignInState build() => seed;
}

void main() {
  testWidgets('renders both fields and the forgot-password link',
      (tester) async {
    await tester.pumpWidget(harness());
    expect(find.byKey(const Key('pp_sign_in_email')), findsOneWidget);
    expect(find.byKey(const Key('pp_sign_in_password')), findsOneWidget);
    expect(find.text(AuthCopy.forgotPassword), findsOneWidget);
  });

  testWidgets('sign-in does not show the password rule as helper text',
      (tester) async {
    // The rule belongs to account creation. Showing it here would imply
    // an existing password is invalid.
    await tester.pumpWidget(harness());
    expect(find.text(AuthCopy.passwordRule), findsNothing);
  });

  testWidgets('wrong password renders on the field, not as an alert',
      (tester) async {
    await tester.pumpWidget(harness(overrides: [
      signInControllerProvider.overrideWith(
        () => _Seeded(const SignInState(
          passwordError: AuthCopy.wrongPassword,
          failedAttempts: 1,
        )),
      ),
    ]));
    expect(find.text(AuthCopy.wrongPassword), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets(
      'five failures promote forgot-password to a full-width button, '
      'and the form stays usable', (tester) async {
    await tester.pumpWidget(harness(overrides: [
      signInControllerProvider.overrideWith(
        () => _Seeded(const SignInState(failedAttempts: 5)),
      ),
    ]));

    // The promoted PPButton form is present...
    expect(
      find.ancestor(
        of: find.text(AuthCopy.forgotPassword),
        matching: find.byType(PPButton),
      ),
      findsOneWidget,
    );
    // ...and the plain text-link form is gone.
    expect(
      find.ancestor(
        of: find.text(AuthCopy.forgotPassword),
        matching: find.byType(TextButton),
      ),
      findsNothing,
    );

    // No lockout drama: both fields are still enabled.
    final email =
        tester.widget<PPTextField>(find.byKey(const Key('pp_sign_in_email')));
    final password = tester.widget<PPTextField>(
        find.byKey(const Key('pp_sign_in_password')));
    expect(email.enabled, isTrue);
    expect(password.enabled, isTrue);
  });

  test('five failures set suggestReset without locking out', () {
    final container = ProviderContainer.test();
    final controller = container.read(signInControllerProvider.notifier);
    for (var i = 0; i < 4; i++) {
      controller.onSignInFailed(AuthCopy.wrongPassword);
    }
    expect(container.read(signInControllerProvider).suggestReset, isFalse);

    controller.onSignInFailed(AuthCopy.wrongPassword);
    final state = container.read(signInControllerProvider);
    expect(state.suggestReset, isTrue);
    expect(state.failedAttempts, 5);
    // No lockout: the form stays usable.
    expect(state.submitting, isFalse);
  });

  test('a successful-looking edit clears the field error', () {
    final container = ProviderContainer.test();
    final controller = container.read(signInControllerProvider.notifier);
    controller.onSignInFailed(AuthCopy.wrongPassword);
    controller.passwordChanged('newpass1');
    expect(container.read(signInControllerProvider).passwordError, isNull);
  });

  // FIX 2 — focus the first invalid field (widget concern, so it lives
  // in the screen rather than in the controller).
  testWidgets('submitting an empty form focuses the email field',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.widgetWithText(PPButton, AuthCopy.signIn));
    await tester.pump();
    expect(find.text(AuthCopy.emailRequired), findsOneWidget);
    final emailNode = tester
        .widget<PPTextField>(find.byKey(const Key('pp_sign_in_email')))
        .focusNode;
    expect(emailNode, isNotNull);
    expect(tester.binding.focusManager.primaryFocus, same(emailNode));
  });

  // FIX 12 — per-screen keyboard wiring, asserted on the inner Material
  // TextField.
  testWidgets('keyboard wiring: email is next, password is go',
      (tester) async {
    await tester.pumpWidget(harness());
    TextField inner(String key) => tester.widget<TextField>(find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(TextField),
        ));
    expect(inner('pp_sign_in_email').textInputAction, TextInputAction.next);
    expect(inner('pp_sign_in_password').textInputAction, TextInputAction.go);
  });
}
