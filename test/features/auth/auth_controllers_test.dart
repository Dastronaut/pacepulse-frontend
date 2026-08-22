import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/auth/domain/auth_validators.dart';
import 'package:pacepulse/features/auth/presentation/reset_password_controller.dart';
import 'package:pacepulse/features/auth/presentation/sign_in_controller.dart';
import 'package:pacepulse/features/auth/presentation/sign_up_controller.dart';

void main() {
  // FIX 1 — the three form providers are auto-dispose, so a second visit
  // to a screen gets a FRESH form. Under the old keep-alive providers the
  // widget was new but the state was not: the user saw an error caption
  // under an empty field, and submit validated text they could not see.
  //
  // Riverpod disposes through its scheduler rather than synchronously
  // when the last listener drops, hence `await container.pump()` between
  // closing the subscription and re-reading.
  group('form providers auto-dispose', () {
    test('sign up state resets once every listener is gone', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var sub = container.listen(signUpControllerProvider, (_, _) {});
      container.read(signUpControllerProvider.notifier)
        ..emailChanged('dana')
        ..passwordChanged('short');
      container.read(signUpControllerProvider.notifier).validate();
      expect(container.read(signUpControllerProvider).email, 'dana');
      expect(container.read(signUpControllerProvider).emailError, isNotNull);

      sub.close();
      await container.pump();

      sub = container.listen(signUpControllerProvider, (_, _) {});
      final fresh = container.read(signUpControllerProvider);
      expect(fresh.email, isEmpty);
      expect(fresh.password, isEmpty);
      expect(fresh.emailError, isNull);
      expect(fresh.passwordError, isNull);
      sub.close();
    });

    test('sign in state — including failedAttempts — resets', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var sub = container.listen(signInControllerProvider, (_, _) {});
      final notifier = container.read(signInControllerProvider.notifier)
        ..emailChanged('dana@pacepulse.app');
      for (var i = 0; i < kSuggestResetAfter; i++) {
        notifier.onSignInFailed(AuthCopy.wrongPassword);
      }
      expect(container.read(signInControllerProvider).suggestReset, isTrue);

      sub.close();
      await container.pump();

      sub = container.listen(signInControllerProvider, (_, _) {});
      final fresh = container.read(signInControllerProvider);
      expect(fresh.email, isEmpty);
      expect(fresh.passwordError, isNull);
      // A UX nicety, not a security control — there is deliberately no
      // lockout, so it must not greet an arriving user with the promoted
      // reset state.
      expect(fresh.failedAttempts, 0);
      expect(fresh.suggestReset, isFalse);
      sub.close();
    });

    test('reset password state resets and its cooldown timer stops',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      var sub = container.listen(resetPasswordControllerProvider, (_, _) {});
      container
          .read(resetPasswordControllerProvider.notifier)
          .onResetLinkSent('dana@pacepulse.app');
      expect(container.read(resetPasswordControllerProvider).sentTo,
          'dana@pacepulse.app');

      sub.close();
      // If the periodic Timer outlived the provider this would leave a
      // pending timer for the test framework to flag.
      await container.pump();

      sub = container.listen(resetPasswordControllerProvider, (_, _) {});
      final fresh = container.read(resetPasswordControllerProvider);
      expect(fresh.sentTo, isNull);
      expect(fresh.email, isEmpty);
      expect(fresh.cooldownRemaining, Duration.zero);
      sub.close();
    });
  });

  // FIX 4 — `emailBlurred` must be able to CLEAR an error. Under the
  // clear-flag convention, passing `emailError: null` is indistinguishable
  // from "not passed", so without `clearEmailError` a valid blur silently
  // preserved the previous error.
  //
  // Typing through `emailChanged` would clear the error on its own and so
  // could never discriminate; these seed the state directly — a valid
  // address that still carries an error, which is exactly what a
  // server-set error (`onSignUpFailed`) or a re-entered field looks like.
  group('emailBlurred clears a stale error', () {
    const valid = 'dana@pacepulse.app';

    test('sign up', () {
      final container = ProviderContainer(overrides: [
        signUpControllerProvider.overrideWith(
          () => _SeededSignUp(const SignUpState(
              email: valid, emailError: AuthCopy.emailTaken)),
        ),
      ]);
      addTearDown(container.dispose);
      expect(container.read(signUpControllerProvider).emailError,
          AuthCopy.emailTaken);
      container.read(signUpControllerProvider.notifier).emailBlurred();
      expect(container.read(signUpControllerProvider).emailError, isNull);
    });

    test('sign in', () {
      final container = ProviderContainer(overrides: [
        signInControllerProvider.overrideWith(
          () => _SeededSignIn(const SignInState(
              email: valid, emailError: AuthCopy.emailInvalid)),
        ),
      ]);
      addTearDown(container.dispose);
      expect(container.read(signInControllerProvider).emailError,
          AuthCopy.emailInvalid);
      container.read(signInControllerProvider.notifier).emailBlurred();
      expect(container.read(signInControllerProvider).emailError, isNull);
    });

    test('reset password', () {
      final container = ProviderContainer(overrides: [
        resetPasswordControllerProvider.overrideWith(
          () => _SeededResetPassword(const ResetPasswordState(
              email: valid, emailError: AuthCopy.emailInvalid)),
        ),
      ]);
      addTearDown(container.dispose);
      expect(container.read(resetPasswordControllerProvider).emailError,
          AuthCopy.emailInvalid);
      container.read(resetPasswordControllerProvider.notifier).emailBlurred();
      expect(
          container.read(resetPasswordControllerProvider).emailError, isNull);
    });
  });
}

/// Seeded subclasses are the codebase's state-seeding convention — there
/// is deliberately no test-only mutator on the production controllers.
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
