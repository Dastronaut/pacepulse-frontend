import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/core/ui/ui.dart';
import 'package:pacepulse/features/auth/domain/auth_validators.dart';
import 'package:pacepulse/features/auth/presentation/sign_up_controller.dart';
import 'package:pacepulse/features/auth/presentation/sign_up_screen.dart';

// Untyped on purpose: `Override` is not exported from flutter_riverpod's
// public API, so typing this would mean importing riverpod's `src/`.
Widget harness({List overrides = const []}) => ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        theme: ppDarkTheme(),
        home: const SignUpScreen(),
      ),
    );

class _Seeded extends SignUpController {
  _Seeded(this.seed);
  final SignUpState seed;
  @override
  SignUpState build() => seed;
}

void main() {
  testWidgets('shows the password rule as helper text up front',
      (tester) async {
    await tester.pumpWidget(harness());
    expect(find.text(AuthCopy.passwordRule), findsOneWidget);
  });

  testWidgets('submitting an empty form marks both fields', (tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.byKey(const Key('pp_sign_up_submit')));
    await tester.pump();
    expect(find.text(AuthCopy.emailRequired), findsOneWidget);
    // The rule doubles as the password error, so it is now shown in error
    // color rather than as helper text — still exactly one instance.
    expect(find.text(AuthCopy.passwordRule), findsOneWidget);
  });

  testWidgets('a valid form clears errors and does not navigate',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.enterText(
        find.byKey(const Key('pp_sign_up_email')), 'dana@pacepulse.app');
    await tester.enterText(
        find.byKey(const Key('pp_sign_up_password')), 'runfast1');
    await tester.tap(find.byKey(const Key('pp_sign_up_submit')));
    await tester.pump();
    expect(find.text(AuthCopy.emailRequired), findsNothing);
    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('password visibility toggle flips obscureText',
      (tester) async {
    await tester.pumpWidget(harness());
    TextField field() => tester.widget<TextField>(
        find.descendant(
            of: find.byKey(const Key('pp_sign_up_password')),
            matching: find.byType(TextField)));
    expect(field().obscureText, isTrue);
    await tester.tap(find.bySemanticsLabel('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
  });

  testWidgets('taken email renders the error and the Sign in instead link',
      (tester) async {
    await tester.pumpWidget(harness(overrides: [
      signUpControllerProvider.overrideWith(
        () => _Seeded(const SignUpState(
          email: 'dana@pacepulse.app',
          emailError: AuthCopy.emailTaken,
        )),
      ),
    ]));
    expect(find.text(AuthCopy.emailTaken), findsOneWidget);
    // Twice: the inline link under the field, plus the standing link in
    // the bottom action block.
    expect(find.text(AuthCopy.signInInstead), findsNWidgets(2));
  });

  testWidgets('submitting state shows the button spinner', (tester) async {
    await tester.pumpWidget(harness(overrides: [
      signUpControllerProvider.overrideWith(
        () => _Seeded(const SignUpState(submitting: true)),
      ),
    ]));
    // Found by key, not by text: PPButton swaps its label for a spinner
    // while loading, so widgetWithText would find nothing here.
    final button = tester.widget<PPButton>(
        find.byKey(const Key('pp_sign_up_submit')));
    expect(button.loading, isTrue);
  });

  test('onSignUpFailed puts the message on the email field', () {
    final container = ProviderContainer.test();
    container.read(signUpControllerProvider.notifier)
        .onSignUpFailed(AuthCopy.emailTaken);
    expect(container.read(signUpControllerProvider).emailError,
        AuthCopy.emailTaken);
    expect(container.read(signUpControllerProvider).submitting, isFalse);
  });

  test('typing into a field with an error clears it', () {
    final container = ProviderContainer.test();
    final controller = container.read(signUpControllerProvider.notifier);
    controller.onSignUpFailed(AuthCopy.emailTaken);
    controller.emailChanged('d');
    expect(container.read(signUpControllerProvider).emailError, isNull);
  });

  test('validate() preserves submitting rather than resetting it', () {
    // Untyped on purpose: `Override` is not exported from flutter_riverpod's
    // public API, so typing this would mean importing riverpod's `src/`.
    final List overrides = [
      signUpControllerProvider.overrideWith(
        () => _Seeded(const SignUpState(submitting: true)),
      ),
    ];
    final container = ProviderContainer.test(overrides: overrides.cast());
    final controller = container.read(signUpControllerProvider.notifier);
    controller.validate();
    expect(container.read(signUpControllerProvider).submitting, isTrue);
  });

  // FIX 2 — the spec says submit() "marks invalid fields, focuses the
  // first one". Focus is a widget concern, so the screen owns it.
  testWidgets('submitting an empty form focuses the first invalid field',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.tap(find.byKey(const Key('pp_sign_up_submit')));
    await tester.pump();
    final emailNode = tester
        .widget<PPTextField>(find.byKey(const Key('pp_sign_up_email')))
        .focusNode;
    expect(emailNode, isNotNull);
    // Both fields are invalid — focus must land on the FIRST one.
    expect(find.text(AuthCopy.passwordRule), findsOneWidget);
    expect(tester.binding.focusManager.primaryFocus, same(emailNode));
  });

  testWidgets('a valid email with an invalid password focuses the password',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.enterText(
        find.byKey(const Key('pp_sign_up_email')), 'dana@pacepulse.app');
    await tester.tap(find.byKey(const Key('pp_sign_up_submit')));
    await tester.pump();
    final passwordNode = tester
        .widget<PPTextField>(find.byKey(const Key('pp_sign_up_password')))
        .focusNode;
    expect(tester.binding.focusManager.primaryFocus, same(passwordNode));
  });

  // FIX 12 — the spec's Testing section promises these per screen, not
  // just as a kit-level passthrough. Asserted on the inner Material
  // TextField, which is what actually drives the keyboard.
  testWidgets('keyboard wiring: email is next, password is go',
      (tester) async {
    await tester.pumpWidget(harness());
    TextField inner(String key) => tester.widget<TextField>(find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(TextField),
        ));
    expect(inner('pp_sign_up_email').textInputAction, TextInputAction.next);
    expect(inner('pp_sign_up_password').textInputAction, TextInputAction.go);
  });
}
