import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/prefs.dart';

part 'onboarding_seen.g.dart';

class OnboardingSeenStore {
  OnboardingSeenStore(this._prefs);

  final Future<SharedPreferences> _prefs;

  static const key = 'onboarding_seen';

  Future<bool> read() async => (await _prefs).getBool(key) ?? false;

  Future<void> markSeen() async => (await _prefs).setBool(key, true);
}

@Riverpod(keepAlive: true)
OnboardingSeenStore onboardingSeenStore(Ref ref) =>
    OnboardingSeenStore(ref.watch(sharedPreferencesProvider.future));

@Riverpod(keepAlive: true)
Future<bool> onboardingSeen(Ref ref) =>
    ref.watch(onboardingSeenStoreProvider).read();
