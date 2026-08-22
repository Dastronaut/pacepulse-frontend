import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/theme/theme.dart';
import 'package:pacepulse/features/auth/domain/auth_validators.dart';
import 'package:pacepulse/features/auth/presentation/reset_password_controller.dart';
import 'package:pacepulse/features/auth/presentation/reset_password_screen.dart';

Widget harness({List overrides = const []}) => ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
          theme: ppDarkTheme(), home: const ResetPasswordScreen()),
    );

void main() {
  testWidgets('starts with the blurb, one field and one button',
      (tester) async {
    await tester.pumpWidget(harness());
    expect(find.text(AuthCopy.resetBlurb), findsOneWidget);
    expect(find.byKey(const Key('pp_reset_email')), findsOneWidget);
    expect(find.text(AuthCopy.sendResetLink), findsOneWidget);
    expect(find.textContaining('Sent —'), findsNothing);
  });

  testWidgets('an invalid email is marked and no send occurs',
      (tester) async {
    await tester.pumpWidget(harness());
    await tester.enterText(find.byKey(const Key('pp_reset_email')), 'dana');
    await tester.tap(find.text(AuthCopy.sendResetLink));
    await tester.pump();
    expect(find.text(AuthCopy.emailInvalid), findsOneWidget);
    expect(find.textContaining('Sent —'), findsNothing);
  });

  testWidgets('sent state shows the confirmation and counts down',
      (tester) async {
    await tester.pumpWidget(harness());
    final container = ProviderScope.containerOf(
        tester.element(find.byType(ResetPasswordScreen)));
    container
        .read(resetPasswordControllerProvider.notifier)
        .onResetLinkSent('dana@pacepulse.app');
    await tester.pump();

    expect(find.text(AuthCopy.sentTo('dana@pacepulse.app')), findsOneWidget);
    expect(find.text('0:30'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    expect(find.text('0:24'), findsOneWidget);

    await tester.pump(const Duration(seconds: 24));
    expect(find.text(AuthCopy.sendResetLink), findsOneWidget);
  });

  test('cooldown timer is cancelled when the provider is disposed', () {
    final container = ProviderContainer.test();
    container
        .read(resetPasswordControllerProvider.notifier)
        .onResetLinkSent('dana@pacepulse.app');
    // Would throw "A Timer is still pending after the widget tree was
    // disposed" at test teardown if ref.onDispose did not cancel it.
    container.dispose();
  });

  test(
      'onResetLinkSent produces identical state for a known and an '
      'unknown email, apart from the echoed address', () {
    final knownContainer = ProviderContainer.test();
    addTearDown(knownContainer.dispose);
    final unknownContainer = ProviderContainer.test();
    addTearDown(unknownContainer.dispose);

    knownContainer
        .read(resetPasswordControllerProvider.notifier)
        .onResetLinkSent('dana@pacepulse.app');
    unknownContainer
        .read(resetPasswordControllerProvider.notifier)
        .onResetLinkSent('nobody@nowhere.test');

    final knownState = knownContainer.read(resetPasswordControllerProvider);
    final unknownState =
        unknownContainer.read(resetPasswordControllerProvider);

    // The only thing that may differ between a known and an unknown
    // account is the echoed address. Every other observable field —
    // including the cooldown, which an attacker could otherwise time —
    // must be identical.
    expect(knownState.sentTo, 'dana@pacepulse.app');
    expect(unknownState.sentTo, 'nobody@nowhere.test');
    expect(knownState.submitting, unknownState.submitting);
    expect(knownState.emailError, unknownState.emailError);
    expect(knownState.cooldownRemaining, unknownState.cooldownRemaining);
    expect(knownState.canResend, unknownState.canResend);
    expect(knownState.cooldownLabel, unknownState.cooldownLabel);
  });

  test('submit() alone never reaches the sent state', () {
    // This is the branch most likely to grow a leak later: someone wires
    // the reset endpoint, calls onResetLinkSent only on a success
    // response, and the UI silently becomes an account-existence oracle
    // (sent state present only for real accounts). submit() must stop at
    // the seam regardless of how "valid" the typed email looks.
    final container = ProviderContainer.test();
    addTearDown(container.dispose);
    final controller =
        container.read(resetPasswordControllerProvider.notifier);
    controller.emailChanged('dana@pacepulse.app');
    controller.submit();

    final state = container.read(resetPasswordControllerProvider);
    expect(state.sentTo, isNull);
    expect(state.cooldownRemaining, Duration.zero);
  });
}
