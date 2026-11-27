import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/core/di/prefs.dart';
import 'package:pacepulse/core/network/connectivity.dart';
import 'package:pacepulse/core/router/app_router.dart';
import 'package:pacepulse/features/auth/data/session.dart';
import 'package:pacepulse/features/auth/presentation/reset_password_controller.dart';
import 'package:pacepulse/features/auth/presentation/sign_in_controller.dart';
import 'package:pacepulse/features/auth/presentation/sign_up_controller.dart';
import 'package:pacepulse/features/home/data/stub_home_repository.dart';
import 'package:pacepulse/features/home/presentation/home_controller.dart';
import 'package:pacepulse/features/onboarding/data/onboarding_seen.dart';
import 'package:pacepulse/features/onboarding/presentation/wizard_controller.dart';
import 'package:pacepulse/features/permissions/presentation/primed_this_session.dart';

void main() {
  // Lifecycles per spec 2026-11-25, Delivery 0 — codegen must not flip them.
  test('keep-alive providers', () {
    expect(sharedPreferencesProvider.isAutoDispose, isFalse);
    expect(connectivityProvider.isAutoDispose, isFalse);
    expect(appRouterProvider.isAutoDispose, isFalse);
    expect(homeRepositoryProvider.isAutoDispose, isFalse);
    expect(sessionProvider.isAutoDispose, isFalse);
    expect(primedThisSessionProvider.isAutoDispose, isFalse);
    expect(onboardingSeenStoreProvider.isAutoDispose, isFalse);
    expect(onboardingSeenProvider.isAutoDispose, isFalse);
    expect(wizardDefaultsProvider.isAutoDispose, isFalse);
    expect(wizardControllerProvider.isAutoDispose, isFalse);
  });

  test('auto-dispose providers', () {
    expect(homeControllerProvider.isAutoDispose, isTrue);
    expect(signInControllerProvider.isAutoDispose, isTrue);
    expect(signUpControllerProvider.isAutoDispose, isTrue);
    expect(resetPasswordControllerProvider.isAutoDispose, isTrue);
    expect(gearScanControllerProvider.isAutoDispose, isTrue);
  });
}
