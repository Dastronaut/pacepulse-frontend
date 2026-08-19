import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/prefs.dart';

class OnboardingSeenStore {
  OnboardingSeenStore(this._prefs);

  final Future<SharedPreferences> _prefs;

  static const key = 'onboarding_seen';

  Future<bool> read() async => (await _prefs).getBool(key) ?? false;

  Future<void> markSeen() async => (await _prefs).setBool(key, true);
}

final onboardingSeenStoreProvider = Provider<OnboardingSeenStore>(
  (ref) => OnboardingSeenStore(ref.watch(sharedPreferencesProvider.future)),
);

final onboardingSeenProvider = FutureProvider<bool>(
  (ref) => ref.watch(onboardingSeenStoreProvider).read(),
);
