import 'package:flutter/widgets.dart';

import 'widgets/onboarding_specimens.dart';

/// One carousel slide. Copy is verbatim from Flow 5 S2–S4.
class OnboardingSlide {
  const OnboardingSlide({
    required this.headline,
    required this.body,
    required this.specimen,
  });

  final String headline;
  final String body;
  final Widget specimen;
}

const onboardingSlides = <OnboardingSlide>[
  OnboardingSlide(
    headline: 'Track every run, ride and session',
    body: 'GPS routes, heart-rate zones and splits — captured '
        'automatically.',
    specimen: GpsRouteSpecimen(),
  ),
  OnboardingSlide(
    headline: 'Race your friends in real time',
    body: 'A live leaderboard mid-workout — watch the gap close with '
        'every stride.',
    specimen: LiveLeaderboardSpecimen(),
  ),
  OnboardingSlide(
    headline: 'Build streaks, beat your bests',
    body: 'Close your rings, keep the streak alive and chase every '
        'record.',
    specimen: StreakRingSpecimen(),
  ),
];
