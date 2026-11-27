import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/onboarding/data/onboarding_seen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // setMockInitialValues talks to the platform channel mock.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('defaults to false when the key was never written', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer.test();
    expect(await container.read(onboardingSeenProvider.future), isFalse);
  });

  test('reads an existing true flag', () async {
    SharedPreferences.setMockInitialValues(
        {OnboardingSeenStore.key: true});
    final container = ProviderContainer.test();
    expect(await container.read(onboardingSeenProvider.future), isTrue);
  });

  test('markSeen persists true and the provider re-reads it', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer.test();
    expect(await container.read(onboardingSeenProvider.future), isFalse);

    await container.read(onboardingSeenStoreProvider).markSeen();
    container.invalidate(onboardingSeenProvider);

    expect(await container.read(onboardingSeenProvider.future), isTrue);
  });
}
