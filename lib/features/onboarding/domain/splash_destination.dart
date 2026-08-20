/// Where the splash sends the user once the boot facts are known.
///
/// Deliberately free of route strings and Flutter imports: the rule is a
/// pure function so the decision table is unit-testable without pumping a
/// widget. The presentation layer maps these to `static const path` values.
enum SplashDestination { home, auth, carousel }

/// The cold-start routing rule (Flow 5 S1; rulings 2026-08-14 and
/// 2026-08-17): an existing session goes straight Home; otherwise a user
/// who has already seen the carousel goes to the auth landing, and a
/// first-run user sees the carousel.
///
/// The 1.5s cap is NOT modelled here on purpose — it fires while
/// [hasSession] is still unknown, so its fallback is a presentation
/// concern, owned by the splash widget.
SplashDestination resolveSplashDestination({
  required bool hasSession,
  required bool seen,
}) {
  if (hasSession) return SplashDestination.home;
  return seen ? SplashDestination.auth : SplashDestination.carousel;
}
