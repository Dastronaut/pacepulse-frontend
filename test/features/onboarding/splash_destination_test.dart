import 'package:flutter_test/flutter_test.dart';
import 'package:pacepulse/features/onboarding/domain/splash_destination.dart';

void main() {
  test('an existing session goes home, whatever the carousel flag says', () {
    expect(
      resolveSplashDestination(hasSession: true, seen: false),
      SplashDestination.home,
    );
    expect(
      resolveSplashDestination(hasSession: true, seen: true),
      SplashDestination.home,
    );
  });

  test('no session and the carousel already seen goes to auth', () {
    expect(
      resolveSplashDestination(hasSession: false, seen: true),
      SplashDestination.auth,
    );
  });

  test('no session and an unseen carousel shows the carousel', () {
    expect(
      resolveSplashDestination(hasSession: false, seen: false),
      SplashDestination.carousel,
    );
  });
}
